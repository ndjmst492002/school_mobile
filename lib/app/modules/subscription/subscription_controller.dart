import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/websocket_service.dart';
import '../../data/providers/api_provider.dart';
import '../../routes/app_routes.dart';
import 'subscription_webview.dart';

class SubscriptionController extends GetxController {
  final AuthApi _authApi = AuthApi();

  final isLoading = false.obs;
  final error = Rxn<String>();
  final selectedPlan = ''.obs;
  Timer? _checkTimer;

  String get planType {
    final auth = Get.find<AuthService>();
    final roles = auth.roles;
    final hasTeacher = roles.contains('TEACHER');
    final hasParent = roles.contains('PARENT');

    if (hasTeacher && hasParent) {
      return 'TEACHER_PARENT';
    } else if (hasTeacher) {
      return 'TEACHER_ONLY';
    } else if (hasParent) {
      return 'PARENT_ONLY';
    }
    return 'PARENT_ONLY';
  }

  String get planName {
    switch (planType) {
      case 'TEACHER_PARENT':
        return 'Teacher + Parent Plan';
      case 'TEACHER_ONLY':
        return 'Teacher Plan';
      case 'PARENT_ONLY':
        return 'Parent Plan';
      default:
        return 'Parent Plan';
    }
  }

  String get planPrice {
    switch (planType) {
      case 'TEACHER_PARENT':
        return '5,000 DZD';
      case 'TEACHER_ONLY':
        return '3,000 DZD';
      case 'PARENT_ONLY':
        return '2,000 DZD';
      default:
        return '2,000 DZD';
    }
  }

  @override
  void onInit() {
    super.onInit();
    selectedPlan.value = planType;
    _startCheckingSubscription();
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    super.onClose();
  }

  void _startCheckingSubscription() {
    int attempts = 0;
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      attempts++;
      if (attempts > 60) {
        timer.cancel();
        return;
      }
      await checkSubscriptionStatus();
    });
  }

  AuthApi get authApi => _authApi;

  Future<void> subscribe() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      debugPrint('Creating subscription for plan: ${selectedPlan.value}');
      final response = await _authApi.createSubscription(selectedPlan.value);

      if (response.containsKey('checkout_url') && response['checkout_url'] != null && response['checkout_url'].isNotEmpty) {
        debugPrint('Received checkout URL: ${response['checkout_url']}');

        if (kIsWeb) {
          final uri = Uri.parse(response['checkout_url']);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            Get.snackbar(
              'Payment',
              'Complete payment in your browser, then wait a moment to be redirected back',
              duration: const Duration(seconds: 4),
            );
          } else {
            error.value = 'Could not open payment page';
          }
        } else {
          isLoading.value = false;
          await Get.to(
            () => SubscriptionWebView(
              url: response['checkout_url'],
              onComplete: () {
                Get.close(1);
                Get.snackbar(
                  'Payment',
                  'Payment completed. Checking subscription status...',
                  duration: const Duration(seconds: 3),
                );
              },
            ),
            fullscreenDialog: true,
          );
          return;
        }
      } else {
        error.value = 'Failed to create checkout';
      }
    } catch (e) {
      debugPrint('Subscription error: $e');
      error.value = 'Failed to create subscription';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {}
    final auth = Get.find<AuthService>();
    auth.logout();
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.disconnectAll();
    } catch (e) {}
    Get.offAllNamed('/login');
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      final response = await _authApi.getSubscriptionStatus();
      final isActive = response['is_active_subscription'] ?? false;

      if (isActive) {
        _navigateToDashboard();
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    }
  }

  void _navigateToDashboard() {
    final auth = Get.find<AuthService>();
    final role = auth.role;

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
        Get.offAllNamed(AppRoutes.login);
    }
  }
}