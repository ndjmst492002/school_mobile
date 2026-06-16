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
    required int levelId,
    required int classId,
  }) async {
    final response = await _api.post(
      '/users/profile/teacher/',
      data: {
        'hire_date': hireDate,
        'specialization': specialization,
        'level_id': levelId,
        'class_id': classId,
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

  Future<Map<String, dynamic>> createSubscription(String planType) async {
    final response = await _api.post(
      '/users/payments/checkout/',
      data: {'plan_type': planType},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'checkout_url': ''};
  }

  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final response = await _api.get('/users/payments/status/');
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'is_active_subscription': false};
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _api.post('/users/token/refresh/');
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {};
  }

  Future<Map<String, dynamic>> createCheckout({
    required int amount,
    required String description,
  }) async {
    final response = await _api.post(
      '/users/payments/checkout/',
      data: {'amount': amount, 'description': description},
    );
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    return {'checkout_url': ''};
  }
}
