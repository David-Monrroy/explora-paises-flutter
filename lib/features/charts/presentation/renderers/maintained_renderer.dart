import 'package:charts_flutter_maintained/charts_flutter_maintained.dart'
    as charts;
import 'package:flutter/material.dart';

import '../../data/creative_chart_data.dart';
import '../../data/maintained_chart_data.dart';
import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../../domain/maintained_chart_spec.dart';
import '../chart_palette.dart';
import 'maintained_palette.dart';
import 'maintained_scene_decorator.dart';

class MaintainedRenderer extends StatelessWidget {
  const MaintainedRenderer({
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
    final spec = definition.maintainedCreative;
    final source = CreativeChartData(points);
    if (spec == null || !source.valid) {
      return const Center(child: Text('Se requieren siete países diferentes.'));
    }
    final data = MaintainedChartData(source);
    final visual = spec.visuals.singleOrNull;
    final relations = visual == MaintainedVisual.chord
        ? data.currencyRelations
        : visual == MaintainedVisual.arcNetwork
        ? data.borderRelations
        : null;
    final metric =
        [
          MaintainedVisual.treemap,
          MaintainedVisual.icicle,
          MaintainedVisual.circlePacking,
        ].contains(visual)
        ? ChartMetric.area
        : ChartMetric.population;
    final needsTotal = [
      MaintainedVisual.treemap,
      MaintainedVisual.sunburst,
      MaintainedVisual.sankey,
      MaintainedVisual.marimekko,
      MaintainedVisual.icicle,
      MaintainedVisual.circlePacking,
      MaintainedVisual.pictogram,
    ].contains(visual);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              spec.componentCount == 1
                  ? 'Diagrama exploratorio'
                  : 'Figura combinada',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(spec.names, style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) => RepaintBoundary(
                key: const Key('maintained-canvas'),
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    height: constraints.maxWidth.clamp(300.0, 440.0),
                    child: MaintainedCountryPlot(
                      spec: spec,
                      data: data,
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
            if (visual == MaintainedVisual.sunburst) ...[
              const SizedBox(height: 12),
              const Text(
                'Anillo interior: regiones',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              for (var i = 0; i < data.regions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        color: ChartPalette.at(i).withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${data.regions[i].name} · '
                          '${data.groupShare(data.regions[i], ChartMetric.population).toStringAsFixed(1)} % de habitantes',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (needsTotal && source.total(metric) == 0)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'No hay un total positivo para repartir. Los siete países y sus ceros permanecen en la leyenda.',
                ),
              ),
            if (relations != null) ...[
              const SizedBox(height: 12),
              Text(
                relations.isEmpty
                    ? 'No hay vínculos internos en esta selección.'
                    : '${relations.length} vínculos internos reales:',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final relation in relations)
                Text(
                  '${points[relation.a].axisLabel} ↔ ${points[relation.b].axisLabel}'
                  '${visual == MaintainedVisual.chord ? ' · ${relation.weight} moneda(s) compartida(s)' : ' · frontera'}',
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
            ],
            if (visual == MaintainedVisual.ternary &&
                List.generate(7, data.ternary).any((value) => value == null))
              const Text(
                'Los perfiles totalmente cero no tienen composición ternaria; se conservan en la lista de datos.',
              ),
            if (visual == MaintainedVisual.pictogram)
              Text(
                '1 figura = ${(source.maximum(ChartMetric.population) / 10).toStringAsFixed(0)} habitantes.',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (visual == MaintainedVisual.horizon)
              const Text(
                'Bandas: clara 0–33,3 · media 33,3–66,7 · oscura 66,7–100. '
                'Lee el índice exacto junto a cada código.',
                style: TextStyle(fontSize: 12, height: 1.5),
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
                          ? MaintainedPalette.at(i)
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
                                  ? MaintainedPalette.at(i)
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
            if (spec.isProfile ||
                visual == MaintainedVisual.ternary ||
                visual == MaintainedVisual.horizon)
              const Text(
                'Índice = valor / máximo de esa métrica entre los siete × 100. '
                'Cada métrica tiene su propio máximo; si todos sus valores son cero, su índice es cero. '
                'No es una puntuación de calidad. Datos originales con unidades debajo.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
            if (!spec.usesLayerColors)
              for (var i = 0; i < points.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(top: 4),
                        color: ChartPalette.at(i),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${points[i].axisLabel} · ${points[i].label}'
                          '${[MaintainedVisual.sunburst, MaintainedVisual.sankey, MaintainedVisual.icicle].contains(visual) ? ' · ${points[i].region.isEmpty ? 'Sin región' : points[i].region}' : ''}',
                          style: const TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                      if (needsTotal)
                        Text(
                          '${source.value(i, metric).toStringAsFixed(0)} ${metric.unit}',
                          style: const TextStyle(fontSize: 10),
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

/// Exactly one native chart. Rare geometry uses the supported native
/// PointRendererDecorator -> ChartCanvas extension, not separate Flutter plots.
class MaintainedCountryPlot extends StatelessWidget {
  const MaintainedCountryPlot({
    super.key,
    required this.spec,
    required this.data,
    this.highlightedCode,
  });
  final MaintainedChartSpec spec;
  final MaintainedChartData data;
  final String? highlightedCode;

  @override
  Widget build(BuildContext context) {
    if (!data.source.valid) return const SizedBox.shrink();
    final series = charts.Series<int, num>(
      id: spec.signature,
      data: List.generate(data.source.points.length, (i) => i),
      domainFn: (i, _) =>
          data.source.relative(i, ChartMetric.density).clamp(0.01, 99.99),
      measureFn: (i, _) => 88 - i * 12,
      radiusPxFn: (_, _) => 0,
    );
    return KeyedSubtree(
      key: ValueKey('${spec.signature}-$highlightedCode'),
      child: charts.ScatterPlotChart(
        [series],
        animate: false,
        defaultInteractions: false,
        domainAxis: const charts.NumericAxisSpec(
          viewport: charts.NumericExtents(0, 100),
          renderSpec: charts.NoneRenderSpec(),
        ),
        primaryMeasureAxis: const charts.NumericAxisSpec(
          viewport: charts.NumericExtents(0, 100),
          renderSpec: charts.NoneRenderSpec(),
        ),
        defaultRenderer: charts.PointRendererConfig<num>(
          radiusPx: 0,
          pointRendererDecorators: [
            MaintainedSceneDecorator(spec, data, highlightedCode),
          ],
        ),
      ),
    );
  }
}
