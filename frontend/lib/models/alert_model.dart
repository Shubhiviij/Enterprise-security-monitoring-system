class AlertModel {
  final String severity;
  final String message;

  AlertModel({
    required this.severity,
    required this.message,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      severity: json['severity'],
      message: json['message'],
    );
  }
}