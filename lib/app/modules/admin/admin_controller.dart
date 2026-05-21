import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/parent_api.dart';
import '../../data/services/websocket_service.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';

class AdminController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final ParentApi _parentApi = ParentApi();

  final notifications = <AppNotification>[].obs;
  final unreadNotificationCount = 0.obs;
  final isLoading = true.obs;

  AuthService get _auth => Get.find<AuthService>();
  ThemeService get _theme => Get.find<ThemeService>();

  String get userName => _auth.userFullName;
  bool get isAdmin => _auth.role == 'ADMIN';
  bool get isDarkMode => _theme.isDarkMode;
  String get currentLanguage => _theme.locale.languageCode;

  int get unreadMessageCount => 0;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await _parentApi.getNotifications();
      notifications.value = data;
      unreadNotificationCount.value = data.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void toggleLanguage() {
    _theme.toggleLanguage();
  }

  void toggleDarkMode() {
    _theme.toggleTheme();
  }

  void switchToRole(String role) {
    _auth.switchRole(role);
    switch (role.toUpperCase()) {
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
        break;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // Continue even if logout fails
    }
    _auth.logout();
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.disconnectAll();
    } catch (e) {
      debugPrint('WebSocket disconnect error: $e');
    }
    Get.offAllNamed(AppRoutes.login);
  }
}
