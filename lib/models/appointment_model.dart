class AppointmentModel {
  final int id;
  final int businessId;
  final int employeeId;
  final int serviceId;
  final int? customerUserId;

  final String customerName;
  final String customerPhone;

  final DateTime startTime;
  final DateTime endTime;

  final double totalPrice;
  final double depositAmount;
  final double remainingAmount;

  final String status;
  final String paymentStatus;

  AppointmentModel({
    required this.id,
    required this.businessId,
    required this.employeeId,
    required this.serviceId,
    required this.customerUserId,
    required this.customerName,
    required this.customerPhone,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    required this.status,
    required this.paymentStatus,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      businessId: json['businessId'],
      employeeId: json['employeeId'],
      serviceId: json['serviceId'],
      customerUserId: json['customerUserId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
    );
  }
}