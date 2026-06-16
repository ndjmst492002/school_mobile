import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/parent_api.dart';
import '../../data/services/student_api.dart';
import '../../data/services/admin_api.dart';
import '../../data/services/websocket_service.dart';
import '../../data/models/parent_models.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';
import '../../data/exceptions.dart';

class ParentController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final ParentApi _parentApi = ParentApi();
  final StudentApi _studentApi = StudentApi();

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

  // Exercise search & assign
  final searchedExercises = <Exercise>[].obs;
  final isSearchingExercises = false.obs;
  final exerciseSearchError = ''.obs;
  final selectedChildForExercises = Rxn<int>();
  final exerciseLevelFilter = Rxn<String>();
  final exerciseClassFilter = ''.obs;
  final exerciseSkillFilter = <int>[].obs;
  final exerciseSkills = <Skill>[].obs;
  final assignedExerciseIds = <int>{}.obs;
  final assigningExerciseId = Rxn<int>();
  final childSubmissions = <Submission>[].obs;
  final isLoadingSubmissions = false.obs;
  final selectedChildForSubmissions = ''.obs;

  // Levels for parent exercise filter
  static const List<Map<String, dynamic>> _allLevelsData = [
    {'id': 1, 'name': '1AP'},
    {'id': 2, 'name': '2AP'},
    {'id': 3, 'name': '3AP'},
    {'id': 4, 'name': '4AP'},
    {'id': 5, 'name': '5AP'},
    {'id': 6, 'name': '1AM'},
    {'id': 7, 'name': '2AM'},
    {'id': 8, 'name': '3AM'},
    {'id': 9, 'name': '4AM'},
    {'id': 10, 'name': '1AS'},
    {'id': 11, 'name': '2AS'},
    {'id': 12, 'name': '3AS'},
  ];

  List<Level> get levels => _allLevelsData
      .map((e) => Level(id: e['id'] as int, name: e['name'] as String))
      .toList();

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
            'Profile Required'.tr,
            e.message.tr,
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

      // Auto-select first child for exercises if none selected (matching web behavior)
      if (childrenData.isNotEmpty && selectedChildForExercises.value == null) {
        setSelectedChildForExercises(childrenData.first.id);
      }

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

      final submissionsData = await _parentApi.getSubmissions().catchError((e) {
        debugPrint('Error loading submissions: $e');
        return <Submission>[];
      });
      childSubmissions.value = submissionsData;

      final notificationsData = await _parentApi.getNotifications().catchError((
        e,
      ) {
        debugPrint('Error loading notifications: $e');
        return <AppNotification>[];
      });
      notifications.value = notificationsData;
      loadExerciseSkills();
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
      debugPrint('Prediction features: ${result.featuresUsed}');
      setPrediction(studentId, result);
      debugPrint('Predictions map now: $predictions');
      Get.snackbar(
        'Success'.tr,
        'Prediction completed for ${result.studentName}'.tr,
      );
    } catch (e) {
      debugPrint('Error predicting student: $e');
      Get.snackbar('Error'.tr, 'Failed to get prediction: $e'.tr);
    } finally {
      predicting.value = null;
    }
  }

  List<String> get childNames => children.map((c) => c.fullName).toList();

  // --- Exercise Search & Assign ---
  void setSelectedChildForExercises(int? childId) {
    selectedChildForExercises.value = childId;
    if (childId != null) searchExercises();
  }

  void setExerciseLevelFilter(String? level) {
    exerciseLevelFilter.value = level;
    if (selectedChildForExercises.value != null) searchExercises();
  }

  void setExerciseClassFilter(String query) {
    exerciseClassFilter.value = query;
    if (selectedChildForExercises.value != null) searchExercises();
  }

  void toggleExerciseSkillFilter(int skillId) {
    if (exerciseSkillFilter.contains(skillId)) {
      exerciseSkillFilter.remove(skillId);
    } else {
      exerciseSkillFilter.add(skillId);
    }
    if (selectedChildForExercises.value != null) searchExercises();
  }

  Future<void> loadExerciseSkills() async {
    try {
      final result = await AdminApi().getSkills();
      exerciseSkills.value = result;
    } catch (e) {
      debugPrint('Error loading exercise skills: $e');
    }
  }

  Future<void> searchExercises() async {
    final childId = selectedChildForExercises.value;
    if (childId == null) return;

    isSearchingExercises.value = true;
    exerciseSearchError.value = '';
    try {
      final results = await _parentApi.searchExercises(
        studentId: childId,
        level: exerciseLevelFilter.value,
        className: exerciseClassFilter.value.isNotEmpty
            ? exerciseClassFilter.value
            : null,
        skillIds: exerciseSkillFilter.isNotEmpty
            ? exerciseSkillFilter.join(',')
            : null,
      );
      searchedExercises.value = results;
      assignedExerciseIds.assignAll(results
          .where((e) => e.isAssigned)
          .map((e) => e.id));
    } catch (e) {
      exerciseSearchError.value = 'Failed to load exercises: $e';
      debugPrint('Error searching exercises: $e');
    } finally {
      isSearchingExercises.value = false;
    }
  }

  Future<void> assignExerciseToChild(int exerciseId) async {
    final childId = selectedChildForExercises.value;
    if (childId == null) return;

    assigningExerciseId.value = exerciseId;
    try {
      await _parentApi.assignExercise(childId, exerciseId);
      assignedExerciseIds.add(exerciseId);
      Get.snackbar('Success'.tr, 'Exercise assigned successfully'.tr);
    } catch (e) {
      debugPrint('Error assigning exercise: $e');
      Get.snackbar('Error'.tr, 'Failed to assign exercise'.tr);
    } finally {
      assigningExerciseId.value = null;
    }
  }

  // --- Submissions ---
  void setSelectedChildForSubmissions(String? childName) {
    selectedChildForSubmissions.value = childName ?? '';
  }

  Future<void> loadSubmissions() async {
    isLoadingSubmissions.value = true;
    try {
      final results = await _parentApi.getSubmissions();
      childSubmissions.value = results;
    } catch (e) {
      debugPrint('Error loading submissions: $e');
    } finally {
      isLoadingSubmissions.value = false;
    }
  }

  // Parent submits file on behalf of child
  final selectedSubmitFile = Rxn<PlatformFile>();
  final selectedSubmitExerciseId = Rxn<int>();
  final isSubmitting = false.obs;

  Future<void> pickSubmitFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        selectedSubmitFile.value = result.files.first;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void clearSubmitFile() {
    selectedSubmitFile.value = null;
  }

  Future<void> submitForChild(int exerciseId, int studentId) async {
    if (selectedSubmitFile.value == null) return;

    isSubmitting.value = true;
    try {
      final file = selectedSubmitFile.value!;
      String? filePath;
      Uint8List? fileBytes;
      String? fileName;

      if (kIsWeb) {
        fileBytes = file.bytes;
        fileName = file.name;
      } else {
        filePath = file.path;
      }

      await _studentApi.submitExercise(
        exerciseId: exerciseId,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        studentId: studentId,
      );
      selectedSubmitFile.value = null;
      Get.snackbar('Success'.tr, 'Exercise submitted successfully'.tr);
      loadSubmissions();
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to submit exercise'.tr);
    } finally {
      isSubmitting.value = false;
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
        debugPrint(
          'About to navigate to student dashboard with childId: $childId',
        );
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
