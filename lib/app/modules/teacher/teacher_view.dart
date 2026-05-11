import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'teacher_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';
import '../../data/providers/api_provider.dart';
import '../../routes/app_routes.dart';

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
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Profile Not Found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You need to complete your teacher profile before accessing the dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
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
          title: null,
          toolbarHeight: controller.showChat.value ? 60 : 80,
          actions: [
            if (!controller.showChat.value) ...[
              _buildNotificationBell(),
              _buildChatButton(),
              _buildProfileMenu(),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Get.delete<ChatController>();
                  controller.toggleChat();
                  controller.updateUnreadMessageCount(0);
                },
              ),
            ],
          ],
          bottom: controller.showChat.value
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Teacher Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome, ${controller.userName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
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
          TextButton.icon(
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
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
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
                decoration: const BoxDecoration(
                  color: Colors.red,
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

  Widget _buildProfileMenu() {
    final auth = Get.find<AuthService>();
    return Obx(
      () => PopupMenuButton<String>(
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue,
          child: Text(
            controller.userName.isNotEmpty
                ? controller.userName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onSelected: (v) {
          if (v == 'logout')
            controller.logout();
          else if (v == 'parent')
            controller.switchToRole('PARENT');
          else if (v == 'student')
            controller.switchToRole('STUDENT');
          else if (v == 'admin')
            controller.switchToRole('ADMIN');
          else if (v == 'dark_mode')
            controller.toggleDarkMode();
          else if (v == 'language')
            controller.toggleLanguage();
        },
        itemBuilder: (ctx) => [
          PopupMenuItem(
            enabled: false,
            child: Text(
              controller.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'dark_mode',
            child: Row(
              children: [
                Icon(
                  controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(controller.isDarkMode ? 'Light Mode' : 'Dark Mode'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'language',
            child: Row(
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 8),
                Text(controller.currentLanguage == 'en' ? 'ع' : 'EN'),
              ],
            ),
          ),
          if (auth.hasMultipleRoles) ...[
            const PopupMenuDivider(),
            if (auth.roles.contains('PARENT'))
              PopupMenuItem(
                value: 'parent',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 20),
                        const SizedBox(width: 8),
                        Text('Switch to Parent'.tr),
                      ],
                    ),
                    if (auth.role == 'PARENT')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
            if (auth.roles.contains('STUDENT'))
              PopupMenuItem(
                value: 'student',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 8),
                        Text('Switch to Student'.tr),
                      ],
                    ),
                    if (auth.role == 'STUDENT')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
            if (auth.roles.contains('ADMIN'))
              PopupMenuItem(
                value: 'admin',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, size: 20),
                        const SizedBox(width: 8),
                        Text('Switch to Admin'.tr),
                      ],
                    ),
                    if (auth.role == 'ADMIN')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
          ],
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text('Logout'.tr, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    controller.markAllNotificationsAsRead();
    Get.dialog(
      Dialog(
        alignment: Alignment.centerRight,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: 350,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    return const Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.notifications.length,
                    itemBuilder: (ctx, i) {
                      final n = controller.notifications[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: n.isRead ? null : Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _getTimeAgo(n.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n.message),
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

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
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
            // Tabs
            SingleChildScrollView(
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
            const SizedBox(height: 12),
            // Tab content
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        selected: isActive,
        onSelected: (selected) {
          if (selected) controller.setActiveTab(tabId);
        },
        selectedColor: Colors.blue,
        labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildMyClassesContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Classes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          const Text(
            'Enrollment Requests',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Students requesting to join your classes',
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                    enrollment.studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Wants to join: ${enrollment.className}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Requested: ${_formatDateTime(enrollment.requestedAt)}',
                                    style: const TextStyle(
                                      color: Colors.grey,
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
                                    backgroundColor: Colors.red,
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
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mark Attendance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              _buildAttendanceButton(),
            ],
          ),
          if (controller.showAttendanceForm.value) ...[
            const SizedBox(height: 12),
            _buildAttendanceForm(),
          ],
          const SizedBox(height: 16),
          _buildClassesCard(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Announcements',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Exercises',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
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
          const Text(
            'Submissions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              ? 'Cancel'
              : 'Create Announcement',
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
          controller.showAttendanceForm.value ? 'Cancel' : 'Mark Attendance',
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
          controller.showUploadForm.value ? 'Cancel' : 'Upload Exercise',
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
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Announcements',
                '${controller.announcements.length}',
                'Posted',
                Colors.blue,
                Icons.campaign,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Total Students',
                '${controller.totalStudents}',
                'Across all classes',
                Colors.green,
                Icons.people,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Exercises',
                '${controller.exercises.length}',
                'Total uploaded',
                Colors.purple,
                Icons.assignment,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Submissions',
                '${controller.submissions.length}',
                'Total received',
                Colors.orange,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Pending',
                '${controller.pendingCount}',
                'Need grading',
                Colors.red,
                Icons.pending_actions,
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
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Container(
        width: 150,
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
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  Icon(icon, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
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
            const Text(
              'Upload Exercise',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.uploadTitleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.uploadDescController,
              decoration: const InputDecoration(labelText: 'Description'),
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
                      labelText: 'Due Date',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            controller.uploadDueDateController.text =
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
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
                decoration: const InputDecoration(labelText: 'Select Class *'),
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
            const Text(
              'Skills (Optional)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.skills.isEmpty) {
                return const Text(
                  'No skills available',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                );
              }
              return Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.skills.map((skill) {
                      return Obx(
                        () => CheckboxListTile(
                          title: Text(
                            skill.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          value: controller.selectedSkills.contains(skill.id),
                          onChanged: (checked) {
                            if (checked == true) {
                              controller.addSkill(skill.id);
                            } else {
                              controller.removeSkill(skill.id);
                            }
                          },
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              final selectedFile = controller.selectedFile.value;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedFile != null
                          ? Icons.insert_drive_file
                          : Icons.attach_file,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile.name
                            : 'No file selected',
                        style: TextStyle(
                          fontSize: 13,
                          color: selectedFile != null
                              ? Colors.black
                              : Colors.grey,
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
                                  ? 'Uploading...'
                                  : 'Upload',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.pickFile,
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: Text('Choose File'.tr),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
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
                                  ? 'Uploading...'
                                  : 'Upload',
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
            const Text(
              'Create Announcement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.announcementTitleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.announcementContentController,
              decoration: const InputDecoration(labelText: 'Content *'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.announcementClassId.value.isEmpty
                    ? null
                    : controller.announcementClassId.value,
                decoration: const InputDecoration(
                  labelText: 'Class (Optional)',
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Classes')),
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
                child: Text(controller.isPosting.value ? 'Posting...' : 'Post'),
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
            const Text(
              'Mark Attendance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.attendanceClassId.value.isEmpty
                    ? null
                    : controller.attendanceClassId.value,
                decoration: const InputDecoration(labelText: 'Select Class'),
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
                  controller.attendanceRecords.clear();
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
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.showLoadStudentsButton.value &&
                  controller.attendanceClassId.value.isNotEmpty) {
                return ElevatedButton.icon(
                  onPressed: controller.isLoadingAttendance.value
                      ? null
                      : () => controller.loadAttendance(),
                  icon: controller.isLoadingAttendance.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.people),
                  label: Text(
                    controller.isLoadingAttendance.value
                        ? 'Loading...'
                        : 'Load Students',
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
              if (selectedClass == null ||
                  selectedClass.students == null ||
                  controller.attendanceRecords.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Students:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...selectedClass.students!.map((student) {
                    final status =
                        controller.attendanceRecords[student.id] ?? 'PRESENT';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(student.fullName)),
                          ChoiceChip(
                            label: Text('Present'.tr),
                            selected: status == 'PRESENT',
                            onSelected: (selected) {
                              if (selected) {
                                controller.setStudentAttendance(
                                  student.id,
                                  'PRESENT',
                                );
                              }
                            },
                            selectedColor: Colors.green,
                            labelStyle: TextStyle(
                              color: status == 'PRESENT'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('Absent'.tr),
                            selected: status == 'ABSENT',
                            onSelected: (selected) {
                              if (selected) {
                                controller.setStudentAttendance(
                                  student.id,
                                  'ABSENT',
                                );
                              }
                            },
                            selectedColor: Colors.red,
                            labelStyle: TextStyle(
                              color: status == 'ABSENT'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
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
                            ? 'Saving...'
                            : 'Save Attendance',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.attendanceRecords.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final presentCount = controller.attendanceRecords.values
                        .where((s) => s == 'PRESENT')
                        .length;
                    final absentCount = controller.attendanceRecords.values
                        .where((s) => s == 'ABSENT')
                        .length;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Summary for ${controller.attendanceDateController.text}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$presentCount',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      Text(
                                        'Present',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[700],
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
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$absentCount',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                      Text(
                                        'Absent',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red[700],
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
                    );
                  }),
                ],
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
        child: Obx(() {
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
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Class: ${ann.className}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDateTime(ann.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
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
                child: Text('No classes assigned'.tr),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.classes.length,
            itemBuilder: (context, index) {
              final cls = controller.classes[index];
              return ListTile(
                title: Text(
                  cls.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cls.description.isNotEmpty)
                      Text(
                        cls.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${cls.studentCount} students enrolled',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                        ),
                      ),
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
      ),
    );
  }

  Widget _buildExercisesOnlyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
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
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (ex.className != null && ex.className!.isNotEmpty)
                      Text(
                        ex.className!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (ex.dueDate != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Due: ${ex.dueDate}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (ex.fileUrl != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => controller.downloadExercise(ex.id),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text(
                            'Download',
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
            const Text(
              'Submissions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.submissions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No submissions'.tr),
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                sub.exerciseTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (sub.grade != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${sub.grade}/20',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sub.studentName ?? 'Student',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Submitted: ${_formatDateTime(sub.submittedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (sub.submissionFileUrl != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      controller.downloadSubmission(sub.id),
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text(
                                    'Download',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                            if (sub.submissionFileUrl != null)
                              const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    controller.openGradingDialog(sub),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  backgroundColor: sub.grade == null
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                                child: Text(
                                  sub.grade == null ? 'Grade' : 'Edit Grade',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
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
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Grade Submission',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Grade (0-20)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.feedbackController,
                    decoration: const InputDecoration(labelText: 'Feedback'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isGrading.value
                                ? null
                                : controller.gradeSubmission,
                            child: Text(
                              controller.isGrading.value ? 'Saving...' : 'Save',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
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
