import 'models.dart';

class StudentChild {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? parentOccupation;
  final String? dateOfBirth;
  final String? enrollmentDate;
  final String? parentName;
  final int? enrollmentAge;

  StudentChild({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.parentOccupation,
    this.dateOfBirth,
    this.enrollmentDate,
    this.parentName,
    this.enrollmentAge,
  });

  factory StudentChild.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return StudentChild(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phoneNumber: user?['phone_number'],
      address: user?['address'],
      parentOccupation: json['parent_occupation'],
      dateOfBirth: json['date_of_birth'] ?? user?['date_of_birth'],
      enrollmentDate: json['enrollment_date'],
      parentName: json['parent_name'],
      enrollmentAge: json['enrollment_age'],
    );
  }
}

class ChildAnnouncement {
  final String childName;
  final AnnouncementData announcement;

  ChildAnnouncement({required this.childName, required this.announcement});

  factory ChildAnnouncement.fromJson(Map<String, dynamic> json) {
    return ChildAnnouncement(
      childName: json['child_name'] ?? '',
      announcement: AnnouncementData.fromJson(json['announcement'] ?? {}),
    );
  }
}

class AnnouncementData {
  final int id;
  final String title;
  final String content;
  final String? teacherName;
  final String? className;
  final String createdAt;

  AnnouncementData({
    required this.id,
    required this.title,
    required this.content,
    this.teacherName,
    this.className,
    required this.createdAt,
  });

  factory AnnouncementData.fromJson(Map<String, dynamic> json) {
    return AnnouncementData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      teacherName: json['teacher_name'],
      className: json['class_name'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ChildAttendance {
  final String childName;
  final List<AttendanceRecord> attendance;

  ChildAttendance({required this.childName, required this.attendance});

  factory ChildAttendance.fromJson(Map<String, dynamic> json) {
    return ChildAttendance(
      childName: json['child_name'] ?? '',
      attendance: json['attendance'] != null
          ? (json['attendance'] as List)
                .map((a) => AttendanceRecord.fromJson(a))
                .toList()
          : [],
    );
  }
}

class PredictionResult {
  final int studentId;
  final String studentName;
  final String prediction;
  final double confidence;
  final Map<String, dynamic> featuresUsed;

  PredictionResult({
    required this.studentId,
    required this.studentName,
    required this.prediction,
    required this.confidence,
    required this.featuresUsed,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      prediction: json['prediction'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      featuresUsed: json['features_used'] ?? {},
    );
  }

  @override
  String toString() => 'PredictionResult(studentId: $studentId, studentName: $studentName, '
      'prediction: $prediction, confidence: $confidence, featuresUsed: $featuresUsed)';
}
