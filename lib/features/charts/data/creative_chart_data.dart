import 'dart:math' as math;

import '../domain/chart_metric.dart';
import '../domain/chart_point.dart';

/// Shared, library-independent calculations for all panels in an exploration.
class CreativeChartData {
  CreativeChartData(List<ChartPoint> points)
    : points = List.unmodifiable(points);

  final List<ChartPoint> points;

  bool get valid =>
      points.length == 7 &&
      points.map((point) => point.countryCode).toSet().length == 7 &&
      points.every(
        (point) =>
            point.countryCode != null &&
            ChartMetric.values.every(point.metrics.containsKey),
      );

  double value(int index, ChartMetric metric) {
    final value = points[index].metrics[metric] ?? 0;
    return value.isFinite && value >= 0 ? value : 0;
  }

  List<double> values(ChartMetric metric) => [
    for (var i = 0; i < points.length; i++) value(i, metric),
  ];

  double total(ChartMetric metric) => values(metric).fold(0, (a, b) => a + b);
  double maximum(ChartMetric metric) => values(metric).fold(0, math.max);
  double mean(ChartMetric metric) =>
      points.isEmpty ? 0 : total(metric) / points.length;

  double relative(int index, ChartMetric metric) {
    final max = maximum(metric);
    return max == 0 ? 0 : value(index, metric) / max * 100;
  }

  double share(int index, ChartMetric metric) {
    final sum = total(metric);
    return sum == 0 ? 0 : value(index, metric) / sum * 100;
  }

  double deviation(int index, ChartMetric metric) {
    final average = mean(metric);
    return average == 0 ? 0 : (value(index, metric) - average) / average * 100;
  }

  /// Midranks: equal measurements share their mean rank.
  double rank(int index, ChartMetric metric) {
    final number = value(index, metric);
    final all = values(metric);
    return 1 +
        all.where((item) => item > number).length +
        (all.where((item) => item == number).length - 1) / 2;
  }

  List<({double x, double y})> concentration() {
    final numbers = values(ChartMetric.population)..sort();
    final sum = total(ChartMetric.population);
    if (sum == 0) return const [];
    var running = 0.0;
    return [
      (x: 0, y: 0),
      for (var i = 0; i < numbers.length; i++)
        (
          x: (i + 1) / numbers.length * 100,
          y: (running += numbers[i]) / sum * 100,
        ),
    ];
  }

  List<({double x, double y})> distribution(ChartMetric metric) {
    final numbers = values(metric)..sort();
    return [
      for (final number in numbers.toSet())
        (
          x: number,
          y:
              numbers.where((value) => value <= number).length /
              numbers.length *
              100,
        ),
    ];
  }

  /// Largest remainder allocation: exactly 100 cells, never fabricated data.
  List<int> waffle() {
    if (total(ChartMetric.area) == 0) return const [];
    final shares = [
      for (var i = 0; i < points.length; i++) share(i, ChartMetric.area),
    ];
    final counts = shares.map((value) => value.floor()).toList();
    final order = List.generate(points.length, (index) => index)
      ..sort((a, b) {
        final difference = (shares[b] - counts[b]).compareTo(
          shares[a] - counts[a],
        );
        return difference == 0 ? a.compareTo(b) : difference;
      });
    final remaining = 100 - counts.fold<int>(0, (a, b) => a + b);
    for (var i = 0; i < remaining; i++) {
      counts[order[i]]++;
    }
    return [
      for (var i = 0; i < counts.length; i++)
        for (var cell = 0; cell < counts[i]; cell++) i,
    ];
  }
}
