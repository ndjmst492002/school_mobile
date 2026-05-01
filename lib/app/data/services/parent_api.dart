import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/parent_models.dart';
import '../models/models.dart';

class ParentApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<StudentChild>> getChildren() async {
    final response = await _api.get('/users/parent/children/');
    final List<dynamic> data = response.data;
    return data.map((json) => StudentChild.fromJson(json)).toList();
  }

  Future<List<ChildAnnouncement>> getAnnouncements() async {
    final response = await _api.get('/users/parent/announcements/');
    final List<dynamic> data = response.data;
    return data.map((json) => ChildAnnouncement.fromJson(json)).toList();
  }

  Future<List<ChildAttendance>> getAttendance() async {
    final response = await _api.get('/users/parent/attendance/');
    final List<dynamic> data = response.data;
    return data.map((json) => ChildAttendance.fromJson(json)).toList();
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('/users/notifications/');
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
