import 'dart:math' as math;

import '../domain/chart_metric.dart';
import 'creative_chart_data.dart';

typedef CountryRect = ({int index, math.Rectangle<double> bounds});
typedef CountryCircle = ({int index, math.Point<double> center, double radius});
typedef CountryRelation = ({int a, int b, int weight});
typedef RegionGroup = ({String name, List<int> countries});

/// Pure calculations. No synthetic API records, inferred migration or finance.
class MaintainedChartData {
  MaintainedChartData(this.source);
  final CreativeChartData source;
  static const kernelWidth = 12.0;

  List<double> profile(int country) => [
    for (final metric in ChartMetric.values) source.relative(country, metric),
  ];

  double quantile(int country, double fraction) {
    final sorted = profile(country)..sort();
    final position = fraction * (sorted.length - 1);
    final lower = position.floor();
    final upper = position.ceil();
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (position - lower);
  }

  /// Reflected Gaussian KDE reduces boundary bias. Units: probability/index.
  double kernel(int country, double x) {
    if (x < 0 || x > 100) return 0;
    final samples = profile(country);
    double gaussian(double distance) =>
        math.exp(-0.5 * math.pow(distance / kernelWidth, 2));
    return samples.fold<double>(
          0,
          (sum, value) =>
              sum +
              gaussian(x - value) +
              gaussian(x + value) +
              gaussian(x - (200 - value)),
        ) /
        (samples.length * kernelWidth * math.sqrt(2 * math.pi));
  }

  double get kernelMaximum {
    var maximum = 0.0;
    for (var country = 0; country < source.points.length; country++) {
      for (var x = 0.0; x <= 100; x += 2) {
        maximum = math.max(maximum, kernel(country, x));
      }
    }
    return maximum;
  }

  List<RegionGroup> get regions {
    final grouped = <String, List<int>>{};
    for (var i = 0; i < source.points.length; i++) {
      final region = source.points[i].region.trim();
      grouped
          .putIfAbsent(region.isEmpty ? 'Sin región' : region, () => [])
          .add(i);
    }
    return List.unmodifiable([
      for (final entry in grouped.entries)
        (name: entry.key, countries: List<int>.unmodifiable(entry.value)),
    ]);
  }

  double groupShare(RegionGroup group, ChartMetric metric) =>
      group.countries.fold(0.0, (sum, i) => sum + source.share(i, metric));

  List<CountryRelation> get currencyRelations {
    Set<String> names(int i) => source.points[i].currencyNames
        .map(
          (name) =>
              name.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim().toLowerCase(),
        )
        .where((name) => name.isNotEmpty)
        .toSet();
    return List.unmodifiable([
      for (var a = 0; a < source.points.length; a++)
        for (var b = a + 1; b < source.points.length; b++)
          if (names(a).intersection(names(b)).isNotEmpty)
            (a: a, b: b, weight: names(a).intersection(names(b)).length),
    ]);
  }

  List<CountryRelation> get borderRelations => List.unmodifiable([
    for (var a = 0; a < source.points.length; a++)
      for (var b = a + 1; b < source.points.length; b++)
        if (source.points[a].borderCodes.contains(
              source.points[b].countryCode,
            ) ||
            source.points[b].borderCodes.contains(source.points[a].countryCode))
          (a: a, b: b, weight: 1),
  ]);

  ({double population, double area, double density})? ternary(int country) {
    final population = source.relative(country, ChartMetric.population);
    final area = source.relative(country, ChartMetric.area);
    final density = source.relative(country, ChartMetric.density);
    final sum = population + area + density;
    return sum == 0
        ? null
        : (
            population: population / sum,
            area: area / sum,
            density: density / sum,
          );
  }

