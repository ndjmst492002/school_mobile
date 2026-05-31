import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../data/providers/api_provider.dart';
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
          backgroundColor: controller.isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFFFFFF),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final isDark = controller.isDarkMode;
      final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);
      final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
      final textColor = isDark ? Colors.white : const Color(0xFF111827);
      final mutedColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
      final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB);

      final activeTab = controller.activeTab.value;
      final exerciseCount = controller.exerciseCount.value;
      final classCount = controller.classCount.value;
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
              children: [
                const Spacer(),
                _buildNotificationBell(isDark),
                _buildProfileMenu(isDark),
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
                    'Admin Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome, ${controller.userName}',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                _buildStatsRow(exerciseCount, classCount, skillsCount, isDark, cardColor, textColor, mutedColor),
                const SizedBox(height: 16),
                _buildTabsRow(activeTab, isDark),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabContent(
                    activeTab, isDark, cardColor, textColor, mutedColor, borderColor,
                    exercises, exerciseRequests, skills,
                    selectedLevelId, selectedClassId, selectedSkills, isUploading,
                    levelClasses, selectedFile, levels, moderating,
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
              right: 6, top: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${controller.unreadNotificationCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
          color: isDark ? const Color(0xFF262638) : Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262638) : Colors.white,
                  border: Border(bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!, width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : null),
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
                      child: Text('No notifications', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
                                    child: Text(notification.title, style: TextStyle(
                                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    )),
                                  ),
                                  Text(notification.createdAt, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notification.message, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
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

  // --- Language Toggle ---

  // --- Profile Menu ---

  Widget _buildProfileMenu(bool isDark) {
    final roles = controller.roles;
    final activeRole = controller.currentRole;
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB)),
          ),
          child: Center(
            child: Text(
              (controller.userName.isNotEmpty ? controller.userName[0] : 'A').toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
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
              Text(isDark ? 'Light Mode' : 'Dark Mode'),
            ],
          ),
        ),
        // Role Switcher (only if multiple roles)
        if (roles.length > 1) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            enabled: false,
            child: Text('Switch Role', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          ...roles.where((r) {
            if (activeRole == 'PARENT' && r == 'STUDENT') return false;
            if (activeRole == 'TEACHER' && r == 'STUDENT') return false;
            return true;
          }).map((role) {
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
                iconColor = Colors.grey;
            }
            final isActive = role == activeRole;
            return PopupMenuItem(
              value: 'switch_$role',
              enabled: !isActive,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_roleLabel(role))),
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
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN': return 'Administrator';
      case 'TEACHER': return 'Teacher';
      case 'STUDENT': return 'Student';
      case 'PARENT': return 'Parent';
      default: return role;
    }
  }

  // --- Stats Row ---

  Widget _buildStatsRow(int exerciseCount, int classCount, int skillsCount, bool isDark, Color cardColor, Color textColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _statCard(cardWidth, 'Exercises', '$exerciseCount', 'Total uploaded', Icons.assignment, Colors.blue, cardColor, textColor, mutedColor),
              _statCard(cardWidth, 'Classes', '$classCount', 'Active classes', Icons.book, Colors.indigo, cardColor, textColor, mutedColor),
              _statCard(cardWidth, 'Skills', '$skillsCount', 'Available skills', Icons.auto_awesome, Colors.purple, cardColor, textColor, mutedColor),
              _statCard(cardWidth, 'System Status', 'Active', 'All systems operational', Icons.check_circle, Colors.green, cardColor, textColor, mutedColor),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(double width, String title, String value, String subtitle, IconData icon, Color color, Color cardColor, Color textColor, Color mutedColor) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: mutedColor, fontWeight: FontWeight.w500)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: value == 'Active' ? Colors.green : textColor)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: mutedColor)),
        ],
      ),
    );
  }

  // --- Tabs Row ---

  Widget _buildTabsRow(String activeTab, bool isDark) {
    final tabs = ['overview', 'exercises', 'exercise-requests'];
    final labels = ['Overview', 'Exercises', 'Exercise Requests'];
    final primary = AppTheme.primary;
    final mutedColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB))),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isSelected ? primary : Colors.transparent, width: 2)),
              ),
              child: Text(labels[index], style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? primary : mutedColor)),
            ),
          );
        },
      ),
    );
  }

  // --- Tab Content Dispatcher ---

  Widget _buildTabContent(
    String activeTab, bool isDark, Color cardColor, Color textColor, Color mutedColor, Color borderColor,
    RxList<Exercise> exercises, RxList<Exercise> exerciseRequests, RxList<Skill> skills,
    int? selectedLevelId, int? selectedClassId, RxList<int> selectedSkills, bool isUploading,
    RxList<ClassModel> levelClasses, PlatformFile? selectedFile, List<Level> levels, int? moderating,
  ) {
    switch (activeTab) {
      case 'overview':
        return _buildOverviewTab(isDark, cardColor, textColor);
      case 'exercises':
        return _buildExercisesTab(isDark, cardColor, textColor, mutedColor, borderColor, exercises, skills, selectedLevelId, selectedClassId, selectedSkills, isUploading, levelClasses, selectedFile, levels);
      case 'exercise-requests':
        return _buildExerciseRequestsTab(isDark, cardColor, textColor, mutedColor, borderColor, exerciseRequests, moderating);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Overview Tab ---

  Widget _buildOverviewTab(bool isDark, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text('Admin system overview', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE)),
              ),
              child: Text('Admin Only: You have full system access', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))),
            ),
          ],
        ),
      ),
    );
  }

  // --- Exercises Tab ---

  Widget _buildExercisesTab(
    bool isDark, Color cardColor, Color textColor, Color mutedColor, Color borderColor,
    RxList<Exercise> exercises, RxList<Skill> skills,
    int? selectedLevelId, int? selectedClassId, RxList<int> selectedSkills, bool isUploading,
    RxList<ClassModel> levelClasses, PlatformFile? selectedFile, List<Level> levels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUploadForm(isDark, cardColor, textColor, mutedColor, borderColor, skills, selectedLevelId, selectedClassId, selectedSkills, isUploading, levelClasses, selectedFile, levels),
        const SizedBox(height: 16),
        _buildExerciseList(isDark, cardColor, textColor, mutedColor, borderColor, exercises),
      ],
    );
  }

  Widget _buildUploadForm(
    bool isDark, Color cardColor, Color textColor, Color mutedColor, Color borderColor,
    RxList<Skill> skills, int? selectedLevelId, int? selectedClassId, RxList<int> selectedSkills, bool isUploading,
    RxList<ClassModel> levelClasses, PlatformFile? selectedFile, List<Level> levels,
  ) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload New Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
            const SizedBox(height: 4),
            Text('Upload an exercise file for students', style: TextStyle(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Exercise Title', border: const OutlineInputBorder(), isDense: true),
              onChanged: (v) => controller.uploadTitle.value = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Description', border: const OutlineInputBorder(), isDense: true),
              maxLines: 2,
              onChanged: (v) => controller.uploadDescription.value = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedLevelId,
              decoration: InputDecoration(labelText: 'Level', border: const OutlineInputBorder(), isDense: true),
              isExpanded: true,
              items: [
                DropdownMenuItem<int>(value: null, child: Text('Select a level', style: TextStyle(color: mutedColor))),
                ...levels.map((l) => DropdownMenuItem<int>(value: l.id, child: Text(l.name))),
              ],
              onChanged: controller.setSelectedLevelId,
            ),
            if (selectedLevelId != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedClassId,
                decoration: InputDecoration(labelText: 'Select Class', border: const OutlineInputBorder(), isDense: true),
                isExpanded: true,
                hint: Text('Select a class'),
                items: levelClasses.map((c) => DropdownMenuItem<int>(value: c.id, child: Text('${c.name} (${c.studentCount} students)'))).toList(),
                onChanged: (v) => controller.selectedClassId.value = v,
              ),
            ],
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Skills (Optional)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: textColor)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(6)),
                    child: Wrap(
                      spacing: 8, runSpacing: 4,
                      children: skills.map((skill) => FilterChip(
                        label: Text(skill.name, style: const TextStyle(fontSize: 12)),
                        selected: selectedSkills.contains(skill.id),
                        onSelected: (_) => controller.toggleSkill(skill.id),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.pickUploadFile,
              icon: const Icon(Icons.attach_file, size: 18),
              label: Text(selectedFile != null ? selectedFile.name : 'Upload File', overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading ? null : controller.uploadExercise,
                child: isUploading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Upload Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList(bool isDark, Color cardColor, Color textColor, Color mutedColor, Color borderColor, RxList<Exercise> exercises) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Uploaded Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
            const SizedBox(height: 4),
            Text("Exercises you've shared with students", style: TextStyle(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 16),
            if (exercises.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No exercises uploaded yet', style: TextStyle(color: mutedColor))))
            else
              ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(8)),
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
                                  Expanded(child: Text(ex.title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
                                  if (ex.level != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)),
                                      child: Text(ex.level!, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF))),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(ex.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: mutedColor)),
                            ],
                          ),
                        ),
                        if (ex.fileUrl != null && ex.fileUrl!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => launchUrl(Uri.parse('${ApiProvider.baseUrl}/users/exercises/${ex.id}/download/'), mode: LaunchMode.externalApplication),
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Download', style: TextStyle(fontSize: 12)),
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

  Widget _buildExerciseRequestsTab(bool isDark, Color cardColor, Color textColor, Color mutedColor, Color borderColor, RxList<Exercise> exerciseRequests, int? moderating) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Exercise Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
            const SizedBox(height: 4),
            Text('Pending exercises from teachers awaiting your approval', style: TextStyle(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 16),
            if (exerciseRequests.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No pending exercise requests', style: TextStyle(color: mutedColor))))
            else
              ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: exerciseRequests.length,
                itemBuilder: (context, index) {
                  final ex = exerciseRequests[index];
                  final isResponding = moderating == ex.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(ex.title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                              const SizedBox(height: 4),
                              Text(ex.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: mutedColor)),
                              const SizedBox(height: 4),
                              Text('Teacher: ${ex.teacherName ?? ""} | Class: ${ex.className ?? ""}', style: TextStyle(fontSize: 12, color: mutedColor)),
                              if (ex.createdAt != null) Text('Requested: ${ex.createdAt}', style: TextStyle(fontSize: 12, color: mutedColor)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: isResponding ? null : () => controller.approveExercise(ex.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: isResponding
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Approve', style: const TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(height: 4),
                            OutlinedButton(
                              onPressed: isResponding ? null : () => controller.rejectExercise(ex.id),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, side: const BorderSide(color: Colors.red)),
                              child: Text('Reject', style: const TextStyle(fontSize: 12)),
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
}
