import 'dart:convert';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider extends GetxService {
  late final dio_pkg.Dio _dio;
  String? _webToken;

  //static const String baseUrl = 'http://localhost:8000/api';
  static const String baseUrl = 'https://school-backend-9j8f.onrender.com/api';
  Future<ApiProvider> init() async {
    _dio = dio_pkg.Dio(
      dio_pkg.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true,
      ),
    );

    // Only use cookie manager on mobile, not on web
    if (!kIsWeb) {
      var cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(cookieJar));
    } else {
      // On web, enable sending cookies cross-origin (needed for HttpOnly cookie auth)
      _dio.options.extra['withCredentials'] = true;
    }
    // Load JWT token from SharedPreferences (for both web and mobile)
    final prefs = await SharedPreferences.getInstance();
    _webToken = prefs.getString('web_token');
    bool _refreshing = false;
    _dio.interceptors.add(
      dio_pkg.InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add JWT token if available (both web and mobile)
          if (_webToken != null) {
            options.headers['Authorization'] = 'Bearer $_webToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_refreshing) {
            _refreshing = true;
            try {
              await _dio.post('/users/token/refresh/');
              final retryOpts = error.requestOptions;
              final retryResponse = await _dio.request(
                retryOpts.path,
                data: retryOpts.data,
                queryParameters: retryOpts.queryParameters,
                options: dio_pkg.Options(
                  method: retryOpts.method,
                  headers: retryOpts.headers,
                ),
              );
              _refreshing = false;
              return handler.resolve(retryResponse);
            } catch (_) {
              _refreshing = false;
              Get.find<AuthService>().logout();
            }
          }
          return handler.next(error);
        },
      ),
    );
    return this;
  }

  dio_pkg.Dio get dio => _dio;
  Future<dio_pkg.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio_pkg.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<dio_pkg.Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<dio_pkg.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<dio_pkg.Response> uploadFile(
    String path, {
    required dio_pkg.FormData data,
  }) async {
    return await _dio.post(
      path,
      data: data,
      options: dio_pkg.Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> downloadFile(String url, String filename) async {
    await _dio.download(url, filename);
  }

  Future<void> setWebToken(String token) async {
    _webToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('web_token', token);
  }

  Future<void> clearWebToken() async {
    _webToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('web_token');
  }
}

class AuthService extends GetxService {
  final _isAuthenticated = false.obs;
  final _user = Rxn<Map<String, dynamic>>();
  final _role = 'STUDENT'.obs;
  final _roles = <String>[].obs;
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  bool get isAuthenticated => _isAuthenticated.value;
  Map<String, dynamic>? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  String get role => _role.value;
  List<String> get roles => _roles.toList();
  bool get hasMultipleRoles => _roles.length > 1;
  int get userId => _user.value?['id'] ?? 0;
  String get userEmail => _user.value?['email'] ?? '';
  String get userFullName {
    final fullName = _user.value?['full_name'] ?? '';
    if (fullName.isNotEmpty) return fullName;

    // Construct from first_name and last_name
    final firstName = _user.value?['first_name'] ?? '';
    final lastName = _user.value?['last_name'] ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    return _user.value?['email'] ?? '';
  }

  void setUser(
    Map<String, dynamic>? userData, {
    String? role,
    List<String>? roles,
  }) {
    _user.value = userData;
    _isAuthenticated.value = userData != null;
    if (role != null) {
      _role.value = role;
    }
    if (roles != null && roles.isNotEmpty) {
      _roles.value = roles;
    }
    _saveToStorage();
  }

  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setError(String? error) {
    _error.value = error;
  }

  void clearError() {
    _error.value = null;
  }

  void switchRole(String newRole) {
    if (_roles.contains(newRole)) {
      _role.value = newRole;
      _saveToStorage();
    }
  }

  Future<void> _saveToStorage() async {
    if (_user.value == null) return;
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('auth_user', json.encode(_user.value));
      await prefs.setString('auth_role', _role.value);
      await prefs.setStringList('auth_roles', _roles.toList());
    } catch (_) {}
  }

  Future<bool> restoreFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('auth_user');
      if (savedUser == null) return false;
      final userData = json.decode(savedUser) as Map<String, dynamic>;
      final role = prefs.getString('auth_role') ?? '';
      final roles = prefs.getStringList('auth_roles') ?? [];
      _user.value = userData;
      _role.value = role;
      _roles.value = roles;
      _isAuthenticated.value = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _user.value = null;
    _isAuthenticated.value = false;
    _clearStorage();
    // Clear JWT token
    final apiProvider = Get.find<ApiProvider>();
    apiProvider.clearWebToken();
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    await prefs.remove('auth_role');
    await prefs.remove('auth_roles');
  }
}
