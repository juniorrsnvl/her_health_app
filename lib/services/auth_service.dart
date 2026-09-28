import 'dart:convert';
import 'package:http/http.dart' as http;

/// Handles HTTP calls to the FastAPI backend for the patient app.
///
/// Base URL notes:
/// - iOS simulator / macOS desktop / Chrome (web): http://127.0.0.1:8000
///   works as-is.
/// - Android emulator: use http://10.0.2.2:8000 instead -- localhost
///   there refers to the emulator itself, not your Mac.
/// - Physical device: use your Mac's LAN IP (e.g. http://192.168.x.x:8000),
///   with the phone on the same Wi-Fi network.
class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// Registers a new account. On success, returns a map containing
  /// email_code and phone_code -- these are SIMULATED verification codes
  /// (no real email/SMS provider is connected yet), meant to be shown
  /// on-screen during development. The user only needs to verify ONE of
  /// the two, their choice. Throws a String error message on failure.
  static Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _post('/auth/register', {
      'email': email,
      'phone': phone,
      'password': password,
    });
    return response;
  }

  /// Verifies the account using ONE method -- 'email' or 'phone' -- with
  /// its corresponding code. Throws a String error message
  /// (e.g. "Incorrect verification code.") on failure.
  static Future<void> verify({
    required String email,
    required String method,
    required String code,
  }) async {
    await _post('/auth/verify', {
      'email': email,
      'method': method,
      'code': code,
    });
  }

  /// Requests new codes. Returns the new SIMULATED codes the same way
  /// register() does.
  static Future<Map<String, dynamic>> resendCodes({
    required String email,
  }) async {
    return await _post('/auth/resend-codes', {'email': email});
  }

  /// Logs in, returning the access token on success.
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return response['access_token'] as String;
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      throw 'Could not reach the server. Check your connection and try again.';
    }

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = data?['detail'];
      throw detail is String ? detail : 'Something went wrong. Please try again.';
    }

    return data ?? {};
  }
}
