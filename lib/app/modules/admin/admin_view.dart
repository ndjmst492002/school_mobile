import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/download_service.dart';
import '../../data/models/models.dart';
import '../../../main.dart';
import 'admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: controller.isDarkMode
              ? AppTheme.darkBackground
              : AppTheme.background,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final isDark = controller.isDarkMode;
      final bgColor = isDark ? AppTheme.darkBackground : AppTheme.background;
      final cardColor = isDark ? AppTheme.darkCard : AppTheme.card;
      final textColor = isDark ? AppTheme.darkForeground : AppTheme.foreground;
      final mutedColor = isDark
          ? AppTheme.darkMutedForeground
          : AppTheme.mutedForeground;
      final borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;

      final activeTab = controller.activeTab.value;
      final skillsCount = controller.skills.length;
      final exercises = controller.exercises;
      final exerciseRequests = controller.exerciseRequests;
      final skills = controller.skills;
      final selectedLevelId = controller.selectedLevelId.value;
      final selectedClassId = controller.selectedClassId.value;
      final selectedSkills = controller.selectedSkills;
      final isUploading = controller.isUploading.value;
      final levelClasses = controller.levelClasses;
      final selectedFile = controller.selectedFile.value;
      final moderating = controller.moderating.value;
      final levels = controller.levels;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          title: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildNotificationBell(isDark),
                _buildLanguageToggle(isDark),
                _buildProfileMenu(isDark, borderColor),
              ],
            ),
          ),
          toolbarHeight: 80,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Dashboard'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkForeground
                          : AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome'.tr + ', ${controller.userName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.darkMutedForeground
                          : AppTheme.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildStatsRow(isDark),
                const SizedBox(height: 16),
                _buildTabsRow(activeTab, isDark, borderColor, mutedColor),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabContent(
                    activeTab,
                    isDark,
                    cardColor,
                    textColor,
                    mutedColor,
                    borderColor,
                    exercises,
                    exerciseRequests,
                    skills,
                    selectedLevelId,
                    selectedClassId,
                    selectedSkills,
                    isUploading,
                    levelClasses,
                    selectedFile,
                    levels,
                    moderating,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    });
  }

  // --- Notification Bell ---

  Widget _buildNotificationBell(bool isDark) {
    return Obx(() {
      final hasUnread = controller.unreadNotificationCount > 0;
      return Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotificationsDialog(),
          ),
          if (hasUnread)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkDestructive
                      : AppTheme.destructive,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${controller.unreadNotificationCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  void _showNotificationsDialog() {
    controller.markAllNotificationsAsRead();
    final isDark = Get.find<ThemeService>().isDarkMode;
    Get.dialog(
      Dialog(
        alignment: Alignment.centerRight,
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: Container(
          width: 350,
          height: double.infinity,
          color: isDark ? AppTheme.darkCard : AppTheme.card,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.card,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppTheme.darkBorder : AppTheme.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.darkForeground
                            : AppTheme.foreground,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => controller.notifications.any((n) => !n.isRead)
                            ? TextButton(
                                onPressed: () =>
                                    controller.markAllNotificationsAsRead(),
                                child: Text('Mark all as read'.tr),
                              )
                            : const SizedBox.shrink()),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: isDark
                                ? AppTheme.darkForeground
                                : AppTheme.foreground,
                          ),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.notifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications'.tr,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkMutedForeground
                              : AppTheme.mutedForeground,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: notification.isRead
                            ? null
                            : (isDark
                                  ? AppTheme.darkBadgeBlueBg
                                  : Colors.blue[50]),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                  top: 2,
                                ),
                                child: _getNotificationIcon(notification.type),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        fontSize: 13,
                                        color: isDark
                                            ? AppTheme.darkForeground
                                            : AppTheme.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getTimeAgo(notification.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppTheme.darkMutedForeground
                                            : AppTheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'EXERCISE':
        return const Icon(Icons.book_outlined, color: Colors.blue, size: 20);
      case 'ABSENCE':
        return const Icon(
          Icons.person_remove_outlined,
          color: Colors.red,
          size: 20,
        );
      case 'ANNOUNCEMENT':
        return const Icon(
          Icons.campaign_outlined,
          color: Colors.purple,
          size: 20,
        );
      case 'GRADE':
        return const Icon(
          Icons.emoji_events_outlined,
          color: Colors.green,
          size: 20,
        );
      default:
        return const Icon(
          Icons.notifications_outlined,
          color: Colors.grey,
          size: 20,
        );
    }
  }

  // --- Language Toggle ---

  Widget _buildLanguageToggle(bool isDark) {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => controller.toggleLanguage(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Text(
              controller.currentLanguage == 'en' ? 'ع' : 'EN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Profile Menu ---

  Widget _buildProfileMenu(bool isDark, Color borderColor) {
    final roles = controller.roles;
    final activeRole = controller.currentRole;
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      constraints: const BoxConstraints(minWidth: 220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              (controller.userName.isNotEmpty ? controller.userName[0] : 'A')
                  .toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
              ),
            ),
          ),
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          controller.logout();
        } else if (value == 'theme') {
          controller.toggleDarkMode();
        } else if (value.startsWith('switch_')) {
          controller.switchToRole(value.replaceFirst('switch_', ''));
        }
      },
      itemBuilder: (context) => [
        // Dark/Light Mode toggle
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 18),
              const SizedBox(width: 8),
              Text(isDark ? 'Light Mode'.tr : 'Dark Mode'.tr),
            ],
          ),
        ),
        // Role Switcher (only if multiple roles)
        if (roles.length > 1) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            enabled: false,
            child: Text(
              'Switch Role'.tr,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          ...roles
              .where((r) {
                if (activeRole == 'PARENT' && r == 'STUDENT') return false;
                if (activeRole == 'TEACHER' && r == 'STUDENT') return false;
                return true;
              })
              .map((role) {
                IconData icon;
                Color iconColor;
                switch (role) {
                  case 'ADMIN':
                    icon = Icons.shield;
                    iconColor = Colors.red;
                    break;
                  case 'TEACHER':
                    icon = Icons.school;
                    iconColor = Colors.blue;
                    break;
                  case 'STUDENT':
                    icon = Icons.people;
                    iconColor = Colors.green;
                    break;
                  case 'PARENT':
                    icon = Icons.child_care;
                    iconColor = Colors.purple;
                    break;
                  default:
                    icon = Icons.person;
                    iconColor = isDark
                        ? AppTheme.darkMutedForeground
                        : AppTheme.mutedForeground;
                }
                final isActive = role == activeRole;
                return PopupMenuItem(
                  value: 'switch_$role',
                  enabled: !isActive,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: iconColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_roleLabel(role).tr)),
                      if (isActive)
                        Text(
                          'ACTIVE'.tr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isDark
                                ? AppTheme.darkMutedForeground
                                : AppTheme.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                );
              }),
        ],
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 18,
                color: isDark ? AppTheme.darkDestructive : AppTheme.destructive,
              ),
              const SizedBox(width: 8),
              Text(
                'Logout'.tr,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkDestructive
                      : AppTheme.destructive,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Administrator';
      case 'TEACHER':
        return 'Teacher';
      case 'STUDENT':
        return 'Student';
      case 'PARENT':
        return 'Parent';
      default:
        return role;
    }
  }

  // --- Stats Row ---

  Widget _buildStatsRow(bool isDark) {
    return SizedBox(
      height: 138,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SizedBox(
            width: 170,
            child: _statCard(
              'Exercises'.tr,
              '${controller.exercises.length}',
              'Total uploaded'.tr,
              Icons.description,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 170,
            child: _statCard(
              'Classes'.tr,
              '${controller.classCount}',
              'Active classes'.tr,
              Icons.book,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 170,
            child: _statCard(
              'Skills'.tr,
              '${controller.skills.length}',
              'Available skills'.tr,
              Icons.auto_awesome,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 170,
            child: _statCard(
              'System Status'.tr,
              'Active'.tr,
              'All systems operational'.tr,
              Icons.check_circle,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.darkMutedForeground
                        : AppTheme.mutedForeground,
                  ),
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: isDark
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: value == 'Active'
                  ? const Color(0xFF16A34A)
                  : (isDark ? AppTheme.darkForeground : AppTheme.foreground),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tabs Row ---

  Widget _buildTabsRow(
    String activeTab,
    bool isDark,
    Color borderColor,
    Color mutedColor,
  ) {
    final tabs = ['overview', 'exercises', 'exercise-requests'];
    final labels = ['Overview'.tr, 'Exercises'.tr, 'Exercise Requests'.tr];

    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = activeTab == tabs[index];
          return GestureDetector(
            onTap: () => controller.setActiveTab(tabs[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? AppTheme.darkForeground : AppTheme.primary)
                      : (isDark ? AppTheme.darkMutedForeground : mutedColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Tab Content Dispatcher ---

  Widget _buildTabContent(
    String activeTab,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    RxList<Exercise> exercises,
    RxList<Exercise> exerciseRequests,
    RxList<Skill> skills,
    int? selectedLevelId,
    int? selectedClassId,
    RxList<int> selectedSkills,
    bool isUploading,
    RxList<ClassModel> levelClasses,
    PlatformFile? selectedFile,
    List<Level> levels,
    int? moderating,
  ) {
    switch (activeTab) {
      case 'overview':
        return _buildOverviewTab(
          isDark,
          cardColor,
          textColor,
          mutedColor,
          borderColor,
        );
      case 'exercises':
        return _buildExercisesTab(
          isDark,
          cardColor,
          textColor,
          mutedColor,
          borderColor,
          exercises,
          skills,
          selectedLevelId,
          selectedClassId,
          selectedSkills,
          isUploading,
          levelClasses,
          selectedFile,
          levels,
        );
      case 'exercise-requests':
        return _buildExerciseRequestsTab(
          isDark,
          cardColor,
          textColor,
          mutedColor,
          borderColor,
          exerciseRequests,
          moderating,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Overview Tab ---

  Widget _buildOverviewTab(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Overview'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Admin system overview'.tr,
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBadgeBlueBg : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Text(
                'Admin Only: You have full system access'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkBadgeBlueText : Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Exercises Tab ---

  Widget _buildExercisesTab(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    RxList<Exercise> exercises,
    RxList<Skill> skills,
    int? selectedLevelId,
    int? selectedClassId,
    RxList<int> selectedSkills,
    bool isUploading,
    RxList<ClassModel> levelClasses,
    PlatformFile? selectedFile,
    List<Level> levels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUploadForm(
          isDark,
          cardColor,
          textColor,
          mutedColor,
          borderColor,
          skills,
          selectedLevelId,
          selectedClassId,
          selectedSkills,
          isUploading,
          levelClasses,
          selectedFile,
          levels,
        ),
        const SizedBox(height: 16),
        _buildExerciseList(
          isDark,
          cardColor,
          textColor,
          mutedColor,
          borderColor,
          exercises,
        ),
      ],
    );
  }

  Widget _buildUploadForm(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    RxList<Skill> skills,
    int? selectedLevelId,
    int? selectedClassId,
    RxList<int> selectedSkills,
    bool isUploading,
    RxList<ClassModel> levelClasses,
    PlatformFile? selectedFile,
    List<Level> levels,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload New Exercise'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload an exercise file for students'.tr,
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Exercise Title'.tr,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => controller.uploadTitle.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description'.tr,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (v) => controller.uploadDescription.value = v,
            ),
            const SizedBox(height: 12),
            Obx(() {
              final dateCtl = TextEditingController(
                text: controller.uploadDueDate.value,
              );
              return TextField(
                controller: dateCtl,
                decoration: InputDecoration(
                  labelText: 'Due Date (optional)'.tr,
                  hintText: 'Select date'.tr,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: mutedColor,
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    controller.uploadDueDate.value =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  }
                },
              );
            }),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedLevelId,
              decoration: InputDecoration(
                labelText: 'Level'.tr,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text(
                    'Select a level'.tr,
                    style: TextStyle(color: mutedColor),
                  ),
                ),
                ...levels.map(
                  (l) =>
                      DropdownMenuItem<int>(value: l.id, child: Text(l.name)),
                ),
              ],
              onChanged: controller.setSelectedLevelId,
            ),
            const SizedBox(height: 12),
            Obx(
              () => levelClasses.isEmpty
                  ? Text(
                      'No classes available'.tr,
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    )
                  : DropdownButtonFormField<int>(
                      value: selectedClassId,
                      decoration: InputDecoration(
                        labelText: 'Select Class'.tr,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      isExpanded: true,
                      hint: Text('Select a class'.tr),
                      items: levelClasses
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text('${c.name} (${c.studentCount} students)'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => controller.selectedClassId.value = v,
                    ),
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Skills (Optional)'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: skills
                            .map(
                              (skill) => FilterChip(
                                label: Text(
                                  skill.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: selectedSkills.contains(skill.id),
                                onSelected: (_) =>
                                    controller.toggleSkill(skill.id),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Obx(() {
              final file = controller.selectedFile.value;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : AppTheme.muted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      file != null
                          ? Icons.insert_drive_file
                          : Icons.attach_file,
                      size: 20,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file != null ? file.name : 'No file selected'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: file != null ? textColor : mutedColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (file != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          controller.selectedFile.value = null;
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.pickUploadFile,
                icon: const Icon(Icons.folder_open, size: 18),
                label: Text('Choose File'.tr),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading ? null : controller.uploadExercise,
                child: isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Upload Exercise'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    RxList<Exercise> exercises,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Uploaded Exercises'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Exercises you've shared with students".tr,
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
            const SizedBox(height: 16),
            if (exercises.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No exercises uploaded yet'.tr,
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ex.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (ex.level != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.darkBadgeBlueBg
                                            : Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        ex.level!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppTheme.darkBadgeBlueText
                                              : Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ex.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mutedColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Class: ${ex.className ?? ""}${ex.dueDate != null ? " | Due: ${_formatDate(ex.dueDate!)}" : ""}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mutedColor,
                                ),
                              ),
                              if (ex.skills.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 2,
                                  children: ex.skills
                                      .map(
                                        (s) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0x33433FA7)
                                                : Colors.purple[50],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            s.name,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (ex.fileUrl != null && ex.fileUrl!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final url = '${ApiProvider.baseUrl}/users/exercises/${ex.id}/download/';
                              final dio = Get.find<ApiProvider>().dio;
                              await DownloadService.downloadFile(
                                dio: dio,
                                url: url,
                                fileUrl: ex.fileUrl,
                              );
                            },
                            icon: const Icon(Icons.download, size: 16),
                            label: Text(
                              'Download'.tr,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- Exercise Requests Tab ---

  Widget _buildExerciseRequestsTab(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    RxList<Exercise> exerciseRequests,
    int? moderating,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exercise Requests'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pending exercises from teachers awaiting your approval'.tr,
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
            const SizedBox(height: 16),
            if (exerciseRequests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No pending exercise requests'.tr,
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exerciseRequests.length,
                itemBuilder: (context, index) {
                  final ex = exerciseRequests[index];
                  final isResponding = moderating == ex.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ex.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ex.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mutedColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Teacher: ${ex.teacherName ?? ""} | Class: ${ex.className ?? ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mutedColor,
                                ),
                              ),
                              if (ex.createdAt != null)
                                Text(
                                  'Requested: ${_formatDateTime(ex.createdAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mutedColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: isResponding
                                  ? null
                                  : () => controller.approveExercise(ex.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(80, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: isResponding
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Approve'.tr,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              onPressed: isResponding
                                  ? null
                                  : () => controller.rejectExercise(ex.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? AppTheme.darkDestructive
                                    : AppTheme.destructive,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(80, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Reject'.tr,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now'.tr;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}${"m".tr}${" ago".tr}';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}${"h".tr}${" ago".tr}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}${"d".tr}${" ago".tr}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final hour = date.hour;
      final amPm = hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${date.month}/${date.day}/${date.year}, $hour12:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')} $amPm';
    } catch (e) {
      return dateStr;
    }
  }
}
