import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/parent_api.dart';
import '../../data/services/websocket_service.dart';
import '../../data/models/parent_models.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';
import '../../data/exceptions.dart';

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
  final profileNotFound = false.obs;

  final activeTab = 'my-children'.obs;
  final selectedChildForAnnouncements = ''.obs;
  final selectedChildForAttendance = ''.obs;
  final selectedChildForProfile = ''.obs;
  final predictions = <int, PredictionResult>{}.obs;
  final predicting = Rxn<int>();

  List<ChildAnnouncement> get filteredAnnouncements {
    if (selectedChildForAnnouncements.value.isEmpty) {
      return announcements;
    }
    return announcements
        .where((a) => a.childName == selectedChildForAnnouncements.value)
        .toList();
  }

  List<ChildAttendance> get filteredAttendance {
    if (selectedChildForAttendance.value.isEmpty) {
      return attendance;
    }
    return attendance
        .where((a) => a.childName == selectedChildForAttendance.value)
        .toList();
  }

  void selectChildForAnnouncements(String childName) {
    selectedChildForAnnouncements.value = childName;
  }

  void selectChildForAttendance(String childName) {
    selectedChildForAttendance.value = childName;
  }

  void selectChildForProfile(String childName) {
    selectedChildForProfile.value = childName;
  }

  void clearChildSelection() {
    selectedChildForProfile.value = '';
  }

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
    _initWebSocketListeners();
  }

  void _initWebSocketListeners() {
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.notificationCountStream.listen((int count) {
        _refreshNotifications();
      });
      wsService.chatUnreadCountStream.listen((int count) {
        unreadMessageCount.value = count;
      });
    } catch (e) {
      debugPrint('WebSocket listeners error: $e');
    }
  }

  Future<void> _refreshNotifications() async {
    try {
      final data = await _parentApi.getNotifications();
      notifications.value = data;
    } catch (e) {
      debugPrint('Error refreshing notifications: $e');
    }
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
    profileNotFound.value = false;
    try {
      // Load children first to debug
      final childrenData = await _parentApi.getChildren().catchError((e) {
        if (e is ProfileNotFoundException) {
          profileNotFound.value = true;
          Get.snackbar(
            'Profile Required',
            e.message,
            duration: const Duration(seconds: 5),
          );
          return <StudentChild>[];
        }
        debugPrint('Error loading children: $e');
        return <StudentChild>[];
      });
      children.value = childrenData;
      debugPrint('=== DEBUG ===');
      debugPrint('Children count: ${children.length}');
      debugPrint('User roles: ${_auth.roles}');
      debugPrint('Has STUDENT role: ${_auth.roles.contains('STUDENT')}');
      for (var child in children) {
        debugPrint('Child: ${child.id} - ${child.fullName}');
      }
      debugPrint('=== END DEBUG ===');

      // Load other data
      final announcementsData = await _parentApi.getAnnouncements().catchError((
        e,
      ) {
        if (e is ProfileNotFoundException) {
          profileNotFound.value = true;
          return <ChildAnnouncement>[];
        }
        debugPrint('Error loading announcements: $e');
        return <ChildAnnouncement>[];
      });
      announcements.value = announcementsData;

      final attendanceData = await _parentApi.getAttendance().catchError((e) {
        if (e is ProfileNotFoundException) {
          profileNotFound.value = true;
          return <ChildAttendance>[];
        }
        debugPrint('Error loading attendance: $e');
        return <ChildAttendance>[];
      });
      attendance.value = attendanceData;

      final notificationsData = await _parentApi.getNotifications().catchError((
        e,
      ) {
        debugPrint('Error loading notifications: $e');
        return <AppNotification>[];
      });
      notifications.value = notificationsData;
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
    debugPrint('toggleLanguage called, current: $_theme.locale');
    _theme.toggleLanguage();
    debugPrint('After toggle, new locale: $_theme.locale');
  }

  void toggleDarkMode() {
    debugPrint('toggleDarkMode called, current: $_theme.isDarkMode');
    _theme.toggleTheme();
    debugPrint('After toggle, new: $_theme.isDarkMode');
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
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.disconnectAll();
    } catch (e) {
      debugPrint('WebSocket disconnect error: $e');
    }
    Get.offAllNamed(AppRoutes.login);
  }

  void switchToRole(String role) {
    debugPrint('=== switchToRole called with: $role ===');
    // Handle switching to a specific child (format: student_123)
    if (role.startsWith('student_')) {
      final childIdStr = role.replaceFirst('student_', '');
      final childId = int.tryParse(childIdStr);
      debugPrint('Switching to child with ID: $childId');
      if (childId != null) {
        final child = children.firstWhereOrNull((c) => c.id == childId);
        _auth.switchRole('STUDENT');
        debugPrint('About to navigate to student dashboard with childId: $childId');
        Get.offAllNamed(
          AppRoutes.student,
          arguments: {'childId': childId, 'childName': child?.fullName},
        );
      } else {
        _auth.switchRole('STUDENT');
        Get.offAllNamed(AppRoutes.student);
      }
      return;
    }

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
