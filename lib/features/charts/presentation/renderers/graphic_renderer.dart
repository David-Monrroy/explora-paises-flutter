import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as g;

import '../../data/creative_chart_data.dart';
import '../../data/graphic_chart_data.dart';
import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../../domain/graphic_chart_spec.dart';
import '../chart_palette.dart';
import 'graphic_palette.dart';
import 'graphic_scene_shape.dart';

class GraphicRenderer extends StatelessWidget {
  const GraphicRenderer({
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
    final source = CreativeChartData(points), spec = definition.graphicCreative;
    if (spec == null || !source.valid) {
      return const Center(child: Text('Se requieren siete países diferentes.'));
    }
    final data = GraphicChartData(source);
    final single = spec.visuals.singleOrNull;
    String codes(List<int> members) =>
        members.map((i) => points[i].axisLabel).join(', ');
    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, height: 1.5)),
    );
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
                key: const Key('graphic-canvas'),
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    height: constraints.maxWidth.clamp(330.0, 480.0),
                    child: GraphicCountryPlot(
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
            if (single == GraphicVisual.voronoi)
              for (final cell in data.voronoi.where(
                (cell) => cell.members.length > 1,
              ))
                note(
                  'Coordenadas coincidentes, misma celda: ${codes(cell.members)}.',
                ),
            if (single == GraphicVisual.minimumSpanningTree)
              for (final edge in data.spanningTree)
                note(
                  '${points[edge.a].axisLabel} ↔ ${points[edge.b].axisLabel} · distancia ${edge.distance.toStringAsFixed(2)} puntos de índice.',
                ),
            if (single == GraphicVisual.convexHull) ...[
              note('Envolventes: colores de región. Puntos: colores de país.'),
              for (var i = 0; i < data.regions.length; i++)
                Row(
                  children: [
                    Container(width: 9, height: 9, color: GraphicPalette.at(i)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: note(
                        '${data.regions[i].name}: ${codes(data.regions[i].members)}',
                      ),
                    ),
                  ],
                ),
            ],
            if (single == GraphicVisual.hexbin) ...[
              note(
                'Etiqueta: cantidad de países · #celda. Intensidad: número de países (1–7). Cada país pertenece a una sola celda.',
              ),
              for (var i = 0; i < data.hexagons.length; i++)
                note(
                  'Celda ${i + 1}: ${data.hexagons[i].members.length} país(es) · ${codes(data.hexagons[i].members)}.',
                ),
            ],
            if (single == GraphicVisual.upset) ...[
              note(
                data.intersections.isEmpty
                    ? 'No hay idiomas registrados en esta selección.'
                    : 'Barras: idiomas distintos. ${data.intersections.length > 7 ? 'La figura muestra los siete conjuntos principales; la lista incluye todos.' : 'La lista incluye todos los conjuntos.'}',
              ),
              for (var i = 0; i < data.intersections.length; i++)
                note(
                  'Conjunto ${i + 1} · ${codes(data.intersections[i].members)}: '
                  '${data.intersections[i].languages.length} idioma(s) — ${data.intersections[i].languages.join(', ')}.',
                ),
            ],
            if (single == GraphicVisual.venn) ...[
              note(
                data.vennSets.isEmpty
                    ? 'No hay idiomas registrados; los siete países están fuera de los conjuntos.'
                    : 'Colores de los círculos: idiomas. Áreas esquemáticas.',
              ),
              for (var k = 0; k < data.vennSets.length; k++)
                Row(
                  children: [
                    Container(width: 9, height: 9, color: GraphicPalette.at(k)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: note(
                        '${String.fromCharCode(65 + k)}: ${data.vennSets[k].name}',
                      ),
                    ),
                  ],
                ),
              for (final entry in data.vennBuckets.entries)
                note(
                  '${entry.key == 0 ? 'Fuera' : [for (var k = 0; k < data.vennSets.length; k++)
                          if (entry.key & (1 << k) != 0) String.fromCharCode(65 + k)].join(' ∩ ')}: '
                  '${entry.value.length} país(es) · ${codes(entry.value)}.',
                ),
            ],
            if (single == GraphicVisual.petals) ...[
              note(
                'Centro: color de país. Pétalos: color de métrica; longitud proporcional al índice.',
              ),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  for (final metric in ChartMetric.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          color: ChartPalette.at(metric.index),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          metric.label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            if (single == GraphicVisual.taylor) ...[
              note(
                'Referencia: perfil medio · desviación estándar ${data.referenceDeviation.toStringAsFixed(2)} puntos de índice.',
              ),
              for (var i = 0; i < 7; i++)
                note(
                  data.taylor(i) == null
                      ? '${points[i].axisLabel}: correlación indefinida por variación cero; no se posiciona.'
                      : '${points[i].axisLabel} · DE ${data.taylor(i)!.standardDeviation.toStringAsFixed(2)} · '
                            'r ${data.taylor(i)!.correlation.toStringAsFixed(2)} · RMS centrada ${data.taylor(i)!.centeredRms.toStringAsFixed(2)}.',
                ),
            ],
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
                          ? GraphicPalette.at(i)
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
                                  ? GraphicPalette.at(i)
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
            if (single != GraphicVisual.upset && single != GraphicVisual.venn)
              note(
                'Índice = valor / máximo de esa métrica entre los siete × 100. '
                'Un máximo cero produce índices cero. Los índices no son una puntuación de calidad ni una suma de unidades físicas.',
              ),
            if (!spec.usesLayerColors)
              for (var i = 0; i < points.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Container(width: 9, height: 9, color: ChartPalette.at(i)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${points[i].axisLabel} · ${points[i].label}',
                          style: const TextStyle(fontSize: 12),
                        ),
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

class GraphicCountryDatum {
  const GraphicCountryDatum(this.index, this.point);
  final int index;
  final ChartPoint point;
}

/// One real Graphic chart; native CustomMarks and Shapes create every layer.
/// No nested charts or external CustomPainter substitute the requested library.
class GraphicCountryPlot extends StatelessWidget {
  const GraphicCountryPlot({
    super.key,
    required this.spec,
    required this.data,
    this.highlightedCode,
  });
  final GraphicChartSpec spec;
  final GraphicChartData data;
  final String? highlightedCode;
  @override
  Widget build(BuildContext context) {
    if (!data.source.valid) return const SizedBox.shrink();
    final order = List.generate(spec.componentCount, (i) => i)
      ..sort(
        (a, b) =>
            graphicLayerPriority(spec.visuals[a])
                .compareTo(graphicLayerPriority(spec.visuals[b])),
      );
    return g.Chart<GraphicCountryDatum>(
      key: ValueKey('${spec.signature}-$highlightedCode'),
      data: [
        for (var i = 0; i < 7; i++)
          GraphicCountryDatum(i, data.source.points[i]),
      ],
      variables: {
        'x': g.Variable(
          accessor: (GraphicCountryDatum d) =>
              data.source.relative(d.index, ChartMetric.area),
          scale: g.LinearScale(min: 0, max: 100),
        ),
        'y': g.Variable(
          accessor: (GraphicCountryDatum d) =>
              data.source.relative(d.index, ChartMetric.population),
          scale: g.LinearScale(min: 0, max: 100),
        ),
      },
      padding: (_) => const EdgeInsets.all(4),
      coord: g.RectCoord(),
      axes: const [],
      marks: [
        for (var position = 0; position < order.length; position++)
          g.CustomMark(
            position: g.Varset('x') * g.Varset('y'),
            shape: g.ShapeEncode(
              value: GraphicSceneShape(
                spec: spec,
                data: data,
                layer: order[position],
                showAxes: position == 0,
                highlightedCode: highlightedCode,
              ),
            ),
          ),
      ],
    );
  }
}
