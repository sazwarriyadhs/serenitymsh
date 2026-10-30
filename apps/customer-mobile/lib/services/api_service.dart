import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static Future<Map<String, dynamic>> submitInquiry({
    required String guestName,
    required String email,
    required String inquiryType,
    required String notes,
  }) async {
    final uri = Uri.parse('$baseUrl/inquiries');

    try {
      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'guest_name': guestName.trim(),
              'email': email.trim(),
              'inquiry_type': inquiryType,
              'notes': notes.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final dynamic decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      final data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      throw ApiException(
        data['error']?.toString() ??
            'Server menolak permintaan (${response.statusCode}).',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('Respons server tidak dapat dibaca.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiException('Koneksi ke server timeout. Coba kembali.');
      }
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.',
      );
    }
  }

  static Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/dashboard'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException('Dashboard tidak tersedia.');
      }

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return data;

      throw ApiException('Format dashboard tidak valid.');
    } catch (_) {
      throw ApiException('Data hotel belum dapat dimuat.');
    }
  }
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
