class StatsModel {
  final int threats;
  final int alerts;
  final int highRisk;
  final int users;

  StatsModel({
    required this.threats,
    required this.alerts,
    required this.highRisk,
    required this.users,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      threats: json['threats'],
      alerts: json['alerts'],
      highRisk: json['high_risk'],
      users: json['users'],
    );
  }
}