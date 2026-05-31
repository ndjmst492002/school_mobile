import 'dart:typed_data';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../providers/api_provider.dart';
import '../models/models.dart';

class AdminApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<List<Exercise>> getExercises() async {
    final response = await _api.get('/users/admin/exercises/');
    if (response.data is! List) {
      debugPrint('getExercises response is not a list: ${response.data}');
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<Exercise> createExercise({
    required String title,
    required String description,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    String? dueDate,
    int? levelId,
    List<int>? classIds,
    List<int>? skillIds,
  }) async {
    final formData = dio_pkg.FormData.fromMap({
      'title': title,
      'description': description,
      if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
      if (levelId != null) 'level_id': levelId,
      if (classIds != null && classIds.isNotEmpty)
        'class_ids': classIds.join(','),
      if (skillIds != null && skillIds.isNotEmpty)
        'skill_ids': skillIds.join(','),
    });

    if (kIsWeb && fileBytes != null) {
      formData.files.add(MapEntry(
        'file_path',
        dio_pkg.MultipartFile.fromBytes(fileBytes, filename: fileName ?? 'exercise.txt'),
      ));
    } else if (filePath != null) {
      formData.files.add(MapEntry(
        'file_path',
        await dio_pkg.MultipartFile.fromFile(filePath),
      ));
    }

    final response = await _api.uploadFile('/users/admin/exercises/', data: formData);
    return Exercise.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Exercise>> getExerciseRequests() async {
    final response = await _api.get('/users/admin/exercises/moderate/');
    if (response.data is! List) {
      debugPrint('getExerciseRequests response is not a list: ${response.data}');
      return [];
    }
    final List<dynamic> data = response.data;
    return data.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<void> respondToExerciseRequest(int exerciseId, String action) async {
    await _api.patch(
      '/users/admin/exercises/moderate/',
      data: {'exercise_id': exerciseId, 'action': action},
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
