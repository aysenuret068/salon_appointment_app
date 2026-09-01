import 'dart:convert';
import 'dart:typed_data';
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
  Future<dynamic> upload(String path, Uint8List bytes, String fileName) async {
    final session = AdminSession.current;
    if (session == null || !session.isValid) {
      throw const AdminApiException('Oturum süresi doldu.', 401);
    }
    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('${ApiService.baseUrl}/admin/$path'),
          )
          ..headers['Authorization'] = 'Bearer ${session.accessToken}'
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: fileName),
          );
    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } catch (_) {
      throw const AdminApiException('Sunucuya bağlanılamadı.', 0);
    }
  }

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
        queryParameters: query.map((k, v) => MapEntry(k, '$v')),
      );
    }
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
    try {
      final response = await switch (method) {
        'POST' => http.post(uri, headers: headers, body: jsonEncode(body)),
        'PUT' => http.put(uri, headers: headers, body: jsonEncode(body)),
        'PATCH' => http.patch(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.get(uri, headers: headers),
      };
      return _decode(response);
    } catch (e) {
      if (e is AdminApiException) rethrow;
      throw const AdminApiException('Sunucuya bağlanılamadı.', 0);
    }
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    }
    if (response.statusCode == 401) AdminSession.clear();
    var message = switch (response.statusCode) {
      400 => 'Gönderilen bilgiler geçersiz.',
      401 => 'Oturum süresi doldu.',
      403 => 'Bu işlem için yetkiniz yok.',
      404 => 'Kayıt bulunamadı.',
      409 => 'İşlem mevcut verilerle çakışıyor.',
      _ => 'Bir hata oluştu.',
    };
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final candidate =
            decoded['message'] ?? decoded['detail'] ?? decoded['title'];
        if (candidate is String && candidate.isNotEmpty) {
          message = candidate;
        }
      } else if (decoded is String && decoded.isNotEmpty) {
        message = decoded;
      }
    } catch (_) {}
    throw AdminApiException(message, response.statusCode);
  }
}
