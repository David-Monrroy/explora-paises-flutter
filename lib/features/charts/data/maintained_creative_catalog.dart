import '../domain/chart_definition.dart';
import '../domain/maintained_chart_spec.dart';

/// Curated shape sets: 15 single diagrams and 48 genuine, shared-axis fusions.
abstract final class MaintainedCreativeCatalog {
  static const specs = <MaintainedChartSpec>[
    MaintainedChartSpec([MaintainedVisual.treemap]),
    MaintainedChartSpec([MaintainedVisual.sunburst]),
    MaintainedChartSpec([MaintainedVisual.sankey]),
    MaintainedChartSpec([MaintainedVisual.chord]),
    MaintainedChartSpec([MaintainedVisual.ternary]),
    MaintainedChartSpec([MaintainedVisual.marimekko]),
    MaintainedChartSpec([MaintainedVisual.icicle]),
    MaintainedChartSpec([MaintainedVisual.circlePacking]),
    MaintainedChartSpec([MaintainedVisual.pictogram]),
    MaintainedChartSpec([MaintainedVisual.violin]),
    MaintainedChartSpec([MaintainedVisual.ridgeline]),
    MaintainedChartSpec([MaintainedVisual.rug]),
    MaintainedChartSpec([MaintainedVisual.horizon]),
    MaintainedChartSpec([MaintainedVisual.beeswarm]),
    MaintainedChartSpec([MaintainedVisual.arcNetwork]),
    MaintainedChartSpec([MaintainedVisual.violin, MaintainedVisual.rug]),
    MaintainedChartSpec([MaintainedVisual.violin, MaintainedVisual.dots]),
    MaintainedChartSpec([MaintainedVisual.violin, MaintainedVisual.boxPlot]),
    MaintainedChartSpec([MaintainedVisual.violin, MaintainedVisual.lollipop]),
    MaintainedChartSpec([MaintainedVisual.violin, MaintainedVisual.dumbbell]),
    MaintainedChartSpec([MaintainedVisual.violin, MaintainedVisual.bullet]),
    MaintainedChartSpec([MaintainedVisual.ridgeline, MaintainedVisual.rug]),
    MaintainedChartSpec([MaintainedVisual.ridgeline, MaintainedVisual.dots]),
    MaintainedChartSpec([MaintainedVisual.ridgeline, MaintainedVisual.boxPlot]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([MaintainedVisual.ridgeline, MaintainedVisual.bullet]),
    MaintainedChartSpec([MaintainedVisual.rug, MaintainedVisual.dots]),
    MaintainedChartSpec([MaintainedVisual.rug, MaintainedVisual.boxPlot]),
    MaintainedChartSpec([MaintainedVisual.rug, MaintainedVisual.lollipop]),
    MaintainedChartSpec([MaintainedVisual.rug, MaintainedVisual.dumbbell]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.dots,
      MaintainedVisual.boxPlot,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.dots,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.dumbbell,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.dots,
      MaintainedVisual.boxPlot,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.dots,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.boxPlot,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.violin,
      MaintainedVisual.rug,
      MaintainedVisual.lollipop,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.boxPlot,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.lollipop,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.dumbbell,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.ridgeline,
      MaintainedVisual.rug,
      MaintainedVisual.boxPlot,
      MaintainedVisual.bullet,
    ]),
    MaintainedChartSpec([
      MaintainedVisual.rug,
      MaintainedVisual.dots,
      MaintainedVisual.boxPlot,
      MaintainedVisual.bullet,
    ]),
  ];

  static final List<ChartDefinition> all = List.unmodifiable([
    for (var index = 0; index < specs.length; index++)
      ChartDefinition(
        id: 'maintained-creative-${index + 1}',
        number: 127 + index,
        library: ChartLibrary.maintained,
        level: index < 31 ? ChartLevel.basic : ChartLevel.advanced,
        metric: ChartMetric.population,
        recipe: const ChartRecipe(
          kind: ChartKind.creative,
          analysis: ChartAnalysis.raw,
          question: 'Diagramas de siete países',
          explanation: 'Una figura con geometrías de datos reales.',
        ),
        maintainedCreative: specs[index],
      ),
  ]);
}
