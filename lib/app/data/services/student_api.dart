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

  Future<List<ClassModel>> getAllClasses({int? studentId, int? levelId}) async {
    final params = <String, dynamic>{
      '_t': DateTime.now().millisecondsSinceEpoch,
    };
    if (studentId != null) params['student_id'] = studentId;
    if (levelId != null) params['level_id'] = levelId;
    final response = await _api.get('/users/classes/', queryParameters: params);
    debugPrint('getAllClasses status: ${response.statusCode}, data type: ${response.data.runtimeType}');
    if (response.statusCode != 200) {
      debugPrint('getAllClasses error response: ${response.data}');
      return [];
    }
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
    debugPrint('getAllClasses returned ${data.length} classes: [${data.map((c) => '${c['id']}:${c['name']}').join(', ')}]');
    final parsed = <ClassModel>[];
    for (final json in data) {
      try {
        parsed.add(ClassModel.fromJson(json as Map<String, dynamic>));
      } catch (e) {
        debugPrint('SKIPPED class ${json['id']} due to parse error: $e');
      }
    }
    debugPrint('Successfully parsed ${parsed.length}/${data.length} classes');
    return parsed;
  }

  Future<List<ClassModel>> getAllClassesPublic({int? levelId}) async {
    final params = <String, dynamic>{};
    if (levelId != null) params['level_id'] = levelId;
    final response = await _api.get('/users/classes/public/', queryParameters: params);
    if (response.data is! List) {
      debugPrint('getAllClassesPublic response is not a list: ${response.data}');
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => ClassModel.fromJson(json)).toList();
  }

  Future<void> enrollInClass(int classTeacherId, {int? studentId}) async {
    final data = <String, dynamic>{'class_teacher_id': classTeacherId};
    if (studentId != null) data['student_id'] = studentId;
    await _api.post('/users/student/enroll/', data: data);
  }

  Future<List<Exercise>> getExercises({int? studentId}) async {
    final params = <String, dynamic>{};
    if (studentId != null) params['student_id'] = studentId;
    final response = await _api.get('/users/student/exercises/', queryParameters: params);
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

  Future<List<Submission>> getSubmissions({int? studentId}) async {
    final params = <String, dynamic>{};
    if (studentId != null) params['student_id'] = studentId;
    final response = await _api.get('/users/student/submissions/', queryParameters: params);
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
    int? studentId,
  }) async {
    final formData = dio_pkg.FormData.fromMap({
      'exercise': exerciseId,
      if (studentId != null) 'student_id': studentId,
    });

    if (filePath != null || (kIsWeb && fileBytes != null)) {
      if (kIsWeb && fileBytes != null) {
        formData.files.add(MapEntry(
          'submission_file',
          dio_pkg.MultipartFile.fromBytes(
            fileBytes,
            filename: fileName ?? 'submission.txt',
          ),
        ));
      } else if (filePath != null) {
        formData.files.add(MapEntry(
          'submission_file',
          await dio_pkg.MultipartFile.fromFile(filePath),
        ));
      }
    }

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

  Future<List<Announcement>> getAnnouncements({int? studentId}) async {
    final params = <String, dynamic>{};
    if (studentId != null) params['student_id'] = studentId;
    final response = await _api.get('/users/student/announcements/', queryParameters: params);
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

  Future<List<AttendanceRecord>> getAttendance({int? studentId}) async {
    final params = <String, dynamic>{};
    if (studentId != null) params['student_id'] = studentId;
    final response = await _api.get('/users/student/attendance/', queryParameters: params);
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
