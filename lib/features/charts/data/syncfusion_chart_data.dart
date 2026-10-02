import 'dart:math' as math;

import '../domain/chart_metric.dart';
import 'creative_chart_data.dart';

const discreteProfileMetrics = [
  ChartMetric.languages,
  ChartMetric.borders,
  ChartMetric.timezones,
  ChartMetric.currencies,
];
const sizeProfileMetrics = [
  ChartMetric.population,
  ChartMetric.area,
  ChartMetric.density,
];

/// A point always retains one of the seven source countries.
class SyncfusionCountryDatum {
  SyncfusionCountryDatum(this.index, this.source);
  final int index;
  final CreativeChartData source;
  String get code => source.points[index].axisLabel;
  String? get countryCode => source.points[index].countryCode;
  double relative(ChartMetric metric) => source.relative(index, metric);
  double raw(ChartMetric metric) => source.value(index, metric);
  List<double> profile(Iterable<ChartMetric> metrics) => [
    for (final metric in metrics) relative(metric),
  ];
  double low(Iterable<ChartMetric> metrics) =>
      profile(metrics).reduce(math.min);
  double high(Iterable<ChartMetric> metrics) =>
      profile(metrics).reduce(math.max);
  double get densityComplement => source.maximum(ChartMetric.density) == 0
      ? 0
      : 100 - relative(ChartMetric.density);
}

class SyncfusionChartData {
  SyncfusionChartData(this.source)
    : countries = List.unmodifiable([
        for (var i = 0; i < source.points.length; i++)
          SyncfusionCountryDatum(i, source),
      ]);
  final CreativeChartData source;
  final List<SyncfusionCountryDatum> countries;
  double get histogramInterval => source.maximum(ChartMetric.density) == 0
      ? 1
      : source.maximum(ChartMetric.density) / 4;
  List<SyncfusionCountryDatum> orderedBy(
    ChartMetric metric, {
    bool ascending = false,
  }) {
    return List.of(countries)..sort((a, b) {
      final comparison = a.raw(metric).compareTo(b.raw(metric));
      return comparison == 0
          ? a.code.compareTo(b.code)
          : ascending
          ? comparison
          : -comparison;
    });
  }
}
