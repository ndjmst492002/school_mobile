import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthApi _authApi = AuthApi();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final showPassword = false.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  AuthService get _auth => Get.find<AuthService>();

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
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
      } else {
        debugPrint('Response does not have user or role. Response: $response');
        error.value = 'Invalid response from server';
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

  @override
  void onClose() {
    // Don't dispose since controller is permanent
  }
}
