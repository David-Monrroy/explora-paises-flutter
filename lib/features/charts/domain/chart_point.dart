import 'chart_metric.dart';

class ChartPoint {
  const ChartPoint({
    required this.label,
    required this.value,
    required this.secondaryValue,
    this.countryCode,
    this.members = const [],
    this.originalValue,
    this.metrics = const {},
  });

  final String label;
  final double value;
  final double secondaryValue;
  final String? countryCode;
  final List<String> members;
  final double? originalValue;
  final Map<ChartMetric, double> metrics;

  String get axisLabel => countryCode ?? label;
}
