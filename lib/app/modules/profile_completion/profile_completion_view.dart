import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_completion_controller.dart';

class ProfileCompletionView extends GetView<ProfileCompletionController> {
  const ProfileCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Create Your Teacher Profile'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in your details to start teaching'.tr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: controller.specializationController,
              decoration: InputDecoration(
                labelText: 'Specialization *'.tr,
                hintText: 'e.g., Mathematics, Science'.tr,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.classNameController,
              decoration: InputDecoration(
                labelText: 'Class Name *'.tr,
                hintText: 'e.g., Grade 5-A'.tr,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.classDescriptionController,
              decoration: InputDecoration(
                labelText: 'Class Description'.tr,
                hintText: 'Optional description for your class'.tr,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.errorMessage.value != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 24),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.createTeacherProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Create Profile'.tr),
              );
            }),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.offAllNamed('/login'),
              child: Text('Logout and try again'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
