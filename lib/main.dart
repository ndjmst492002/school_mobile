import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/providers/api_provider.dart';
import 'app/data/services/translations_service.dart';
import 'app/data/services/websocket_service.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'app/initial_binding.dart';

class ThemeService extends GetxService {
  final _isDarkMode = false.obs;
  final _locale = const Locale('en').obs;

  bool get isDarkMode => _isDarkMode.value;
  Locale get locale => _locale.value;

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleLanguage() {
    final currentCode = _locale.value.languageCode;
    if (currentCode == 'en') {
      _locale.value = const Locale('ar');
    } else {
      _locale.value = const Locale('en');
    }
    Get.updateLocale(_locale.value);
  }

  void setDarkMode(bool value) {
    _isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setLocale(Locale locale) {
    _locale.value = locale;
    Get.updateLocale(locale);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServices();

  runApp(const SchoolMobileApp());
}

Future<void> initServices() async {
  Get.put(ThemeService());
  Get.put(TranslationsService());
  Get.put(AuthService());
  await Get.putAsync(() => ApiProvider().init());
  Get.put(WebSocketService());
  InitialBinding().dependencies();
}

class SchoolMobileApp extends StatelessWidget {
  const SchoolMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        title: 'Smart School',
        debugShowCheckedModeBanner: false,
        translations: TranslationsService(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        locale: themeService.locale,
        fallbackLocale: const Locale('en'),
        initialRoute: '/',
        getPages: AppRoutes.pages,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() {
    try {
      final auth = Get.find<AuthService>();

      if (!auth.isAuthenticated) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      switch (auth.role) {
        case 'ADMIN':
          Get.offAllNamed(AppRoutes.admin);
          break;
        case 'TEACHER':
          Get.offAllNamed(AppRoutes.teacher);
          break;
        case 'STUDENT':
          Get.offAllNamed(AppRoutes.student);
          break;
        case 'PARENT':
          Get.offAllNamed(AppRoutes.parent);
          break;
        default:
          Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
