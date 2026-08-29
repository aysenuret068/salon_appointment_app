class AppUserModel {
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  AppUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}