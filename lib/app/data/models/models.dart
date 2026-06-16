class Level {
  final int id;
  final String name;

  Level({required this.id, required this.name});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TeacherInfo {
  final int id;
  final String name;
  final int classTeacherId;
  final int? levelId;
  final String? levelName;

  TeacherInfo({
    required this.id,
    required this.name,
    required this.classTeacherId,
    this.levelId,
    this.levelName,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    final level = json['level'];
    String? levelName;
    int? levelId;
    if (level is Map<String, dynamic>) {
      levelName = level['name'];
      levelId = level['id'];
    } else if (level is String) {
      levelName = level;
    }
    return TeacherInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      classTeacherId: json['class_teacher_id'] ?? 0,
      levelId: levelId ?? json['level_id'],
      levelName: levelName ?? json['level_name'],
    );
  }
}

class ClassModel {
  final int id;
  final String name;
  final String description;
  final int? teacher;
  final String? teacherName;
  final List<StudentInfo>? students;
  final int studentCount;
  final EnrollmentStatusInfo? enrollmentStatus;
  final List<TeacherInfo>? teachers;
  final String? levelName;

  ClassModel({
    required this.id,
    required this.name,
    required this.description,
    this.teacher,
    this.teacherName,
    this.students,
    this.studentCount = 0,
    this.enrollmentStatus,
    this.teachers,
    this.levelName,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    EnrollmentStatusInfo? enrollmentStatus;
    final enrollmentStatusJson = json['enrollment_status'];
    if (enrollmentStatusJson is Map<String, dynamic>) {
      enrollmentStatus = EnrollmentStatusInfo.fromJson(enrollmentStatusJson);
    }

    List<TeacherInfo>? teachers;
    if (json['teachers'] is List) {
      teachers = (json['teachers'] as List)
          .map((t) => TeacherInfo.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return ClassModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      teacher: json['teacher'],
      teacherName: json['teacher_name'] ?? (teachers?.isNotEmpty == true ? teachers!.first.name : null),
      students: json['students'] != null
          ? (json['students'] as List)
                .map(
                  (s) => StudentInfo.fromJson(
                    s is Map<String, dynamic> ? s : {'id': s, 'full_name': ''},
                  ),
                )
                .toList()
          : null,
      studentCount: json['student_count'] != null
          ? (json['student_count'] is int
                ? json['student_count']
                : int.tryParse(json['student_count'].toString()) ?? 0)
          : 0,
      enrollmentStatus: enrollmentStatus,
      teachers: teachers,
      levelName: json['level_name'] ?? (teachers?.isNotEmpty == true ? teachers!.first.levelName : null),
    );
  }
}

class EnrollmentStatusInfo {
  final String status;
  final String? requestedAt;
  final String? respondedAt;
  final int? classTeacherId;

  EnrollmentStatusInfo({
    required this.status,
    this.requestedAt,
    this.respondedAt,
    this.classTeacherId,
  });

  factory EnrollmentStatusInfo.fromJson(Map<String, dynamic> json) {
    return EnrollmentStatusInfo(
      status: json['status'] ?? 'PENDING',
      requestedAt: json['requested_at'],
      respondedAt: json['responded_at'],
      classTeacherId: json['class_teacher_id'],
    );
  }
}

class StudentInfo {
  final int id;
  final int? userId;
  final String fullName;

  StudentInfo({required this.id, this.userId, required this.fullName});

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      fullName: json['full_name'] ?? '',
    );
  }
}

class Exercise {
  final int id;
  final String title;
  final String description;
  final String? fileUrl;
  final int? relatedClass;
  final String? className;
  final String? teacherName;
  final String? dueDate;
  final String? level;
  final int? levelId;
  final String status;
  final String? createdAt;
  final bool isAssigned;
  final List<Skill> skills;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    this.fileUrl,
    this.relatedClass,
    this.className,
    this.teacherName,
    this.dueDate,
    this.level,
    this.levelId,
    this.status = 'APPROVED',
    this.createdAt,
    this.isAssigned = false,
    this.skills = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List<Skill> skills = [];
    if (json['skills'] is List) {
      skills = (json['skills'] as List).map((s) {
        if (s is Map<String, dynamic>) return Skill.fromJson(s);
        return Skill(id: s is int ? s : 0, name: '');
      }).toList();
    }
    return Exercise(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['file_url'],
      relatedClass: json['related_class'],
      className: json['class_name'],
      teacherName: json['teacher_name'],
      dueDate: json['due_date'],
      level: json['level'],
      levelId: json['level_id'],
      status: json['status'] ?? 'APPROVED',
      createdAt: json['created_at'],
      isAssigned: json['is_assigned'] ?? false,
      skills: skills,
    );
  }
}

