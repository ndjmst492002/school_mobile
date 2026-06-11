import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../../main.dart';
import 'teacher_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';

class TeacherView extends GetView<TeacherController> {
  const TeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (controller.profileNotFound.value) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: controller.isDarkMode
                        ? AppTheme.darkPrimary
                        : AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile Not Found'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You need to complete your teacher profile before accessing the dashboard.'
                        .tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: controller.isDarkMode
                          ? AppTheme.darkMutedForeground
                          : AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.profileCompletion,
                      arguments: {'role': 'TEACHER'},
                    ),
                    child: Text('Complete Profile'.tr),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed('/login');
                    },
                    child: Text('Logout'.tr),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          title: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                const Spacer(),
                _buildNotificationBell(),
                _buildChatButton(),
                _buildLanguageToggle(),
                _buildProfileMenu(),
              ],
            ),
          ),
          toolbarHeight: 56,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Obx(() {
              if (controller.showChat.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Teacher Dashboard'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${"Welcome".tr}, ${controller.userName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: controller.isDarkMode
                            ? AppTheme.darkMutedForeground
                            : AppTheme.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        body: controller.showChat.value
            ? ChatView(
                onClose: () {
                  Get.delete<ChatController>();
                  controller.toggleChat();
                  controller.updateUnreadMessageCount(0);
                },
              )
            : _buildContent(),
      );
    });
  }

  Widget _buildChatButton() {
    return Obx(() {
      final count = controller.unreadMessageCount.value;
      return Stack(
        children: [
          controller.showChat.value
              ? TextButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: Text('Chat'.tr, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    Get.delete<ChatController>();
                    controller.toggleChat();
                    controller.updateUnreadMessageCount(0);
                  },
                )
              : TextButton.icon(
                  icon: const Icon(Icons.chat, size: 18),
                  label: Text('Chat'.tr, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    Get.put(ChatController());
                    controller.toggleChat();
                    controller.updateUnreadMessageCount(0);
                  },
                ),
          if (count > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: controller.isDarkMode
                      ? AppTheme.darkDestructive
                      : AppTheme.destructive,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: TextStyle(
                    color: controller.isDarkMode
                        ? AppTheme.darkPrimaryForeground
                        : AppTheme.primaryForeground,
                    fontSize: 9,
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

  Widget _buildNotificationBell() {
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
                  color: controller.isDarkMode
                      ? AppTheme.darkDestructive
                      : AppTheme.destructive,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${controller.unreadNotificationCount}',
                  style: TextStyle(
                    color: controller.isDarkMode
                        ? AppTheme.darkPrimaryForeground
                        : AppTheme.primaryForeground,
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

  Widget _buildLanguageToggle() {
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
                color: controller.isDarkMode
                    ? AppTheme.darkPrimary
                    : AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    final auth = Get.find<AuthService>();
    return Obx(
      () => PopupMenuButton<String>(
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
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                controller.userName.isNotEmpty
                    ? controller.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        onSelected: (v) {
          if (v == 'logout')
            controller.logout();
          else if (v == 'dark_mode')
            controller.toggleDarkMode();
          else if (v.startsWith('switch_'))
            controller.switchToRole(v.replaceFirst('switch_', ''));
        },
        itemBuilder: (ctx) => [
          PopupMenuItem(
            value: 'dark_mode',
            child: Row(
              children: [
                Icon(
                  controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(controller.isDarkMode ? 'Light Mode'.tr : 'Dark Mode'.tr),
              ],
            ),
          ),
          if (auth.hasMultipleRoles) ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: false,
              child: Text(
                'Switch Role'.tr,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            ...auth.roles
                .where((r) {
                  if (auth.role == 'PARENT' && r == 'STUDENT') return false;
                  if (auth.role == 'TEACHER' && r == 'STUDENT') return false;
                  return true;
                })
                .map((role) {
                  IconData icon;
                  Color iconColor;
                  String label;
                  switch (role) {
                    case 'ADMIN':
                      icon = Icons.shield;
                      iconColor = Colors.red;
                      label = 'Administrator'.tr;
                      break;
                    case 'TEACHER':
                      icon = Icons.school;
                      iconColor = Colors.blue;
                      label = 'Teacher'.tr;
                      break;
                    case 'STUDENT':
                      icon = Icons.people;
                      iconColor = Colors.green;
                      label = 'Student'.tr;
                      break;
                    case 'PARENT':
                      icon = Icons.child_care;
                      iconColor = Colors.purple;
                      label = 'Parent'.tr;
                      break;
                    default:
                      icon = Icons.person;
                      iconColor = controller.isDarkMode
                          ? AppTheme.darkMutedForeground
                          : AppTheme.mutedForeground;
                      label = role;
                  }
                  final isActive = role == auth.role;
                  return PopupMenuItem(
                    value: 'switch_$role',
                    enabled: !isActive,
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: iconColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(label)),
                        if (isActive)
                          Text(
                            'ACTIVE'.tr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: controller.isDarkMode
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
                  color: controller.isDarkMode
                      ? AppTheme.darkDestructive
                      : AppTheme.destructive,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logout'.tr,
                  style: TextStyle(
                    color: controller.isDarkMode
                        ? AppTheme.darkDestructive
                        : AppTheme.destructive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                      color: controller.isDarkMode
                          ? AppTheme.darkBorder
                          : AppTheme.border,
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.notifications.isEmpty)
                    return Center(
                      child: Text(
                        'No notifications'.tr,
                        style: TextStyle(
                          color: controller.isDarkMode
                              ? AppTheme.darkMutedForeground
                              : AppTheme.mutedForeground,
                        ),
                      ),
                    );
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.notifications.length,
                    itemBuilder: (ctx, i) {
                      final n = controller.notifications[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: n.isRead
                            ? null
                            : (controller.isDarkMode
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
                                child: _getNotificationIcon(n.type),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (n.title.isNotEmpty) ...[
                                      Text(
                                        n.title,
                                        style: TextStyle(
                                          fontWeight: n.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: controller.isDarkMode
                                              ? AppTheme.darkForeground
                                              : AppTheme.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    Text(
                                      n.message,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: controller.isDarkMode
                                            ? AppTheme.darkForeground
                                            : AppTheme.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getTimeAgo(n.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: controller.isDarkMode
                                            ? AppTheme.darkMutedForeground
                                            : AppTheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 4,
                                  ),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: controller.isDarkMode
                                          ? AppTheme.darkPrimary
                                          : AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
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
      barrierDismissible: true,
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

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inSeconds < 60) return 'Just now'.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes}${"m".tr}${" ago".tr}';
      if (diff.inHours < 24) return '${diff.inHours}${"h".tr}${" ago".tr}';
      if (diff.inDays < 7) return '${diff.inDays}${"d".tr}${" ago".tr}';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildStatsCards(),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: controller.isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.border,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => Row(
                    children: [
                      _buildTabChip('my-classes', 'My Classes'),
                      _buildTabChip('enrollments', 'Enrollments'),
                      _buildTabChip('mark-attendance', 'Attendance'),
                      _buildTabChip('create-announcement', 'Announcements'),
                      _buildTabChip('upload-exercise', 'Exercises'),
                      _buildTabChip('student-submissions', 'Submissions'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              switch (controller.activeTab.value) {
                case 'my-classes':
                  return _buildMyClassesContent();
                case 'enrollments':
                  return _buildEnrollmentsContent();
                case 'mark-attendance':
                  return _buildAttendanceContent();
                case 'create-announcement':
                  return _buildAnnouncementContent();
                case 'upload-exercise':
                  return _buildExerciseContent();
                case 'student-submissions':
                  return _buildSubmissionContent();
                default:
                  return _buildMyClassesContent();
              }
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String tabId, String label) {
    final isActive = controller.activeTab.value == tabId;
    return GestureDetector(
      onTap: () => controller.setActiveTab(tabId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? (controller.isDarkMode
                        ? AppTheme.darkPrimary
                        : AppTheme.primary)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive
                ? (controller.isDarkMode
                      ? AppTheme.darkPrimary
                      : AppTheme.primary)
                : (controller.isDarkMode
                      ? AppTheme.darkMutedForeground
                      : AppTheme.mutedForeground),
          ),
        ),
      ),
    );
  }

  Widget _buildMyClassesContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Classes'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Classes you teach'.tr,
            style: TextStyle(
              fontSize: 12,
              color: controller.isDarkMode
                  ? AppTheme.darkMutedForeground
                  : AppTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          _buildClassesCard(),
        ],
      ),
    );
  }

  Widget _buildEnrollmentsContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment Requests'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Students requesting to join your classes'.tr,
            style: TextStyle(
              color: controller.isDarkMode
                  ? AppTheme.darkMutedForeground
                  : AppTheme.mutedForeground,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.enrollments.isEmpty) {
              return Text('No pending enrollment requests'.tr);
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.enrollments.length,
              itemBuilder: (ctx, i) {
                final enrollment = controller.enrollments[i];
                final isDark = controller.isDarkMode;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? const Color(0xFF3F3F46) : AppTheme.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enrollment.studentName.isNotEmpty
                                      ? enrollment.studentName
                                      : 'Student #${enrollment.student}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Wants to join: ${enrollment.className}'.tr,
                                  style: TextStyle(
                                    color: controller.isDarkMode
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Requested: ${_formatDateTime(enrollment.requestedAt)}'
                                      .tr,
                                  style: TextStyle(
                                    color: controller.isDarkMode
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed:
                                    controller.respondingEnrollment.value ==
                                        enrollment.id
                                    ? null
                                    : () => controller.respondToEnrollment(
                                        enrollment.id,
                                        'approve',
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                child:
                                    controller.respondingEnrollment.value ==
                                        enrollment.id
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Approve'.tr),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Obx(
                              () => ElevatedButton(
                                onPressed:
                                    controller.respondingEnrollment.value ==
                                        enrollment.id
                                    ? null
                                    : () => controller.respondToEnrollment(
                                        enrollment.id,
                                        'reject',
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.isDarkMode
                                      ? AppTheme.darkDestructive
                                      : AppTheme.destructive,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                child:
                                    controller.respondingEnrollment.value ==
                                        enrollment.id
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Reject'.tr),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
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

  Widget _buildAttendanceContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mark Attendance'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                'Mark students as present or absent for today'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: controller.isDarkMode
                      ? AppTheme.darkMutedForeground
                      : AppTheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              _buildAttendanceButton(),
            ],
          ),
          if (controller.showAttendanceForm.value) ...[
            const SizedBox(height: 12),
            _buildAttendanceForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnnouncementContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Announcements'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildAnnouncementButton(),
            ],
          ),
          if (controller.showAnnouncementForm.value) ...[
            const SizedBox(height: 12),
            _buildAnnouncementForm(),
          ],
          const SizedBox(height: 16),
          _buildAnnouncementsCard(),
        ],
      ),
    );
  }

  Widget _buildExerciseContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercises'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildUploadButton(),
            ],
          ),
          if (controller.showUploadForm.value) ...[
            const SizedBox(height: 12),
            _buildUploadForm(),
          ],
          const SizedBox(height: 16),
          _buildExercisesOnlyCard(),
        ],
      ),
    );
  }

  Widget _buildSubmissionContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Submissions'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            'Review and grade work from your students'.tr,
            style: TextStyle(
              fontSize: 12,
              color: controller.isDarkMode
                  ? AppTheme.darkMutedForeground
                  : AppTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubmissionsCard(),
          _buildGradingDialog(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementButton() {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: controller.toggleAnnouncementForm,
        icon: const Icon(Icons.campaign, size: 18),
        label: Text(
          controller.showAnnouncementForm.value
              ? 'Cancel'.tr
              : 'Create Announcement'.tr,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
      ),
    );
  }

  Widget _buildAttendanceButton() {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: controller.toggleAttendanceForm,
        icon: const Icon(Icons.people, size: 18),
        label: Text(
          controller.showAttendanceForm.value
              ? 'Cancel'.tr
              : 'Mark Attendance'.tr,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: controller.toggleUploadForm,
        icon: const Icon(Icons.upload, size: 18),
        label: Text(
          controller.showUploadForm.value
              ? 'Cancel'.tr
              : 'Upload New Exercise'.tr,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(
      () => SizedBox(
        height: 125,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(
              width: 200,
              child: _buildStatCard(
                'Announcements'.tr,
                '${controller.announcements.length}',
                'Posted'.tr,
                Icons.campaign,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: _buildStatCard(
                'Total Students'.tr,
                '${controller.totalStudents}',
                'Across all classes'.tr,
                Icons.menu_book,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: _buildStatCard(
                'Exercises'.tr,
                '${controller.exercises.length}',
                'Total uploaded'.tr,
                Icons.description,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: _buildStatCard(
                'Submissions'.tr,
                '${controller.submissions.length}',
                'Total received'.tr,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: _buildStatCard(
                'Pending Review'.tr,
                '${controller.pendingCount}',
                'Need grading'.tr,
                Icons.access_time,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    final isDark = controller.isDarkMode;
    return Card(
      child: Container(
        width: 200,
        constraints: const BoxConstraints(minHeight: 100),
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                  color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
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
        ),
      ),
    );
  }

  Widget _buildUploadForm() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload an exercise file for your students'.tr,
              style: TextStyle(
                fontSize: 11,
                color: controller.isDarkMode
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.uploadTitleController,
              decoration: InputDecoration(
                labelText: 'Exercise Title'.tr,
                hintText: 'e.g., Math Homework Chapter 5'.tr,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.uploadDescController,
              decoration: InputDecoration(
                labelText: 'Description'.tr,
                hintText: 'Exercise description'.tr,
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    controller.uploadDueDateController.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: controller.uploadDueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date (Optional)'.tr,
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.uploadClassId.value.isEmpty
                    ? null
                    : controller.uploadClassId.value,
                decoration: InputDecoration(
                  labelText: 'Select Class'.tr,
                  hintText: 'Select a class'.tr,
                ),
                items: controller.classes
                    .map(
                      (cls) => DropdownMenuItem(
                        value: cls.id.toString(),
                        child: Text('${cls.name} (${cls.studentCount})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controller.updateUploadClassId(v ?? ''),
              ),
            ),
            const SizedBox(height: 12),
            if (controller.skills.isNotEmpty) ...[
              Text(
                'Skills (Optional)'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: controller.isDarkMode
                      ? AppTheme.darkForeground
                      : AppTheme.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.border,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: controller.skills
                        .map(
                          (skill) => FilterChip(
                            label: Text(
                              skill.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: controller.selectedSkills.contains(
                              skill.id,
                            ),
                            onSelected: (_) => controller.toggleSkill(skill.id),
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
            const SizedBox(height: 12),
            Text(
              'Upload File'.tr,
              style: TextStyle(
                fontSize: 12,
                color: controller.isDarkMode
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Obx(() {
              final selectedFile = controller.selectedFile.value;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.isDarkMode
                      ? AppTheme.darkSurface
                      : AppTheme.muted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedFile != null
                          ? Icons.insert_drive_file
                          : Icons.attach_file,
                      size: 20,
                      color: controller.isDarkMode
                          ? AppTheme.darkMutedForeground
                          : AppTheme.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile.name
                            : 'No file selected'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: selectedFile != null
                              ? (controller.isDarkMode
                                    ? AppTheme.darkForeground
                                    : AppTheme.foreground)
                              : (controller.isDarkMode
                                    ? AppTheme.darkMutedForeground
                                    : AppTheme.mutedForeground),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (selectedFile != null)
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;

                if (isSmallScreen) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.pickFile,
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: Text('Choose File'.tr),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isUploading.value
                                ? null
                                : controller.uploadExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              controller.isUploading.value
                                  ? 'Uploading...'.tr
                                  : 'Upload Exercise'.tr,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.pickFile,
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
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isUploading.value
                                ? null
                                : controller.uploadExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              controller.isUploading.value
                                  ? 'Uploading...'.tr
                                  : 'Upload Exercise'.tr,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementForm() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Announcement'.tr,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Post an announcement for your students and their parents'.tr,
              style: TextStyle(
                fontSize: 11,
                color: controller.isDarkMode
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.announcementTitleController,
              decoration: InputDecoration(
                labelText: 'Title'.tr,
                hintText: 'Announcement title'.tr,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.announcementContentController,
              decoration: InputDecoration(
                labelText: 'Content'.tr,
                hintText: 'Write your announcement here...'.tr,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.announcementClassId.value.isEmpty
                    ? null
                    : controller.announcementClassId.value,
                decoration: InputDecoration(labelText: 'Class (Optional)'.tr),
                items: [
                  DropdownMenuItem(value: '', child: Text('All my classes'.tr)),
                  ...controller.classes.map(
                    (cls) => DropdownMenuItem(
                      value: cls.id.toString(),
                      child: Text(cls.name),
                    ),
                  ),
                ],
                onChanged: (v) => controller.updateAnnouncementClassId(v ?? ''),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isPosting.value
                    ? null
                    : controller.createAnnouncement,
                child: Text(
                  controller.isPosting.value
                      ? 'Posting...'.tr
                      : 'Post Announcement'.tr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceForm() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.attendanceClassId.value.isEmpty
                    ? null
                    : controller.attendanceClassId.value,
                decoration: InputDecoration(labelText: 'Select Class'.tr),
                items: controller.classes
                    .map(
                      (cls) => DropdownMenuItem(
                        value: cls.id.toString(),
                        child: Text('${cls.name} (${cls.studentCount})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  controller.updateAttendanceClassId(v ?? '');
                  controller.showLoadStudentsButton.value = true;
                },
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (ctx) => GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    controller.attendanceDateController.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: controller.attendanceDateController,
                    decoration: InputDecoration(
                      labelText: 'Date'.tr,
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.attendanceClassId.value.isNotEmpty) {
                return ElevatedButton(
                  onPressed: controller.isLoadingAttendance.value
                      ? null
                      : () => controller.loadAttendance(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.isLoadingAttendance.value)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Text(
                        controller.isLoadingAttendance.value
                            ? 'Loading...'.tr
                            : 'Load Students'.tr,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),
            Obx(() {
              final selectedClass = controller.classes.firstWhereOrNull(
                (c) => c.id.toString() == controller.attendanceClassId.value,
              );
              if (selectedClass == null) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.isDarkMode
                        ? AppTheme.darkBorder
                        : AppTheme.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Students in ${selectedClass.name}'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: controller.isDarkMode
                            ? AppTheme.darkForeground
                            : AppTheme.foreground,
                      ),
                    ),
                    if (selectedClass.students != null &&
                        selectedClass.students!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...selectedClass.students!.map((student) {
                        final status =
                            controller.attendanceRecords[student.id] ??
                            'PRESENT';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: controller.isDarkMode
                                ? AppTheme.darkSurface
                                : AppTheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  student.fullName,
                                  style: TextStyle(
                                    color: controller.isDarkMode
                                        ? AppTheme.darkForeground
                                        : AppTheme.foreground,
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: status == 'PRESENT'
                                      ? (controller.isDarkMode
                                            ? AppTheme.darkBadgeGreenBg
                                            : Colors.green)
                                      : Colors.transparent,
                                  foregroundColor: status == 'PRESENT'
                                      ? Colors.white
                                      : (controller.isDarkMode
                                            ? AppTheme.darkForeground
                                            : AppTheme.foreground),
                                  side: BorderSide(
                                    color: status == 'PRESENT'
                                        ? (controller.isDarkMode
                                              ? AppTheme.darkBadgeGreenBg
                                              : Colors.green)
                                        : (controller.isDarkMode
                                              ? AppTheme.darkBorder
                                              : AppTheme.border),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    controller.setStudentAttendance(
                                      student.id,
                                      'PRESENT',
                                    ),
                                child: Text(
                                  'Present'.tr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: status == 'ABSENT'
                                      ? (controller.isDarkMode
                                            ? AppTheme.darkBadgeRedBg
                                            : Colors.red)
                                      : Colors.transparent,
                                  foregroundColor: status == 'ABSENT'
                                      ? Colors.white
                                      : (controller.isDarkMode
                                            ? AppTheme.darkForeground
                                            : AppTheme.foreground),
                                  side: BorderSide(
                                    color: status == 'ABSENT'
                                        ? (controller.isDarkMode
                                              ? AppTheme.darkBadgeRedBg
                                              : Colors.red)
                                        : (controller.isDarkMode
                                              ? AppTheme.darkBorder
                                              : AppTheme.border),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => controller
                                    .setStudentAttendance(student.id, 'ABSENT'),
                                child: Text(
                                  'Absent'.tr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSavingAttendance.value
                              ? null
                              : controller.saveAttendance,
                          child: Text(
                            controller.isSavingAttendance.value
                                ? 'Saving...'.tr
                                : 'Save Attendance'.tr,
                          ),
                        ),
                      ),
                    ],
                    if (controller.attendance.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: controller.isDarkMode
                              ? AppTheme.darkSurface
                              : AppTheme.muted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.isDarkMode
                                ? AppTheme.darkBorder
                                : AppTheme.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Summary for ${controller.attendanceDateController.text}'
                                  .tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: controller.isDarkMode
                                    ? AppTheme.darkForeground
                                    : AppTheme.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: controller.isDarkMode
                                          ? AppTheme.darkBadgeGreenBg
                                          : Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${controller.attendance.where((s) => s.status == 'PRESENT').length}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: controller.isDarkMode
                                                ? AppTheme.darkBadgeGreenText
                                                : Colors.green[700],
                                          ),
                                        ),
                                        Text(
                                          'Present'.tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: controller.isDarkMode
                                                ? AppTheme.darkBadgeGreenText
                                                : Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: controller.isDarkMode
                                          ? AppTheme.darkBadgeRedBg
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${controller.attendance.where((s) => s.status == 'ABSENT').length}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: controller.isDarkMode
                                                ? AppTheme.darkBadgeRedText
                                                : Colors.red[700],
                                          ),
                                        ),
                                        Text(
                                          'Absent'.tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: controller.isDarkMode
                                                ? AppTheme.darkBadgeRedText
                                                : Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Announcements'.tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              "Announcements you've posted".tr,
              style: TextStyle(
                fontSize: 11,
                color: controller.isDarkMode
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No announcements yet'.tr),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.announcements.length,
                itemBuilder: (context, index) {
                  final ann = controller.announcements[index];
                  return ListTile(
                    title: Text(
                      ann.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ann.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (ann.className != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: controller.isDarkMode
                                      ? AppTheme.darkBadgeBlueBg
                                      : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Class: ${ann.className}'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: controller.isDarkMode
                                        ? AppTheme.darkBadgeBlueText
                                        : Colors.blue[700],
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: controller.isDarkMode
                                    ? AppTheme.darkSurface
                                    : AppTheme.muted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _formatDateTime(ann.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: controller.isDarkMode
                                      ? AppTheme.darkMutedForeground
                                      : AppTheme.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.classes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No classes assigned yet'.tr),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.classes.length,
            itemBuilder: (context, index) {
              final cls = controller.classes[index];
              final isDark = controller.isDarkMode;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cls.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (cls.levelName != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkBadgeBlueBg
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cls.levelName!,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppTheme.darkBadgeBlueText
                                    : Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (cls.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          cls.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkMutedForeground
                                : AppTheme.mutedForeground,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${cls.studentCount} students enrolled'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkMutedForeground
                              : AppTheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildExercisesOnlyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Exercises'.tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              "Files you've shared with students".tr,
              style: TextStyle(
                fontSize: 11,
                color: controller.isDarkMode
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.exercises.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No exercises uploaded yet'.tr),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.exercises.length,
                itemBuilder: (context, index) {
                  final ex = controller.exercises[index];
                  final isDark = controller.isDarkMode;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          ex.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (ex.level != null) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppTheme.darkBadgeBlueBg
                                                : Colors.blue[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            ex.level!,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDark
                                                  ? AppTheme.darkBadgeBlueText
                                                  : Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            if (ex.status == 'REJECTED')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkBadgeRedBg
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Rejected'.tr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppTheme.darkBadgeRedText
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (ex.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              ex.description,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Class: ${ex.className ?? "N/A"}${ex.dueDate != null ? " | Due: ${_formatDate(ex.dueDate!)}" : ""}'
                                .tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.darkMutedForeground
                                  : AppTheme.mutedForeground,
                            ),
                          ),
                        ),
                        if (ex.skills.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: ex.skills
                                  .map(
                                    (s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0x593B0764)
                                            : const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        s.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? const Color(0xFFD8B4FE)
                                              : const Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (ex.fileUrl != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  controller.downloadExercise(ex.id),
                              icon: const Icon(Icons.download, size: 16),
                              label: Text(
                                'Download'.tr,
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        const Divider(height: 16),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (controller.submissions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No submissions yet'.tr),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.submissions.length > 10
                    ? 10
                    : controller.submissions.length,
                itemBuilder: (context, index) {
                  final sub = controller.submissions[index];
                  final isDark = controller.isDarkMode;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.studentName ?? 'Student'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Exercise: ${sub.exerciseTitle} | Submitted: ${_formatDateTime(sub.submittedAt)}'
                                          .tr,
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
                              if (sub.grade != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Grade: ${sub.grade}/20'.tr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF16A34A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (sub.submissionFileUrl != null)
                          SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  controller.downloadSubmission(sub.id),
                              icon: const Icon(Icons.download, size: 14),
                              label: Text(
                                'Download'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.darkMutedForeground
                                      : AppTheme.mutedForeground,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.border,
                                ),
                                foregroundColor: isDark
                                    ? AppTheme.darkMutedForeground
                                    : AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () => controller.openGradingDialog(sub),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              backgroundColor: isDark
                                  ? AppTheme.darkPrimary
                                  : AppTheme.primary,
                              foregroundColor: isDark
                                  ? AppTheme.darkPrimaryForeground
                                  : AppTheme.primaryForeground,
                            ),
                            child: Text(
                              sub.grade == null ? 'Grade'.tr : 'Re-grade'.tr,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGradingDialog() {
    return Obx(() {
      if (controller.gradingSubmission.value == null)
        return const SizedBox.shrink();
      return Container(
        color: controller.isDarkMode ? Colors.black87 : Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Grade Submission'.tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Provide a grade and feedback for the student'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      color: controller.isDarkMode
                          ? AppTheme.darkMutedForeground
                          : AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: () => controller.adjustGrade(-0.5),
                          icon: const Icon(Icons.remove, size: 18),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: controller.isDarkMode
                                  ? AppTheme.darkBorder
                                  : AppTheme.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: controller.gradeController,
                          decoration: InputDecoration(
                            labelText: 'Grade (0-20)'.tr,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: () => controller.adjustGrade(0.5),
                          icon: const Icon(Icons.add, size: 18),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: controller.isDarkMode
                                  ? AppTheme.darkBorder
                                  : AppTheme.border,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.feedbackController,
                    decoration: InputDecoration(labelText: 'Feedback'.tr),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isGrading.value
                                ? null
                                : controller.gradeSubmission,
                            child: Text(
                              controller.isGrading.value
                                  ? 'Saving...'.tr
                                  : 'Save Grade'.tr,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: controller.closeGradingDialog,
                          child: Text('Cancel'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