  /// Binary weighted partition: exact proportional areas, zeros omitted.
  List<CountryRect> get treemap {
    final result = <CountryRect>[];
    final indices =
        [
          for (var i = 0; i < source.points.length; i++)
            if (source.value(i, ChartMetric.area) > 0) i,
        ]..sort(
          (a, b) => source
              .value(b, ChartMetric.area)
              .compareTo(source.value(a, ChartMetric.area)),
        );
    double weight(List<int> items) =>
        items.fold(0, (sum, i) => sum + source.value(i, ChartMetric.area));
    void split(List<int> items, math.Rectangle<double> rectangle) {
      if (items.isEmpty) return;
      if (items.length == 1) {
        result.add((index: items.single, bounds: rectangle));
        return;
      }
      final total = weight(items);
      var cut = 1;
      var accumulated = source.value(items.first, ChartMetric.area);
      while (cut < items.length - 1 &&
          (accumulated + source.value(items[cut], ChartMetric.area) - total / 2)
                  .abs() <
              (accumulated - total / 2).abs()) {
        accumulated += source.value(items[cut++], ChartMetric.area);
      }
      final fraction = accumulated / total;
      if (rectangle.width >= rectangle.height) {
        final width = rectangle.width * fraction;
        split(
          items.take(cut).toList(),
          math.Rectangle(
            rectangle.left,
            rectangle.top,
            width,
            rectangle.height,
          ),
        );
        split(
          items.skip(cut).toList(),
          math.Rectangle(
            rectangle.left + width,
            rectangle.top,
            rectangle.width - width,
            rectangle.height,
          ),
        );
      } else {
        final height = rectangle.height * fraction;
        split(
          items.take(cut).toList(),
          math.Rectangle(
            rectangle.left,
            rectangle.top,
            rectangle.width,
            height,
          ),
        );
        split(
          items.skip(cut).toList(),
          math.Rectangle(
            rectangle.left,
            rectangle.top + height,
            rectangle.width,
            rectangle.height - height,
          ),
        );
      }
    }

    split(indices, const math.Rectangle(0.0, 0.0, 100.0, 100.0));
    return List.unmodifiable(result);
  }

  /// Tangent placement candidates, then one common scale: no overlaps and area
  /// ratios unchanged. Coordinates describe layout, not geographic positions.
  List<CountryCircle> get packedCircles {
    final placed = <CountryCircle>[];
    final order =
        [
          for (var i = 0; i < source.points.length; i++)
            if (source.value(i, ChartMetric.area) > 0) i,
        ]..sort(
          (a, b) => source
              .value(b, ChartMetric.area)
              .compareTo(source.value(a, ChartMetric.area)),
        );
    final maximum = source.maximum(ChartMetric.area);
    for (final index in order) {
      final radius = math.sqrt(source.value(index, ChartMetric.area) / maximum);
      var best = const math.Point(0.0, 0.0);
      var bestScore = double.infinity;
      if (placed.isNotEmpty) {
        for (final anchor in placed) {
          for (var angle = 0; angle < 360; angle += 6) {
            final rad = angle * math.pi / 180;
            final distance = anchor.radius + radius + 0.018;
            final candidate =
                anchor.center +
                math.Point(math.cos(rad), math.sin(rad)) * distance;
            if (placed.any(
              (other) =>
                  candidate.distanceTo(other.center) <
                  radius + other.radius + 0.017,
            )) {
              continue;
            }
            final score = candidate.magnitude + radius;
            if (score < bestScore) {
              best = candidate;
              bestScore = score;
            }
          }
        }
        // Fallback has a provable separating x coordinate.
        if (!bestScore.isFinite) {
          best = math.Point(
            placed.map((c) => c.center.x + c.radius).reduce(math.max) +
                radius +
                0.02,
            0.0,
          );
        }
      }
      placed.add((index: index, center: best, radius: radius));
    }
    if (placed.isEmpty) return const [];
    final left = placed.map((c) => c.center.x - c.radius).reduce(math.min);
    final right = placed.map((c) => c.center.x + c.radius).reduce(math.max);
    final top = placed.map((c) => c.center.y - c.radius).reduce(math.min);
    final bottom = placed.map((c) => c.center.y + c.radius).reduce(math.max);
    final scale = 90 / math.max(right - left, bottom - top);
    return List.unmodifiable([
      for (final c in placed)
        (
          index: c.index,
          center: math.Point(
            50 + (c.center.x - (left + right) / 2) * scale,
            50 + (c.center.y - (top + bottom) / 2) * scale,
          ),
          radius: c.radius * scale,
        ),
    ]);
  }

  /// Horizontal positions retained; vertical offsets have no analytical unit.
  List<({int index, double x, double y})> get swarm {
    final placed = <({int index, double x, double y})>[];
    final order = List.generate(source.points.length, (i) => i)
      ..sort(
        (a, b) => source
            .value(a, ChartMetric.density)
            .compareTo(source.value(b, ChartMetric.density)),
      );
    for (final index in order) {
      final x = source.relative(index, ChartMetric.density);
      var y = 50.0;
      for (final offset in [0, -10, 10, -20, 20, -30, 30]) {
        final candidate = 50.0 + offset;
        if (placed.every(
          (p) =>
              math.sqrt(math.pow(p.x - x, 2) + math.pow(p.y - candidate, 2)) >=
              10,
        )) {
          y = candidate;
          break;
        }
      }
      placed.add((index: index, x: x, y: y));
    }
    return List.unmodifiable(placed);
  }
}
