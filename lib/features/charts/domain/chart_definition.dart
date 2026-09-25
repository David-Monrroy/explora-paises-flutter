enum ChartLibrary { flChart, syncfusion, maintained, graphic }

enum ChartLevel { basic, advanced }

enum ChartKind { bar, line, area, pie, donut, scatter }

enum ChartMetric {
  population,
  area,
  density,
  languages,
  borders,
  timezones,
  currencies,
}

enum ChartAnalysis {
  raw,
  share,
  percentOfMaximum,
  indexToAverage,
  gapToMaximum,
  gapToMinimum,
  distanceToAverage,
  rank,
  cumulative,
  cumulativePercent,
  remainingPercent,
  runningAverage,
  aboveAverage,
  belowAverage,
  scatter,
  scatterRank,
  topGroup,
  bottomGroup,
  regionGroup,
  subregionGroup,
}

class ChartRecipe {
  const ChartRecipe({
    required this.kind,
    required this.analysis,
    required this.question,
    required this.explanation,
    this.groupSize = 0,
    this.secondaryOffset = 0,
    this.ascending = false,
  });

  final ChartKind kind;
  final ChartAnalysis analysis;
  final String question;
  final String explanation;
  final int groupSize;
  final int secondaryOffset;
  final bool ascending;

  String get key => [
    kind.name,
    analysis.name,
    groupSize,
    secondaryOffset,
    ascending,
  ].join('|');
}

class ChartDefinition {
  const ChartDefinition({
    required this.id,
    required this.number,
    required this.library,
    required this.level,
    required this.metric,
    required this.recipe,
  });

  final String id;
  final int number;
  final ChartLibrary library;
  final ChartLevel level;
  final ChartMetric metric;
  final ChartRecipe recipe;

  ChartKind get kind => recipe.kind;
  ChartAnalysis get analysis => recipe.analysis;
  String get title => kind == ChartKind.scatter
      ? analysis == ChartAnalysis.scatterRank
            ? '${metric.label} frente al puesto en ${secondaryMetric!.label}'
            : '${metric.label} frente a ${secondaryMetric!.label}'
      : '${metric.label}: ${recipe.question}';
  String get description => recipe.explanation;
  String get semanticKey => '${metric.name}|${recipe.key}';

  ChartMetric? get secondaryMetric => recipe.secondaryOffset == 0
      ? null
      : ChartMetric.values[(metric.index + recipe.secondaryOffset) %
            ChartMetric.values.length];

  String get valueUnit => kind == ChartKind.pie || kind == ChartKind.donut
      ? metric.unit
      : switch (analysis) {
          ChartAnalysis.share ||
          ChartAnalysis.percentOfMaximum ||
          ChartAnalysis.indexToAverage ||
          ChartAnalysis.cumulativePercent ||
          ChartAnalysis.remainingPercent => '%',
          ChartAnalysis.rank => 'posición',
          _ => metric.unit,
        };

  String get horizontalLabel => analysis == ChartAnalysis.rank
      ? 'Países seleccionados en orden alfabético'
      : kind == ChartKind.scatter
      ? analysis == ChartAnalysis.scatterRank
            ? 'Posición según ${secondaryMetric!.label.toLowerCase()}'
            : '${secondaryMetric!.label} (${secondaryMetric!.unit})'
      : kind == ChartKind.pie || kind == ChartKind.donut
      ? 'País o grupo'
      : 'Países seleccionados (ordenados por ${metric.label.toLowerCase()})';

  String get verticalLabel => kind == ChartKind.pie || kind == ChartKind.donut
      ? 'Parte del total de los 7 países (%)'
      : '${metric.label} ($valueUnit)';
}

extension ChartMetricLabels on ChartMetric {
  String get meaning => switch (this) {
    ChartMetric.population => 'Número de habitantes registrado por la API.',
    ChartMetric.area => 'Superficie terrestre en kilómetros cuadrados.',
    ChartMetric.density => 'Habitantes divididos entre kilómetros cuadrados.',
    ChartMetric.languages => 'Número de idiomas registrados para el país.',
    ChartMetric.borders => 'Número de países vecinos con frontera terrestre, aunque no estén entre los siete elegidos.',
    ChartMetric.timezones =>
      'Número de zonas horarias registradas para el país.',
    ChartMetric.currencies => 'Número de monedas registradas para el país.',
  };

  String get label => switch (this) {
    ChartMetric.population => 'Población',
    ChartMetric.area => 'Superficie',
    ChartMetric.density => 'Densidad poblacional',
    ChartMetric.languages => 'Idiomas registrados',
    ChartMetric.borders => 'Países limítrofes',
    ChartMetric.timezones => 'Zonas horarias',
    ChartMetric.currencies => 'Monedas registradas',
  };

  String get unit => switch (this) {
    ChartMetric.population => 'habitantes',
    ChartMetric.area => 'km²',
    ChartMetric.density => 'hab./km²',
    ChartMetric.languages => 'idiomas',
    ChartMetric.borders => 'fronteras',
    ChartMetric.timezones => 'zonas horarias',
    ChartMetric.currencies => 'monedas',
  };
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
