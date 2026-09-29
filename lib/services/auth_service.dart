import 'dart:convert';
import 'package:http/http.dart' as http;

/// An error from the backend, carrying the HTTP status code so callers can
/// react to specific cases (e.g. an unverified account at login).
///
/// toString() returns just the message, so existing code that shows
/// e.toString() to the user keeps working unchanged.
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  /// True when login was refused because the account isn't verified yet.
  /// Matches the 403 the backend sends for that case (a 403 is also used
  /// for inactive accounts, so the message is checked as well).
  bool get isUnverified =>
      statusCode == 403 && message.toLowerCase().contains('verify');

  @override
  String toString() => message;
}

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

  /// The login token, held in memory only for now -- it is lost when the
  /// app restarts. Persistent storage (flutter_secure_storage) should be
  /// added when authenticated endpoints such as the health journey are
  /// wired up.
  static String? accessToken;

  static bool get isLoggedIn => accessToken != null;

  static void logout() {
    accessToken = null;
  }

  /// Registers a new account. On success, returns a map containing
  /// email_code and phone_code -- these are SIMULATED verification codes
  /// (no real email/SMS provider is connected yet), meant to be shown
  /// on-screen during development. The user only needs to verify ONE of
  /// the two, their choice. Throws a String error message on failure.
  static Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
    String? fullName,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'phone': phone,
      'password': password,
    };

    // Optional profile details -- only sent when filled in. When a name is
    // sent, the backend creates the patient profile together with the
    // account.
    if (fullName != null && fullName.trim().isNotEmpty) {
      body['full_name'] = fullName.trim();
    }
    if (dateOfBirth != null) {
      final mm = dateOfBirth.month.toString().padLeft(2, '0');
      final dd = dateOfBirth.day.toString().padLeft(2, '0');
      body['date_of_birth'] = '${dateOfBirth.year}-$mm-$dd';
    }
    if (emergencyContactName != null && emergencyContactName.trim().isNotEmpty) {
      body['emergency_contact_name'] = emergencyContactName.trim();
    }
    if (emergencyContactPhone != null &&
        emergencyContactPhone.trim().isNotEmpty) {
      body['emergency_contact_phone'] = emergencyContactPhone.trim();
    }

    return await _post('/auth/register', body);
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
  /// Saves (creates or updates) the caller's health journey. Requires the
  /// user to be logged in -- accessToken must be set.
  static Future<void> saveHealthJourney({
    required String journeyType,
    required Map<String, dynamic> answers,
  }) async {
    await _authorizedPost('/health-journey/setup', {
      'journey_type': journeyType,
      'answers': answers,
    });
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    final token = response['access_token'] as String;
    accessToken = token;
    return token;
  }

  /// Same as _post, but attaches the logged-in user's token. Throws an
  /// AuthException immediately if no one is logged in, rather than sending
  /// a request that the backend would just reject as unauthenticated.
  static Future<Map<String, dynamic>> _authorizedPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = accessToken;
    if (token == null) {
      throw AuthException('You need to be logged in to do that.');
    }

    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      throw AuthException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    return _handleResponse(response);
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
      throw AuthException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    return _handleResponse(response);
  }

  /// Shared response parsing for both _post and _authorizedPost.
  static Map<String, dynamic> _handleResponse(http.Response response) {

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = data?['detail'];
      throw AuthException(
        detail is String ? detail : 'Something went wrong. Please try again.',
        statusCode: response.statusCode,
      );
    }

    return data ?? {};
  }
}
