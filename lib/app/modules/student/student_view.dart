import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/models.dart';
import '../../data/providers/api_provider.dart';
import 'student_controller.dart';

class StudentView extends GetView<StudentController> {
  const StudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
          actions: [_buildNotificationBell(), _buildProfileMenu()],
        ),
        body: RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Welcome, ${controller.userName}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                _buildStatsCards(),
                const SizedBox(height: 16),
                _buildTabs(),
                const SizedBox(height: 8),
                _buildTabContent(),
                _buildSubmitDialog(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatsCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'My Classes',
              '${controller.enrolledCount}',
              'Enrolled in',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Exercises',
              '${controller.exercises.length}',
              'Available',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Submitted',
              '${controller.submissions.length}',
              'Completed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey),
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
                  final ann = controller.announcements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ann.teacherName != null)
                            Text(
                              'From: ${ann.teacherName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          const SizedBox(height: 4),
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
                          Text(
                            ann.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
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
                                  _formatDate(ann.createdAt),
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
              'My Attendance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${controller.presentCount}',
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
                                '${controller.absentCount}',
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.attendance.length > 10
                        ? 10
                        : controller.attendance.length,
                    itemBuilder: (context, index) {
                      final record = controller.attendance[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          record.className ?? 'Class',
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(record.date),
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (record.teacherName != null)
                              Text(
                                'Teacher: ${record.teacherName}',
                                style: const TextStyle(
                                  fontSize: 11,
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
                              fontSize: 12,
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
                ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Classes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.classes.isEmpty) {
                return const Text('No classes available');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.classes.length,
                itemBuilder: (context, index) {
                  final cls = controller.classes[index];
                  final enrolled = controller.isEnrolled(cls.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cls.description.isNotEmpty
                                      ? cls.description
                                      : 'No description',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (cls.teacherName != null)
                                      Text(
                                        'Teacher: ${cls.teacherName}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Text(
                                      '${cls.studentCount} students',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (enrolled)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Enrolled ✓',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!enrolled)
                            SizedBox(
                              height: 36,
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed:
                                      controller.enrolling.value == cls.id
                                      ? null
                                      : () => controller.enrollInClass(cls.id),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  child: Text(
                                    controller.enrolling.value == cls.id
                                        ? '...'
                                        : 'Enroll',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Enrolled',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
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
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesCard() {
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Submitted',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  if (isOverdue && !submitted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Overdue',
                                        style: TextStyle(fontSize: 10),
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
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (ex.className != null)
                                Text(
                                  'Class: ${ex.className}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (ex.teacherName != null)
                                Text(
                                  'Teacher: ${ex.teacherName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (ex.dueDate != null)
                                Text(
                                  'Due: ${_formatDate(ex.dueDate!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue && !submitted
                                        ? Colors.red
                                        : Colors.grey,
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
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grade: ${submission.grade}/20',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (submission.feedback.isNotEmpty)
                                    Text(
                                      submission.feedback,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
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
                              if (!submitted)
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
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Submitted',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
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
                            onPressed:
                                controller.selectedSubmitFile.value == null ||
                                    controller.isSubmitting.value
                                ? null
                                : controller.submitExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              controller.isSubmitting.value
                                  ? 'Submitting...'
                                  : 'Submit',
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

  void _showNotificationsDialog() {
    controller.markAllNotificationsAsRead();
    Get.dialog(
      Dialog(
        alignment: Alignment.centerRight,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: 350,
          height: double.infinity, // Full screen height
          color: Colors.white,
          child: Column(
            children: [
              // Header
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
          else if (v == 'teacher')
            controller.switchToRole('TEACHER');
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
              const PopupMenuItem(
                value: 'parent',
                child: Row(
                  children: [
                    Icon(Icons.people, size: 20),
                    SizedBox(width: 8),
                    Text('Switch to Parent'),
                  ],
                ),
              ),
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

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabButton('class-enrollment', 'Classes'),
          _buildTabButton('announcements', 'Announcements'),
          _buildTabButton('available-exercises', 'Exercises'),
          _buildTabButton('my-attendance', 'Attendance'),
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
        case 'class-enrollment':
          return _buildClassesCard();
        case 'announcements':
          return _buildAnnouncementsCard();
        case 'available-exercises':
          return _buildExercisesCard();
        case 'my-attendance':
          return _buildAttendanceCard();
        default:
          return _buildClassesCard();
      }
    });
  }
}
