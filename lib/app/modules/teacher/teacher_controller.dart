import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/teacher_api.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';
import '../../data/exceptions.dart';

class TeacherController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final TeacherApi _teacherApi = TeacherApi();

  final classes = <ClassModel>[].obs;
  final exercises = <Exercise>[].obs;
  final submissions = <Submission>[].obs;
  final announcements = <Announcement>[].obs;
  final attendance = <AttendanceRecord>[].obs;
  final notifications = <AppNotification>[].obs;
  final enrollments = <EnrollmentRequest>[].obs;
  final skills = <Skill>[].obs;
  final isLoading = true.obs;
  final showUploadForm = false.obs;
  final showAnnouncementForm = false.obs;
  final showChat = false.obs;
  final showAttendanceForm = false.obs;
  final gradingSubmission = Rxn<Submission>();
  final isGrading = false.obs;
  final isUploading = false.obs;
  final isPosting = false.obs;
  final isSavingAttendance = false.obs;
  final selectedFile = Rxn<PlatformFile>();
  final unreadMessageCount = 0.obs;
  final unreadNotificationCount = 0.obs;
  final respondingEnrollment = Rxn<int>();
  final profileNotFound = false.obs;

  final activeTab = 'my-classes'.obs;
  final uploadClassId = ''.obs;
  final announcementClassId = ''.obs;
  final attendanceClassId = ''.obs;
  final attendanceDateController = TextEditingController();
  final attendanceRecords = <int, String>{}.obs;
  final isLoadingAttendance = false.obs;
  final showLoadStudentsButton = true.obs;
  final selectedSkills = <int>[].obs;

  final uploadTitleController = TextEditingController();
  final uploadDescController = TextEditingController();
  final uploadDueDateController = TextEditingController();
  final announcementTitleController = TextEditingController();
  final announcementContentController = TextEditingController();
  final gradeController = TextEditingController();
  final feedbackController = TextEditingController();

  AuthService get _auth => Get.find<AuthService>();
  ThemeService get _theme => Get.find<ThemeService>();
  String get userName => _auth.userFullName;

  bool get isDarkMode => _theme.isDarkMode;
  String get currentLanguage => _theme.locale.languageCode;

  int get totalStudents =>
      classes.fold(0, (sum, cls) => sum + cls.studentCount);
  int get pendingCount => submissions.where((s) => s.grade == null).length;

  @override
  void onInit() {
    super.onInit();
    attendanceDateController.text = DateTime.now().toString().split(' ')[0];
    loadData();
    loadUnreadMessageCount();
    loadNotifications();
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  void toggleLanguage() {
    _theme.toggleLanguage();
  }

  void toggleDarkMode() {
    _theme.toggleTheme();
  }

  void toggleSkill(int skillId) {
    if (selectedSkills.contains(skillId)) {
      selectedSkills.remove(skillId);
    } else {
      selectedSkills.add(skillId);
    }
  }

  void addSkill(int skillId) {
    if (!selectedSkills.contains(skillId)) {
      selectedSkills.add(skillId);
    }
  }

  void removeSkill(int skillId) {
    selectedSkills.remove(skillId);
  }

  @override
  void onClose() {
    uploadTitleController.dispose();
    uploadDescController.dispose();
    uploadDueDateController.dispose();
    announcementTitleController.dispose();
    announcementContentController.dispose();
    gradeController.dispose();
    feedbackController.dispose();
    attendanceDateController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    profileNotFound.value = false;
    try {
      debugPrint('Loading teacher data...');
      final results = await Future.wait([
        _teacherApi.getClasses(),
        _teacherApi.getExercises(),
        _teacherApi.getSubmissions(),
        _teacherApi.getAnnouncements(),
        _teacherApi.getEnrollments(),
        _teacherApi.getSkills(),
      ]);
      classes.value = results[0] as List<ClassModel>;
      exercises.value = results[1] as List<Exercise>;
      submissions.value = results[2] as List<Submission>;
      announcements.value = results[3] as List<Announcement>;
      enrollments.value = results[4] as List<EnrollmentRequest>;
      skills.value = results[5] as List<Skill>;
      debugPrint(
        'Loaded ${classes.length} classes, ${exercises.length} exercises, ${enrollments.length} enrollments',
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
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToEnrollment(int enrollmentId, String action) async {
    respondingEnrollment.value = enrollmentId;
    try {
      await _teacherApi.respondToEnrollment(enrollmentId, action);
      loadData();
      Get.snackbar('Success', 'Enrollment ${action}ed successfully');
    } catch (e) {
      debugPrint('Error responding to enrollment: $e');
      Get.snackbar('Error', 'Failed to respond to enrollment');
    } finally {
      respondingEnrollment.value = null;
    }
  }

  void toggleUploadForm() {
    showUploadForm.value = !showUploadForm.value;
    if (!showUploadForm.value) {
      uploadTitleController.clear();
      uploadDescController.clear();
      uploadDueDateController.clear();
      uploadClassId.value = '';
      selectedFile.value = null;
    }
  }

  void toggleAnnouncementForm() {
    showAnnouncementForm.value = !showAnnouncementForm.value;
    if (!showAnnouncementForm.value) {
      announcementTitleController.clear();
      announcementContentController.clear();
      announcementClassId.value = '';
    }
  }

  void toggleChat() {
    showChat.value = !showChat.value;
  }

  Future<void> loadUnreadMessageCount() async {
    try {
      final count = await _teacherApi.getUnreadMessageCount();
      debugPrint('Loaded unread message count: $count');
      unreadMessageCount.value = count;
    } catch (e) {
      debugPrint('Error loading unread message count: $e');
    }
  }

  void updateUnreadMessageCount(int count) {
    debugPrint('updateUnreadMessageCount called with: $count');
    unreadMessageCount.value = count.clamp(0, 999);
    debugPrint('unreadMessageCount.value is now: ${unreadMessageCount.value}');
  }

  Future<void> loadNotifications() async {
    try {
      final results = await Future.wait([
        _teacherApi.getNotifications(),
        _teacherApi.getUnreadNotificationCount(),
      ]);
      notifications.value = results[0] as List<AppNotification>;
      unreadNotificationCount.value = results[1] as int;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void markAllNotificationsAsRead() {
    for (var notification in notifications) {
      if (!notification.isRead) {
        _teacherApi.markNotificationAsRead(notification.id).catchError((e) {
          debugPrint('Error marking notification as read: $e');
        });
      }
    }
    unreadNotificationCount.value = 0;
    notifications.value = notifications
        .map(
          (n) => AppNotification(
            id: n.id,
            recipient: n.recipient,
            type: n.type,
            title: n.title,
            message: n.message,
            createdAt: n.createdAt,
            isRead: true,
          ),
        )
        .toList();
  }

  void toggleAttendanceForm() {
    showAttendanceForm.value = !showAttendanceForm.value;
    if (!showAttendanceForm.value) {
      attendanceClassId.value = '';
      attendanceRecords.clear();
    }
  }

  Future<void> loadAttendance() async {
    if (attendanceClassId.value.isEmpty) return;

    isLoadingAttendance.value = true;
    try {
      final classId = int.parse(attendanceClassId.value);
      final date = attendanceDateController.text;
      final records = await _teacherApi.getAttendance(classId, date);
      attendance.value = records;

      attendanceRecords.clear();
      for (var record in records) {
        attendanceRecords[record.student] = record.status;
      }

      final cls = classes.firstWhereOrNull((c) => c.id == classId);
      if (cls != null) {
        for (var student in cls.students ?? []) {
          if (!attendanceRecords.containsKey(student.id)) {
            attendanceRecords[student.id] = 'PRESENT';
          }
        }
      }
      showLoadStudentsButton.value = false;
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  Future<void> saveAttendance() async {
    if (attendanceClassId.value.isEmpty || attendanceRecords.isEmpty) return;

    isSavingAttendance.value = true;
    try {
      final records = attendanceRecords.entries
          .map(
            (entry) => {
              'student_id': entry.key,
              'class_id': int.parse(attendanceClassId.value),
              'date': attendanceDateController.text,
              'status': entry.value,
            },
          )
          .toList();

      await _teacherApi.markAttendance(records);
      await loadAttendance();
      Get.snackbar('Success', 'Attendance saved successfully');
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      Get.snackbar('Error', 'Failed to save attendance');
    } finally {
      isSavingAttendance.value = false;
    }
  }

  void setStudentAttendance(int studentId, String status) {
    attendanceRecords[studentId] = status;
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        selectedFile.value = result.files.first;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> uploadExercise() async {
    if (selectedFile.value == null || uploadClassId.value.isEmpty) {
      Get.snackbar('Error', 'Please select a file and class');
      return;
    }

    isUploading.value = true;
    try {
      debugPrint(
        'Uploading exercise: title=${uploadTitleController.text}, classId=${uploadClassId.value}',
      );

      final file = selectedFile.value!;
      String? filePath;
      Uint8List? fileBytes;
      String? fileName;

      if (kIsWeb) {
        fileBytes = file.bytes;
        fileName = file.name;
      } else {
        filePath = file.path;
      }

      await _teacherApi.createExercise(
        title: uploadTitleController.text,
        description: uploadDescController.text,
        classId: int.parse(uploadClassId.value),
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        dueDate: uploadDueDateController.text.isNotEmpty
            ? uploadDueDateController.text
            : null,
      );
      toggleUploadForm();
      loadData();
      Get.snackbar('Success', 'Exercise uploaded successfully');
    } catch (e) {
      debugPrint('Error uploading exercise: $e');
      Get.snackbar('Error', 'Failed to upload exercise: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void openGradingDialog(Submission submission) {
    gradingSubmission.value = submission;
    gradeController.text = submission.grade?.toString() ?? '';
    feedbackController.text = submission.feedback ?? '';
  }

  void closeGradingDialog() {
    gradingSubmission.value = null;
    gradeController.clear();
    feedbackController.clear();
  }

  Future<void> gradeSubmission() async {
    if (gradingSubmission.value == null || gradeController.text.isEmpty) return;

    final grade = double.tryParse(gradeController.text);
    if (grade == null || grade < 0 || grade > 20) {
      Get.snackbar('Error', 'Grade must be between 0 and 20');
      return;
    }

    isGrading.value = true;
    try {
      await _teacherApi.gradeSubmission(
        gradingSubmission.value!.id,
        grade,
        feedbackController.text,
      );
      closeGradingDialog();
      loadData();
      Get.snackbar('Success', 'Grade saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to grade submission');
    } finally {
      isGrading.value = false;
    }
  }

  void updateUploadClassId(String value) => uploadClassId.value = value;
  void updateAnnouncementClassId(String value) =>
      announcementClassId.value = value;
  void updateAttendanceClassId(String value) => attendanceClassId.value = value;

  Future<void> createAnnouncement() async {
    if (announcementTitleController.text.isEmpty ||
        announcementContentController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in both title and content');
      return;
    }

    isPosting.value = true;
    try {
      debugPrint(
        'Creating announcement: title=${announcementTitleController.text}',
      );
      final classId = announcementClassId.value.isNotEmpty
          ? int.tryParse(announcementClassId.value)
          : null;
      await _teacherApi.createAnnouncement(
        title: announcementTitleController.text,
        content: announcementContentController.text,
        classId: classId,
      );
      toggleAnnouncementForm();
      loadData();
      Get.snackbar('Success', 'Announcement posted successfully');
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      Get.snackbar('Error', 'Failed to create announcement: $e');
    } finally {
      isPosting.value = false;
    }
  }

  String downloadSubmissionUrl(int submissionId) {
    return _teacherApi.downloadSubmissionUrl(submissionId);
  }

  Future<void> downloadSubmission(int submissionId) async {
    final url = downloadSubmissionUrl(submissionId);
    debugPrint('Download URL: $url');

    final submission = submissions.firstWhereOrNull(
      (s) => s.id == submissionId,
    );
    if (submission == null) {
      Get.snackbar('Error', 'Submission not found');
      return;
    }

    if (submission.submissionFileUrl == null) {
      Get.snackbar('Error', 'No file attached to this submission');
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open download link');
    }
  }

  String downloadExerciseUrl(int exerciseId) {
    return _teacherApi.downloadExerciseUrl(exerciseId);
  }

  Future<void> downloadExercise(int exerciseId) async {
    final url = downloadExerciseUrl(exerciseId);
    debugPrint('Download Exercise URL: $url');

    final exercise = exercises.firstWhereOrNull((e) => e.id == exerciseId);
    if (exercise == null) {
      Get.snackbar('Error', 'Exercise not found');
      return;
    }

    if (exercise.fileUrl == null) {
      Get.snackbar('Error', 'No file attached to this exercise');
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open download link');
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

  void switchToRole(String role) {
    _auth.switchRole(role);
    switch (role.toUpperCase()) {
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
        break;
    }
  }
}
