class AdminSessionData {
  const AdminSessionData({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.expiresAt,
  });
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String accessToken;
  final DateTime expiresAt;
  bool get isAdmin => role == 'Admin' || role == 'SuperAdmin';
  bool get isValid =>
      isAdmin &&
      accessToken.isNotEmpty &&
      expiresAt.isAfter(DateTime.now().toUtc());
  factory AdminSessionData.fromJson(Map<String, dynamic> json) =>
      AdminSessionData(
        userId: json['userId'] as int,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        accessToken: json['accessToken'] as String,
        expiresAt: DateTime.parse(json['expiresAtUtc'] as String).toUtc(),
      );
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'role': role,
    'accessToken': accessToken,
    'expiresAtUtc': expiresAt.toIso8601String(),
  };
}
