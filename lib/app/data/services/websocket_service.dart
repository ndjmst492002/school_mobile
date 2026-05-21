import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../providers/api_provider.dart';
import 'chat_api.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _chatChannel;
  WebSocketChannel? _notificationChannel;
  final _chatMessages = <String, dynamic>{}.obs;
  final _notificationCount = 0.obs;
  final _chatUnreadCount = 0.obs;
  final _isChatConnected = false.obs;
  final _isNotificationConnected = false.obs;

  int get notificationCount => _notificationCount.value;
  int get chatUnreadCount => _chatUnreadCount.value;
  bool get isChatConnected => _isChatConnected.value;
  bool get isNotificationConnected => _isNotificationConnected.value;

  Stream<dynamic> get chatMessages => _chatMessages.stream;
  Stream<int> get notificationCountStream => _notificationCount.stream;
  Stream<int> get chatUnreadCountStream => _chatUnreadCount.stream;

  Future<WebSocketService> init() async {
    debugPrint('WebSocketService initialized');
    return this;
  }

  Future<void> connectChat() async {
    try {
      final chatApi = ChatApi();
      final ticket = await chatApi.getWsTicket();
      final wsUrl = _getWsUrl('chat', ticket);
      debugPrint('Connecting to chat WebSocket: $wsUrl');
      _chatChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _chatChannel!.stream.listen(
        (data) {
          _handleChatMessage(data);
        },
        onDone: () {
          debugPrint('Chat WebSocket disconnected');
          _isChatConnected.value = false;
        },
        onError: (error) {
          debugPrint('Chat WebSocket error: $error');
          _isChatConnected.value = false;
        },
      );
      _isChatConnected.value = true;
      debugPrint('Chat WebSocket connected');
    } catch (e) {
      debugPrint('Failed to connect chat WebSocket: $e');
      _isChatConnected.value = false;
    }
  }

  Future<void> connectNotifications() async {
    try {
      final chatApi = ChatApi();
      final ticket = await chatApi.getWsTicket();
      final wsUrl = _getWsUrl('notifications', ticket);
      debugPrint('Connecting to notification WebSocket: $wsUrl');
      _notificationChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _notificationChannel!.stream.listen(
        (data) {
          _handleNotificationMessage(data);
        },
        onDone: () {
          debugPrint('Notification WebSocket disconnected');
          _isNotificationConnected.value = false;
        },
        onError: (error) {
          debugPrint('Notification WebSocket error: $error');
          _isNotificationConnected.value = false;
        },
      );
      _isNotificationConnected.value = true;
      debugPrint('Notification WebSocket connected');
    } catch (e) {
      debugPrint('Failed to connect notification WebSocket: $e');
      _isNotificationConnected.value = false;
    }
  }

  String _getWsUrl(String path, String ticket) {
    final apiProvider = Get.find<ApiProvider>();
    String baseUrl = ApiProvider.baseUrl;
    if (baseUrl.startsWith('http://')) {
      baseUrl = baseUrl.replaceFirst('http://', 'ws://');
    } else if (baseUrl.startsWith('https://')) {
      baseUrl = baseUrl.replaceFirst('https://', 'wss://');
    }
    baseUrl = baseUrl.replaceAll('/api', '');
    return '$baseUrl/ws/$path/?ticket=$ticket';
  }

  void _handleChatMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String);
      final type = message['type'];
      if (type == 'new_message') {
        final msg = message['message'];
        final receiverId = msg['receiver'];
        final senderId = msg['sender'];
        final auth = Get.find<AuthService>();
        final currentUserId = auth.userId;

        if (receiverId == currentUserId) {
          _chatUnreadCount.value++;
        }
      } else if (type == 'chat_unread_update') {
        _chatUnreadCount.value = message['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error handling chat message: $e');
    }
  }

  void _handleNotificationMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String);
      final type = message['type'];
      if (type == 'notification_update') {
        _notificationCount.value = message['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error handling notification message: $e');
    }
  }

  void sendChatMessage(int receiverId, String content) {
    if (_chatChannel != null) {
      final auth = Get.find<AuthService>();
      final message = jsonEncode({
        'type': 'chat_message',
        'receiver_id': receiverId,
        'content': content,
      });
      _chatChannel!.sink.add(message);
    }
  }

  void disconnectChat() {
    _chatChannel?.sink.close();
    _chatChannel = null;
    _isChatConnected.value = false;
  }

  void disconnectNotifications() {
    _notificationChannel?.sink.close();
    _notificationChannel = null;
    _isNotificationConnected.value = false;
  }

  void disconnectAll() {
    disconnectChat();
    disconnectNotifications();
  }

  void setNotificationCount(int count) {
    _notificationCount.value = count;
  }

  void setChatUnreadCount(int count) {
    _chatUnreadCount.value = count;
  }

  void decrementChatUnread() {
    if (_chatUnreadCount.value > 0) {
      _chatUnreadCount.value--;
    }
  }

  void incrementNotificationCount() {
    _notificationCount.value++;
  }
}
