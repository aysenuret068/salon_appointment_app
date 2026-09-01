import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import 'admin_session.dart';

class AdminApiException implements Exception {
  const AdminApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
  @override
  String toString() => message;
}

class AdminApiService {
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);
  Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body: body);
  Future<dynamic> patch(String path, [Object? body]) =>
      _send('PATCH', path, body: body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final session = AdminSession.current;
    if (session == null || !session.isValid) {
      await AdminSession.clear();
      throw const AdminApiException('Oturum süresi doldu.', 401);
    }
    var uri = Uri.parse('${ApiService.baseUrl}/admin/$path');
    if (query != null) {
      uri = uri.replace(
        queryParameters: query.map((key, value) => MapEntry(key, '$value')),
      );
    }
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
    late http.Response response;
    try {
      response = await switch (method) {
        'POST' => http.post(uri, headers: headers, body: jsonEncode(body)),
        'PUT' => http.put(uri, headers: headers, body: jsonEncode(body)),
        'PATCH' => http.patch(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.get(uri, headers: headers),
      };
    } catch (_) {
      throw const AdminApiException('Sunucuya bağlanılamadı.', 0);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    }
    if (response.statusCode == 401) await AdminSession.clear();
    var message = 'İşlem gerçekleştirilemedi.';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) {
        message = decoded['message'] as String;
      } else if (decoded is String) {
        message = decoded;
      }
    } catch (_) {
      if (response.statusCode == 403) message = 'Bu işlem için yetkiniz yok.';
      if (response.statusCode == 404) message = 'Kayıt bulunamadı.';
      if (response.statusCode == 409)
        message = 'İşlem mevcut verilerle çakışıyor.';
    }
    throw AdminApiException(message, response.statusCode);
  }
}
