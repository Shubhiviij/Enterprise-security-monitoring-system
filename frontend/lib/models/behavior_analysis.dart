class BehaviorAnalysis {
  final String status;
  final int riskScore;
  final List<String> anomalies;
  final DateTime evaluatedAt;
  final Map<String, dynamic> trackedMetrics;

  BehaviorAnalysis({
    required this.status,
    required this.riskScore,
    required this.anomalies,
    required this.evaluatedAt,
    required this.trackedMetrics,
  });

  factory BehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    final metrics = meta['tracked_metrics'] ?? {};

    return BehaviorAnalysis(
      status: json['status'] ?? 'UNKNOWN',
      riskScore: json['risk_score'] ?? 0,
      anomalies: List<String>.from(json['anomalies'] ?? []),
      evaluatedAt: DateTime.tryParse(
        meta['evaluated_at'] ?? '',
      ) ??
          DateTime.now(),
      trackedMetrics: Map<String, dynamic>.from(metrics),
    );
  }
}