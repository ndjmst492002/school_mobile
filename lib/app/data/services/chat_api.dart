import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/chat_models.dart';

class ChatApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<Contact>> getContacts() async {
    final auth = Get.find<AuthService>();
    final role = auth.role;

    final response = await _api.get(
      '/users/chat/contacts/',
      queryParameters: {'role': role},
    );
    if (response.data is! List) return [];
    return (response.data as List).map((json) => Contact.fromJson(json)).toList();
  }

  Future<List<ChatMessage>> getMessages(int contactId) async {
    final response = await _api.get('/users/chat/messages/$contactId/');
    if (response.data is! List) return [];
    return (response.data as List).map((json) => ChatMessage.fromJson(json)).toList();
  }

  Future<ChatMessage> sendMessage(int contactId, String content) async {
    final response = await _api.post(
      '/users/chat/messages/$contactId/',
      data: {'content': content},
    );
    return ChatMessage.fromJson(response.data);
  }

  Future<String> getWsTicket() async {
    final response = await _api.post('/users/ws-ticket/');
    if (response.data is! Map) return '';
    return (response.data as Map)['ticket'] ?? '';
  }
}
