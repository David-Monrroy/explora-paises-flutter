import '../domain/chart_definition.dart';

abstract final class ChartCatalog {
  static final List<ChartDefinition> all = _buildCatalog();

  static List<ChartDefinition> _buildCatalog() {
    const basicKinds = [
      ChartKind.bar,
      ChartKind.line,
      ChartKind.area,
      ChartKind.pie,
      ChartKind.donut,
      ChartKind.scatter,
    ];
    const advancedKinds = [
      ChartKind.scatter,
      ChartKind.area,
      ChartKind.line,
      ChartKind.donut,
      ChartKind.bar,
      ChartKind.pie,
    ];
    const metrics = ChartMetric.values;
    const groupings = ChartGrouping.values;
    const aggregations = ChartAggregation.values;
    const regions = <String?>[
      null,
      'América',
      'Europa',
      'Asia',
      'África',
      'Oceanía',
    ];

    final result = <ChartDefinition>[];
    for (final library in ChartLibrary.values) {
      for (var local = 0; local < 63; local++) {
        final number = library.index * 63 + local + 1;
        final level = local < 31 ? ChartLevel.basic : ChartLevel.advanced;
        final kinds = level == ChartLevel.basic ? basicKinds : advancedKinds;
        final kind = kinds[(local + library.index * 2) % kinds.length];
        final metric = metrics[(number * 3 + library.index) % metrics.length];
        final grouping =
            groupings[(number * 2 + local ~/ 7) % groupings.length];
        final aggregation =
            aggregations[(number + local ~/ 5) % aggregations.length];
        final region = regions[(local + library.index * 2) % regions.length];
        final limit = 5 + ((local + library.index) % 5);
        final offset = (local * 3 + library.index * 5) % 13;
        final ascending = (local + library.index).isOdd;
        final metricLabel = _metricLabel(metric);
        final groupingLabel = _groupingLabel(grouping);
        final scope = region ?? 'el mundo';

        result.add(
          ChartDefinition(
            id: '${library.name}-${level.name}-${local + 1}',
            number: number,
            library: library,
            level: level,
            kind: kind,
            metric: metric,
            grouping: grouping,
            aggregation: aggregation,
            title: '$metricLabel por $groupingLabel',
            description:
                '${_aggregationLabel(aggregation)} de $metricLabel en $scope; '
                '${ascending ? 'orden ascendente' : 'orden descendente'}, '
                '$limit categorías desde la posición ${offset + 1}.',
            limit: limit,
            offset: offset,
            ascending: ascending,
            region: region,
          ),
        );
      }
    }
    return List.unmodifiable(result);
  }

  static String _metricLabel(ChartMetric value) => switch (value) {
    ChartMetric.population => 'Población',
    ChartMetric.area => 'Superficie',
    ChartMetric.density => 'Densidad',
    ChartMetric.languages => 'Diversidad lingüística',
    ChartMetric.currencies => 'Variedad monetaria',
    ChartMetric.nameLength => 'Longitud del nombre',
    ChartMetric.capitalLength => 'Longitud de la capital',
  };

  static String _groupingLabel(ChartGrouping value) => switch (value) {
    ChartGrouping.country => 'país',
    ChartGrouping.region => 'región',
    ChartGrouping.subregion => 'subregión',
    ChartGrouping.language => 'idioma',
    ChartGrouping.currency => 'moneda',
  };

  static String _aggregationLabel(ChartAggregation value) => switch (value) {
    ChartAggregation.sum => 'Suma',
    ChartAggregation.average => 'Promedio',
    ChartAggregation.maximum => 'Máximo',
    ChartAggregation.count => 'Cantidad de países',
  };
}
