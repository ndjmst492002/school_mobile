import 'package:get/get.dart';
import '../providers/api_provider.dart';

class AuthApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post(
      '/users/login/',
      data: {'email': email, 'password': password},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<void> logout() async {
    try {
      await _api.post('/users/logout/');
    } catch (e) {
      // Continue even if logout fails
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _api.get('/users/me/');
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {};
  }

  Future<String> getWsTicket() async {
    final response = await _api.post('/users/ws-ticket/');
    return response.data['ticket'];
  }

  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    final response = await _api.post(
      '/users/otp/send/',
      data: {'phone_number': phoneNumber},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String code,
    required String email,
    String? firstName,
    String? lastName,
    String? address,
    String? dateOfBirth,
  }) async {
    final response = await _api.post(
      '/users/otp/verify/',
      data: {
        'phone_number': phoneNumber,
        'code': code,
        'email': email,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
        'address': address ?? '',
        'date_of_birth': dateOfBirth ?? '',
      },
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> phoneLoginSend(String phoneNumber) async {
    final response = await _api.post(
      '/users/login/phone/send/',
      data: {'phone_number': phoneNumber},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> phoneLoginVerify(
    String phoneNumber,
    String code,
  ) async {
    final response = await _api.post(
      '/users/login/phone/verify/',
      data: {'phone_number': phoneNumber, 'code': code},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> googleAuth(String accessToken) async {
    final response = await _api.post(
      '/users/auth/google/',
      data: {'access_token': accessToken},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> googleLoginOnly(String accessToken) async {
    final response = await _api.post(
      '/users/login/google/',
      data: {'access_token': accessToken},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> contactUs({
    required String name,
    required String email,
    required String message,
  }) async {
    final response = await _api.post(
      '/users/contact/',
      data: {'name': name, 'email': email, 'message': message},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> createTeacherProfile({
    required String hireDate,
    required String specialization,
    required String className,
    String? classDescription,
  }) async {
    final response = await _api.post(
      '/users/profile/teacher/',
      data: {
        'hire_date': hireDate,
        'specialization': specialization,
        'class_name': className,
        'class_description': classDescription ?? '',
      },
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }

  Future<Map<String, dynamic>> createParentProfile({
    required String occupation,
    required List<Map<String, dynamic>> students,
  }) async {
    final response = await _api.post(
      '/users/profile/parent/',
      data: {'occupation': occupation, 'students': students},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'success': true};
  }
}
