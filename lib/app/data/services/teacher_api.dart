import 'dart:typed_data';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/models.dart';

class TeacherApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<ClassModel>> getClasses() async {
    final response = await _api.get('/users/teacher/classes/');
    final List<dynamic> data = response.data;
    return data.map((json) => ClassModel.fromJson(json)).toList();
  }

  Future<List<Exercise>> getExercises() async {
    final response = await _api.get('/users/teacher/exercises/');
    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<List<Submission>> getSubmissions() async {
    final response = await _api.get('/users/teacher/submissions/');
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
    return Exercise.fromJson(response.data);
  }

  String downloadSubmissionUrl(int submissionId) {
    return '${ApiProvider.baseUrl}/users/submissions/$submissionId/download/';
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
    return Announcement.fromJson(response.data);
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

  Future<Map<String, dynamic>> getUnreadCounts() async {
    final response = await _api.get('/users/chat/unread-count/');
    return response.data as Map<String, dynamic>;
  }

  Future<int> getUnreadMessageCount() async {
    final response = await _api.get('/users/chat/unread-count/');
    final data = response.data as Map<String, dynamic>;
    return data['total_unread'] ?? 0;
  }
}