class Submission {
  final int id;
  final int student;
  final String? studentName;
  final int exercise;
  final String exerciseTitle;
  final String? submissionFile;
  final String? submissionFileUrl;
  final String submissionText;
  final String submittedAt;
  final double? grade;
  final String feedback;
  final String? gradedAt;

  Submission({
    required this.id,
    required this.student,
    this.studentName,
    required this.exercise,
    required this.exerciseTitle,
    this.submissionFile,
    this.submissionFileUrl,
    this.submissionText = '',
    required this.submittedAt,
    this.grade,
    this.feedback = '',
    this.gradedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] ?? 0,
      student: json['student'] ?? 0,
      studentName: json['student_name'],
      exercise: json['exercise'] ?? 0,
      exerciseTitle: json['exercise_title'] ?? '',
      submissionFile: json['submission_file'],
      submissionFileUrl: json['submission_file_url'],
      submissionText: json['submission_text'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      grade: json['grade'] != null
          ? (json['grade'] is String
                ? double.tryParse(json['grade'].toString())
                : (json['grade'] as num).toDouble())
          : null,
      feedback: json['feedback'] ?? '',
      gradedAt: json['graded_at'],
    );
  }
}

class Announcement {
  final int id;
  final String title;
  final String content;
  final String? teacherName;
  final String? className;
  final String createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.teacherName,
    this.className,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      teacherName: json['teacher_name'],
      className: json['class_name'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class AttendanceRecord {
  final int id;
  final int student;
  final String? studentName;
  final int relatedClass;
  final String? className;
  final String date;
  final String status;
  final int markedBy;
  final String? teacherName;
  final String markedAt;

  AttendanceRecord({
    required this.id,
    required this.student,
    this.studentName,
    required this.relatedClass,
    this.className,
    required this.date,
    required this.status,
    required this.markedBy,
    this.teacherName,
    required this.markedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0,
      student: json['student'] ?? json['student_id'] ?? 0,
      studentName: json['student_name'],
      relatedClass: json['related_class'] ?? 0,
      className: json['class_name'],
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      markedBy: json['marked_by'] ?? 0,
      teacherName: json['teacher_name'] ?? json['marked_by_name'],
      markedAt: json['marked_at'] ?? '',
    );
  }
}

class AppNotification {
  final int id;
  final int recipient;
  final String type;
  final String message;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.recipient,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      recipient: json['recipient'] ?? 0,
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Skill {
  final int id;
  final String name;
  final int? skillImportance;

  Skill({required this.id, required this.name, this.skillImportance});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      skillImportance: json['skill_importance'],
    );
  }
}

class EnrollmentRequest {
  final int id;
  final int student;
  final String studentName;
  final int classObj;
  final String className;
  final String teacherName;
  final String status;
  final String requestedAt;
  final String? respondedAt;
  final int? classTeacherId;
  final String? levelName;

  EnrollmentRequest({
    required this.id,
    required this.student,
    required this.studentName,
    required this.classObj,
    required this.className,
    required this.teacherName,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.classTeacherId,
    this.levelName,
  });

  factory EnrollmentRequest.fromJson(Map<String, dynamic> json) {
    return EnrollmentRequest(
      id: json['id'] ?? 0,
      student: json['student'] ?? 0,
      studentName: json['student_name'] ?? '',
      classObj: json['class_obj'] ?? 0,
      className: json['class_name'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      requestedAt: json['requested_at'] ?? '',
      respondedAt: json['responded_at'],
      classTeacherId: json['class_teacher'],
      levelName: json['level_name'],
    );
  }
}
