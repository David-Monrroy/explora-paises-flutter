import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartPoint;

import '../../data/creative_chart_data.dart';
import '../../data/syncfusion_chart_data.dart';
import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../../domain/syncfusion_chart_spec.dart';
import '../chart_palette.dart';

abstract final class SyncfusionPalette {
  static const colors = [
    Color(0xFF007E87),
    Color(0xFF8D49AB),
    Color(0xFFD66600),
    Color(0xFF315AC1),
  ];
  static Color at(int index) => colors[index % colors.length];
}

/// A complete native Syncfusion plot, never a collection of separate panels.
class SyncfusionRenderer extends StatelessWidget {
  const SyncfusionRenderer({
    super.key,
    required this.definition,
    required this.points,
    this.highlightedCode,
  });
  final ChartDefinition definition;
  final List<ChartPoint> points;
  final String? highlightedCode;

  @override
  Widget build(BuildContext context) {
    final spec = definition.syncfusionCreative;
    final source = CreativeChartData(points);
    if (spec == null || !source.valid) {
      return const Center(child: Text('Se requieren siete países diferentes.'));
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              spec.componentCount == 1 ? 'Figura nativa' : 'Figura combinada',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(spec.names, style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) => RepaintBoundary(
                key: const Key('syncfusion-canvas'),
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    height: constraints.maxWidth.clamp(270.0, 420.0),
                    child: SyncfusionCountryPlot(
                      spec: spec,
                      data: SyncfusionChartData(source),
                      highlightedCode: highlightedCode,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              spec.axes,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Qué representa cada capa',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            for (var i = 0; i < spec.visuals.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4, right: 9),
                      color: spec.usesLayerColors
                          ? SyncfusionPalette.at(i)
                          : Colors.black54,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spec.visuals[i].label,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: spec.usesLayerColors
                                  ? SyncfusionPalette.at(i)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            spec.visuals[i].explanation,
                            style: const TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (spec.usesLayerColors &&
                spec.visuals.singleOrNull != SyncfusionVisual.histogram)
              const Text(
                'Índice = valor del país / máximo de esa métrica entre los siete × 100. '
                'Cada métrica usa su propio máximo. No es una puntuación de calidad. '
                'Los datos originales y sus unidades están debajo.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            if (spec.visuals.contains(SyncfusionVisual.histogram))
              Text(
                'Ancho de intervalo: ${SyncfusionChartData(source).histogramInterval.toStringAsFixed(2)} hab./km². '
                'Se cuentan los siete países, incluidos los de densidad cero.',
                style: const TextStyle(fontSize: 11, height: 1.4),
              ),
            if (!spec.usesLayerColors)
              for (final point in SyncfusionChartData(source).countries)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        color: ChartPalette.at(point.index),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${point.code} · ${source.points[point.index].label}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        spec.visuals.single == SyncfusionVisual.funnel
                            ? '${point.raw(ChartMetric.population).round()} hab.'
                            : spec.visuals.single == SyncfusionVisual.pyramid
                            ? '${point.raw(ChartMetric.area).toStringAsFixed(0)} km²'
                            : '${point.relative(ChartMetric.area).toStringAsFixed(1)} %',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class SyncfusionCountryPlot extends StatelessWidget {
  const SyncfusionCountryPlot({
    super.key,
    required this.spec,
    required this.data,
    this.highlightedCode,
  });
  final SyncfusionChartSpec spec;
  final SyncfusionChartData data;
  final String? highlightedCode;

  double _alpha(SyncfusionCountryDatum point) =>
      highlightedCode == null || highlightedCode == point.countryCode
      ? 1
      : 0.16;
  Color _pointColor(SyncfusionCountryDatum point, int layer) =>
      SyncfusionPalette.at(layer).withValues(alpha: _alpha(point));
  Color _countryColor(SyncfusionCountryDatum point) =>
      ChartPalette.at(point.index).withValues(alpha: _alpha(point));

  @override
  Widget build(BuildContext context) {
    if (!data.source.valid) {
      return const Center(child: Text('Selecciona siete países diferentes.'));
    }
    final single = spec.visuals.singleOrNull;
    if (single == SyncfusionVisual.histogram) return _histogram();
    if (single == SyncfusionVisual.funnel ||
        single == SyncfusionVisual.pyramid) {
      final metric = single == SyncfusionVisual.funnel
          ? ChartMetric.population
          : ChartMetric.area;
      if (data.source.total(metric) == 0) {
        return const Center(
          child: Text(
            'No hay un total positivo para dibujar proporciones.',
            textAlign: TextAlign.center,
          ),
        );
      }
      return _segmented(single!);
    }
    if (single == SyncfusionVisual.radialBar) return _radial();
    return _cartesian();
  }

  Widget _cartesian() => SfCartesianChart(
    key: const Key('syncfusion-native-cartesian'),
    margin: const EdgeInsets.fromLTRB(2, 8, 6, 4),
    plotAreaBorderWidth: 0,
    enableSideBySideSeriesPlacement: false,
    legend: const Legend(isVisible: false),
    primaryXAxis: CategoryAxis(
      interval: 1,
      labelStyle: TextStyle(fontSize: 10),
      majorGridLines: MajorGridLines(width: 0),
      majorTickLines: MajorTickLines(size: 0),
      plotBands: [
        if (highlightedCode != null)
          for (final country in data.countries)
            if (country.countryCode == highlightedCode)
              PlotBand(
                isVisible: true,
                start: country.index - 0.3,
                end: country.index + 0.3,
                color: const Color(0x14007E87),
                borderColor: const Color(0x40007E87),
                borderWidth: 1,
              ),
      ],
    ),
    primaryYAxis: const NumericAxis(
      minimum: 0,
      maximum: 100,
      interval: 25,
      rangePadding: ChartRangePadding.none,
      labelStyle: TextStyle(fontSize: 10),
      majorGridLines: MajorGridLines(width: 0.6, color: Color(0xFFDCE7E3)),
      axisLine: AxisLine(width: 0),
      majorTickLines: MajorTickLines(size: 0),
    ),
    // One native chart means all geometries use the same country positions.
    series: [
      for (var i = 0; i < spec.visuals.length; i++)
        if (spec.visuals[i].isBackground) ..._series(spec.visuals[i], i),
      for (var i = 0; i < spec.visuals.length; i++)
        if (!spec.visuals[i].isBackground) ..._series(spec.visuals[i], i),
    ],
  );

  List<CartesianSeries<SyncfusionCountryDatum, String>> _series(
    SyncfusionVisual visual,
    int layer,
  ) {
    final points = data.countries;
    final color = SyncfusionPalette.at(layer);
    final multiple = spec.componentCount > 1;
    const marker = MarkerSettings(isVisible: true, width: 5, height: 5);
    switch (visual) {
      case SyncfusionVisual.rangeColumn:
        return [
          RangeColumnSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            lowValueMapper: (point, _) =>
                point.low([ChartMetric.population, ChartMetric.area]),
            highValueMapper: (point, _) =>
                point.high([ChartMetric.population, ChartMetric.area]),
            width: 0.55,
            color: color,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            opacity: multiple ? 0.3 : 0.65,
            borderColor: color,
            borderWidth: 1,
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.splineRange:
        return [
          SplineRangeAreaSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            lowValueMapper: (point, _) => point.low(discreteProfileMetrics),
            highValueMapper: (point, _) => point.high(discreteProfileMetrics),
            splineType: SplineType.monotonic,
            color: color.withValues(alpha: 0.12),
            borderColor: color.withValues(alpha: 0.65),
            borderWidth: 1,
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.stepLine:
        return [
          StepLineSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.relative(ChartMetric.languages),
            color: color,
            width: 2,
            markerSettings: marker,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.stepArea:
        return [
          StepAreaSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.relative(ChartMetric.timezones),
            color: color.withValues(alpha: 0.12),
            borderColor: color,
            borderWidth: 1.5,
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.spline:
        return [
          SplineSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.relative(ChartMetric.density),
            splineType: SplineType.monotonic,
            color: color,
            width: 2.5,
            markerSettings: marker,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.splineArea:
        return [
          SplineAreaSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.relative(ChartMetric.borders),
            splineType: SplineType.monotonic,
            color: color.withValues(alpha: 0.12),
            borderColor: color,
            borderWidth: 1.5,
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.boxPlot:
        return [
          BoxAndWhiskerSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.profile(ChartMetric.values),
            boxPlotMode: BoxPlotMode.inclusive,
            showMean: false,
            width: 0.3,
            color: color,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            opacity: multiple ? 0.45 : 0.7,
            borderColor: color,
            borderWidth: 1.3,
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.hilo:
        return [
          HiloSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            lowValueMapper: (point, _) => point.low(sizeProfileMetrics),
            highValueMapper: (point, _) => point.high(sizeProfileMetrics),
            color: color,
            borderWidth: 2,
            showIndicationForSameValues: true,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.ohlc:
        return [
          HiloOpenCloseSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            lowValueMapper: (point, _) => point.low(ChartMetric.values),
            highValueMapper: (point, _) => point.high(ChartMetric.values),
            openValueMapper: (point, _) =>
                point.relative(ChartMetric.population),
            closeValueMapper: (point, _) => point.relative(ChartMetric.area),
            bullColor: color,
            bearColor: color,
            borderWidth: 1.5,
            spacing: 0.6,
            showIndicationForSameValues: true,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.candle:
        return [
          CandleSeries<SyncfusionCountryDatum, String>(
            name: visual.label,
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            lowValueMapper: (point, _) => point.low(discreteProfileMetrics),
            highValueMapper: (point, _) => point.high(discreteProfileMetrics),
            openValueMapper: (point, _) =>
                point.relative(ChartMetric.languages),
            closeValueMapper: (point, _) => point.relative(ChartMetric.borders),
            width: 0.2,
            borderWidth: 1.3,
            enableSolidCandles: true,
            bullColor: color,
            bearColor: color,
            showIndicationForSameValues: true,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      case SyncfusionVisual.stackedColumn:
        return [
          StackedColumnSeries<SyncfusionCountryDatum, String>(
            name: '${visual.label}: densidad',
            groupName: 'density-complement',
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.relative(ChartMetric.density),
            width: 0.75,
            color: color,
            pointColorMapper: (point, _) => _pointColor(point, layer),
            opacity: multiple ? 0.24 : 0.65,
            animationDuration: 0,
            enableTooltip: false,
          ),
          StackedColumnSeries<SyncfusionCountryDatum, String>(
            name: '${visual.label}: distancia al máximo',
            groupName: 'density-complement',
            dataSource: points,
            xValueMapper: (point, _) => point.code,
            yValueMapper: (point, _) => point.densityComplement,
            width: 0.75,
            color: color.withValues(alpha: 0.07),
            animationDuration: 0,
            enableTooltip: false,
          ),
        ];
      default:
        throw StateError(
          'Esta geometría necesita ejes propios: ${visual.name}',
        );
    }
  }

  Widget _histogram() => SfCartesianChart(
    key: const Key('syncfusion-native-histogram'),
    margin: const EdgeInsets.all(6),
    primaryXAxis: NumericAxis(
      labelStyle: TextStyle(fontSize: 10),
      majorGridLines: MajorGridLines(width: 0),
      axisLabelFormatter: (details) =>
          ChartAxisLabel(details.value.toStringAsFixed(1), details.textStyle),
    ),
    primaryYAxis: const NumericAxis(
      minimum: 0,
      maximum: 7,
      interval: 1,
      labelStyle: TextStyle(fontSize: 10),
    ),
    series: [
      HistogramSeries<SyncfusionCountryDatum, double>(
        name: 'Número de países',
        dataSource: data.countries,
        yValueMapper: (point, _) => point.raw(ChartMetric.density),
        binInterval: data.histogramInterval,
        showNormalDistributionCurve: false,
        color: SyncfusionPalette.at(0),
        borderWidth: 1,
        borderColor: Colors.white,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
        animationDuration: 0,
        enableTooltip: false,
      ),
    ],
  );

  Widget _segmented(SyncfusionVisual visual) {
    const labels = DataLabelSettings(
      isVisible: true,
      labelPosition: ChartDataLabelPosition.outside,
      textStyle: TextStyle(fontSize: 10),
    );
    if (visual == SyncfusionVisual.funnel) {
      return SfFunnelChart(
        key: const Key('syncfusion-native-funnel'),
        margin: const EdgeInsets.all(8),
        series: FunnelSeries<SyncfusionCountryDatum, String>(
          // The native funnel paints its source in reverse order, top to bottom.
          dataSource: data.orderedBy(ChartMetric.population, ascending: true),
          xValueMapper: (point, _) => point.code,
          yValueMapper: (point, _) => point.raw(ChartMetric.population),
          textFieldMapper: (point, _) => point.code,
          pointColorMapper: (point, _) => _countryColor(point),
          neckWidth: '12%',
          neckHeight: '12%',
          gapRatio: 0.02,
          dataLabelSettings: labels,
          animationDuration: 0,
        ),
      );
    }
    return SfPyramidChart(
      key: const Key('syncfusion-native-pyramid'),
      margin: const EdgeInsets.all(8),
      series: PyramidSeries<SyncfusionCountryDatum, String>(
        dataSource: data.orderedBy(ChartMetric.area, ascending: true),
        xValueMapper: (point, _) => point.code,
        yValueMapper: (point, _) => point.raw(ChartMetric.area),
        textFieldMapper: (point, _) => point.code,
        pointColorMapper: (point, _) => _countryColor(point),
        pyramidMode: PyramidMode.surface,
        gapRatio: 0.01,
        dataLabelSettings: labels,
        animationDuration: 0,
      ),
    );
  }

  Widget _radial() => SfCircularChart(
    key: const Key('syncfusion-native-radial'),
    margin: const EdgeInsets.all(8),
    series: [
      RadialBarSeries<SyncfusionCountryDatum, String>(
        name: 'Superficie relativa',
        dataSource: data.countries,
        xValueMapper: (point, _) => point.code,
        yValueMapper: (point, _) => point.relative(ChartMetric.area),
        dataLabelMapper: (point, _) => point.code,
        pointColorMapper: (point, _) => _countryColor(point),
        maximumValue: 100,
        innerRadius: '18%',
        radius: '96%',
        gap: '3%',
        trackColor: const Color(0xFFE9EFED),
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(fontSize: 10),
        ),
        animationDuration: 0,
        enableTooltip: false,
      ),
    ],
  );
}
