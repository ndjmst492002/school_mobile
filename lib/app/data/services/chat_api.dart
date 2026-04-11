import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/chat_models.dart';

class ChatApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<Contact>> getContacts() async {
    final response = await _api.get('/users/chat/contacts/');
    debugPrint('API Response for contacts: ${response.data}');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Contact.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<ChatMessage>> getMessages(int contactId) async {
    final response = await _api.get('/users/chat/messages/$contactId/');
    if (response.data is List) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map(
            (json) =>
                ChatMessage.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();
    }
    return [];
  }

  Future<ChatMessage> sendMessage(int contactId, String content) async {
    final response = await _api.post(
      '/users/chat/messages/$contactId/',
      data: {'content': content},
    );
    return ChatMessage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> getWsTicket() async {
    final response = await _api.post('/users/ws-ticket/');
    return response.data['ticket'] as String;
  }

  Future<int> getUnreadMessageCount() async {
    final response = await _api.get('/users/chat/unread-count/');
    final data = response.data as Map<String, dynamic>;
    return data['total_unread'] ?? 0;
  }
}
