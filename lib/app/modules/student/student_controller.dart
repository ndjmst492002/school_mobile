import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/student_api.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';
import '../../data/exceptions.dart';

class StudentController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final StudentApi _studentApi = StudentApi();

  final classes = <ClassModel>[].obs;
  final exercises = <Exercise>[].obs;
  final submissions = <Submission>[].obs;
  final announcements = <Announcement>[].obs;
  final attendance = <AttendanceRecord>[].obs;
  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final enrolling = Rxn<int>();
  final selectedExercise = Rxn<Exercise>();
  final selectedSubmitFile = Rxn<PlatformFile>();
  final isSubmitting = false.obs;
  final activeTab = 'class-enrollment'.obs;
  final profileNotFound = false.obs;
  final searchQuery = ''.obs;
  final enrollmentFilter = 'all'.obs; // 'all', 'enrolled', 'not_enrolled'

  List<ClassModel> get filteredClasses {
    var result = classes.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where(
            (cls) =>
                cls.name.toLowerCase().contains(query) ||
                cls.description.toLowerCase().contains(query) ||
                (cls.teacherName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    // Apply enrollment filter
    if (enrollmentFilter.value == 'enrolled') {
      result = result.where((cls) => isEnrolled(cls.id)).toList();
    } else if (enrollmentFilter.value == 'not_enrolled') {
      result = result.where((cls) => !isEnrolled(cls.id)).toList();
    }

    return result;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setEnrollmentFilter(String filter) {
    enrollmentFilter.value = filter;
  }

  AuthService get _auth => Get.find<AuthService>();
  ThemeService get _theme => Get.find<ThemeService>();
  String get userName => _auth.userFullName;
  int get userId => _auth.userId;

  bool get isDarkMode => _theme.isDarkMode;
  String get currentLanguage => _theme.locale.languageCode;

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  int get enrolledCount => classes
      .where((c) => c.students?.any((s) => s.id == userId) ?? false)
      .length;

  int get presentCount => attendance.where((a) => a.status == 'PRESENT').length;
  int get absentCount => attendance.where((a) => a.status == 'ABSENT').length;

  void toggleLanguage() {
    _theme.toggleLanguage();
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
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
      case 'PARENT':
        Get.offAllNamed(AppRoutes.parent);
        break;
      case 'ADMIN':
        Get.offAllNamed(AppRoutes.admin);
        break;
      default:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    profileNotFound.value = false;
    try {
      debugPrint('Loading student data...');
      final results = await Future.wait([
        _studentApi.getAllClasses(),
        _studentApi.getExercises(),
        _studentApi.getSubmissions(),
        _studentApi.getAnnouncements(),
        _studentApi.getAttendance(),
        _studentApi.getNotifications(),
      ]);
      classes.value = results[0] as List<ClassModel>;
      exercises.value = results[1] as List<Exercise>;
      submissions.value = results[2] as List<Submission>;
      announcements.value = results[3] as List<Announcement>;
      attendance.value = results[4] as List<AttendanceRecord>;
      notifications.value = results[5] as List<AppNotification>;
      debugPrint(
        'Loaded ${attendance.length} attendance records, ${notifications.length} notifications',
      );
    } on ProfileNotFoundException catch (e) {
      debugPrint('Profile not found: ${e.message}');
      profileNotFound.value = true;
      Get.snackbar(
        'Profile Required',
        e.message,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isEnrolled(int classId) {
    final cls = classes.firstWhereOrNull((c) => c.id == classId);
    if (cls?.enrollmentStatus != null) {
      return cls!.enrollmentStatus!.status == 'APPROVED';
    }
    return cls?.students?.any((s) => s.id == userId) ?? false;
  }

  String getEnrollmentStatus(int classId) {
    final cls = classes.firstWhereOrNull((c) => c.id == classId);
    if (cls?.enrollmentStatus != null) {
      return cls!.enrollmentStatus!.status;
    }
    if (isEnrolled(classId)) return 'APPROVED';
    return 'NOT_ENROLLED';
  }

  bool isPending(int classId) {
    return getEnrollmentStatus(classId) == 'PENDING';
  }

  bool isRejected(int classId) {
    return getEnrollmentStatus(classId) == 'REJECTED';
  }

  Future<void> enrollInClass(int classId) async {
    enrolling.value = classId;
    try {
      await _studentApi.enrollInClass(classId);
      loadData();
      Get.snackbar('Success', 'Enrolled in class successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to enroll in class');
    } finally {
      enrolling.value = null;
    }
  }

  bool isSubmitted(int exerciseId) {
    return submissions.any((s) => s.exercise == exerciseId);
  }

  Submission? getSubmission(int exerciseId) {
    return submissions.firstWhereOrNull((s) => s.exercise == exerciseId);
  }

  bool isOverdue(Exercise exercise) {
    if (exercise.dueDate == null) return false;
    try {
      final dueDate = DateTime.parse(exercise.dueDate!);
      return dueDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  String downloadExerciseUrl(int exerciseId) {
    return _studentApi.downloadExerciseUrl(exerciseId);
  }

  // FIXED: Now works on both web and mobile
  Future<void> downloadExercise(int exerciseId) async {
    final url = downloadExerciseUrl(exerciseId);
    debugPrint('Download URL: $url');

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open download link');
    }
  }

  void openSubmitDialog(Exercise exercise) {
    selectedExercise.value = exercise;
    selectedSubmitFile.value = null;
  }

  void closeSubmitDialog() {
    selectedExercise.value = null;
    selectedSubmitFile.value = null;
  }

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

  Future<void> submitExercise() async {
    if (selectedExercise.value == null || selectedSubmitFile.value == null)
      return;

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
        exerciseId: selectedExercise.value!.id,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      closeSubmitDialog();
      loadData();
      Get.snackbar('Success', 'Exercise submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit exercise');
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
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _studentApi.markNotificationAsRead(notificationId);
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
        await _studentApi.markNotificationAsRead(notification.id);
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
}
