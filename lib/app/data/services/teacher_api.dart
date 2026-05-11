import 'dart:typed_data';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/models.dart';
import '../exceptions.dart';

class TeacherApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  bool _isProfileNotFoundError(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      return detail != null &&
          (detail.toString().contains('profile not found') ||
              detail.toString().contains('not found'));
    }
    return false;
  }

  Future<List<ClassModel>> getClasses() async {
    final response = await _api.get('/users/teacher/classes/');
    if (response.data is! List) {
      debugPrint('getClasses response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Teacher profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => ClassModel.fromJson(json)).toList();
  }

  Future<List<Exercise>> getExercises() async {
    final response = await _api.get('/users/teacher/exercises/');
    if (response.data is! List) {
      debugPrint('getExercises response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Teacher profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<List<Submission>> getSubmissions() async {
    final response = await _api.get('/users/teacher/submissions/');
    if (response.data is! List) {
      debugPrint('getSubmissions response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Teacher profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Submission.fromJson(json)).toList();
  }

  Future<Exercise> createExercise({
    required String title,
    required String description,
    required int classId,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    String? dueDate,
  }) async {
    dio_pkg.MultipartFile file;

    if (kIsWeb && fileBytes != null) {
      file = dio_pkg.MultipartFile.fromBytes(
        fileBytes,
        filename: fileName ?? 'exercise.txt',
      );
    } else if (filePath != null) {
      file = await dio_pkg.MultipartFile.fromFile(filePath);
    } else {
      throw Exception('No file provided');
    }

    final formData = dio_pkg.FormData.fromMap({
      'title': title,
      'description': description,
      'related_class': classId,
      'file_path': file,
      if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
    });

    final response = await _api.uploadFile(
      '/users/teacher/exercises/',
      data: formData,
    );
    debugPrint('Exercise upload response type: ${response.data.runtimeType}');
    debugPrint('Exercise upload response: ${response.data}');
    if (response.data is String) {
      throw Exception('Server error: $response.data');
    }
    return Exercise.fromJson(response.data as Map<String, dynamic>);
  }

  String downloadSubmissionUrl(int submissionId) {
    return '${ApiProvider.baseUrl}/users/submissions/$submissionId/download/';
  }

  String downloadExerciseUrl(int exerciseId) {
    return '${ApiProvider.baseUrl}/users/exercises/$exerciseId/download/';
  }

  Future<Submission> gradeSubmission(
    int submissionId,
    double grade,
    String feedback,
  ) async {
    final response = await _api.patch(
      '/users/submissions/$submissionId/grade/',
      data: {'grade': grade, 'feedback': feedback},
    );
    return Submission.fromJson(response.data);
  }

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _api.get('/users/teacher/announcements/');
    if (response.data is! List) {
      debugPrint('getAnnouncements response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Teacher profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Announcement.fromJson(json)).toList();
  }

  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    int? classId,
  }) async {
    final Map<String, dynamic> data = {'title': title, 'content': content};
    if (classId != null) {
      data['related_class'] = classId;
    }

    final response = await _api.post(
      '/users/teacher/announcements/',
      data: data,
    );
    debugPrint('Announcement response type: ${response.data.runtimeType}');
    debugPrint('Announcement response: ${response.data}');
    if (response.data is String) {
      throw Exception('Server error: $response.data');
    }
    return Announcement.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AttendanceRecord>> getAttendance(int classId, String date) async {
    final response = await _api.get(
      '/users/teacher/attendance/',
      queryParameters: {'class_id': classId, 'date': date},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => AttendanceRecord.fromJson(json)).toList();
  }

  Future<List<AttendanceRecord>> markAttendance(
    List<Map<String, dynamic>> records,
  ) async {
    final response = await _api.post(
      '/users/teacher/attendance/',
      data: {'records': records},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => AttendanceRecord.fromJson(json)).toList();
  }

  Future<int> getUnreadMessageCount() async {
    final response = await _api.get('/users/chat/unread-count/');
    return response.data['count'] ?? 0;
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

  Future<List<EnrollmentRequest>> getEnrollments() async {
    final response = await _api.get('/users/teacher/enrollments/');
    if (response.data is! List) {
      debugPrint('getEnrollments response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Teacher profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => EnrollmentRequest.fromJson(json)).toList();
  }

  Future<void> respondToEnrollment(int enrollmentId, String action) async {
    await _api.post(
      '/users/teacher/enrollments/',
      data: {'enrollment_id': enrollmentId, 'action': action},
    );
  }

  Future<List<Skill>> getSkills() async {
    final response = await _api.get('/users/skills/');
    if (response.data is! List) {
      debugPrint('getSkills response is not a list: ${response.data}');
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Skill.fromJson(json)).toList();
  }
}
