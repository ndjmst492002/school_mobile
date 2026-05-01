import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' show Locale;
import '../../data/models/models.dart';
import '../../data/providers/api_provider.dart';
import '../../routes/app_routes.dart';
import 'teacher_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';

class TeacherView extends GetView<TeacherController> {
  const TeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF18181B)
              : const Color(0xFFF8FAFC),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      final auth = Get.find<AuthService>();
      final userName = auth.userFullName.isNotEmpty
          ? auth.userFullName
          : auth.userEmail;
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF18181B)
            : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF27272A) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          elevation: 1,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Dashboard'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Welcome'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            _buildNotificationButton(isDark),
            _buildChatButton(isDark),
            _buildLanguageButton(),
            _buildProfileMenu(auth, isDark),
          ],
        ),
        body: controller.showChat.value
            ? ChatView(onClose: _toggleChat)
            : _buildMainContent(isDark),
      );
    });
  }

  void _toggleChat() {
    if (controller.showChat.value) {
      controller.toggleChat();
    } else {
      Get.put(ChatController());
      controller.toggleChat();
    }
  }

  void _handleMenuAction(String action) {
    if (action == 'dark_mode') {
      final newMode = Get.isDarkMode ? ThemeMode.light : ThemeMode.dark;
      Get.changeThemeMode(newMode);
      Get.forceAppUpdate();
    } else if (action == 'logout') {
      controller.logout();
    } else if (action.startsWith('role_')) {
      final newRole = action.substring(5);
      final auth = Get.find<AuthService>();
      auth.switchRole(newRole);
      if (newRole == 'TEACHER')
        Get.offNamed(AppRoutes.teacher);
      else if (newRole == 'PARENT')
        Get.offNamed(AppRoutes.parent);
      else if (newRole == 'STUDENT')
        Get.offNamed(AppRoutes.student);
      else if (newRole == 'ADMIN')
        Get.offNamed(AppRoutes.admin);
    }
  }

  Widget _buildMainContent(bool isDark) {
    return Column(
      children: [
        _buildStatsCards(isDark),
        _buildTabs(isDark),
        Expanded(
          child: Obx(() {
            switch (controller.activeTab.value) {
              case 0:
                return _buildMyClassesTab(isDark);
              case 1:
                return _buildEnrollmentsTab(isDark);
              case 2:
                return _buildAttendanceTab(isDark);
              case 3:
                return _buildAnnouncementsTab(isDark);
              case 4:
                return _buildExercisesTab(isDark);
              case 5:
                return _buildSubmissionsTab(isDark);
              default:
                return _buildMyClassesTab(isDark);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildTabs(bool isDark) {
    final titles = [
      'My Classes'.tr,
      'Enrollments'.tr,
      'Attendance'.tr,
      'Announcements'.tr,
      'Exercises'.tr,
      'Submissions'.tr,
    ];
    final pendingCount = controller.submissions
        .where((s) => s.grade == null)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: List.generate(titles.length, (i) {
          final active = controller.activeTab.value == i;
          final showBadge = i == 5 && pendingCount > 0;

          return Expanded(
            child: InkWell(
              onTap: () => controller.activeTab.value = i,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active
                          ? const Color(0xFF3B82F6)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titles[i],
                      style: TextStyle(
                        color: active
                            ? const Color(0xFF3B82F6)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    if (showBadge) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pendingCount > 9 ? '9+' : '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationButton(bool isDark) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: _showNotificationsDialog,
        ),
        if (controller.unreadNotificationCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                controller.unreadNotificationCount > 9
                    ? '9+'
                    : '${controller.unreadNotificationCount}',
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
  }

  Widget _buildChatButton(bool isDark) {
    return Stack(
      children: [
        TextButton.icon(
          onPressed: _toggleChat,
          icon: Icon(Icons.chat, color: isDark ? Colors.white : Colors.black87),
          label: Text(
            'Chat',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        if (controller.unreadMessageCount.value > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                controller.unreadMessageCount.value > 9
                    ? '9+'
                    : '${controller.unreadMessageCount.value}',
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
  }

  Widget _buildLanguageButton() {
    final lang = Get.locale?.languageCode ?? 'en';
    final isArabic = lang == 'ar';
    return IconButton(
      icon: Text(
        isArabic ? 'EN' : 'ع',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isArabic ? const Color(0xFF3B82F6) : Colors.white,
        ),
      ),
      onPressed: () {
        final newLocale = isArabic ? const Locale('en') : const Locale('ar');
        Get.updateLocale(newLocale);
        Get.forceAppUpdate();
        Get.snackbar(
          isArabic ? 'English' : 'بالعربية',
          isArabic ? 'Switched to English' : 'تم التغيير للعربية',
        );
      },
    );
  }

  Widget _buildProfileMenu(AuthService auth, bool isDark) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF3B82F6),
        child: Text(
          auth.userFullName.isNotEmpty
              ? auth.userFullName[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onSelected: _handleMenuAction,
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'dark_mode',
          child: Row(
            children: [
              Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 12),
              Text(
                isDark ? 'Light Mode' : 'Dark Mode',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
        if (auth.hasMultipleRoles) ...[
          PopupMenuItem(
            enabled: false,
            child: Divider(color: Colors.grey[300]),
          ),
          ...auth.roles.map(
            (r) => PopupMenuItem(
              value: 'role_$r',
              child: Row(
                children: [
                  if (r == auth.role)
                    Icon(Icons.check, size: 18, color: Colors.blue)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(
                    r,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationsDialog() {
    controller.markAllNotificationsAsRead();
    final isDark = Get.isDarkMode;
    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF27272A) : Colors.white,
        child: Container(
          width: 350,
          height: MediaQuery.of(Get.context!).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: controller.notifications.length,
                    itemBuilder: (ctx, i) {
                      final n = controller.notifications[i];
                      return ListTile(
                        title: Text(
                          n.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          n.message,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final columns = screenWidth > 900 ? 5 : 3;
    final totalStudents = controller.classes.fold(
      0,
      (sum, c) => sum + (c.studentCount ?? 0),
    );
    final totalSubmitted = controller.submissions.length;
    final pendingGrading = controller.submissions
        .where((s) => s.grade == null)
        .length;
    return Obx(() {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: (screenWidth - 36 - (columns - 1) * 12) / columns,
            child: _buildStatCard(
              'Announcements'.tr,
              '${controller.announcements.length}',
              'Posted'.tr,
              Icons.campaign,
              isDark,
            ),
          ),
          SizedBox(
            width: (screenWidth - 36 - (columns - 1) * 12) / columns,
            child: _buildStatCard(
              'Total Students'.tr,
              '$totalStudents',
              'Across all classes'.tr,
              Icons.group,
              isDark,
            ),
          ),
          SizedBox(
            width: (screenWidth - 36 - (columns - 1) * 12) / columns,
            child: _buildStatCard(
              'Exercises'.tr,
              '${controller.exercises.length}',
              'Total uploaded'.tr,
              Icons.assignment,
              isDark,
            ),
          ),
          SizedBox(
            width: (screenWidth - 36 - (columns - 1) * 12) / columns,
            child: _buildStatCard(
              'Submissions'.tr,
              '$totalSubmitted',
              'Total received'.tr,
              Icons.upload_file,
              isDark,
            ),
          ),
          SizedBox(
            width: (screenWidth - 36 - (columns - 1) * 12) / columns,
            child: _buildStatCard(
              'Pending'.tr,
              '$pendingGrading',
              'Need grading'.tr,
              Icons.pending_actions,
              isDark,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Card(
      color: isDark ? const Color(0xFF27272A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
                Icon(
                  icon,
                  size: 16,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(dynamic c, bool isDark) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            c.description ?? '',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              Icon(
                Icons.group,
                size: 14,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                '${c.studentCount ?? 0} students',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyClassesTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isDark ? const Color(0xFF27272A) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Classes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.classes.isEmpty) {
                        return Text(
                          'No classes yet',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF64748B),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: controller.classes
                            .map((c) => _buildClassCard(c, isDark))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentsTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Card(
          color: isDark ? const Color(0xFF27272A) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enrollment Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.enrollments.isEmpty) {
                    return Text(
                      'No pending enrollment requests',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF64748B),
                      ),
                    );
                  }
                  return Column(
                    children: controller.enrollments
                        .map((e) => _buildEnrollmentItem(e, isDark))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollmentItem(dynamic e, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.studentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Wants to join: ${e.className}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'Requested: ${_formatDate(e.requestedAt)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: controller.respondingEnrollment.value == e.id
                    ? null
                    : () => controller.respondToEnrollment(e.id, 'approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.respondingEnrollment.value == e.id
                    ? null
                    : () => controller.respondToEnrollment(e.id, 'reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Card(
          color: isDark ? const Color(0xFF27272A) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.attendanceClassId.value.isEmpty
                      ? null
                      : controller.attendanceClassId.value,
                  decoration: InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: controller.classes
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id.toString(),
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      controller.attendanceClassId.value = v ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: controller.attendanceDate.value,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null)
                      controller.attendanceDate.value = d
                          .toIso8601String()
                          .split('T')[0];
                  },
                ),
                const SizedBox(height: 16),
                if (controller.attendanceClassId.value.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => controller.loadAttendance(),
                    child: const Text('Load Students'),
                  ),
                if (controller.selectedClassForAttendance.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Students in ${controller.selectedClassForAttendance.first.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (controller.selectedClassForAttendance.first.students !=
                      null)
                    ...controller.selectedClassForAttendance.first.students!
                        .map<Widget>((s) {
                          final status = controller.attendanceRecords[s.id];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: status == 'PRESENT'
                                  ? Colors.green[50]
                                  : (status == 'ABSENT'
                                        ? Colors.red[50]
                                        : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(s.fullName)),
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => controller.markAttendance(
                                    s.id,
                                    'PRESENT',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      controller.markAttendance(s.id, 'ABSENT'),
                                ),
                              ],
                            ),
                          );
                        }),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.isSavingAttendance.value
                      ? null
                      : () => controller.saveAttendance(),
                  icon: controller.isSavingAttendance.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save Attendance'),
                ),
                if (controller.hasAttendanceData) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Summary for ${controller.attendanceDate.value}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${controller.presentCount}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Text(
                                      'Present',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${controller.absentCount}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const Text(
                                      'Absent',
                                      style: TextStyle(color: Colors.red),
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
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isDark ? const Color(0xFF27272A) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Announcement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: controller.announcementTitle.value,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (v) => controller.announcementTitle.value = v,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: controller.announcementClassId.value.isEmpty
                          ? null
                          : controller.announcementClassId.value,
                      decoration: InputDecoration(
                        labelText: 'Select Class',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('All my classes'),
                        ),
                        ...controller.classes.map(
                          (c) => DropdownMenuItem(
                            value: c.id.toString(),
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          controller.announcementClassId.value = v ?? '',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: controller.announcementContent.value,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 4,
                      onChanged: (v) =>
                          controller.announcementContent.value = v,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.isPosting.value
                          ? null
                          : () => controller.createAnnouncement(),
                      icon: controller.isPosting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: const Text('Post Announcement'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF27272A) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Announcements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.announcements.isEmpty) {
                        return Text(
                          'No announcements yet',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF64748B),
                          ),
                        );
                      }
                      return Column(
                        children: controller.announcements
                            .map((a) => _buildAnnouncementItem(a, isDark))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(dynamic a, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : const Color(0xFFF8FAFC),
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
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
                child: Text(
                  a.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (a.className != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    a.className,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            a.content,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By ${a.teacherName ?? "Teacher"} - ${_formatDate(a.createdAt)}',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isDark ? const Color(0xFF27272A) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Exercise',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: controller.uploadTitle.value,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (v) => controller.uploadTitle.value = v,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: controller.uploadClassId.value.isEmpty
                          ? null
                          : controller.uploadClassId.value,
                      decoration: InputDecoration(
                        labelText: 'Select Class',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Select a class'),
                        ),
                        ...controller.classes.map(
                          (c) => DropdownMenuItem(
                            value: c.id.toString(),
                            child: Text(
                              '${c.name} (${c.studentCount ?? 0} students)',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          controller.uploadClassId.value = v ?? '',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: controller.uploadDescription.value,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (v) => controller.uploadDescription.value = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: controller.uploadDueDate.value,
                      decoration: InputDecoration(
                        labelText: 'Due Date (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: Get.context!,
                              initialDate: DateTime.now().add(
                                const Duration(days: 7),
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (d != null)
                              controller.uploadDueDate.value = d
                                  .toIso8601String()
                                  .split('T')[0];
                          },
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Skills (Optional)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.skills.isEmpty
                            ? [
                                Text(
                                  'No skills available',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : const Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ]
                            : controller.skills
                                  .map(
                                    (s) => FilterChip(
                                      label: Text(s.name),
                                      selected: controller.selectedSkills
                                          .contains(s.id),
                                      onSelected: (sel) {
                                        if (sel)
                                          controller.selectedSkills.add(s.id);
                                        else
                                          controller.selectedSkills.remove(
                                            s.id,
                                          );
                                      },
                                    ),
                                  )
                                  .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: controller.selectedFile.value != null
                                  ? Text(
                                      controller.selectedFile.value!.name,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                      ),
                                    )
                                  : Text(
                                      'No file selected',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => controller.pickFile(),
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.isUploading.value
                          ? null
                          : () => controller.uploadExercise(),
                      icon: controller.isUploading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: const Text('Upload Exercise'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: isDark ? const Color(0xFF27272A) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Exercises',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.exercises.isEmpty) {
                        return Text(
                          'No exercises yet',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF64748B),
                          ),
                        );
                      }
                      return Column(
                        children: controller.exercises
                            .map((e) => _buildExerciseItem(e, isDark))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(dynamic ex, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
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
                      ex.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      ex.description ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ex.className,
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (ex.dueDate != null) ...[
            const SizedBox(height: 8),
            Wrap(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(ex.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
          if (ex.skills != null && (ex.skills as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (ex.skills as List).map<Widget>((si) {
                final sn = si is Map ? si['name'] : 'Skill $si';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sn,
                    style: TextStyle(fontSize: 10, color: Colors.purple[800]),
                  ),
                );
              }).toList(),
            ),
          ],
          if (ex.fileUrl != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => controller.downloadExercise(ex.id),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Card(
          color: isDark ? const Color(0xFF27272A) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Submissions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.submissions.isEmpty) {
                    return Text(
                      'No submissions yet',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF64748B),
                      ),
                    );
                  }
                  return Column(
                    children: controller.submissions
                        .map((s) => _buildSubmissionItem(s, isDark))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionItem(dynamic s, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
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
                      s.studentName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Exercise: ${s.exerciseTitle} | Submitted: ${_formatDate(s.submittedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (s.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${s.grade}/20',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (s.submissionFileUrl != null)
                ElevatedButton.icon(
                  onPressed: () => controller.downloadSubmission(s.id),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.openGradingDialog(s),
                child: Text(s.grade != null ? 'Re-grade' : 'Grade'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return d;
    }
  }
}
