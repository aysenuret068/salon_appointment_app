class AdminDashboardData {
  const AdminDashboardData(this.values);
  final Map<String, dynamic> values;
  factory AdminDashboardData.fromJson(Map<String, dynamic> json) =>
      AdminDashboardData(json);
  int count(String key) => (values[key] as num?)?.toInt() ?? 0;
  double number(String key) => (values[key] as num?)?.toDouble() ?? 0;
}
