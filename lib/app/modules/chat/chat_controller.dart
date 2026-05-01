import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/services/chat_api.dart';
import '../../data/providers/api_provider.dart';
import '../../data/models/chat_models.dart';
import '../teacher/teacher_controller.dart';
import '../parent/parent_controller.dart';

class ChatController extends GetxController {
  final ChatApi _chatApi = ChatApi();

  final TextEditingController messageController = TextEditingController();

  final contacts = <Contact>[].obs;
  final selectedContact = Rxn<Contact>();
  final messages = <ChatMessage>[].obs;
  final newMessage = ''.obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final isWsConnected = false.obs;
  final connectionStatus = ''.obs;

  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  AuthService get _auth => Get.find<AuthService>();
  int get currentUserId => _auth.userId;

  @override
  void onInit() {
    super.onInit();
    debugPrint('ChatController onInit - userId: $currentUserId');

    messageController.addListener(() {
      updateNewMessage(messageController.text);
    });

    loadContacts();
  }

  @override
  void onClose() {
    messageController.dispose();
    disconnectWebSocket();
    _reconnectTimer?.cancel();
    super.onClose();
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    try {
      final data = await _chatApi.getContacts();
      debugPrint('Loaded ${data.length} contacts');
      contacts.value = data;
      _notifyParentController();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      Get.snackbar('Error', 'Failed to load contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(int contactId) async {
    try {
      final data = await _chatApi.getMessages(contactId);
      messages.value = data.reversed.toList();
      debugPrint('Loaded ${data.length} messages for contact $contactId');
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void selectContact(Contact contact) {
    selectedContact.value = contact;
    loadMessages(contact.userId);
    connectWebSocket();
  }

  Future<void> connectWebSocket() async {
    disconnectWebSocket();

    try {
      connectionStatus.value = 'Connecting...';
      debugPrint('=== CONNECTING TO WEBSOCKET ===');

      final ticket = await _chatApi.getWsTicket();
      debugPrint('Got ticket: $ticket');

      final baseUrl = ApiProvider.baseUrl;
      final cleanBaseUrl = baseUrl
          .replaceFirst('/api', '')
          .replaceFirst('http', 'ws');
      debugPrint('Clean base URL: $cleanBaseUrl');

      final wsUrl = '$cleanBaseUrl/ws/chat/?ticket=$ticket';
      debugPrint('WebSocket URL: $wsUrl');

      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Mark as connected immediately since server accepts the connection
      isWsConnected.value = true;
      connectionStatus.value = '';
      _reconnectAttempts = 0;
      debugPrint('✅ WebSocket connected successfully');

      _wsSubscription = _wsChannel!.stream.listen(
        (data) {
          debugPrint('WebSocket received data: $data');
          _handleWsMessage(data);
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          isWsConnected.value = false;
          connectionStatus.value = 'Connection lost';
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('❌ WebSocket disconnected');
          isWsConnected.value = false;
          connectionStatus.value = 'Disconnected';
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      connectionStatus.value = 'Connection failed';
      isWsConnected.value = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (selectedContact.value == null) return;
    if (_reconnectTimer?.isActive == true) return;

    if (_reconnectAttempts >= 10) {
      debugPrint('Max reconnection attempts reached');
      connectionStatus.value = '';
      return;
    }

    final delay = Duration(
      seconds: [2, 4, 8, 16, 30][_reconnectAttempts.clamp(0, 4)],
    );
    _reconnectAttempts++;

    debugPrint(
      'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );
    connectionStatus.value = 'Reconnecting...';

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (selectedContact.value != null) {
        connectWebSocket();
      }
    });
  }

  void _handleWsMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data as String);
      final type = decoded['type'];
      debugPrint('Received WebSocket message type: $type');

      if (type == 'message_sent' || type == 'new_message') {
        final msgData = decoded['message'];
        final msg = ChatMessage.fromJson(msgData);

        final contactUserId = selectedContact.value?.userId;

        if (msg.sender != currentUserId) {
          _updateUnreadCountForContact(msg.sender);
        }

        if (contactUserId == null) return;

        if ((msg.sender == currentUserId && msg.receiver == contactUserId) ||
            (msg.sender == contactUserId && msg.receiver == currentUserId)) {
          final exists = messages.any((m) => m.id == msg.id);
          if (!exists) {
            messages.add(msg);
            debugPrint('Added message: ${msg.content}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  void _updateUnreadCountForContact(int contactUserId) {
    debugPrint(
      '_updateUnreadCountForContact called for userId: $contactUserId',
    );
    debugPrint(
      'Current contacts: ${contacts.map((c) => '${c.userId}:${c.unreadCount}').toList()}',
    );

    final contactIndex = contacts.indexWhere((c) => c.userId == contactUserId);
    debugPrint('Contact index: $contactIndex');

    if (contactIndex != -1) {
      final contact = contacts[contactIndex];
      final newCount = (contact.unreadCount ?? 0) + 1;
      debugPrint(
        'Updating unread count from ${contact.unreadCount} to $newCount',
      );
      contacts[contactIndex] = Contact(
        id: contact.id,
        userId: contact.userId,
        fullName: contact.fullName,
        role: contact.role,
        unreadCount: newCount,
      );
      _notifyParentController();
    } else {
      debugPrint('Contact not found in contacts list!');
    }
  }

  void _notifyParentController() {
    final totalUnread = contacts.fold<int>(
      0,
      (sum, c) => sum + (c.unreadCount ?? 0),
    );
    debugPrint('Total unread count: $totalUnread');

    if (Get.isRegistered<TeacherController>()) {
      try {
        final teacherController = Get.find<TeacherController>();
        teacherController.updateUnreadMessageCount(totalUnread);
        debugPrint('Updated TeacherController unread count');
      } catch (e) {
        debugPrint('TeacherController error: $e');
      }
    }
    if (Get.isRegistered<ParentController>()) {
      try {
        final parentController = Get.find<ParentController>();
        parentController.updateUnreadMessageCount(totalUnread);
        debugPrint('Updated ParentController unread count');
      } catch (e) {
        debugPrint('ParentController error: $e');
      }
    }
  }

  void disconnectWebSocket() {
    _wsSubscription?.cancel();
    try {
      _wsChannel?.sink.close();
    } catch (e) {}
    _wsChannel = null;
    _wsSubscription = null;
  }

  Future<void> sendMessage() async {
    final messageText = newMessage.value.trim();
    if (messageText.isEmpty || selectedContact.value == null) return;

    isSending.value = true;

    try {
      final contactUserId = selectedContact.value!.userId;

      if (_wsChannel != null && isWsConnected.value) {
        final message = jsonEncode({
          'type': 'chat_message',
          'receiver_id': contactUserId,
          'content': messageText,
        });
        _wsChannel!.sink.add(message);
        debugPrint('Message sent via WebSocket');

        await Future.delayed(const Duration(milliseconds: 500));
        await loadMessages(contactUserId);

        newMessage.value = '';
        messageController.clear();
      } else {
        debugPrint('WebSocket not connected, using REST API');
        await _chatApi.sendMessage(contactUserId, messageText);
        await loadMessages(contactUserId);

        newMessage.value = '';
        messageController.clear();
      }
    } catch (e) {
      debugPrint('ERROR sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  void updateNewMessage(String value) {
    newMessage.value = value;
  }

  bool isOwnMessage(ChatMessage msg) {
    return msg.sender == currentUserId;
  }

  String formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);

      if (messageDate == today) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
