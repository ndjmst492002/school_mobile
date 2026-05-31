import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/student_api.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';

class ProfileCompletionController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final StudentApi _studentApi = StudentApi();

  final hireDateController = TextEditingController();
  final specializationController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final levels = <Level>[].obs;
  final classes = <ClassModel>[].obs;
  final selectedLevelId = Rxn<int>();
  final selectedClassId = Rxn<int>();

  String get userRole => Get.arguments?['role'] ?? 'TEACHER';

  static const List<Map<String, dynamic>> _allLevelsData = [
    {'id': 1, 'name': '1AP'}, {'id': 2, 'name': '2AP'},
    {'id': 3, 'name': '3AP'}, {'id': 4, 'name': '4AP'},
    {'id': 5, 'name': '5AP'}, {'id': 6, 'name': '1AM'},
    {'id': 7, 'name': '2AM'}, {'id': 8, 'name': '3AM'},
    {'id': 9, 'name': '4AM'}, {'id': 10, 'name': '1AS'},
    {'id': 11, 'name': '2AS'}, {'id': 12, 'name': '3AS'},
  ];

  @override
  void onInit() {
    super.onInit();
    levels.value = _allLevelsData
        .map((e) => Level(id: e['id'] as int, name: e['name'] as String))
        .toList();
  }

  @override
  void onClose() {
    hireDateController.dispose();
    specializationController.dispose();
    super.onClose();
  }

  void onLevelChanged(int? levelId) {
    selectedLevelId.value = levelId;
    selectedClassId.value = null;
    if (levelId != null) {
      _loadClassesForLevel(levelId);
    } else {
      classes.clear();
    }
  }

  Future<void> _loadClassesForLevel(int levelId) async {
    try {
      final result = await _studentApi.getAllClassesPublic(levelId: levelId);
      classes.value = result;
    } catch (e) {
      debugPrint('Error loading classes: $e');
    }
  }

  Future<void> createTeacherProfile() async {
    if (specializationController.text.isEmpty ||
        selectedLevelId.value == null ||
        selectedClassId.value == null) {
      errorMessage.value = 'Please fill in all required fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authApi.createTeacherProfile(
        hireDate: hireDateController.text.isEmpty
            ? DateTime.now().toString().split(' ')[0]
            : hireDateController.text,
        specialization: specializationController.text,
        levelId: selectedLevelId.value!,
        classId: selectedClassId.value!,
      );

      Get.snackbar('Success'.tr, 'Profile created successfully'.tr);
      Get.offAllNamed(AppRoutes.teacher);
    } catch (e) {
      errorMessage.value = 'Failed to create profile: $e';
      Get.snackbar('Error'.tr, errorMessage.value ?? 'Failed to create profile');
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      hireDateController.text = date.toString().split(' ')[0];
    }
  }
}
