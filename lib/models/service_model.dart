class ServiceModel {
  final int id;
  final int businessId;
  final String name;
  final int durationMinutes;
  final int bufferMinutes;
  final double price;

  ServiceModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.durationMinutes,
    required this.bufferMinutes,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      businessId: json['businessId'],
      name: json['name'],
      durationMinutes: json['durationMinutes'],
      bufferMinutes: json['bufferMinutes'],
      price: (json['price'] as num).toDouble(),
    );
  }
}