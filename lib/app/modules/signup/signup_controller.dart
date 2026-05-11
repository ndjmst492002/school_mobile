import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../routes/app_routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum SignupStep { details, phone, role, teacher, parent }

class StudentData {
  String firstName;
  String lastName;
  String enrollmentDate;
  String dateOfBirth;
  bool gender;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final enrollmentDateController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  StudentData({
    this.firstName = '',
    this.lastName = '',
    this.enrollmentDate = '',
    this.dateOfBirth = '',
    this.gender = true,
  });

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    enrollmentDateController.dispose();
    dateOfBirthController.dispose();
  }
}

class SignupController extends GetxController {
  final AuthApi _authApi = AuthApi();
  static const String _serverClientId =
      '719247317672-32jg242u60iic2hjkvg2selclsb4ebrb.apps.googleusercontent.com';
  late GoogleSignIn googleSignIn;

  @override
  void onInit() {
    super.onInit();
    if (kIsWeb) {
      googleSignIn = GoogleSignIn(scopes: ['email', 'profile', 'openid']);
    } else {
      googleSignIn = GoogleSignIn(
        serverClientId: _serverClientId,
        scopes: ['email', 'profile', 'openid'],
      );
    }
  }

  final currentStep = SignupStep.details.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  final phoneNumberController = TextEditingController();
  final otpCodeController = TextEditingController();
  final otpSent = false.obs;

  final selectedRoles = <String>[].obs;

  final hireDateController = TextEditingController();
  final specializationController = TextEditingController();
  final classNameController = TextEditingController();
  final classDescriptionController = TextEditingController();

  final occupationController = TextEditingController();
  final students = <StudentData>[StudentData()].obs;

  bool get isTeacherSelected => selectedRoles.contains('teacher');
  bool get isParentSelected => selectedRoles.contains('parent');

  AuthService get _auth => Get.find<AuthService>();

  void goToStep(SignupStep step) {
    currentStep.value = step;
    error.value = null;
  }

  void goToRoleStep() {
    if (firstNameController.text.isEmpty) {
      error.value = 'First name is required';
      return;
    }
    if (lastNameController.text.isEmpty) {
      error.value = 'Last name is required';
      return;
    }
    error.value = null;
    currentStep.value = SignupStep.phone;
  }

  void goBackToDetails() {
    currentStep.value = SignupStep.details;
  }

  void goToPhoneStep() {
    if (firstNameController.text.isEmpty) {
      error.value = 'First name is required';
      return;
    }
    if (lastNameController.text.isEmpty) {
      error.value = 'Last name is required';
      return;
    }
    error.value = null;
    currentStep.value = SignupStep.phone;
  }

