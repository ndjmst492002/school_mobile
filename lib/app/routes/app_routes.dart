import 'package:get/get.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/signup/signup_binding.dart';
import '../modules/signup/signup_view.dart';
import '../modules/admin/admin_binding.dart';
import '../modules/admin/admin_view.dart';
import '../modules/teacher/teacher_binding.dart';
import '../modules/teacher/teacher_view.dart';
import '../modules/student/student_binding.dart';
import '../modules/student/student_view.dart';
import '../modules/parent/parent_binding.dart';
import '../modules/parent/parent_view.dart';
import '../modules/profile_completion/profile_completion_binding.dart';
import '../modules/profile_completion/profile_completion_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String admin = '/admin';
  static const String teacher = '/teacher';
  static const String student = '/student';
  static const String parent = '/parent';
  static const String profileCompletion = '/profile-completion';
  static const String home = '/';

  static List<GetPage> get pages => [
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: admin,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: teacher,
      page: () => const TeacherView(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: student,
      page: () => const StudentView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: parent,
      page: () => const ParentView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: profileCompletion,
      page: () => const ProfileCompletionView(),
      binding: ProfileCompletionBinding(),
    ),
  ];
}
