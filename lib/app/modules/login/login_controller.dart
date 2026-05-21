import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/websocket_service.dart';
import '../../routes/app_routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginController extends GetxController {
  final AuthApi _authApi = AuthApi();
  static const String _serverClientId =
      '719247317672-32jg242u60iic2hjkvg2selclsb4ebrb.apps.googleusercontent.com';
  late GoogleSignIn _googleSignIn;

  @override
  void onInit() {
    super.onInit();
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(scopes: <String>['email', 'profile']);
    } else {
      _googleSignIn = GoogleSignIn(
        serverClientId: _serverClientId,
        scopes: <String>[
          'email',
          'profile',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
    }
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final showPassword = false.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();
  final selectedTab = 'email'.obs; // 'email' or 'phone'
  final otpSent = false.obs;

  AuthService get _auth => Get.find<AuthService>();

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
    error.value = null;
    if (tab == 'email') {
      otpSent.value = false;
    }
  }

  Future<void> sendOTP() async {
    if (phoneController.text.isEmpty) {
      error.value = 'Please enter phone number';
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      await _authApi.phoneLoginSend(phoneController.text);
      otpSent.value = true;
    } catch (e) {
      error.value = 'Failed to send OTP';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTPAndLogin() async {
    if (otpController.text.isEmpty) {
      error.value = 'Please enter verification code';
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      final response = await _authApi.phoneLoginVerify(
        phoneController.text,
        otpController.text,
      );

      // Handle login response
      Map<String, dynamic>? userData;
      String? role;
      List<String> roles = [];

      if (response.containsKey('user') && response.containsKey('roles')) {
        userData = response['user'] as Map<String, dynamic>?;
        roles =
            (response['roles'] as List?)?.map((e) => e.toString()).toList() ??
            [];
        if (roles.contains('PARENT')) {
          role = 'PARENT';
        } else if (roles.isNotEmpty) {
          role = roles.first;
        }
      }

      if (userData != null && role != null) {
        _auth.setUser(userData, role: role, roles: roles);

        switch (role.toUpperCase()) {
          case 'TEACHER':
            Get.offAllNamed(AppRoutes.teacher);
            break;
          case 'PARENT':
            Get.offAllNamed(AppRoutes.parent);
            break;
          case 'STUDENT':
            Get.offAllNamed(AppRoutes.student);
            break;
          case 'ADMIN':
            Get.offAllNamed(AppRoutes.admin);
            break;
          default:
            Get.offAllNamed(AppRoutes.login);
        }

        _connectWebSocket();
      } else {
        error.value =
            'No roles assigned to this account. Please complete registration first.';
      }
    } catch (e) {
      error.value = 'Invalid code or expired';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkSubscriptionAndNavigate(String role) async {
    _connectWebSocket();

    // Only check subscription for TEACHER and PARENT roles
    if (role != 'TEACHER' && role != 'PARENT') {
      _navigateToDashboard(role);
      return;
    }

    try {
      final subData = await _authApi.getSubscriptionStatus();
      final isActive = subData['is_active_subscription'] ?? false;

      if (!isActive) {
        Get.offAllNamed(AppRoutes.subscription);
      } else {
        _navigateToDashboard(role);
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      _navigateToDashboard(role);
    }
  }

  void _navigateToDashboard(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        Get.offAllNamed(AppRoutes.admin);
        break;
      case 'TEACHER':
        Get.offAllNamed(AppRoutes.teacher);
        break;
      case 'STUDENT':
        Get.offAllNamed(AppRoutes.student);
        break;
      case 'PARENT':
        Get.offAllNamed(AppRoutes.parent);
        break;
      default:
        Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      error.value = 'Please enter email and password';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      debugPrint('Attempting login to http://127.0.0.1:8000/api/users/login/');

      final response = await _authApi.login(
        emailController.text,
        passwordController.text,
      );

      debugPrint('Login response type: ${response.runtimeType}');
      debugPrint('Login response keys: ${response.keys.toList()}');
      debugPrint('Full response: $response');

      // Try to find user and role from response - check multiple formats
      Map<String, dynamic>? userData;
      String? role;
      List<String> roles = [];

      // Format 1: response has 'user' and 'role' directly
      if (response.containsKey('user') && response.containsKey('role')) {
        userData = response['user'] as Map<String, dynamic>?;
        role = response['role'] as String?;
        debugPrint('Found user and role in response format 1');
      }
      // Format 2: response has 'user' and 'roles' (array) like web
      else if (response.containsKey('user') && response.containsKey('roles')) {
        userData = response['user'] as Map<String, dynamic>?;
        roles =
            (response['roles'] as List?)?.map((e) => e.toString()).toList() ??
            [];
        // Prioritize PARENT role if available, otherwise use first role
        if (roles.contains('PARENT')) {
          role = 'PARENT';
        } else if (roles.isNotEmpty) {
          role = roles.first;
        }
        debugPrint(
          'Found user and roles in response format 2: roles=$roles, selected role: $role',
        );
      }
      // Format 3: response has nested structure
      else if (response.containsKey('data')) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data != null && data.containsKey('user')) {
          userData = data['user'] as Map<String, dynamic>?;
          if (data.containsKey('role')) {
            role = data['role'] as String?;
          } else if (data.containsKey('roles')) {
            roles =
                (data['roles'] as List?)?.map((e) => e.toString()).toList() ??
                [];
            if (roles.contains('PARENT')) {
              role = 'PARENT';
            } else if (roles.isNotEmpty) {
              role = roles.first;
            }
          }
        }
      }
      // Format 4: response has just user with role inside
      else if (response.containsKey('user')) {
        userData = response['user'] as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('role')) {
          role = userData['role'] as String?;
        }
      }

      // If we found user data and role, proceed
      if (userData != null && role != null && role.isNotEmpty) {
        // Save token for web if present in response
        if (response.containsKey('token')) {
          final apiProvider = Get.find<ApiProvider>();
          apiProvider.dio.options.headers['Authorization'] =
              'Bearer ${response['token']}';
          debugPrint('Saved token for web requests');
        }

        _auth.setUser(userData, role: role, roles: roles);
        _auth.setLoading(false);

        debugPrint(
          'Login successful with role: $role, roles: $roles, navigating to $role dashboard',
        );

        await _checkSubscriptionAndNavigate(role.toUpperCase());
      } else {
        debugPrint('Response does not have user or role. Response: $response');
        if (roles.isEmpty) {
          error.value =
              'No roles assigned. Please complete your profile registration.';
        } else {
          error.value = 'Invalid response from server';
        }
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Type: ${e.type}');
      debugPrint('Response: ${e.response?.data}');

      if (e.type == dio.DioExceptionType.connectionTimeout) {
        error.value =
            'Connection timeout - is the backend running on port 8000?';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        error.value = 'Cannot connect to server - check if backend is running';
      } else if (e.response?.statusCode == 401) {
        error.value = 'Invalid email or password';
      } else {
        error.value = 'Login failed (${e.response?.statusCode ?? "unknown"})';
      }
    } catch (e) {
      debugPrint('Login error: $e');
      error.value = 'Login failed';
    } finally {
      isLoading.value = false;
    }
  }

  void _connectWebSocket() {
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.connectChat();
      wsService.connectNotifications();
      debugPrint('WebSocket connected after login');
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    error.value = null;
    try {
      // Force fresh sign-in
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // For Android, we can use serverAuthCode to get a proper token
      final String? serverAuthCode = googleAuth.serverAuthCode;
      debugPrint('serverAuthCode: $serverAuthCode');

      // Use accessToken for backend verification
      final String? token = googleAuth.accessToken;

      debugPrint('Sending token: ${token?.substring(0, 30)}...');

      if (token == null) {
        error.value = 'Failed to get token';
        isLoading.value = false;
        return;
      }

      final response = await _authApi.googleLoginOnly(token);
      debugPrint('Google login response: $response');
      debugPrint('Response keys: ${response.keys.toList()}');

      Map<String, dynamic>? userData;
      String? role;
      List<String> roles = [];

      if (response.containsKey('user') && response.containsKey('roles')) {
        userData = response['user'] as Map<String, dynamic>?;
        roles =
            (response['roles'] as List?)?.map((e) => e.toString()).toList() ??
            [];
        debugPrint('User data: $userData');
        debugPrint('Roles: $roles');

        // Set role from roles list
        if (roles.contains('PARENT')) {
          role = 'PARENT';
        } else if (roles.contains('TEACHER')) {
          role = 'TEACHER';
        } else if (roles.contains('STUDENT')) {
          role = 'STUDENT';
        } else if (roles.contains('ADMIN')) {
          role = 'ADMIN';
        } else if (roles.isNotEmpty) {
          role = roles.first;
        }
        debugPrint('Selected role: $role');
      } else {
        debugPrint('Response does not contain user/roles keys');
        debugPrint('Full response: $response');
      }

      if (userData != null && role != null && role.isNotEmpty) {
        _auth.setUser(userData, role: role, roles: roles);

        // Save token for web
        if (kIsWeb && response.containsKey('access')) {
          final apiProvider = Get.find<ApiProvider>();
          await apiProvider.setWebToken(response['access']);
        }

        await _checkSubscriptionAndNavigate(role.toUpperCase());
      } else {
        debugPrint('Login failed - roles list: $roles');
        error.value =
            'No roles assigned. If you just signed up, please complete your profile registration first.';
      }
    } catch (e) {
      debugPrint('Google login error: $e');
      String errorMessage = 'Google sign in failed';
      if (e.toString().contains('404') ||
          e.toString().contains('No account found')) {
        errorMessage =
            'No account found with this Google email. Please sign up first.';
      } else if (e.toString().contains('detail')) {
        errorMessage = e.toString();
      }
      error.value = errorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> contactUs({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      await _authApi.contactUs(
        name: name,
        email: email,
        message: message,
      );
    } catch (e) {
      debugPrint('Contact Us error: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    // Don't dispose since controller is permanent
  }
}
