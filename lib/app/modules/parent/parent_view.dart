import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/models.dart';
import '../../data/models/parent_models.dart';
import '../../data/providers/api_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../../main.dart';
import 'parent_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';

class ParentView extends GetView<ParentController> {
  const ParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Get.find<ThemeService>().isDarkMode;
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
                    color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile Not Found'.tr,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You need to complete your parent profile before accessing the dashboard.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.profileCompletion,
                      arguments: {'role': 'PARENT'},
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
                if (!controller.showChat.value) ...[
                  _buildNotificationBell(),
                  _buildChatButton(),
                  _buildLanguageToggle(),
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
            ),
          ),
          toolbarHeight: controller.showChat.value ? 60 : 80,
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
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Parent Dashboard'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${"Welcome".tr}, ${controller.userName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
            : _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _buildStatsCards(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 8),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabButton('my-children', 'My Children'),
            _buildTabButton('announcements', 'Announcements'),
            _buildTabButton('attendance-records', 'Attendance Records'),
            _buildTabButton('predictions', 'Predictions'),
            _buildTabButton('assign-exercise', 'Assign Exercise'),
            _buildTabButton('child-submissions', 'Submissions'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label) {
    return Obx(() {
      final isActive = controller.activeTab.value == tabId;
      final isDark = controller.isDarkMode;
      return GestureDetector(
        onTap: () => controller.setActiveTab(tabId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? (isDark ? AppTheme.darkPrimary : AppTheme.primary) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        child: Text(
          label.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? (isDark ? AppTheme.darkForeground : AppTheme.primary) : (isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
        ),
        ),
      );
    });
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.activeTab.value) {
        case 'my-children':
          return _buildMyChildrenTab();
        case 'announcements':
          return _buildAnnouncementsTab();
        case 'attendance-records':
          return _buildAttendanceTab();
        case 'predictions':
          return _buildPredictionsTab();
        case 'assign-exercise':
          return _buildAssignExerciseTab();
        case 'child-submissions':
          return _buildSubmissionsTab();
        default:
          return _buildMyChildrenTab();
      }
    });
  }

  Widget _buildMyChildrenTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildChildrenCard()),
          const SizedBox(width: 16),
          Expanded(child: _buildImportantInfoCard()),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildAnnouncementsCard(),
    );
  }

  Widget _buildAttendanceTab() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Records'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
          const SizedBox(height: 4),
          Text(
            'Attendance for your children'.tr,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 12),
          _buildAttendanceCard(),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predictions'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
          const SizedBox(height: 4),
          Text(
            'Predict student dropout/graduation outcomes'.tr,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 16),
          _buildPredictionsCard(),
        ],
      ),
    );
  }

  Widget _buildAssignExerciseTab() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Assign Exercise'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
          const SizedBox(height: 4),
          Text(
            'Search and assign exercises for your children'.tr,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.children.isEmpty) {
              return Center(child: Text('No children found', style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Select Child:'.tr,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: controller.children.map((child) {
                            final selected = controller.selectedChildForExercises.value == child.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => controller.setSelectedChildForExercises(child.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                        : (isDark ? AppTheme.darkCard : AppTheme.muted),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    child.fullName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selected ? (isDark ? AppTheme.darkPrimaryForeground : Colors.white) : (isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (controller.selectedChildForExercises.value != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters'.tr,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)),
                              const SizedBox(height: 4),
                              _buildLevelDropdown(isDark),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Skills', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)),
                              const SizedBox(height: 4),
                              _buildSkillsDropdown(isDark),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Class Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)),
                              const SizedBox(height: 4),
                              Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextField(
                                  onChanged: controller.setExerciseClassFilter,
                                  decoration: InputDecoration(
                                    hintText: 'Search by class name',
                                    hintStyle: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Obx(() {
                    if (controller.isSearchingExercises.value) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (controller.exerciseSearchError.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: isDark ? AppTheme.darkBadgeRedText : Colors.red[600]),
                              const SizedBox(height: 8),
                              Text(
                                controller.exerciseSearchError.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDark ? AppTheme.darkBadgeRedText : Colors.red[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (controller.searchedExercises.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No assignable exercises',
                            style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.searchedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = controller.searchedExercises[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildExerciseCard(exercise, isDark),
                        );
                      },
                    );
                  }),
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Select a child to browse exercises',
                        style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLevelDropdown(bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.exerciseLevelFilter.value,
          isExpanded: true,
          hint: Text('Level', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)),
          items: [
            DropdownMenuItem(value: null, child: Text('All Levels', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkForeground : AppTheme.foreground))),
            ...controller.levels.map((l) => DropdownMenuItem(
              value: l.name,
              child: Text(l.name, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkForeground : AppTheme.foreground)),
            )),
          ],
          onChanged: controller.setExerciseLevelFilter,
          dropdownColor: isDark ? AppTheme.darkCard : AppTheme.card,
          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
        ),
      ),
    );
  }

  Widget _buildSkillsDropdown(bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            controller.exerciseSkillFilter.isNotEmpty
                ? '${controller.exerciseSkillFilter.length} skill(s)'
                : 'Filter by skills',
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          items: controller.exerciseSkills.map((s) => DropdownMenuItem(
            value: s.id.toString(),
            child: Row(
              children: [
                Icon(
                  controller.exerciseSkillFilter.contains(s.id)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 16,
                  color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(s.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkForeground : AppTheme.foreground)),
                ),
              ],
            ),
          )).toList(),
          onChanged: (val) {
            if (val != null) controller.toggleExerciseSkillFilter(int.parse(val));
          },
          dropdownColor: isDark ? AppTheme.darkCard : AppTheme.card,
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exercise.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
                ),
              ),
              if (exercise.level != null)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x33433FA7) : Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                    child: Text(
                      exercise.level!,
                      style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF93C5FD) : Colors.blue[800]),
                    ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            exercise.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 6),
          Text(
            'Teacher: ${exercise.teacherName ?? ""}',
            style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          if (exercise.className != null)
            Text(
              'Class: ${exercise.className}',
              style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
            ),
          if (exercise.dueDate != null && exercise.dueDate!.isNotEmpty)
            Text(
              'Due: ${exercise.dueDate}',
              style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
            ),
          if (exercise.skills.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 20,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:                 exercise.skills.map((s) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x33433FA7) : Colors.purple[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.name,
                    style: TextStyle(fontSize: 9, color: isDark ? const Color(0xFFC4B5FD) : Colors.purple[800]),
                  ),
                )).toList(),
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              final assigned = controller.assignedExerciseIds.contains(exercise.id);
              final assigning = controller.assigningExerciseId.value == exercise.id;
              return GestureDetector(
                onTap: assigned || assigning ? null : () => controller.assignExerciseToChild(exercise.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: assigned
            ? (isDark ? const Color(0xFF27272A) : Colors.grey[200])
            : (isDark ? AppTheme.darkPrimary : AppTheme.primary),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        assigning ? 'Assigning...'.tr : (assigned ? 'Assigned'.tr : 'Assign'.tr),
        style: TextStyle(fontSize: 11, color: assigned ? (isDark ? const Color(0xFFD4D4D8) : Colors.grey[700]) : (isDark ? AppTheme.darkPrimaryForeground : Colors.white)),
      ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submissions'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
          const SizedBox(height: 4),
          Text(
            'Review submissions your children made on exercises you assigned'.tr,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingSubmissions.value && controller.childSubmissions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.childSubmissions.isEmpty) {
              return Center(
                child: Text(
                  'No submissions yet'.tr,
                  style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                ),
              );
            }
            final childNames = controller.childSubmissions
                .map((s) => s.studentName ?? '')
                .where((n) => n.isNotEmpty)
                .toSet()
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSubmissionFilterTab('All', controller.selectedChildForSubmissions.value.isEmpty, () => controller.setSelectedChildForSubmissions(''), isDark),
                      ...childNames.map((name) {
                        return _buildSubmissionFilterTab(
                          name,
                          controller.selectedChildForSubmissions.value == name,
                          () => controller.setSelectedChildForSubmissions(name),
                          isDark,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final filtered = controller.selectedChildForSubmissions.value.isNotEmpty
                      ? controller.childSubmissions.where((s) => s.studentName == controller.selectedChildForSubmissions.value).toList()
                      : controller.childSubmissions.toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No submissions for this child',
                        style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final submission = filtered[index];
                      return _buildSubmissionCard(submission, isDark);
                    },
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubmissionFilterTab(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                : (isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(Submission submission, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  submission.studentName ?? '',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x25433FA7) : Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Assigned Exercise',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF93C5FD) : Colors.blue[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Exercise: ${submission.exerciseTitle}',
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 2),
          Text(
            'Submitted: ${_formatDateTime(submission.submittedAt)}',
            style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (submission.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x3016A34A) : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Grade: ${submission.grade!.toStringAsFixed(submission.grade! == submission.grade!.truncateToDouble() ? 0 : 1)}/20',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF4ADE80) : Colors.green[700]),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x33A1A1AA) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Not graded yet'.tr,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFA1A1AA) : Colors.grey[500]),
                  ),
                ),
              const Spacer(),
              if (submission.submissionFileUrl != null && submission.submissionFileUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final url = submission.submissionFileUrl!;
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 14, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                        const SizedBox(width: 4),
                        Text(
                          'Download'.tr,
                          style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (submission.feedback.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: isDark ? const Color(0xFF52525B) : Colors.grey[400]!, width: 2)),
                  ),
                  child: Text(
                    '"${submission.feedback}"',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isDark ? const Color(0xFFD4D4D8) : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildStatsCards() {
    final isDark = Get.find<ThemeService>().isDarkMode;
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
              'My Children'.tr,
              '${controller.children.length}',
              'Enrolled students'.tr,
              Icons.people,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: _buildStatCard(
              'Average Progress'.tr,
              controller.children.isNotEmpty ? 'Good' : 'N/A',
              'Overall status'.tr,
              Icons.trending_up,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: _buildStatCard(
              'Enrolled Classes'.tr,
              controller.children.isNotEmpty ? 'Active' : 'N/A',
              'Class status'.tr,
              Icons.book,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: _buildStatCard(
              'Notifications'.tr,
              '${controller.children.isNotEmpty ? controller.children.length : 0}',
              'Children linked'.tr,
              Icons.notifications,
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
      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
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
                title.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
              ),
            ),
            Icon(icon, size: 16, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
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
            subtitle.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildAnnouncementsCard() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Announcements'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16,
                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Announcements for your children'.tr,
              style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.children.isEmpty) return const SizedBox.shrink();
              return Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterTab(
                        'All',
                        controller.selectedChildForAnnouncements.value.isEmpty,
                        () => controller.selectChildForAnnouncements(''),
                        isDark,
                      ),
                      ...controller.children.map(
                        (child) => _buildFilterTab(
                          child.fullName,
                          controller.selectedChildForAnnouncements.value ==
                              child.fullName,
                          () => controller.selectChildForAnnouncements(
                            child.fullName,
                          ),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.filteredAnnouncements.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No announcements'.tr,
                      style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                    ),
                  ),
                );
              }

              // Group by child name, then by teacher name (matching web)
              final announcements = controller.filteredAnnouncements;
              final groupedByChild = <String, Map<String, List<ChildAnnouncement>>>{};
              for (final ca in announcements) {
                final childName = ca.childName;
                final teacherName = ca.announcement.teacherName ?? 'Teacher';
                groupedByChild.putIfAbsent(childName, () => {});
                groupedByChild[childName]!.putIfAbsent(teacherName, () => []);
                groupedByChild[childName]![teacherName]!.add(ca);
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: groupedByChild.entries.map((childEntry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? AppTheme.darkCard : AppTheme.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childEntry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...childEntry.value.entries.map((teacherEntry) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkBackground : AppTheme.muted,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'From: ${teacherEntry.key}'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...teacherEntry.value.map((ca) {
                                    final ann = ca.announcement;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        border: Border(left: BorderSide(color: isDark ? AppTheme.darkBadgeBlueText : Colors.blue[300]!, width: 2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ann.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                                            ),
                                          ),
                                          Text(
                                            ann.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (ann.className != null)
                                                Text(
                                                  'Class: ${ann.className}  |  ',
                                                  style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                                ),
                                              Text(
                                                _formatDateTime(ann.createdAt),
                                                style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      );
  }

  Widget _buildAttendanceCard() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
            Obx(() {
              if (controller.children.isEmpty) return const SizedBox.shrink();
              return Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterTab(
                        'All',
                        controller.selectedChildForAttendance.value.isEmpty,
                        () => controller.selectChildForAttendance(''),
                        isDark,
                      ),
                      ...controller.children.map(
                        (child) => _buildFilterTab(
                          child.fullName,
                          controller.selectedChildForAttendance.value ==
                              child.fullName,
                          () => controller.selectChildForAttendance(
                            child.fullName,
                          ),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.filteredAttendance.isEmpty) {
                return const Text('No attendance records');
              }
              return Column(
                children: controller.filteredAttendance.map((childAtt) {
                  final presentCount = childAtt.attendance
                      .where((a) => a.status == 'PRESENT')
                      .length;
                  final absentCount = childAtt.attendance
                      .where((a) => a.status == 'ABSENT')
                      .length;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  childAtt.childName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBadgeGreenBg : Colors.green[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: isDark ? AppTheme.darkBadgeGreenText : Colors.green[800]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$presentCount Present',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkBadgeGreenText : Colors.green[800]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkBadgeRedBg : Colors.red[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel, size: 14, color: isDark ? AppTheme.darkBadgeRedText : Colors.red[800]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$absentCount Absent',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkBadgeRedText : Colors.red[800]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        if (childAtt.attendance.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: childAtt.attendance.length > 10
                                  ? 10
                                  : childAtt.attendance.length,
                              itemBuilder: (context, index) {
                                final record = childAtt.attendance[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.darkBackground : AppTheme.muted,
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
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_formatDate(record.date)}${record.teacherName != null ? " - Teacher: ${record.teacherName}" : ""}',
                                              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: record.status == 'PRESENT'
                                              ? (isDark ? AppTheme.darkBadgeGreenBg : Colors.green[100])
                                              : (isDark ? AppTheme.darkBadgeRedBg : Colors.red[100]),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              record.status == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                                              size: 14,
                                              color: record.status == 'PRESENT'
                                                  ? (isDark ? AppTheme.darkBadgeGreenText : Colors.green[800])
                                                  : (isDark ? AppTheme.darkBadgeRedText : Colors.red[800]),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              record.status,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: record.status == 'PRESENT'
                                                    ? (isDark ? AppTheme.darkBadgeGreenText : Colors.green[800])
                                                    : (isDark ? AppTheme.darkBadgeRedText : Colors.red[800]),
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
                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
    );
  }

  Widget _buildChildrenCard() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'My Children'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
          const SizedBox(height: 4),
          Text(
            'Overview of your children\'s information'.tr,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.children.isEmpty) {
              return Text('No children linked'.tr, style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.children.length,
              itemBuilder: (context, index) {
                final child = controller.children[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? AppTheme.darkBackground : AppTheme.muted,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              child.fullName,
                              softWrap: true,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkBadgeGreenBg : Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Active'.tr,
                              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkBadgeGreenText : Colors.green[800]),
                            ),
                          ),
                        ],
                      ),
                      if (child.enrollmentDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Enrolled: ${_formatDate(child.enrollmentDate!)}',
                          softWrap: true,
                          style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.foreground),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (child.phoneNumber != null)
                            _buildInfoChip('Phone', child.phoneNumber!, isDark),
                          if (child.address != null)
                            _buildInfoChip('Address', child.address!, isDark),
                          if (child.dateOfBirth != null)
                            _buildInfoChip(
                              'Date of Birth',
                              _formatDate(child.dateOfBirth!),
                              isDark,
                            ),
                          if (child.enrollmentAge != null)
                            _buildInfoChip(
                              'Enrollment Age',
                              '${child.enrollmentAge}',
                              isDark,
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

  Widget _buildInfoChip(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.tr, style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)),
        SizedBox(
          width: 140,
          child: Text(
            value,
            softWrap: true,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
        ),
      ],
    );
  }

  Widget _buildImportantInfoCard() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.card,
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Important Information'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
          const SizedBox(height: 4),
          Text(
            'Details about your linked children'.tr,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.children.isEmpty) {
              return Text(
                'Contact the school administration to link your children to your account.'.tr,
                style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.children.length,
              itemBuilder: (context, index) {
                final child = controller.children[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? AppTheme.darkBackground : AppTheme.muted,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        child.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.notifications,
                        Colors.blue,
                        'You are linked as the parent of this student'.tr,
                        isDark,
                      ),
                      if (child.phoneNumber != null)
                        _buildInfoRow(
                          Icons.notifications,
                          Colors.green,
                          'Contact number: ${child.phoneNumber}',
                          isDark,
                        ),
                      _buildInfoRow(
                        Icons.book,
                        Colors.purple,
                        'Check their exercises and assignments regularly'.tr,
                        isDark,
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

  Widget _buildInfoRow(IconData icon, Color color, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          label.tr,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                : (isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
          ),
        ),
      ),
    );
  }

  Widget _buildChildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
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
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${date.month}/${date.day}/${date.year}, $hour12:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')} $amPm';
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

  Widget _buildChatButton() {
    return Obx(() {
      final unreadCount = controller.unreadMessageCount.value;
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
          if (unreadCount > 0)
            Positioned(
              right: 50,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
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

  Widget _buildLanguageToggle() {
    return Obx(() => InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => controller.toggleLanguage(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Text(
            controller.currentLanguage == 'en' ? 'ع' : 'EN',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ));
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
          color: isDark ? AppTheme.darkCard : Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border, width: 1),
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
                        color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
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
                  if (controller.notifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications'.tr,
                        style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
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
                        color: notification.isRead ? null : (isDark ? AppTheme.darkBadgeBlueBg : Colors.blue[50]),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 12, top: 2),
                                child: _getNotificationIcon(notification.type),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (notification.title.isNotEmpty) ...[
                                      Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontWeight: notification.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    Text(
                                      notification.message,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getTimeAgo(notification.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notification.isRead)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.darkBadgeBlueText : Colors.blue,
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
        return const Icon(Icons.person_remove_outlined, color: Colors.red, size: 20);
      case 'ANNOUNCEMENT':
        return const Icon(Icons.campaign_outlined, color: Colors.purple, size: 20);
      case 'GRADE':
        return const Icon(Icons.emoji_events_outlined, color: Colors.green, size: 20);
      default:
        return const Icon(Icons.notifications_outlined, color: Colors.grey, size: 20);
    }
  }

  Widget _buildPredictionsCard() {
    final isDark = Get.find<ThemeService>().isDarkMode;
    return Obx(() {
      if (controller.children.isEmpty)
        return Text('No children linked to your account yet'.tr);

      final predictionsMap = controller.predictions;
      final predictingId = controller.predicting.value;

      return Column(
        children: controller.children.map((child) {
          final prediction = predictionsMap.containsKey(child.id)
              ? predictionsMap[child.id]
              : null;
          final isPredicting = predictingId == child.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppTheme.darkCard : AppTheme.card,
              ),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              child.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                              ),
                            ),
                          ),
                          if (prediction == null)
                            OutlinedButton(
                              onPressed: isPredicting
                                  ? null
                                  : () => controller.predictStudent(child.id),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                isPredicting ? 'Predicting...' : 'Predict'.tr,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      if (prediction != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: prediction.prediction == 'Dropout'
                                ? (isDark ? AppTheme.darkBadgeRedBg : Colors.red[50])
                                : (isDark ? AppTheme.darkBadgeGreenBg : Colors.green[50]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prediction'.tr,
                                      style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      prediction.prediction,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: prediction.prediction == 'Dropout'
                                            ? (isDark ? AppTheme.darkBadgeRedText : Colors.red[600])
                                            : (isDark ? AppTheme.darkBadgeGreenText : Colors.green[600]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Confidence'.tr,
                                    style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkForeground : AppTheme.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Features Used'.tr,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureRow('Total Absences'.tr, '${prediction.featuresUsed['total_absences'] ?? 0}', isDark),
                        _buildFeatureRow('Absence Rate'.tr, '${((prediction.featuresUsed['absence_rate'] ?? 0.0) * 100).toStringAsFixed(1)}%', isDark),
                        _buildFeatureRow('Exercises Completed'.tr, '${prediction.featuresUsed['exercises_completed'] ?? 0}', isDark),
                        _buildFeatureRow('Exercise Completion'.tr, '${((prediction.featuresUsed['exercise_completion_rate'] ?? 0.0) * 100).toStringAsFixed(1)}%', isDark),
                        if (prediction.featuresUsed.containsKey('critical_skill_completion_rate') || prediction.featuresUsed.containsKey('critical_skills_completion'))
                          _buildFeatureRow('Critical Skill Completion'.tr, '${((prediction.featuresUsed['critical_skill_completion_rate'] ?? prediction.featuresUsed['critical_skills_completion'] ?? 0.0) * 100).toStringAsFixed(1)}%', isDark),
                        if (prediction.featuresUsed.containsKey('total_critical_skills_missed') || prediction.featuresUsed.containsKey('critical_skills_missed'))
                          _buildFeatureRow('Critical Skills Missed'.tr, '${prediction.featuresUsed['total_critical_skills_missed'] ?? prediction.featuresUsed['critical_skills_missed'] ?? 0}', isDark),
                      ],
                    ],
                  ),
                ),
              );
          }).toList(),
        );
    });
  }

  Widget _buildFeatureRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppTheme.darkMutedForeground : AppTheme.mutedForeground, fontSize: 12)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: isDark ? AppTheme.darkForeground : AppTheme.foreground),
          ),
        ],
      ),
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
          else if (v.startsWith('student_'))
            controller.switchToRole(v);
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
                  iconColor = controller.isDarkMode ? AppTheme.darkDestructive : Colors.red;
                  label = 'Administrator';
                  break;
                case 'TEACHER':
                  icon = Icons.school;
                  iconColor = controller.isDarkMode ? AppTheme.darkPrimary : Colors.blue;
                  label = 'Teacher';
                  break;
                case 'STUDENT':
                  icon = Icons.people;
                  iconColor = controller.isDarkMode ? AppTheme.darkBadgeGreenText : Colors.green;
                  label = 'Student';
                  break;
                case 'PARENT':
                  icon = Icons.child_care;
                  iconColor = controller.isDarkMode ? AppTheme.darkMutedForeground : Colors.purple;
                  label = 'Parent';
                  break;
                default:
                  icon = Icons.person;
                  iconColor = controller.isDarkMode ? AppTheme.darkMutedForeground : AppTheme.mutedForeground;
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
                      Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: controller.isDarkMode ? AppTheme.darkMutedForeground : AppTheme.mutedForeground)),
                  ],
                ),
              );
            }),
          ],
          if (controller.children.isNotEmpty) ...[
            const PopupMenuDivider(),
            const PopupMenuItem(
              enabled: false,
              child: Text('Select Child', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            ...controller.children.map(
              (child) => PopupMenuItem(
                value: 'student_${child.id}',
                child: Row(
                  children: [
                    const Icon(Icons.child_care, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(child.fullName)),
                  ],
                ),
              ),
            ),
          ],
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 18, color: controller.isDarkMode ? AppTheme.darkDestructive : Colors.red),
                const SizedBox(width: 8),
                Text('Logout', style: TextStyle(color: controller.isDarkMode ? AppTheme.darkDestructive : Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
