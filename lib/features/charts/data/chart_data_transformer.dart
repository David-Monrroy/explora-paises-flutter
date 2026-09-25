import '../../../data/models/country.dart';
import '../domain/chart_definition.dart';
import '../domain/chart_point.dart';

abstract final class ChartDataTransformer {
  static List<ChartPoint> transform(
    ChartDefinition definition,
    List<Country> countries,
  ) {
    final filtered = definition.region == null
        ? countries
        : countries.where((country) => country.region == definition.region);
    final buckets = <String, List<Country>>{};

    for (final country in filtered) {
      for (final label in _labels(country, definition.grouping)) {
        if (label.trim().isNotEmpty) {
          buckets.putIfAbsent(label, () => <Country>[]).add(country);
        }
      }
    }

    final points = buckets.entries
        .map((entry) {
          final values = entry.value
              .map((country) => _metric(country, definition.metric))
              .toList();
          return ChartPoint(
            label: entry.key,
            value: _aggregate(values, definition.aggregation),
            secondaryValue: _secondary(entry.value),
          );
        })
        .where((point) => point.value.isFinite && point.value >= 0)
        .toList();

    points.sort(
      (a, b) => definition.ascending
          ? a.value.compareTo(b.value)
          : b.value.compareTo(a.value),
    );
    if (points.isEmpty) return const [];

    final start = definition.offset % points.length;
    final rotated = [...points.skip(start), ...points.take(start)];
    return rotated.take(definition.limit).toList(growable: false);
  }

  static Iterable<String> _labels(Country country, ChartGrouping grouping) {
    return switch (grouping) {
      ChartGrouping.country => [country.name],
      ChartGrouping.region => [country.region],
      ChartGrouping.subregion => [country.subregion],
      ChartGrouping.language =>
        country.languages.isEmpty
            ? const ['Sin idioma registrado']
            : country.languages,
      ChartGrouping.currency =>
        country.currencies.isEmpty
            ? const ['Sin moneda registrada']
            : country.currencies,
    };
  }

  static double _metric(Country country, ChartMetric metric) {
    return switch (metric) {
      ChartMetric.population => country.population / 1000000,
      ChartMetric.area => country.area / 1000,
      ChartMetric.density =>
        country.area <= 0 ? 0 : country.population / country.area,
      ChartMetric.languages => country.languages.length.toDouble(),
      ChartMetric.currencies => country.currencies.length.toDouble(),
      ChartMetric.nameLength => country.name.runes.length.toDouble(),
      ChartMetric.capitalLength => country.capital.runes.length.toDouble(),
    };
  }

  static double _aggregate(List<double> values, ChartAggregation aggregation) {
    if (values.isEmpty) return 0;
    return switch (aggregation) {
      ChartAggregation.sum => values.fold(0.0, (sum, value) => sum + value),
      ChartAggregation.average =>
        values.fold(0.0, (sum, value) => sum + value) / values.length,
      ChartAggregation.maximum => values.reduce((a, b) => a > b ? a : b),
      ChartAggregation.count => values.length.toDouble(),
    };
  }

  static double _secondary(List<Country> countries) {
    if (countries.isEmpty) return 0;
    return countries.fold<double>(0, (sum, item) => sum + item.area) /
        countries.length /
        1000;
  }
}
