import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/appointment_model.dart';
import '../models/app_user_model.dart';
import '../models/business_model.dart';
import '../models/employee_model.dart';
import '../models/service_model.dart';
import '../models/slot_model.dart';
import '../models/review_model.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://onlineesistem-api.onrender.com/api',
  );

  Future<AppUserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/register');

    final body = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Kayıt başarısız: ${response.body}');
    }

    return AppUserModel.fromJson(jsonDecode(response.body));
  }

  Future<AppUserModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/login');

    final body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Giriş başarısız: ${response.body}');
    }

    return AppUserModel.fromJson(jsonDecode(response.body));
  }

  Future<List<BusinessModel>> getBusinesses() async {
    final url = Uri.parse('$baseUrl/Businesses');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('İşletmeler getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => BusinessModel.fromJson(item)).toList();
  }

  Future<List<BusinessModel>> getBusinessesByOwner(int ownerUserId) async {
    final url = Uri.parse('$baseUrl/Businesses/owner/$ownerUserId');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('İşletmeler getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => BusinessModel.fromJson(item)).toList();
  }

  Future<BusinessModel> createBusiness({
    required int ownerUserId,
    required String name,
    required String address,
    required String phone,
    required String openTime,
    required String closeTime,
  }) async {
    final url = Uri.parse('$baseUrl/Businesses');

    final body = {
      'ownerUserId': ownerUserId,
      'name': name,
      'address': address,
      'phone': phone,
      'openTime': openTime,
      'closeTime': closeTime,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('İşletme oluşturulamadı: ${response.body}');
    }

    return BusinessModel.fromJson(jsonDecode(response.body));
  }

  Future<BusinessModel> updateBusiness({
    required int businessId,
    required String name,
    required String address,
    required String phone,
    required String openTime,
    required String closeTime,
  }) async {
    final url = Uri.parse('$baseUrl/Businesses/$businessId');

    final body = {
      'name': name,
      'address': address,
      'phone': phone,
      'openTime': openTime,
      'closeTime': closeTime,
    };

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('İşletme güncellenemedi: ${response.body}');
    }

    return BusinessModel.fromJson(jsonDecode(response.body));
  }

  Future<List<ServiceModel>> getServicesByBusiness(int businessId) async {
    final url = Uri.parse('$baseUrl/Services/business/$businessId');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Hizmetler getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => ServiceModel.fromJson(item)).toList();
  }

  Future<ServiceModel> createService({
    required int businessId,
    required String name,
    required int durationMinutes,
    required int bufferMinutes,
    required double price,
  }) async {
    final url = Uri.parse('$baseUrl/Services');

    final body = {
      'businessId': businessId,
      'name': name,
      'durationMinutes': durationMinutes,
      'bufferMinutes': bufferMinutes,
      'price': price,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Hizmet eklenemedi: ${response.body}');
    }

    return ServiceModel.fromJson(jsonDecode(response.body));
  }

  Future<List<EmployeeModel>> getEmployeesByBusiness(int businessId) async {
    final url = Uri.parse('$baseUrl/Employees/business/$businessId');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Çalışanlar getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => EmployeeModel.fromJson(item)).toList();
  }

  Future<EmployeeModel> createEmployee({
    required int businessId,
    required String fullName,
  }) async {
    final url = Uri.parse('$baseUrl/Employees');

    final body = {
      'businessId': businessId,
      'fullName': fullName,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Çalışan eklenemedi: ${response.body}');
    }

    return EmployeeModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteEmployee(int employeeId) async {
    final url = Uri.parse('$baseUrl/Employees/$employeeId');

    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Çalışan silinemedi: ${response.body}');
    }
  }

  Future<void> assignServiceToEmployee({
    required int employeeId,
    required int serviceId,
  }) async {
    final url = Uri.parse('$baseUrl/EmployeeServices');

    final body = {
      'employeeId': employeeId,
      'serviceId': serviceId,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Hizmet çalışana atanamadı: ${response.body}');
    }
  }

  Future<List<EmployeeModel>> getEmployeesByBusinessAndService({
    required int businessId,
    required int serviceId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/EmployeeServices/business/$businessId/service/$serviceId/employees',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Bu hizmeti yapan çalışanlar getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => EmployeeModel.fromJson(item)).toList();
  }

  Future<List<SlotModel>> getAvailableSlots({
    required int businessId,
    required int employeeId,
    required int serviceId,
    required DateTime date,
  }) async {
    final url = Uri.parse(
      '$baseUrl/Availability'
      '?businessId=$businessId'
      '&employeeId=$employeeId'
      '&serviceId=$serviceId'
      '&date=${date.toIso8601String()}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Uygun saatler getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => SlotModel.fromJson(item)).toList();
  }

  Future<void> createAppointment({
    required int businessId,
    required int employeeId,
    required int serviceId,
    int? customerUserId,
    required String customerName,
    required String customerPhone,
    required DateTime startTime,
  }) async {
    final url = Uri.parse('$baseUrl/Appointments');

    final body = {
      'businessId': businessId,
      'employeeId': employeeId,
      'serviceId': serviceId,
      'customerUserId': customerUserId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'startTime': startTime.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 409) {
      throw Exception('Bu saat dolu. Başka saat seç.');
    }

    if (response.statusCode != 200) {
      throw Exception('Randevu oluşturulamadı: ${response.body}');
    }
  }

  Future<List<AppointmentModel>> getCustomerAppointments(int customerUserId) async {
    final url = Uri.parse('$baseUrl/Appointments/customer/$customerUserId');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Randevular getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => AppointmentModel.fromJson(item)).toList();
  }

  Future<List<AppointmentModel>> getBusinessAppointments({
    required int businessId,
    required DateTime date,
  }) async {
    final url = Uri.parse(
      '$baseUrl/Appointments/business/$businessId'
      '?date=${date.toIso8601String()}',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('İşletme randevuları getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => AppointmentModel.fromJson(item)).toList();
  }

  Future<List<AppointmentModel>> getAllBusinessAppointments(int businessId) async {
    final url = Uri.parse('$baseUrl/Appointments/business/$businessId/all');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'İşletme randevuları getirilemedi. '
        'Kod: ${response.statusCode} '
        'Cevap: ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => AppointmentModel.fromJson(item)).toList();
  }

  Future<void> cancelAppointment({
    required int appointmentId,
    String? reason,
  }) async {
    final uri = Uri.parse('$baseUrl/Appointments/$appointmentId/cancel');

    final url = reason == null || reason.trim().isEmpty
        ? uri
        : uri.replace(queryParameters: {'reason': reason.trim()});

    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('Randevu iptal edilemedi: ${response.body}');
    }
  }

  Future<void> completeAppointment(int appointmentId) async {
    final url = Uri.parse('$baseUrl/Appointments/$appointmentId/complete');

    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('Randevu tamamlanamadı: ${response.body}');
    }
  }

  Future<void> markNoShow(int appointmentId) async {
    final url = Uri.parse('$baseUrl/Appointments/$appointmentId/no-show');

    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('Randevu gelmedi yapılamadı: ${response.body}');
    }
  }

  Future<void> createReview({
    required int appointmentId,
    required int rating,
    required String comment,
  }) async {
    final url = Uri.parse('$baseUrl/Reviews');

    final body = {
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Yorum eklenemedi: ${response.body}');
    }
  }

  Future<List<ReviewModel>> getBusinessReviews(int businessId) async {
    final url = Uri.parse('$baseUrl/Reviews/business/$businessId');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Yorumlar getirilemedi: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => ReviewModel.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getBusinessAverageRating(int businessId) async {
    final url = Uri.parse('$baseUrl/Reviews/business/$businessId/average');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Ortalama puan getirilemedi: ${response.body}');
    }

    return jsonDecode(response.body);
  }
  Future<void> deleteBusiness(int businessId) async {
  final url = Uri.parse('$baseUrl/Businesses/$businessId');

  final response = await http.delete(url);

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      response.body.isEmpty
          ? 'İşletme silinemedi.'
          : response.body,
    );
  }
}
}
