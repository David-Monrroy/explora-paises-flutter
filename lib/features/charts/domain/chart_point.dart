class ChartPoint {
  const ChartPoint({
    required this.label,
    required this.value,
    required this.secondaryValue,
    this.countryCode,
    this.members = const [],
    this.originalValue,
  });

  final String label;
  final double value;
  final double secondaryValue;
  final String? countryCode;
  final List<String> members;
  final double? originalValue;

  String get axisLabel => countryCode ?? label;
}
