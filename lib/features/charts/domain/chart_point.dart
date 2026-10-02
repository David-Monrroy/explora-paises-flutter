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
    this.region = '',
    this.currencyNames = const [],
    this.borderCodes = const [],
    this.languageNames = const [],
  });

  final String label;
  final double value;
  final double secondaryValue;
  final String? countryCode;
  final List<String> members;
  final double? originalValue;
  final Map<ChartMetric, double> metrics;
  final String region;
  final List<String> currencyNames;
  final List<String> borderCodes;
  final List<String> languageNames;

  String get axisLabel => countryCode ?? label;
}
