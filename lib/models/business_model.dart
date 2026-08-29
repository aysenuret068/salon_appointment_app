class BusinessModel {
  final int id;
  final int? ownerUserId;
  final String name;
  final String? address;
  final String? phone;
  final String? openTime;
  final String? closeTime;

  BusinessModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    this.address,
    this.phone,
    this.openTime,
    this.closeTime,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      ownerUserId: json['ownerUserId'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
    );
  }
}