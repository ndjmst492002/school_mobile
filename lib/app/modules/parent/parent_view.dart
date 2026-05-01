import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/parent_models.dart';
import '../../data/providers/api_provider.dart';
import 'parent_controller.dart';
import '../chat/chat_view.dart';
import '../chat/chat_controller.dart';

class ParentView extends GetView<ParentController> {
  const ParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Row(
              children: [
                Text('Parent Dashboard'),
                const SizedBox(width: 8),
                Text(
                  ', ${controller.userName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            _buildNotificationBell(),
            _buildChatButton(),
            _buildLanguageToggle(),
            _buildProfileMenu(),
          ],
        ),
        body: controller.showChat.value
            ? ChatView(
                onClose: () {
                  Get.delete<ChatController>();
                  controller.toggleChat();
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabButton('my-children', 'My Children'),
          _buildTabButton('announcements', 'Announcements'),
          _buildTabButton('attendance-records', 'Attendance'),
          _buildTabButton('predictions', 'Predictions'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label) {
    return Obx(() {
      final isActive = controller.activeTab.value == tabId;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: isActive,
          onSelected: (selected) {
            if (selected) controller.setActiveTab(tabId);
          },
          selectedColor: Colors.blue,
          labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildFilter(
            controller.selectedChildForAnnouncements.value,
            (v) => controller.setSelectedChildForAnnouncements(v),
          ),
          const SizedBox(height: 16),
          _buildAnnouncementsCard(),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChildFilter(
            controller.selectedChildForAttendance.value,
            (v) => controller.setSelectedChildForAttendance(v),
          ),
          const SizedBox(height: 16),
          _buildAttendanceCard(),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Predictions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Predict student dropout/graduation outcomes',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildPredictionsCard(),
        ],
      ),
    );
  }

  Widget _buildChildFilter(String selectedValue, Function(String) onChanged) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedValue.isEmpty,
              onSelected: (s) {
                if (s) onChanged('');
              },
            ),
            const SizedBox(width: 8),
            ...controller.children.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.fullName),
                  selected: selectedValue == c.fullName,
                  onSelected: (s) {
                    if (s) onChanged(c.fullName);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(
      () => SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'My Children',
                '${controller.children.length}',
                'Enrolled students',
                Colors.blue,
                Icons.group,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Average Progress',
                controller.children.isNotEmpty ? 'Good' : 'N/A',
                'Overall status',
                Colors.green,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Enrolled Classes',
                controller.children.isNotEmpty ? 'Active' : 'N/A',
                'Class status',
                Colors.purple,
                Icons.menu_book,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 150,
              child: _buildStatCard(
                'Notifications',
                '${controller.children.isNotEmpty ? controller.children.length : 0}',
                'Children linked',
                Colors.orange,
                Icons.notifications,
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
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                Icon(icon, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 4),
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
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Announcements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.announcements.isEmpty) {
                return const Text('No announcements');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.announcements.length > 5
                    ? 5
                    : controller.announcements.length,
                itemBuilder: (context, index) {
                  final childAnn = controller.announcements[index];
                  final ann = childAnn.announcement;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Teacher name (matching StudentView)
                          Text(
                            'From: ${ann.teacherName ?? "Teacher"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Child name (additional info for parent)
                          Text(
                            'Child: ${childAnn.childName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Title (matching StudentView)
                          Text(
                            ann.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Content (matching StudentView)
                          Text(
                            ann.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          // Tags (matching StudentView)
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
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
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
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
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Attendance Records',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.attendance.isEmpty) {
                return const Text('No attendance records');
              }
              return Column(
                children: controller.attendance.map((childAtt) {
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
                        Text(
                          childAtt.childName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                      '$presentCount',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    Text(
                                      'Present',
                                      style: TextStyle(
                                        fontSize: 12,
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$absentCount',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                    Text(
                                      'Absent',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
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
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  record.className ?? 'Class',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(record.date),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    if (record.teacherName != null)
                                      Text(
                                        'Teacher: ${record.teacherName}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: record.status == 'PRESENT'
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    record.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: record.status == 'PRESENT'
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                  ),
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
      ),
    );
  }

  Widget _buildChildrenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Children',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.children.isEmpty) {
                return const Text('No children linked');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.children.length,
                itemBuilder: (context, index) {
                  final child = controller.children[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          if (child.enrollmentDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Enrolled: ${_formatDate(child.enrollmentDate!)}',
                              softWrap: true,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              if (child.phoneNumber != null)
                                _buildInfoChip('Phone', child.phoneNumber!),
                              if (child.address != null)
                                _buildInfoChip('Address', child.address!),
                              if (child.parentOccupation != null)
                                _buildInfoChip(
                                  'Parent Occupation',
                                  child.parentOccupation!,
                                ),
                              if (child.dateOfBirth != null)
                                _buildInfoChip(
                                  'Date of Birth',
                                  _formatDate(child.dateOfBirth!),
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

  Widget _buildChatButton() {
    return Obx(() {
      final unreadCount = controller.unreadMessageCount.value;
      return Stack(
        children: [
          controller.showChat.value
              ? TextButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Chat', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Get.delete<ChatController>();
                    controller.toggleChat();
                    controller.updateUnreadMessageCount(0);
                  },
                )
              : TextButton.icon(
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Chat', style: TextStyle(fontSize: 12)),
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
    return Obx(() {
      return TextButton(
        onPressed: controller.toggleLanguage,
        child: Text(
          controller.currentLanguage == 'en' ? 'ع' : 'EN',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
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

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(
          width: 120,
          child: Text(
            value,
            softWrap: true,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildImportantInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Important Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.children.isEmpty) {
                return const Text(
                  'Contact the school administration to link your children to your account.',
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.children.length,
                itemBuilder: (context, index) {
                  final child = controller.children[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            child.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.notifications,
                            Colors.blue,
                            'You are linked as the parent of this student',
                          ),
                          if (child.phoneNumber != null)
                            _buildInfoRow(
                              Icons.phone,
                              Colors.green,
                              'Contact number: ${child.phoneNumber}',
                            ),
                          _buildInfoRow(
                            Icons.book,
                            Colors.purple,
                            'Check their exercises and assignments regularly',
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

  Widget _buildInfoRow(IconData icon, Color color, String text) {
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
              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
              // Header - Clean white with bottom border (no blue)
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
              // Content
              Expanded(
                child: Obx(() {
                  if (controller.notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(color: Colors.grey),
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
                        color: notification.isRead ? null : Colors.blue[50],
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
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getTimeAgo(notification.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
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

  Widget _buildPredictionsCard() {
    return Obx(() {
      if (controller.children.isEmpty)
        return const Text('No children linked to your account yet');

      final predictionsMap = controller.predictions;
      final predictingId = controller.predicting.value;

      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: controller.children.length,
          itemBuilder: (ctx, i) {
            final child = controller.children[i];
            final prediction = predictionsMap.containsKey(child.id)
                ? predictionsMap[child.id]
                : null;
            final isPredicting = predictingId == child.id;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (prediction == null)
                    Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: isPredicting
                              ? null
                              : () => controller.predictStudent(child.id),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            isPredicting ? '...' : 'Predict',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    )
                  else if (isPredicting)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: prediction.prediction == 'Dropout'
                            ? Colors.red[50]
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Text(
                            prediction.prediction,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: prediction.prediction == 'Dropout'
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFeatureRow(
                              'Absences',
                              '${prediction.featuresUsed['total_absences'] ?? 0}',
                            ),
                            _buildFeatureRow(
                              'Absence Rate',
                              '${((prediction.featuresUsed['absence_rate'] ?? 0.0) * 100).toStringAsFixed(0)}%',
                            ),
                            _buildFeatureRow(
                              'Exercises',
                              '${prediction.featuresUsed['exercises_completed'] ?? 0}',
                            ),
                            _buildFeatureRow(
                              'Completion',
                              '${((prediction.featuresUsed['exercise_completion_rate'] ?? 0.0) * 100).toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildFeatureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
    );
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
          else if (v == 'teacher')
            controller.switchToRole('TEACHER');
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
            if (auth.roles.contains('TEACHER'))
              const PopupMenuItem(
                value: 'teacher',
                child: Row(
                  children: [
                    Icon(Icons.school, size: 20),
                    SizedBox(width: 8),
                    Text('Switch to Teacher'),
                  ],
                ),
              ),
            if (auth.roles.contains('STUDENT'))
              const PopupMenuItem(
                value: 'student',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Switch to Student'),
                  ],
                ),
              ),
            if (auth.roles.contains('ADMIN'))
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, size: 20),
                    SizedBox(width: 8),
                    Text('Switch to Admin'),
                  ],
                ),
              ),
          ],
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Logout', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
