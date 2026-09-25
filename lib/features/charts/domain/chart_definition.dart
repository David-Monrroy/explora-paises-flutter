enum ChartLibrary { flChart, syncfusion, maintained, graphic }

enum ChartLevel { basic, advanced }

enum ChartKind { bar, line, area, pie, donut, scatter }

enum ChartMetric {
  population,
  area,
  density,
  languages,
  currencies,
  nameLength,
  capitalLength,
}

enum ChartGrouping { country, region, subregion, language, currency }

enum ChartAggregation { sum, average, maximum, count }

class ChartDefinition {
  const ChartDefinition({
    required this.id,
    required this.number,
    required this.library,
    required this.level,
    required this.kind,
    required this.metric,
    required this.grouping,
    required this.aggregation,
    required this.title,
    required this.description,
    required this.limit,
    required this.offset,
    required this.ascending,
    this.region,
  });

  final String id;
  final int number;
  final ChartLibrary library;
  final ChartLevel level;
  final ChartKind kind;
  final ChartMetric metric;
  final ChartGrouping grouping;
  final ChartAggregation aggregation;
  final String title;
  final String description;
  final int limit;
  final int offset;
  final bool ascending;
  final String? region;

  String get semanticKey => [
    library.name,
    level.name,
    kind.name,
    metric.name,
    grouping.name,
    aggregation.name,
    region ?? 'mundo',
    limit,
    offset,
    ascending,
  ].join('|');
}

extension ChartLibraryLabels on ChartLibrary {
  String get label => switch (this) {
    ChartLibrary.flChart => 'FL Chart',
    ChartLibrary.syncfusion => 'Syncfusion',
    ChartLibrary.maintained => 'Maintained Charts',
    ChartLibrary.graphic => 'Graphic',
  };
}

extension ChartLevelLabels on ChartLevel {
  String get label => this == ChartLevel.basic ? 'Básica' : 'Avanzada';
}

extension ChartKindLabels on ChartKind {
  String get label => switch (this) {
    ChartKind.bar => 'Barras',
    ChartKind.line => 'Líneas',
    ChartKind.area => 'Área',
    ChartKind.pie => 'Pastel',
    ChartKind.donut => 'Dona',
    ChartKind.scatter => 'Dispersión',
  };
}
