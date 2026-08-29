import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../models/admin_session_data.dart';

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AdminAuthService {
  Future<AdminSessionData> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/admin/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );
    if (response.statusCode == 403) {
      throw const AdminAuthException('Bu hesabın yönetim paneline erişim yetkisi bulunmuyor.');
    }
    if (response.statusCode == 401) throw const AdminAuthException('Email veya şifre hatalı.');
    if (response.statusCode != 200) {
      throw const AdminAuthException('Sunucuya bağlanılamadı. Lütfen tekrar deneyin.');
    }
    final session = AdminSessionData.fromJson(jsonDecode(response.body));
    if (!session.isAdmin) {
      throw const AdminAuthException('Bu hesabın yönetim paneline erişim yetkisi bulunmuyor.');
    }
    return session;
  }
}
