class HistoryModel {
  final String timestamp;
  final int threats;
  final int alerts;
  final int highRisk;

  HistoryModel({
    required this.timestamp,
    required this.threats,
    required this.alerts,
    required this.highRisk,
  });

  factory HistoryModel.fromJson(
      Map<String, dynamic> json) {
    return HistoryModel(
      timestamp: json["timestamp"],
      threats: json["threats"],
      alerts: json["alerts"],
      highRisk: json["high_risk"],
    );
  }
}