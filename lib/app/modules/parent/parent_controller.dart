import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/parent_api.dart';
import '../../data/models/parent_models.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';

class ParentController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final ParentApi _parentApi = ParentApi();

  final children = <StudentChild>[].obs;
  final announcements = <ChildAnnouncement>[].obs;
  final attendance = <ChildAttendance>[].obs;
  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final showChat = false.obs;
  final unreadMessageCount = 0.obs;

  final activeTab = 'my-children'.obs;
  final selectedChildForAnnouncements = ''.obs;
  final selectedChildForAttendance = ''.obs;
  final predictions = <int, PredictionResult>{}.obs;
  final predicting = Rxn<int>();

  bool hasPrediction(int studentId) => predictions.containsKey(studentId);
  PredictionResult? getPrediction(int studentId) => predictions[studentId];

  void setPrediction(int studentId, PredictionResult result) {
    final newPredictions = Map<int, PredictionResult>.from(predictions);
    newPredictions[studentId] = result;
    predictions.value = newPredictions;
    debugPrint(
      'Prediction set for student $studentId: ${result.prediction}, all predictions: $predictions',
    );
  }

  AuthService get _auth => Get.find<AuthService>();
  ThemeService get _theme => Get.find<ThemeService>();
  String get userName => _auth.userFullName;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  bool get isDarkMode => _theme.isDarkMode;
  String get currentLanguage => _theme.locale.languageCode;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadUnreadMessageCount();
  }

  Future<void> loadUnreadMessageCount() async {
    try {
      final count = await _parentApi.getUnreadMessageCount();
      unreadMessageCount.value = count;
    } catch (e) {
      debugPrint('Error loading unread message count: $e');
    }
  }

  void updateUnreadMessageCount(int count) {
    unreadMessageCount.value = count.clamp(0, 999);
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _parentApi.getChildren(),
        _parentApi.getAnnouncements(),
        _parentApi.getAttendance(),
        _parentApi.getNotifications(),
      ]);
      children.value = results[0] as List<StudentChild>;
      announcements.value = results[1] as List<ChildAnnouncement>;
      attendance.value = results[2] as List<ChildAttendance>;
      notifications.value = results[3] as List<AppNotification>;
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _parentApi.markNotificationAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = AppNotification(
          id: notifications[index].id,
          recipient: notifications[index].recipient,
          type: notifications[index].type,
          title: notifications[index].title,
          message: notifications[index].message,
          isRead: true,
          createdAt: notifications[index].createdAt,
        );
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      for (var notification in notifications.where((n) => !n.isRead)) {
        await _parentApi.markNotificationAsRead(notification.id);
      }
      notifications.value = notifications
          .map(
            (n) => AppNotification(
              id: n.id,
              recipient: n.recipient,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  void toggleChat() {
    showChat.value = !showChat.value;
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  void setSelectedChildForAnnouncements(String childName) {
    selectedChildForAnnouncements.value = childName;
  }

  void setSelectedChildForAttendance(String childName) {
    selectedChildForAttendance.value = childName;
  }

  void toggleLanguage() {
    _theme.toggleLanguage();
  }

  void toggleDarkMode() {
    _theme.toggleTheme();
  }

  Future<void> predictStudent(int studentId) async {
    predicting.value = studentId;
    try {
      debugPrint('Calling predict API for student: $studentId');
      final result = await _parentApi.predictStudent(studentId);
      debugPrint('Prediction result: $result');
      debugPrint('Prediction prediction: ${result.prediction}');
      debugPrint('Prediction confidence: ${result.confidence}');
      setPrediction(studentId, result);
      debugPrint('Predictions map now: $predictions');
      Get.snackbar('Success', 'Prediction completed for ${result.studentName}');
    } catch (e) {
      debugPrint('Error predicting student: $e');
      Get.snackbar('Error', 'Failed to get prediction: $e');
    } finally {
      predicting.value = null;
    }
  }

  List<String> get childNames => children.map((c) => c.fullName).toList();

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // Continue even if logout fails
    }
    _auth.logout();
    Get.offAllNamed(AppRoutes.login);
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
      case 'ADMIN':
        Get.offAllNamed(AppRoutes.admin);
        break;
      default:
        break;
    }
  }
}
