import 'creative_chart.dart';
import 'chart_metric.dart';
import 'country_chart_spec.dart';
import 'syncfusion_chart_spec.dart';
import 'maintained_chart_spec.dart';

export 'chart_metric.dart';

enum ChartLibrary { flChart, syncfusion, maintained, graphic }

enum ChartLevel { basic, advanced }

enum ChartKind { bar, line, area, pie, donut, scatter, creative }

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
    this.creative,
    this.syncfusionCreative,
    this.maintainedCreative,
  });

  final String id;
  final int number;
  final ChartLibrary library;
  final ChartLevel level;
  final ChartMetric metric;
  final ChartRecipe recipe;
  final CreativeChartSpec? creative;
  final SyncfusionChartSpec? syncfusionCreative;
  final MaintainedChartSpec? maintainedCreative;
  CountryChartSpec? get exploration =>
      creative ?? syncfusionCreative ?? maintainedCreative;

  ChartKind get kind => recipe.kind;
  ChartAnalysis get analysis => recipe.analysis;
  String get title =>
      exploration?.title ??
      (kind == ChartKind.scatter
          ? analysis == ChartAnalysis.scatterRank
                ? '${metric.label} frente al puesto en ${secondaryMetric!.label}'
                : '${metric.label} frente a ${secondaryMetric!.label}'
          : '${metric.label}: ${recipe.question}');
  String get description => exploration?.explanation ?? recipe.explanation;
  String get semanticKey => exploration == null
      ? '${metric.name}|${recipe.key}'
      : 'creative|${creative?.signature ?? syncfusionCreative?.signature ?? maintainedCreative!.signature}';

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
    ChartKind.creative => 'Exploración visual',
  };
}
