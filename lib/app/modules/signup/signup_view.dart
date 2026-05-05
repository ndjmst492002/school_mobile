import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'signup_controller.dart';
import '../../../main.dart';
import '../../routes/app_routes.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18181B) : const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          const _AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Obx(() => _buildStep(isDark)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildIconButton(
            icon: Obx(() {
              final theme = Get.find<ThemeService>();
              return Text(
                theme.locale.languageCode == 'en' ? 'ع' : 'EN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              );
            }),
            onPressed: () {
              Get.find<ThemeService>().toggleLanguage();
            },
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Obx(() {
              final theme = Get.find<ThemeService>();
              return Icon(
                theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : Colors.black87,
              );
            }),
            onPressed: () {
              Get.find<ThemeService>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(icon: icon, onPressed: onPressed),
    );
  }

  Widget _buildStep(bool isDark) {
    switch (controller.currentStep.value) {
      case SignupStep.details:
        return _buildDetailsStep(isDark);
      case SignupStep.phone:
        return _buildPhoneStep(isDark);
      case SignupStep.role:
        return _buildRoleStep(isDark);
      case SignupStep.teacher:
        return _buildTeacherStep(isDark);
      case SignupStep.parent:
        return _buildParentStep(isDark);
    }
  }

  Widget _buildDetailsStep(bool isDark) {
    return Card(
      elevation: 8,
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.school, size: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Create your account',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.error.value != null) {
                return _buildErrorBanner(controller.error.value!);
              }
              return const SizedBox.shrink();
            }),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.firstNameController,
                    label: 'First Name *',
                    hint: 'First Name',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: controller.lastNameController,
                    label: 'Last Name *',
                    hint: 'Last Name',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.emailController,
              label: 'Email Address *',
              hint: 'email@example.com',
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.addressController,
              label: 'Address',
              hint: 'Address',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.dateOfBirthController,
              label: 'Date of Birth',
              hint: 'Select date',
              isDark: isDark,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  controller.dateOfBirthController.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),
