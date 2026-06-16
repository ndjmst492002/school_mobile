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

  List<Level> get _allLevels => _allLevelsData
      .map((e) => Level(id: e['id'] as int, name: e['name'] as String))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Get.find<ThemeService>().isDarkMode;
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkBackground
              : AppTheme.background,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.profileNotFound.value) {
        return Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkBackground
              : AppTheme.background,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  Text(
                    'Profile Not Found'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkForeground
                          : AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You need to complete your student profile before accessing the dashboard.'
                        .tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkMutedForeground
                          : AppTheme.mutedForeground,
                    ),
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
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          title: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                    '${"Welcome".tr}, ${controller.userName}',
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
        body: Stack(
          children: [
            RefreshIndicator(
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
                  ],
                ),
              ),
            ),
            _buildSubmitDialog(),
          ],
        ),
      );
    });
  }

  Widget _buildStatsCards(bool isDark) {
    return Obx(
      () => SizedBox(
        height: 125,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(
              width: 230,
              child: _buildStatCard(
                'My Classes'.tr,
                '${controller.enrolledCount}',
                'Enrolled in'.tr,
                Icons.check_circle,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 230,
              child: _buildStatCard(
                'Available Exercises'.tr,
                '${controller.exercises.length}',
                'From enrolled classes'.tr,
                Icons.description,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 230,
              child: _buildStatCard(
                'Submitted'.tr,
                '${controller.submissions.length}',
                'Exercises completed'.tr,
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
    IconData icon,
    bool isDark,
  ) {
    return Container(
      width: 200,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.border,
        ),
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
    );
  }

  Widget _buildAnnouncementsCard(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Announcements'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Announcements from your teachers'.tr,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty) {
                return Text(
                  'No announcements'.tr,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkMutedForeground
                        : AppTheme.mutedForeground,
                  ),
                );
              }
              // Group by teacher name
              final grouped = <String, List<Announcement>>{};
              for (final ann in controller.announcements) {
                final key = ann.teacherName ?? 'Unknown'.tr;
                grouped.putIfAbsent(key, () => []);
                grouped[key]!.add(ann);
              }
              return Column(
                children: [
                  for (final entry in grouped.entries.toList()) ...[
                    if (entry != grouped.entries.first)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          color: isDark ? AppTheme.darkBorder : AppTheme.border,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${"From:".tr} ${entry.key}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: isDark
                                ? AppTheme.darkForeground
                                : AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...entry.value.map(
                          (ann) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSurface.withValues(alpha: 0.5)
                                  : AppTheme.muted,
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.border,
                              ),
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
                                    color: isDark
                                        ? AppTheme.darkForeground
                                        : AppTheme.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ann.content,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 4,
                                  children: [
                                    if (ann.className != null)
                                      Text(
                                        '${"Class:".tr} ${ann.className}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppTheme.darkMutedForeground
                                              : AppTheme.mutedForeground,
                                        ),
                                      ),
                                    Text(
                                      _formatDateTime(ann.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppTheme.darkMutedForeground
                                            : AppTheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAttendanceCard(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Attendance'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your attendance record'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppTheme.darkMutedForeground
                      : AppTheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.attendance.isEmpty) {
                  return Text('No attendance records'.tr);
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkBadgeGreenBg
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.presentCount}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkBadgeGreenText
                                        : Colors.green[700],
                                  ),
                                ),
                                Text(
                                  'Present'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkBadgeRedBg
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${controller.absentCount}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkBadgeRedText
                                        : Colors.red[700],
                                  ),
                                ),
                                Text(
                                  'Absent'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
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
                    const SizedBox(height: 12),
                    Column(
                      children: controller.attendance.take(10).map((record) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.border,
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
                                      record.className ?? 'Class'.tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppTheme.darkForeground
                                            : AppTheme.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(record.date),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppTheme.darkMutedForeground
                                            : AppTheme.mutedForeground,
                                      ),
                                    ),
                                    if (record.teacherName != null &&
                                        record.teacherName!.isNotEmpty)
                                      Text(
                                        '${"Teacher:".tr} ${record.teacherName}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppTheme.darkMutedForeground
                                              : AppTheme.mutedForeground,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: record.status == 'PRESENT'
                                      ? (isDark
                                            ? AppTheme.darkBadgeGreenBg
                                            : Colors.green[100])
                                      : (isDark
                                            ? AppTheme.darkBadgeRedBg
                                            : Colors.red[100]),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      record.status == 'PRESENT'
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: record.status == 'PRESENT'
                                          ? (isDark
                                                ? AppTheme.darkBadgeGreenText
                                                : Colors.green[700])
                                          : (isDark
                                                ? AppTheme.darkBadgeRedText
                                                : Colors.red[700]),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      record.status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: record.status == 'PRESENT'
                                          ? (isDark
                                                ? AppTheme.darkBadgeGreenText
                                                : Colors.green[700])
                                          : (isDark
                                                ? AppTheme.darkBadgeRedText
                                                : Colors.red[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      ));
  }

  Widget _buildFilterButton(
    String label,
    String value,
    String currentFilter,
    bool isDark,
  ) {
    final isSelected = currentFilter == value;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (value == 'all') {
      backgroundColor = isSelected
          ? const Color(0xFF2563EB)
          : (isDark ? AppTheme.darkCard : AppTheme.card);
      textColor = isSelected
          ? Colors.white
          : (isDark ? AppTheme.darkMutedForeground : AppTheme.foreground);
      borderColor = isSelected
          ? const Color(0xFF2563EB)
          : (isDark ? AppTheme.darkBorder : AppTheme.border);
    } else if (value == 'enrolled') {
      backgroundColor = isSelected
          ? const Color(0xFF16A34A)
          : (isDark ? AppTheme.darkCard : AppTheme.card);
      textColor = isSelected
          ? Colors.white
          : (isDark ? AppTheme.darkMutedForeground : AppTheme.foreground);
      borderColor = isSelected
          ? const Color(0xFF16A34A)
          : (isDark ? AppTheme.darkBorder : AppTheme.border);
    } else if (value == 'not_enrolled') {
      backgroundColor = isSelected
          ? const Color(0xFFF97316)
          : (isDark ? AppTheme.darkCard : AppTheme.card);
      textColor = isSelected
          ? Colors.white
          : (isDark ? AppTheme.darkMutedForeground : AppTheme.foreground);
      borderColor = isSelected
          ? const Color(0xFFF97316)
          : (isDark ? AppTheme.darkBorder : AppTheme.border);
    } else {
      backgroundColor = isDark ? AppTheme.darkCard : AppTheme.card;
      textColor = isDark ? AppTheme.darkMutedForeground : AppTheme.foreground;
      borderColor = isDark ? AppTheme.darkBorder : AppTheme.border;
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
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
            Text(
              'Available Classes'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse and enroll in classes to access exercises'.tr,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            // Search Bar
            TextField(
              controller: controller.searchTextController,
              decoration: InputDecoration(
                hintText: 'Search by class name or teacher'.tr,
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
                    ...levels.map(
                      (level) => DropdownMenuItem<int>(
                        value: level.id,
                        child: Text(level.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    controller.setLevelFilter(value);
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
                    'All Classes'.tr,
                    'all',
                    controller.enrollmentFilter.value,
                    isDark,
                  ),
                  _buildFilterButton(
                    'Enrolled'.tr,
                    'enrolled',
                    controller.enrollmentFilter.value,
                    isDark,
                  ),
                  _buildFilterButton(
                    'Not Enrolled'.tr,
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
                return Text('No classes match your filters'.tr);
              }
              return Column(
                children: filteredClasses.map((cls) {
                  final firstTeacher = cls.teachers?.isNotEmpty == true
                      ? cls.teachers!.first
                      : null;
                  final classTeacherId = firstTeacher?.classTeacherId ?? cls.id;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.border,
                      ),
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
                                  color: isDark
                                      ? AppTheme.darkForeground
                                      : AppTheme.foreground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cls.description.isNotEmpty
                                    ? cls.description
                                    : 'No description'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppTheme.darkMutedForeground
                                      : AppTheme.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (cls.teacherName != null ||
                                  cls.levelName != null) ...[
                                if (cls.teacherName != null)
                                  Text(
                                    '${"Teacher:".tr} ${cls.teacherName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppTheme.darkMutedForeground
                                          : AppTheme.mutedForeground,
                                    ),
                                  ),
                                if (cls.levelName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${"Level:".tr} ${cls.levelName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppTheme.darkMutedForeground
                                            : AppTheme.mutedForeground,
                                      ),
                                    ),
                                  ),
                              ],
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${cls.studentCount} ${"students enrolled".tr}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() {
                                controller.classes.length;
                                final status = cls.enrollmentStatus?.status ?? 'NOT_ENROLLED';
                                if (status == 'APPROVED') {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.darkBadgeGreenBg
                                          : Colors.green[100]!,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 12,
                                          color: isDark
                                              ? AppTheme.darkBadgeGreenText
                                              : Colors.green[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Enrolled'.tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppTheme.darkBadgeGreenText
                                                : Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (status == 'PENDING') {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.amber[900]!
                                          : Colors.amber[100]!,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Pending'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.amber[200]
                                            : Colors.amber[800],
                                      ),
                                    ),
                                  );
                                } else if (status == 'REJECTED') {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.darkBadgeRedBg
                                          : Colors.red[100]!,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Rejected'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppTheme.darkBadgeRedText
                                            : Colors.red[700],
                                      ),
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
                          controller.classes.length;
                          final status = cls.enrollmentStatus?.status ?? 'NOT_ENROLLED';
                          if (status == 'APPROVED') {
                          return ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              backgroundColor: isDark
                                  ? AppTheme.darkBadgeGreenBg
                                  : Colors.green[100],
                              foregroundColor: isDark
                                  ? AppTheme.darkBadgeGreenText
                                  : Colors.green[700],
                              disabledBackgroundColor: isDark
                                  ? AppTheme.darkBadgeGreenBg
                                  : Colors.green[100],
                              disabledForegroundColor: isDark
                                  ? AppTheme.darkBadgeGreenText
                                  : Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: isDark
                                      ? AppTheme.darkBadgeGreenText
                                      : Colors.green[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Enrolled'.tr,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                          } else if (status == 'PENDING') {
                            return ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: isDark
                                    ? AppTheme.darkMutedForeground
                                    : AppTheme.mutedForeground,
                                disabledBackgroundColor: Colors.transparent,
                                disabledForegroundColor: isDark
                                    ? AppTheme.darkMutedForeground
                                    : AppTheme.mutedForeground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    color: isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.border,
                                  ),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pending'.tr,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          } else if (status == 'REJECTED') {
                            return controller.enrolling.value == classTeacherId
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () => controller.enrollInClass(
                                      classTeacherId,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      backgroundColor: isDark
                                          ? AppTheme.darkBadgeRedBg
                                          : Colors.red[100],
                                      foregroundColor: isDark
                                          ? AppTheme.darkBadgeRedText
                                          : Colors.red[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Resend Request'.tr,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  );
                          }
                          return controller.enrolling.value == classTeacherId
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () =>
                                      controller.enrollInClass(classTeacherId),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    backgroundColor: isDark
                                        ? AppTheme.darkPrimary
                                        : AppTheme.primary,
                                    foregroundColor: isDark
                                        ? AppTheme.darkPrimaryForeground
                                        : AppTheme.primaryForeground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_add,
                                        size: 14,
                                        color: isDark
                                            ? AppTheme.darkPrimaryForeground
                                            : Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Request Enrollment'.tr,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                        }),
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

  Widget _buildExercisesCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Exercises'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              'Download and view exercises from your enrolled classes'.tr,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.darkMutedForeground
                    : AppTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.exercises.isEmpty) {
                return Text('No exercises. Enroll in classes first.'.tr);
              }
              return Column(
                children: controller.exercises.take(10).map((ex) {
                  final submitted = controller.isSubmitted(ex.id);
                  final isOverdue = controller.isOverdue(ex);
                  final submission = controller.getSubmission(ex.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.border,
                      ),
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
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    ex.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isDark
                                          ? AppTheme.darkForeground
                                          : AppTheme.foreground,
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
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        ex.level!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppTheme.darkBadgeBlueText
                                              : Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  if (submitted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.darkBadgeGreenBg
                                            : Colors.green[100],
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: isDark
                                                ? AppTheme.darkBadgeGreenText
                                                : Colors.green[700],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Submitted'.tr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppTheme.darkBadgeGreenText
                                                  : Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (isOverdue && !submitted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.darkBadgeRedBg
                                            : Colors.red[100],
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'Overdue'.tr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppTheme.darkBadgeRedText
                                              : Colors.red[700],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ex.description.isNotEmpty
                                    ? ex.description
                                    : 'No description'.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.darkMutedForeground
                                      : AppTheme.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (ex.className != null)
                                Text(
                                  '${"Class:".tr} ${ex.className}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                              if (ex.className != null)
                                const SizedBox(height: 12),
                              if (ex.teacherName != null)
                                Text(
                                  '${"Teacher:".tr} ${ex.teacherName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                              if (ex.teacherName != null)
                                const SizedBox(height: 12),
                              if (ex.dueDate != null)
                                Text(
                                  '${"Due:".tr} ${_formatDate(ex.dueDate!)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppTheme.darkMutedForeground
                                        : AppTheme.mutedForeground,
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
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0x30C084FC)
                                                : const Color(0xFFF3E8FF),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            s.name,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFFD8B4FE)
                                                  : const Color(0xFF6B21A8),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              if (submission != null &&
                                  submission.grade != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.darkBadgeBlueBg
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${"Grade:".tr} ${submission.grade}/20',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppTheme.darkForeground
                                              : AppTheme.foreground,
                                        ),
                                      ),
                                      if (submission.feedback.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            submission.feedback,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppTheme.darkForeground
                                                  : AppTheme.foreground,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ex.fileUrl != null && ex.fileUrl!.isNotEmpty) ...[
                              ElevatedButton.icon(
                                onPressed: () =>
                                    controller.downloadExercise(ex.id),
                                icon: const Icon(Icons.download, size: 14),
                                label: Text(
                                  'Download'.tr,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.white
                                      : AppTheme.primary,
                                  foregroundColor: isDark
                                      ? AppTheme.foreground
                                      : AppTheme.primaryForeground,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (!submitted && !isOverdue) ...[
                              OutlinedButton.icon(
                                onPressed: () =>
                                    controller.openSubmitDialog(ex),
                                icon: const Icon(Icons.upload, size: 14),
                                label: Text(
                                  'Submit Solution'.tr,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (!submitted && !isOverdue) ...[
                              ElevatedButton.icon(
                                onPressed: () => controller.markAsDone(ex.id),
                                icon: const Icon(Icons.check, size: 14),
                                label: Text(
                                  'Mark as Done'.tr,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.white
                                      : AppTheme.primary,
                                  foregroundColor: isDark
                                      ? AppTheme.foreground
                                      : AppTheme.primaryForeground,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (!submitted && isOverdue)
                              OutlinedButton(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Due Date Passed'.tr,
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                          ],
                        ),
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

  Widget _buildSubmitDialog() {
    return Obx(() {
      if (controller.selectedExercise.value == null)
        return const SizedBox.shrink();
      return Positioned.fill(
        child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Submit Solution'.tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your solution file for this exercise'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.pickSubmitFile,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: Text(
                        controller.selectedSubmitFile.value != null
                            ? controller.selectedSubmitFile.value!.name
                            : 'Choose File'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          child: Text(
                            'Cancel'.tr,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
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
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.month}/${date.day}/${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
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
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppTheme.darkForeground : null,
                      ),
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
                              if (!notification.isRead)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    top: 4,
                                  ),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isDark
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
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logout'.tr,
                  style: TextStyle(
                    color: controller.isDarkMode
                        ? AppTheme.darkDestructive
                        : Colors.red,
                  ),
                ),
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
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.border,
          ),
        ),
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
                color: isActive
                    ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
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
                  ? (isDark ? AppTheme.darkForeground : AppTheme.primary)
                  : (isDark
                        ? AppTheme.darkMutedForeground
                        : AppTheme.mutedForeground),
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
