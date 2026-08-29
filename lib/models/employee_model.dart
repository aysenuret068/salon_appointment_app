class EmployeeModel {
  final int id;
  final int businessId;
  final String fullName;

  EmployeeModel({
    required this.id,
    required this.businessId,
    required this.fullName,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      businessId: json['businessId'],
      fullName: json['fullName'],
    );
  }
}