const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: controller.isLoading.value ? null : controller.signInWithGoogle,
                icon: const Icon(Icons.login, size: 20),
                label: const Text('Sign up with Google'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.goToPhoneStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue to Phone Verification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.login),
              child: Text(
                'Already have an account? Login',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep(bool isDark) {
    return Card(
      elevation: 8,
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.phone_android, size: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Phone Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Obx(() => Text(
              controller.otpSent.value
                  ? 'Enter the code sent to your phone'
                  : 'Enter your phone number',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.error.value != null) {
                return _buildErrorBanner(controller.error.value!);
              }
              return const SizedBox.shrink();
            }),
            Obx(() => _buildTextField(
              controller: controller.otpSent.value
                  ? controller.otpCodeController
                  : controller.phoneNumberController,
              label: controller.otpSent.value ? 'Verification Code' : 'Phone Number',
              hint: controller.otpSent.value ? '123456' : '+213551234567',
              isDark: isDark,
              keyboardType: controller.otpSent.value
                  ? TextInputType.number
                  : TextInputType.phone,
              maxLength: controller.otpSent.value ? 6 : null,
            )),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : (controller.otpSent.value
                        ? controller.verifyOTP
                        : controller.sendOTP),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(controller.otpSent.value ? 'Verifying...' : 'Sending...'),
                        ],
                      )
                    : Text(
                        controller.otpSent.value ? 'Verify & Continue' : 'Send Code',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: controller.isLoading.value ? null : controller.goBackToDetails,
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleStep(bool isDark) {
    return Card(
      elevation: 8,
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Your Role',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Choose one or both roles',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.error.value != null) {
                return _buildErrorBanner(controller.error.value!);
              }
              return const SizedBox.shrink();
            }),
            Obx(() => Row(
              children: [
                Expanded(
                  child: _buildRoleButton(
                    label: 'Teacher',
                    icon: Icons.person,
                    isSelected: controller.isTeacherSelected,
                    isDark: isDark,
                    onTap: () => controller.toggleRole('teacher'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRoleButton(
                    label: 'Parent',
                    icon: Icons.family_restroom,
                    isSelected: controller.isParentSelected,
                    isDark: isDark,
                    onTap: () => controller.toggleRole('parent'),
                  ),
                ),
              ],
            )),
            Obx(() {
              if (controller.isTeacherSelected && controller.isParentSelected) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'You\'ll fill in teacher details first, then add your children.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: (controller.isLoading.value || controller.selectedRoles.isEmpty)
                    ? null
                    : controller.continueFromRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherStep(bool isDark) {
    return Card(
      elevation: 8,
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (controller.isParentSelected) {
                return Text(
                  'Step 1 of 2',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                );
              }
              return const SizedBox.shrink();
            }),
            Text(
              'Teacher Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your teaching details',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.error.value != null) {
                return _buildErrorBanner(controller.error.value!);
              }
              return const SizedBox.shrink();
            }),
            _buildTextField(
              controller: controller.hireDateController,
              label: 'Hire Date *',
              hint: 'Select date',
              isDark: isDark,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1970),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  controller.hireDateController.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.specializationController,
              label: 'Specialization *',
              hint: 'e.g., Mathematics',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.classNameController,
              label: 'Class Name *',
              hint: 'e.g., Grade 10-A',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.classDescriptionController,
              label: 'Class Description',
              hint: 'Class description',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitTeacherProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Saving...'),
                        ],
                      )
                    : Text(
                        controller.isParentSelected
                            ? 'Save & Continue to Parent Info'
                            : 'Complete Registration',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildParentStep(bool isDark) {
    return Card(
      elevation: 8,
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              if (controller.isTeacherSelected) {
                return Text(
                  'Step 2 of 2',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                );
              }
              return const SizedBox.shrink();
            }),
            Text(
              'Parent & Children Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your occupation and add your children',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.error.value != null) {
                return _buildErrorBanner(controller.error.value!);
              }
              return const SizedBox.shrink();
            }),
            _buildTextField(
              controller: controller.occupationController,
              label: 'Your Occupation *',
              hint: 'e.g., Engineer',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Children (at least 1) *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: List.generate(controller.students.length, (index) {
                final student = controller.students[index];
                return _buildStudentCard(student, index, isDark);
              }),
            )),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: controller.addStudent,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Another Student'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitParentProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Creating...'),
                        ],
                      )
                    : const Text(
                        'Complete Registration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentData student, int index, bool isDark) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF18181B) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Child ${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  if (controller.students.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      onPressed: () => controller.removeStudent(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: student.firstNameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'First Name *',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: student.lastNameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Last Name *',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: student.enrollmentDateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          student.enrollmentDateController.text =
                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          setInnerState(() {});
                        }
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enrollment Date *',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: student.dateOfBirthController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          student.dateOfBirthController.text =
                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          setInnerState(() {});
                        }
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Date of Birth',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool>(
                    value: student.gender,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    borderRadius: BorderRadius.circular(8),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Male')),
                      DropdownMenuItem(value: false, child: Text('Female')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        student.gender = v;
                        setInnerState(() {});
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500]),
        filled: true,
        fillColor: isDark ? const Color(0xFF18181B) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        counterText: maxLength != null ? '' : null,
      ),
    );
  }

  Widget _buildCompactTextField({
    required String text,
    required String hint,
    required bool isDark,
    bool readOnly = false,
    VoidCallback? onTap,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: text),
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF27272A) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? const Color(0xFF18181B) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? const Color(0xFF3F3F46) : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MatrixPainter(animation: _controller.value, isDark: isDark),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _MatrixPainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.25 + i * 0.25);
      final dropPosition = (animation + i * 0.3) % 1.0;

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.15),
          isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.15),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(
            x - 0.5,
            size.height * (dropPosition - 0.15),
            1,
            size.height * 0.2,
          ),
        );

      canvas.drawLine(
        Offset(x, size.height * (dropPosition - 0.15)),
        Offset(x, size.height * dropPosition),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.isDark != isDark;
}
