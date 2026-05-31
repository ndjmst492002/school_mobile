import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/admin_api.dart';
import '../../data/services/student_api.dart';
import '../../data/services/websocket_service.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../../main.dart';

class AdminController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final AdminApi _adminApi = AdminApi();

  final notifications = <AppNotification>[].obs;
  final unreadNotificationCount = 0.obs;
  final isLoading = true.obs;

  // Exercise management
  final exercises = <Exercise>[].obs;
  final exerciseRequests = <Exercise>[].obs;
  final skills = <Skill>[].obs;
  final classCount = 0.obs;
  final activeTab = 'overview'.obs;

  // Exercise upload form
  final uploadTitle = ''.obs;
  final uploadDescription = ''.obs;
  final selectedLevelId = Rxn<int>();
  final selectedClassId = Rxn<int>();
  final selectedFile = Rxn<PlatformFile>();
  final isUploading = false.obs;
  final selectedSkills = <int>[].obs;
  final levelClasses = <ClassModel>[].obs;

  // Moderation
  final moderating = Rxn<int>();

  // Stats
  final exerciseCount = 0.obs;
  final pendingCount = 0.obs;
  final approvedCount = 0.obs;

  AuthService get _auth => Get.find<AuthService>();
  ThemeService get _theme => Get.find<ThemeService>();

  String get userName => _auth.userFullName;
  bool get isAdmin => _auth.role == 'ADMIN';
  bool get isDarkMode => _theme.isDarkMode;
  String get currentLanguage => _theme.locale.languageCode;
  List<String> get roles => _auth.roles;
  String get currentRole => _auth.role;

  int get unreadMessageCount => 0;

  static const List<Map<String, dynamic>> _allLevelsData = [
    {'id': 1, 'name': '1AP'}, {'id': 2, 'name': '2AP'},
    {'id': 3, 'name': '3AP'}, {'id': 4, 'name': '4AP'},
    {'id': 5, 'name': '5AP'}, {'id': 6, 'name': '1AM'},
    {'id': 7, 'name': '2AM'}, {'id': 8, 'name': '3AM'},
    {'id': 9, 'name': '4AM'}, {'id': 10, 'name': '1AS'},
    {'id': 11, 'name': '2AS'}, {'id': 12, 'name': '3AS'},
  ];

  List<Level> get levels =>
      _allLevelsData.map((e) => Level(id: e['id'] as int, name: e['name'] as String)).toList();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _adminApi.getExercises(),
        _adminApi.getExerciseRequests(),
        _adminApi.getSkills(),
      ]);
      exercises.value = results[0] as List<Exercise>;
      exerciseRequests.value = results[1] as List<Exercise>;
      skills.value = results[2] as List<Skill>;
      notifications.value = [];
      unreadNotificationCount.value = 0;
      _updateStats();
    } catch (e) {
      debugPrint('Error loading admin data: $e');
    } finally {
      isLoading.value = false;
    }

    // Load class count separately (non-blocking)
    try {
      final classes = await StudentApi().getAllClassesPublic();
      classCount.value = classes.length;
    } catch (e) {
      debugPrint('Error loading class count: $e');
    }
  }

  void _updateStats() {
    exerciseCount.value = exercises.length;
    pendingCount.value = exerciseRequests.length;
    approvedCount.value = exercises.where((e) => e.status == 'APPROVED').length;
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  void setSelectedLevelId(int? levelId) {
    selectedLevelId.value = levelId;
    selectedClassId.value = null;
    levelClasses.clear();
    if (levelId != null) {
      _loadLevelClasses(levelId);
    }
  }

  Future<void> _loadLevelClasses(int levelId) async {
    try {
      final result = await StudentApi().getAllClassesPublic(levelId: levelId);
      levelClasses.value = result;
    } catch (e) {
      debugPrint('Error loading level classes: $e');
    }
  }

  void toggleSkill(int skillId) {
    if (selectedSkills.contains(skillId)) {
      selectedSkills.remove(skillId);
    } else {
      selectedSkills.add(skillId);
    }
  }

  Future<void> pickUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.isNotEmpty) {
      selectedFile.value = result.files.first;
    }
  }

  Future<void> uploadExercise() async {
    if (uploadTitle.value.isEmpty || uploadDescription.value.isEmpty) {
      Get.snackbar('Error'.tr, 'Title and description are required'.tr);
      return;
    }

    isUploading.value = true;
    try {
      await _adminApi.createExercise(
        title: uploadTitle.value,
        description: uploadDescription.value,
        fileBytes: selectedFile.value?.bytes,
        fileName: selectedFile.value?.name,
        filePath: selectedFile.value?.path,
        levelId: selectedLevelId.value,
        classIds: selectedClassId.value != null ? [selectedClassId.value!] : null,
        skillIds: selectedSkills.isNotEmpty ? selectedSkills.toList() : null,
      );
      Get.snackbar('Success'.tr, 'Exercise uploaded successfully'.tr);
      uploadTitle.value = '';
      uploadDescription.value = '';
      selectedLevelId.value = null;
      selectedFile.value = null;
      await loadData();
    } catch (e) {
      debugPrint('Upload error: $e');
      Get.snackbar('Error'.tr, 'Failed to upload exercise'.tr);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> approveExercise(int exerciseId) async {
    moderating.value = exerciseId;
    try {
      await _adminApi.respondToExerciseRequest(exerciseId, 'approve');
      await loadData();
      Get.snackbar('Success'.tr, 'Exercise approved'.tr);
    } catch (e) {
      debugPrint('Approve error: $e');
    } finally {
      moderating.value = null;
    }
  }

  Future<void> rejectExercise(int exerciseId) async {
    moderating.value = exerciseId;
    try {
      await _adminApi.respondToExerciseRequest(exerciseId, 'reject');
      await loadData();
      Get.snackbar('Success'.tr, 'Exercise rejected'.tr);
    } catch (e) {
      debugPrint('Reject error: $e');
    } finally {
      moderating.value = null;
    }
  }

  void toggleLanguage() {
    _theme.toggleLanguage();
  }

  void toggleDarkMode() {
    _theme.toggleTheme();
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      for (var notification in notifications.where((n) => !n.isRead)) {
        await StudentApi().markNotificationAsRead(notification.id);
      }
      notifications.value = notifications
          .map((n) => AppNotification(
                id: n.id,
                recipient: n.recipient,
                type: n.type,
                title: n.title,
                message: n.message,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
      unreadNotificationCount.value = 0;
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
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
    } catch (e) {}
    _auth.logout();
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.disconnectAll();
    } catch (e) {}
    Get.offAllNamed(AppRoutes.login);
  }
}
