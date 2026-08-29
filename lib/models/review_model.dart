class ReviewModel {
  final int id;
  final int rating;
  final String? comment;
  final String? customerName;
  final String? employeeName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    this.customerName,
    this.employeeName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      customerName: json['customerName'],
      employeeName: json['employeeName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}