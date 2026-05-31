import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../../main.dart';
import 'student_controller.dart';

class StudentView extends GetView<StudentController> {
  const StudentView({super.key});

  static const List<Map<String, dynamic>> _allLevelsData = [
    {'id': 1, 'name': '1AP'}, {'id': 2, 'name': '2AP'},
    {'id': 3, 'name': '3AP'}, {'id': 4, 'name': '4AP'},
    {'id': 5, 'name': '5AP'}, {'id': 6, 'name': '1AM'},
    {'id': 7, 'name': '2AM'}, {'id': 8, 'name': '3AM'},
    {'id': 9, 'name': '4AM'}, {'id': 10, 'name': '1AS'},
    {'id': 11, 'name': '2AS'}, {'id': 12, 'name': '3AS'},
  ];

  List<Level> get _allLevels =>
      _allLevelsData.map((e) => Level(id: e['id'] as int, name: e['name'] as String)).toList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Get.find<ThemeService>().isDarkMode;
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.profileNotFound.value) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile Not Found'.tr,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You need to complete your student profile before accessing the dashboard.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.profileCompletion,
                      arguments: {'role': 'STUDENT'},
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
        backgroundColor: isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF),
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
                _buildLanguageToggle(),
                _buildProfileMenu(),
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
                    'Student Dashboard'.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.isViewingAsChild
                        ? '${"Viewing as:".tr} ${controller.viewingAsChildName ?? controller.userName}'
                        : '${"Welcome".tr}, ${controller.userName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildStatsCards(isDark),
                const SizedBox(height: 16),
                _buildTabs(isDark),
                const SizedBox(height: 12),
                _buildTabContent(isDark),
                const SizedBox(height: 16),
                _buildSubmitDialog(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatsCards(bool isDark) {
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
                'My Classes',
                '${controller.enrolledCount}',
                'Enrolled in',
                Colors.blue,
                Icons.class_,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Exercises',
                '${controller.exercises.length}',
                'Available',
                Colors.purple,
                Icons.assignment,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Submitted',
                '${controller.submissions.length}',
                'Completed',
                Colors.green,
                Icons.check_circle,
                isDark,
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
    bool isDark,
  ) {
    return Container(
      width: 150,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : Colors.white,
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
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
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              Icon(icon, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Announcements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : null),
            ),
            const SizedBox(height: 4),
            Text(
              'Announcements from your teachers',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty) {
                return Text('No announcements', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500]));
              }
              // Group by teacher name
              final grouped = <String, List<Announcement>>{};
              for (final ann in controller.announcements) {
                final key = ann.teacherName ?? 'Unknown';
                grouped.putIfAbsent(key, () => []);
                grouped[key]!.add(ann);
              }
              return Column(
                children: grouped.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'From: ${entry.key}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...entry.value.map((ann) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[50]!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ann.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ann.content,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 16,
                                runSpacing: 4,
                                children: [
                                  if (ann.className != null)
                                    Text(
                                      'Class: ${ann.className}',
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                                    ),
                                  Text(
                                    _formatDateTime(ann.createdAt),
                                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Attendance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Your attendance record',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.attendance.isEmpty) {
                return const Text('No attendance records');
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.green[900] : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${controller.presentCount}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.green[400] : Colors.green[600],
                                ),
                              ),
                              Text(
                                'Present',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.green[400] : Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.red[900] : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${controller.absentCount}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.red[400] : Colors.red[600],
                                ),
                              ),
                              Text(
                                'Absent',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.red[400] : Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.attendance.length > 10
                        ? 10
                        : controller.attendance.length,
                    itemBuilder: (context, index) {
                      final record = controller.attendance[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.className ?? 'Class',
                                    style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : null),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDate(record.date)} - Teacher: ${record.teacherName ?? ''}',
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: record.status == 'PRESENT'
                                    ? (isDark ? Colors.green[900] : Colors.green[100])
                                    : (isDark ? Colors.red[900] : Colors.red[100]),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    record.status == 'PRESENT' ? Icons.person : Icons.person_off,
                                    size: 16,
                                    color: record.status == 'PRESENT'
                                        ? (isDark ? Colors.green[200] : Colors.green[800])
                                        : (isDark ? Colors.red[200] : Colors.red[800]),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    record.status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: record.status == 'PRESENT'
                                          ? (isDark ? Colors.green[200] : Colors.green[800])
                                          : (isDark ? Colors.red[200] : Colors.red[800]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value, String currentFilter, bool isDark) {
    final isSelected = currentFilter == value;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (value == 'all') {
      backgroundColor = isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.grey[800]! : Colors.white);
      textColor = isSelected ? Colors.white : (isDark ? Colors.grey[300]! : Colors.grey[700]!);
      borderColor = isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.grey[700]! : Colors.grey[300]!);
    } else if (value == 'enrolled') {
      backgroundColor = isSelected ? const Color(0xFF16A34A) : (isDark ? Colors.grey[800]! : Colors.white);
      textColor = isSelected ? Colors.white : (isDark ? Colors.grey[300]! : Colors.grey[700]!);
      borderColor = isSelected ? const Color(0xFF16A34A) : (isDark ? Colors.grey[700]! : Colors.grey[300]!);
    } else if (value == 'not_enrolled') {
      backgroundColor = isSelected ? const Color(0xFFF97316) : (isDark ? Colors.grey[800]! : Colors.white);
      textColor = isSelected ? Colors.white : (isDark ? Colors.grey[300]! : Colors.grey[700]!);
      borderColor = isSelected ? const Color(0xFFF97316) : (isDark ? Colors.grey[700]! : Colors.grey[300]!);
    } else {
      backgroundColor = isDark ? Colors.grey[800]! : Colors.white;
      textColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
      borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: GestureDetector(
        onTap: () => controller.setEnrollmentFilter(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
        ),
      ),
    );
  }

  Widget _buildClassesCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Classes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse and enroll in classes to access exercises',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            // Search Bar
            TextField(
              controller: controller.searchTextController,
              decoration: InputDecoration(
                hintText: 'Search by class name or teacher...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onChanged: (value) => controller.setSearchQuery(value),
            ),
            const SizedBox(height: 12),
            // Level Filter Dropdown
            Obx(() {
              final levels = _allLevels;
              return SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<int>(
                  value: controller.levelFilter.value,
                  decoration: InputDecoration(
                    labelText: 'Filter by Level'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Levels'.tr),
                    ),
                    ...levels.map((level) => DropdownMenuItem<int>(
                      value: level.id,
                      child: Text(level.name),
                    )),
                  ],
                  onChanged: (value) {
                    controller.setLevelFilter(value);
                    controller.loadData();
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            // Filter Buttons
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterButton(
                    'All Classes',
                    'all',
                    controller.enrollmentFilter.value,
                    isDark,
                  ),
                  _buildFilterButton(
                    'Enrolled',
                    'enrolled',
                    controller.enrollmentFilter.value,
                    isDark,
                  ),
                  _buildFilterButton(
                    'Not Enrolled',
                    'not_enrolled',
                    controller.enrollmentFilter.value,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final filteredClasses = controller.filteredClasses;
              if (filteredClasses.isEmpty) {
                return const Text('No classes match your filters');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredClasses.length,
                itemBuilder: (context, index) {
                  final cls = filteredClasses[index];
                  final firstTeacher = cls.teachers?.isNotEmpty == true ? cls.teachers!.first : null;
                  final classTeacherId = firstTeacher?.classTeacherId ?? cls.id;
                  final enrollmentStatus = controller.getEnrollmentStatus(cls.id);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
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
                                cls.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cls.description.isNotEmpty
                                    ? cls.description
                                    : 'No description provided',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (cls.teacherName != null || cls.levelName != null) ...[
                                if (cls.teacherName != null)
                                  Text(
                                    'Teacher: ${cls.teacherName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                                    ),
                                  ),
                                if (cls.levelName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Level: ${cls.levelName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                              ],
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${cls.studentCount} students enrolled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() {
                                final status = controller.getEnrollmentStatus(cls.id);
                                if (status == 'APPROVED') {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.green[900]! : Colors.green[100]!,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 12, color: isDark ? Colors.green[200] : Colors.green[800]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Enrolled',
                                          style: TextStyle(fontSize: 12, color: isDark ? Colors.green[200] : Colors.green[800]),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (status == 'PENDING') {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.amber[900]! : Colors.amber[100]!,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Pending',
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.amber[200] : Colors.amber[800]),
                                    ),
                                  );
                                } else if (status == 'REJECTED') {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.red[900]! : Colors.red[100]!,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Rejected - Can Resubmit',
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.red[200] : Colors.red[800]),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Obx(() {
                          final status = controller.getEnrollmentStatus(cls.id);
                          if (status == 'APPROVED') {
                            return ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: isDark ? Colors.green[900] : Colors.green[100],
                                foregroundColor: isDark ? Colors.green[200] : Colors.green[800],
                                disabledBackgroundColor: isDark ? Colors.green[900] : Colors.green[100],
                                disabledForegroundColor: isDark ? Colors.green[200] : Colors.green[800],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: isDark ? Colors.green[200] : Colors.green[800]),
                                  const SizedBox(width: 6),
                                  Text('Enrolled', style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          } else if (status == 'PENDING') {
                            return ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: Colors.transparent,
                                foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                                disabledBackgroundColor: Colors.transparent,
                                disabledForegroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 6),
                                  Text('Pending...', style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          } else if (status == 'REJECTED') {
                            return controller.enrolling.value == classTeacherId
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : ElevatedButton(
                                    onPressed: () => controller.enrollInClass(classTeacherId),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      backgroundColor: isDark ? Colors.red[900] : Colors.red[100],
                                      foregroundColor: isDark ? Colors.red[200] : Colors.red[800],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text('Resend Request', style: const TextStyle(fontSize: 14)),
                                  );
                          }
                          return controller.enrolling.value == classTeacherId
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : ElevatedButton(
                                  onPressed: () => controller.enrollInClass(classTeacherId),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    minimumSize: const Size(0, 42),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_add, size: 16, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Text('Request Enrollment', style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                );
                        }),
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

  Widget _buildExercisesCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Exercises',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Download and view exercises from your enrolled classes',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.exercises.isEmpty) {
                return const Text('No exercises. Enroll in classes first.');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.exercises.length > 10
                    ? 10
                    : controller.exercises.length,
                itemBuilder: (context, index) {
                  final ex = controller.exercises[index];
                  final submitted = controller.isSubmitted(ex.id);
                  final isOverdue = controller.isOverdue(ex);
                  final submission = controller.getSubmission(ex.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  ex.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (submitted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.green[900] : Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Submitted',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.green[200] : Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  if (isOverdue && !submitted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.red[900] : Colors.red[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Overdue',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.red[200] : Colors.red[800],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ex.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[300] : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (ex.level != null)
                                Text(
                                  'Level: ${ex.level}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              if (ex.className != null)
                                Text(
                                  'Class: ${ex.className}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              if (ex.teacherName != null)
                                Text(
                                  'Teacher: ${ex.teacherName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              if (ex.status != 'APPROVED')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                  color: ex.status == 'REJECTED'
                                      ? (isDark ? Colors.red[900] : Colors.red[100])
                                      : (isDark ? Colors.amber[900] : Colors.amber[100]),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ex.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ex.status == 'REJECTED'
                                      ? (isDark ? Colors.red[200] : Colors.red[800])
                                      : (isDark ? Colors.amber[200] : Colors.amber[800]),
                                ),
                                  ),
                                ),
                              if (ex.dueDate != null)
                                Text(
                                  'Due: ${_formatDate(ex.dueDate!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue && !submitted
                                        ? Colors.red
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                  ),
                                ),
                            ],
                          ),
                          if (submission != null &&
                              submission.grade != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.blue[950] : Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grade: ${submission.grade}/20',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : null,
                                    ),
                                  ),
                                  if (submission.feedback.isNotEmpty)
                                    Text(
                                      submission.feedback,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[300] : null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (ex.fileUrl != null)
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      controller.downloadExercise(ex.id),
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text('Download'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              if (!submitted) ...[
                                ElevatedButton.icon(
                                  onPressed: isOverdue
                                      ? null
                                      : () => controller.openSubmitDialog(ex),
                                  icon: const Icon(Icons.upload, size: 16),
                                  label: Text(isOverdue ? 'Overdue' : 'Submit'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                if (!isOverdue)
                                  TextButton(
                                    onPressed: () => controller.markAsDone(ex.id),
                                    child: Text(
                                      'Mark as Done'.tr,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ] else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.green[900] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: isDark ? Colors.green[200] : Colors.green[800],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Submitted',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.green[200] : Colors.green[800],
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }

  Widget _buildSubmitDialog() {
    return Obx(() {
      if (controller.selectedExercise.value == null)
        return const SizedBox.shrink();
      return Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Submit Solution',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.selectedExercise.value?.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.pickSubmitFile,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: Text(
                        controller.selectedSubmitFile.value != null
                            ? controller.selectedSubmitFile.value!.name
                            : 'Choose File',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submitExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              controller.isSubmitting.value
                                  ? 'Submitting...'.tr
                                  : 'Submit'.tr,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.closeSubmitDialog,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'File is optional. Submit without a file to mark as done.'.tr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
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

  Widget _buildLanguageToggle() {
    return Obx(() {
      return TextButton(
        onPressed: controller.toggleLanguage,
        child: SizedBox(
          width: 28,
          child: Text(
            controller.currentLanguage == 'en' ? 'ع' : 'EN',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
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
          color: isDark ? const Color(0xFF262638) : Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262638) : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!, width: 1),
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
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : null),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Obx(() {
                  if (controller.notifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                        color: notification.isRead ? null : (isDark ? Colors.blue[900]!.withValues(alpha: 0.3) : Colors.blue[50]),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight: notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        color: isDark ? Colors.white : null,
                                      ),
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[300] : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getTimeAgo(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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

  Widget _buildProfileMenu() {
    final auth = Get.find<AuthService>();
    return Obx(
      () => PopupMenuButton<String>(
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                controller.userName.isNotEmpty
                    ? controller.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                Text(controller.isDarkMode ? 'Light Mode' : 'Dark Mode'),
              ],
            ),
          ),
          if (auth.hasMultipleRoles) ...[
            const PopupMenuDivider(),
            const PopupMenuItem(
              enabled: false,
              child: Text('Switch Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            ...auth.roles.where((r) {
              if (auth.role == 'PARENT' && r == 'STUDENT') return false;
              if (auth.role == 'TEACHER' && r == 'STUDENT') return false;
              return true;
            }).map((role) {
              IconData icon;
              Color iconColor;
              String label;
              switch (role) {
                case 'ADMIN':
                  icon = Icons.shield;
                  iconColor = Colors.red;
                  label = 'Administrator';
                  break;
                case 'TEACHER':
                  icon = Icons.school;
                  iconColor = Colors.blue;
                  label = 'Teacher';
                  break;
                case 'STUDENT':
                  icon = Icons.people;
                  iconColor = Colors.green;
                  label = 'Student';
                  break;
                case 'PARENT':
                  icon = Icons.child_care;
                  iconColor = Colors.purple;
                  label = 'Parent';
                  break;
                default:
                  icon = Icons.person;
                  iconColor = Colors.grey;
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
                      Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey[500])),
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
                const Icon(Icons.logout, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text('Logout', style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabButton('class-enrollment', 'My Classes', isDark),
            _buildTabButton('announcements', 'Announcements', isDark),
            _buildTabButton('available-exercises', 'Exercises', isDark),
            _buildTabButton('my-attendance', 'Attendance', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, bool isDark) {
    return Obx(() {
      final isActive = controller.activeTab.value == tabId;
      return GestureDetector(
        onTap: () => controller.setActiveTab(tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppTheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppTheme.primary : Colors.grey[600],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabContent(bool isDark) {
    return Obx(() {
      switch (controller.activeTab.value) {
        case 'class-enrollment':
          return _buildClassesCard(isDark);
        case 'announcements':
          return _buildAnnouncementsCard(isDark);
        case 'available-exercises':
          return _buildExercisesCard(isDark);
        case 'my-attendance':
          return _buildAttendanceCard(isDark);
        default:
          return _buildClassesCard(isDark);
      }
    });
  }
}
