import '../domain/chart_definition.dart';
import '../domain/syncfusion_chart_spec.dart';

/// Curated combinations: every set of native shapes occurs just once.
abstract final class SyncfusionCreativeCatalog {
  static const specs = <SyncfusionChartSpec>[
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
    ], subject: 'Distancia entre habitantes y territorio'),
    SyncfusionChartSpec([
      SyncfusionVisual.splineRange,
    ], subject: 'Amplitud del perfil discreto'),
    SyncfusionChartSpec([
      SyncfusionVisual.stepLine,
    ], subject: 'Peldaños de diversidad lingüística'),
    SyncfusionChartSpec([
      SyncfusionVisual.stepArea,
    ], subject: 'Escalones de zonas horarias'),
    SyncfusionChartSpec([
      SyncfusionVisual.spline,
    ], subject: 'Perfil suave de densidades'),
    SyncfusionChartSpec([
      SyncfusionVisual.splineArea,
    ], subject: 'Relieve de vecindad terrestre'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
    ], subject: 'Dispersión de características relativas'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
    ], subject: 'Extremos del tamaño y la densidad'),
    SyncfusionChartSpec([
      SyncfusionVisual.ohlc,
    ], subject: 'Tamaño dentro del perfil completo'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
    ], subject: 'Diversidad dentro de sus extremos'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
    ], subject: 'Densidad y distancia al máximo'),
    SyncfusionChartSpec([
      SyncfusionVisual.histogram,
    ], subject: 'Frecuencia de densidades'),
    SyncfusionChartSpec([
      SyncfusionVisual.funnel,
    ], subject: 'Orden de los habitantes'),
    SyncfusionChartSpec([
      SyncfusionVisual.pyramid,
    ], subject: 'Reparto de superficie'),
    SyncfusionChartSpec([
      SyncfusionVisual.radialBar,
    ], subject: 'Vueltas del territorio'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.stepLine,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.splineRange,
      SyncfusionVisual.spline,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.stepArea,
      SyncfusionVisual.boxPlot,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.splineArea,
      SyncfusionVisual.hilo,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.stepLine,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
      SyncfusionVisual.spline,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.ohlc,
      SyncfusionVisual.stepArea,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.spline,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.splineArea,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
      SyncfusionVisual.stepLine,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.splineRange,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
      SyncfusionVisual.stepLine,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.ohlc,
      SyncfusionVisual.splineArea,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.splineRange,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.spline,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
      SyncfusionVisual.stepArea,
    ], subject: 'Comparación integrada'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.ohlc,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.ohlc,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.spline,
    ], subject: 'Perfil de tres geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.stepLine,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.stepLine,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.hilo,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.stepLine,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.candle,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.stepLine,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.ohlc,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.stepLine,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.stepLine,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.stepLine,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.hilo,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.candle,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.ohlc,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.hilo,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.candle,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.stepLine,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.ohlc,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.stepLine,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.rangeColumn,
      SyncfusionVisual.stepArea,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.boxPlot,
      SyncfusionVisual.splineRange,
      SyncfusionVisual.stepLine,
    ], subject: 'Atlas de cuatro geometrías'),
    SyncfusionChartSpec([
      SyncfusionVisual.stackedColumn,
      SyncfusionVisual.candle,
      SyncfusionVisual.splineArea,
      SyncfusionVisual.spline,
    ], subject: 'Atlas de cuatro geometrías'),
  ];
  static final List<ChartDefinition> all = List.unmodifiable([
    for (var index = 0; index < specs.length; index++)
      ChartDefinition(
        id: 'syncfusion-creative-${index + 1}',
        number: 64 + index,
        library: ChartLibrary.syncfusion,
        level: index < 31 ? ChartLevel.basic : ChartLevel.advanced,
        metric: ChartMetric.population,
        recipe: const ChartRecipe(
          kind: ChartKind.creative,
          analysis: ChartAnalysis.raw,
          question: 'Exploración de siete países',
          explanation: 'Geometrías nativas con datos de la selección.',
        ),
        syncfusionCreative: specs[index],
      ),
  ]);
}
