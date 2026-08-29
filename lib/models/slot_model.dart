class SlotModel {
  final DateTime startTime;
  final DateTime endTime;
  final int totalMinutes;

  SlotModel({
    required this.startTime,
    required this.endTime,
    required this.totalMinutes,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      totalMinutes: json['totalMinutes'],
    );
  }
}