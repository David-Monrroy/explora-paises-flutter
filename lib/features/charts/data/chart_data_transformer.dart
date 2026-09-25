import 'dart:math' as math;

import '../../../data/models/country.dart';
import '../domain/chart_definition.dart';
import '../domain/chart_point.dart';

abstract final class ChartDataTransformer {
  static List<ChartPoint> transform(
    ChartDefinition definition,
    List<Country> countries,
  ) {
    if (countries.length != 7 ||
        countries.map((country) => country.code).toSet().length != 7) {
      return const [];
    }

    final sorted = List<Country>.of(countries)
      ..sort((a, b) {
        final comparison = metricValue(
          b,
          definition.metric,
        ).compareTo(metricValue(a, definition.metric));
        return comparison == 0 ? a.name.compareTo(b.name) : comparison;
      });
    final values = [
      for (final country in sorted) metricValue(country, definition.metric),
    ];
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final maximum = values.first;
    final minimum = values.last;
    final mean = total / 7;

    if (definition.kind == ChartKind.pie ||
        definition.kind == ChartKind.donut) {
      return _circular(definition, sorted, values, total);
    }

    final ordered = definition.analysis == ChartAnalysis.rank
        ? (List<Country>.of(sorted)..sort((a, b) => a.name.compareTo(b.name)))
        : definition.recipe.ascending
        ? sorted.reversed.toList()
        : sorted;
    final secondMetric = definition.secondaryMetric;
    final secondarySorted = secondMetric == null
        ? const <Country>[]
        : (List<Country>.of(countries)..sort((a, b) {
            final comparison = metricValue(
              b,
              secondMetric,
            ).compareTo(metricValue(a, secondMetric));
            return comparison == 0 ? a.name.compareTo(b.name) : comparison;
          }));
    final secondaryRanking = {
      for (var i = 0; i < secondarySorted.length; i++)
        secondarySorted[i].code: i + 1,
    };

    var running = 0.0;
    final points = <ChartPoint>[];
    for (var index = 0; index < 7; index++) {
      final country = ordered[index];
      final raw = metricValue(country, definition.metric);
      running += raw;
      final value = switch (definition.analysis) {
        ChartAnalysis.raw ||
        ChartAnalysis.scatter ||
        ChartAnalysis.scatterRank => raw,
        ChartAnalysis.share => total == 0 ? 0.0 : raw / total * 100,
        ChartAnalysis.percentOfMaximum =>
          maximum == 0 ? 0.0 : raw / maximum * 100,
        ChartAnalysis.indexToAverage => mean == 0 ? 0.0 : raw / mean * 100,
        ChartAnalysis.gapToMaximum => maximum - raw,
        ChartAnalysis.gapToMinimum => raw - minimum,
        ChartAnalysis.distanceToAverage => (raw - mean).abs(),
        ChartAnalysis.rank =>
          sorted.indexWhere((item) => item.code == country.code) + 1.0,
        ChartAnalysis.cumulative => running,
        ChartAnalysis.cumulativePercent =>
          total == 0 ? 0.0 : running / total * 100,
        ChartAnalysis.remainingPercent =>
          total == 0 ? 0.0 : (total - running) / total * 100,
        ChartAnalysis.runningAverage => running / (index + 1),
        ChartAnalysis.aboveAverage => math.max(0.0, raw - mean),
        ChartAnalysis.belowAverage => math.max(0.0, mean - raw),
        _ => raw,
      };
      final xValue = definition.analysis == ChartAnalysis.scatterRank
          ? secondaryRanking[country.code]!.toDouble()
          : secondMetric == null
          ? index.toDouble()
          : metricValue(country, secondMetric);
      points.add(
        ChartPoint(
          label: country.name,
          countryCode: country.code,
          value: value.isFinite ? value : 0,
          secondaryValue: xValue,
          originalValue: raw,
        ),
      );
    }
    return List.unmodifiable(points);
  }

  static List<ChartPoint> _circular(
    ChartDefinition definition,
    List<Country> sorted,
    List<double> values,
    double total,
  ) {
    if (total <= 0) return const [];
    if (definition.analysis == ChartAnalysis.share) {
      return List.unmodifiable([
        for (var i = 0; i < 7; i++)
          ChartPoint(
            label: sorted[i].name,
            countryCode: sorted[i].code,
            value: values[i],
            secondaryValue: 0,
            originalValue: values[i],
          ),
      ]);
    }

    if (definition.analysis == ChartAnalysis.regionGroup ||
        definition.analysis == ChartAnalysis.subregionGroup) {
      final groups = <String, List<Country>>{};
      for (final country in sorted) {
        final label = definition.analysis == ChartAnalysis.regionGroup
            ? country.region
            : country.subregion;
        groups.putIfAbsent(label, () => []).add(country);
      }
      final points =
          [
            for (final entry in groups.entries)
              ChartPoint(
                label: entry.key,
                value: entry.value.fold<double>(
                  0,
                  (sum, country) =>
                      sum + metricValue(country, definition.metric),
                ),
                secondaryValue: 0,
                members: [for (final country in entry.value) country.name],
              ),
          ]..sort((a, b) {
            final comparison = b.value.compareTo(a.value);
            return comparison == 0 ? a.label.compareTo(b.label) : comparison;
          });
      return List.unmodifiable(points);
    }

    final size = definition.recipe.groupSize;
    final first = definition.analysis == ChartAnalysis.bottomGroup
        ? sorted.sublist(7 - size)
        : sorted.take(size).toList();
    final second = definition.analysis == ChartAnalysis.bottomGroup
        ? sorted.take(7 - size).toList()
        : sorted.skip(size).toList();
    final firstValue = first.fold<double>(
      0,
      (sum, country) => sum + metricValue(country, definition.metric),
    );
    final firstLabel = definition.analysis == ChartAnalysis.bottomGroup
        ? '$size menores'
        : '$size mayores';
    final secondLabel = '${7 - size} restantes';
    return List.unmodifiable([
      ChartPoint(
        label: firstLabel,
        value: firstValue,
        secondaryValue: 0,
        members: [for (final country in first) country.name],
      ),
      ChartPoint(
        label: secondLabel,
        value: total - firstValue,
        secondaryValue: 0,
        members: [for (final country in second) country.name],
      ),
    ]);
  }

  static double metricValue(Country country, ChartMetric metric) {
    return switch (metric) {
      ChartMetric.population => country.population.toDouble(),
      ChartMetric.area => country.area,
      ChartMetric.density =>
        country.area > 0 ? country.population / country.area : 0,
      ChartMetric.languages => country.languages.length.toDouble(),
      ChartMetric.borders => country.borders.length.toDouble(),
      ChartMetric.timezones => country.timezones.length.toDouble(),
      ChartMetric.currencies => country.currencies.length.toDouble(),
    };
  }
}
