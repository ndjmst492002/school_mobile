import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_api.dart';
import '../../routes/app_routes.dart';

class ProfileCompletionController extends GetxController {
  final AuthApi _authApi = AuthApi();

  final hireDateController = TextEditingController();
  final specializationController = TextEditingController();
  final classNameController = TextEditingController();
  final classDescriptionController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  String get userRole => Get.arguments?['role'] ?? 'TEACHER';

  @override
  void onClose() {
    hireDateController.dispose();
    specializationController.dispose();
    classNameController.dispose();
    classDescriptionController.dispose();
    super.onClose();
  }

  Future<void> createTeacherProfile() async {
    if (specializationController.text.isEmpty ||
        classNameController.text.isEmpty) {
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
        className: classNameController.text,
        classDescription: classDescriptionController.text.isEmpty
            ? null
            : classDescriptionController.text,
      );

      Get.snackbar('Success', 'Profile created successfully');
      Get.offAllNamed(AppRoutes.teacher);
    } catch (e) {
      errorMessage.value = 'Failed to create profile: $e';
      Get.snackbar('Error', errorMessage.value ?? 'Failed to create profile');
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