  Future<void> sendOTP() async {
    if (phoneNumberController.text.isEmpty) {
      error.value = 'Phone number is required';
      return;
    }
    // Basic phone validation - should contain at least country code and number
    if (phoneNumberController.text.length < 8) {
      error.value = 'Please enter a valid phone number';
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      final response = await _authApi.sendOTP(phoneNumberController.text);
      otpSent.value = true;
    } catch (e) {
      error.value = 'Failed to send OTP: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP() async {
    if (otpCodeController.text.isEmpty) {
      error.value = 'Please enter the verification code';
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      final email = emailController.text.isNotEmpty
          ? emailController.text
          : '${phoneNumberController.text}@phone.local';

      await _authApi.verifyOTP(
        phoneNumber: phoneNumberController.text,
        code: otpCodeController.text,
        email: email,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        address: addressController.text,
        dateOfBirth: dateOfBirthController.text.isNotEmpty
            ? dateOfBirthController.text
            : null,
      );
      currentStep.value = SignupStep.role;
      otpSent.value = false;
      otpCodeController.clear();
    } catch (e) {
      error.value = 'Invalid or expired code. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRole(String role) {
    if (selectedRoles.contains(role)) {
      selectedRoles.remove(role);
    } else {
      selectedRoles.add(role);
    }
    error.value = null;
  }

  void continueFromRole() {
    if (selectedRoles.isEmpty) {
      error.value = 'Please select at least one role';
      return;
    }
    error.value = null;
    if (isTeacherSelected) {
      currentStep.value = SignupStep.teacher;
    } else {
      currentStep.value = SignupStep.parent;
    }
  }

  Future<void> submitTeacherProfile() async {
    if (hireDateController.text.isEmpty ||
        specializationController.text.isEmpty ||
        classNameController.text.isEmpty) {
      error.value = 'Please fill in all required fields';
      return;
    }
    isLoading.value = true;
    error.value = null;
    debugPrint('=== Submitting teacher profile ===');
    try {
      final result = await _authApi.createTeacherProfile(
        hireDate: hireDateController.text,
        specialization: specializationController.text,
        className: classNameController.text,
        classDescription: classDescriptionController.text.isNotEmpty
            ? classDescriptionController.text
            : null,
      );
      debugPrint('Teacher profile result: $result');
      if (isParentSelected) {
        currentStep.value = SignupStep.parent;
      } else {
        Get.snackbar(
          'Registration Complete!',
          'Please login again with Google to access your dashboard.',
          duration: const Duration(seconds: 5),
        );
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Teacher profile creation error: $e');
      error.value =
          'Failed to create teacher profile. Please try again. Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void addStudent() {
    students.add(StudentData());
  }

  void removeStudent(int index) {
    if (students.length > 1) {
      students[index].dispose();
      students.removeAt(index);
    }
  }

  Future<void> submitParentProfile() async {
    if (occupationController.text.isEmpty) {
      error.value = 'Please enter your occupation';
      return;
    }

    // Check each child - if any required field is filled, all must be filled
    for (var s in students) {
      final firstName = s.firstNameController.text;
      final lastName = s.lastNameController.text;
      final enrollmentDate = s.enrollmentDateController.text;

      final hasAnyField =
          firstName.isNotEmpty ||
          lastName.isNotEmpty ||
          enrollmentDate.isNotEmpty;
      if (hasAnyField) {
        if (firstName.isEmpty || lastName.isEmpty || enrollmentDate.isEmpty) {
          error.value =
              'Please fill all required fields (First Name, Last Name, Enrollment Date) for each child, or leave empty';
          return;
        }
      }
    }

    // Count valid students using controller text
    final validStudents = students
        .where(
          (s) =>
              s.firstNameController.text.isNotEmpty &&
              s.lastNameController.text.isNotEmpty &&
              s.enrollmentDateController.text.isNotEmpty,
        )
        .toList();

    if (validStudents.isEmpty) {
      error.value =
          'Please add at least one child with first name, last name, and enrollment date';
      return;
    }

    isLoading.value = true;
    error.value = null;
    try {
      final studentsData = validStudents
          .map(
            (s) => {
              'first_name': s.firstNameController.text,
              'last_name': s.lastNameController.text,
              'enrollment_date': s.enrollmentDateController.text,
              'date_of_birth': s.dateOfBirthController.text.isNotEmpty
                  ? s.dateOfBirthController.text
                  : null,
              'gender': s.gender,
            },
          )
          .toList();

      await _authApi.createParentProfile(
        occupation: occupationController.text,
        students: studentsData,
      );

      debugPrint('Parent profile created successfully');
      Get.snackbar(
        'Registration Complete!',
        'Please login again with Google to access your dashboard.',
        duration: const Duration(seconds: 5),
      );
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('Parent profile creation error: $e');
      String errorMsg = 'Failed to create parent profile.';
      if (e.toString().contains('401')) {
        errorMsg = 'Authentication failed. Please try logging in again.';
      } else if (e.toString().contains('400')) {
        errorMsg = 'Invalid data. Please check your inputs.';
      } else {
        errorMsg =
            'Failed to create parent profile. Please try again. Error: $e';
      }
      error.value = errorMsg;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    error.value = null;
    debugPrint('=== Starting Google Sign-In ===');
    try {
      // Force fresh sign-in to show account picker
      await googleSignIn.signOut();
      debugPrint('Signed out previous session');

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      debugPrint('Google user: $googleUser');

      if (googleUser == null) {
        debugPrint('Google sign-in cancelled by user');
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('Got Google auth');
      // Use accessToken for backend (idToken doesn't work with tokeninfo endpoint)
      final String? token = googleAuth.accessToken ?? googleAuth.idToken;

      if (token == null) {
        error.value = 'Failed to get token';
        isLoading.value = false;
        return;
      }

      debugPrint('Calling backend googleAuth...');
      try {
        final response = await _authApi.googleAuth(token);
        debugPrint('Backend auth response: $response');
        // Save token for web
        if (kIsWeb && response.containsKey('access')) {
          final apiProvider = Get.find<ApiProvider>();
          await apiProvider.setWebToken(response['access'].toString());
          debugPrint('Web token saved');
        }
      } catch (e) {
        debugPrint('Backend auth failed: $e');
        rethrow;
      }

      final displayName = googleUser.displayName ?? '';
      final nameParts = displayName.split(' ');
      firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      lastNameController.text = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';
      emailController.text = googleUser.email;

      debugPrint('Moving to phone step');
      currentStep.value = SignupStep.phone;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      error.value = 'Google sign-in failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void setEmailFromGoogle(String email) {
    emailController.text = email;
  }

  Future<void> _autoLoginAfterSignup() async {
    try {
      final currentUserData = await _authApi.getCurrentUser();
      String? role;
      List<String> roles = [];

      if (currentUserData.containsKey('roles')) {
        roles = (currentUserData['roles'] as List)
            .map((e) => e.toString())
            .toList();
      }

      if (roles.contains('TEACHER')) {
        role = 'TEACHER';
      } else if (roles.contains('PARENT')) {
        role = 'PARENT';
      } else if (roles.isNotEmpty) {
        role = roles.first;
      }

      if (role != null && role.isNotEmpty) {
        _auth.setUser(currentUserData, role: role, roles: roles);
        _auth.setLoading(false);
      }

      // After signup, redirect to login page (like web frontend)
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error.value =
          'Registration successful but auto-login failed. Please login manually.';
      Get.offAllNamed(AppRoutes.login);
    }
  }

  String getProgressLabel() {
    final hasTeacher = isTeacherSelected;
    final hasParent = isParentSelected;

    switch (currentStep.value) {
      case SignupStep.teacher:
        if (hasParent) return 'Step 1 of 2 — Teacher Information';
        return 'Teacher Information';
      case SignupStep.parent:
        if (hasTeacher) return 'Step 2 of 2 — Parent & Children Information';
        return 'Parent & Children Information';
      default:
        return '';
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    dateOfBirthController.dispose();
    phoneNumberController.dispose();
    otpCodeController.dispose();
    hireDateController.dispose();
    specializationController.dispose();
    classNameController.dispose();
    classDescriptionController.dispose();
    occupationController.dispose();
    super.onClose();
  }
}
