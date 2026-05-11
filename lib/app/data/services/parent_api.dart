import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/parent_models.dart';
import '../models/models.dart';
import '../exceptions.dart';

class ParentApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  bool _isProfileNotFoundError(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      return detail != null &&
          (detail.toString().contains('profile not found') ||
              detail.toString().contains('not found') ||
              detail.toString().contains('Parent not found'));
    }
    return false;
  }

  Future<List<StudentChild>> getChildren() async {
    final response = await _api.get('/users/parent/children/');
    // Handle both List and Map responses
    if (response.data is List) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => StudentChild.fromJson(json)).toList();
    } else if (response.data is Map && response.data.containsKey('results')) {
      final List<dynamic> data = response.data['results'] as List<dynamic>;
      return data.map((json) => StudentChild.fromJson(json)).toList();
    }
    debugPrint('getChildren response is not a list: ${response.data}');
    if (_isProfileNotFoundError(response.data)) {
      throw ProfileNotFoundException(
        'Parent profile not found. Please complete your profile.',
      );
    }
    return [];
  }

  Future<List<ChildAnnouncement>> getAnnouncements() async {
    final response = await _api.get('/users/parent/announcements/');
    if (response.data is! List) {
      debugPrint('getAnnouncements response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Parent profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => ChildAnnouncement.fromJson(json)).toList();
  }

  Future<List<ChildAttendance>> getAttendance() async {
    final response = await _api.get('/users/parent/attendance/');
    if (response.data is! List) {
      debugPrint('getAttendance response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Parent profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => ChildAttendance.fromJson(json)).toList();
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('/users/notifications/');
    if (response.data is! List) {
      debugPrint('getNotifications response is not a list: ${response.data}');
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await _api.get('/users/notifications/unread-count/');
    return response.data['count'] ?? 0;
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await _api.post('/users/notifications/$notificationId/read/');
  }

  Future<int> getUnreadMessageCount() async {
    final response = await _api.get('/users/chat/unread-count/');
    return response.data['count'] ?? 0;
  }

  Future<PredictionResult> predictStudent(int studentId) async {
    final response = await _api.get('/users/predict/student/$studentId/');
    return PredictionResult.fromJson(response.data);
  }
}
