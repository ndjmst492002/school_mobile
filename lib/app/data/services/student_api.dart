import 'dart:typed_data';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/models.dart';
import '../exceptions.dart';

class StudentApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  bool _isProfileNotFoundError(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      return detail != null &&
          (detail.toString().contains('profile not found') ||
              detail.toString().contains('not found') ||
              detail.toString().contains('Student not found'));
    }
    return false;
  }

  Future<List<ClassModel>> getAllClasses() async {
    final response = await _api.get('/users/classes/');
    if (response.data is! List) {
      debugPrint('getAllClasses response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Student profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => ClassModel.fromJson(json)).toList();
  }

  Future<void> enrollInClass(int classId) async {
    await _api.post('/users/student/enroll/', data: {'class_id': classId});
  }

  Future<List<Exercise>> getExercises() async {
    final response = await _api.get('/users/student/exercises/');
    if (response.data is! List) {
      debugPrint('getExercises response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Student profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<List<Submission>> getSubmissions() async {
    final response = await _api.get('/users/student/submissions/');
    if (response.data is! List) {
      debugPrint('getSubmissions response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Student profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Submission.fromJson(json)).toList();
  }

  Future<Submission> submitExercise({
    required int exerciseId,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    dio_pkg.MultipartFile file;

    if (kIsWeb && fileBytes != null) {
      file = dio_pkg.MultipartFile.fromBytes(
        fileBytes,
        filename: fileName ?? 'submission.txt',
      );
    } else if (filePath != null) {
      file = await dio_pkg.MultipartFile.fromFile(filePath);
    } else {
      throw Exception('No file provided');
    }

    final formData = dio_pkg.FormData.fromMap({
      'exercise': exerciseId,
      'submission_file': file,
    });

    final response = await _api.uploadFile(
      '/users/student/submissions/',
      data: formData,
    );
    return Submission.fromJson(response.data);
  }

  String downloadExerciseUrl(int exerciseId) {
    return '${ApiProvider.baseUrl}/users/exercises/$exerciseId/download/';
  }

  String downloadSubmissionUrl(int submissionId) {
    return '${ApiProvider.baseUrl}/users/submissions/$submissionId/download/';
  }

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _api.get('/users/student/announcements/');
    if (response.data is! List) {
      debugPrint('getAnnouncements response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Student profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Announcement.fromJson(json)).toList();
  }

  Future<List<AttendanceRecord>> getAttendance() async {
    final response = await _api.get('/users/student/attendance/');
    if (response.data is! List) {
      debugPrint('getAttendance response is not a list: ${response.data}');
      if (_isProfileNotFoundError(response.data)) {
        throw ProfileNotFoundException(
          'Student profile not found. Please complete your profile.',
        );
      }
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => AttendanceRecord.fromJson(json)).toList();
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
}
