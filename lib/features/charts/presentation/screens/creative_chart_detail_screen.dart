import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/number_formatters.dart';
import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../chart_palette.dart';
import '../renderers/fl_chart_renderer.dart';

class CreativeChartDetailScreen extends StatefulWidget {
  const CreativeChartDetailScreen({
    super.key,
    required this.definition,
    required this.points,
  });

  final ChartDefinition definition;
  final List<ChartPoint> points;

  @override
  State<CreativeChartDetailScreen> createState() =>
      _CreativeChartDetailScreenState();
}

class _CreativeChartDetailScreenState extends State<CreativeChartDetailScreen> {
  String? _highlightedCode;

  @override
  Widget build(BuildContext context) {
    final spec = widget.definition.creative!;
    return Scaffold(
      appBar: AppBar(title: Text('Gráfica ${widget.definition.number}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FL Chart · ${widget.definition.level.label} · '
                  '${spec.componentCount} ${spec.componentCount == 1 ? 'visualización' : 'tipos fusionados en una figura'}',
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.definition.title,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(spec.explanation, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 18),
                Text(
                  'Los siete países',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  spec.fusion == null
                      ? 'Los colores identifican países, salvo donde se indica otra escala. Toca un país para resaltarlo; todos siguen incluidos en los cálculos.'
                      : 'Los países se identifican por sus códigos en la figura. Los colores distinguen tipos de gráfica en la leyenda. Toca un país para destacar sus barras o marcadores; los siete siguen incluidos.',
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < widget.points.length; i++)
                      FilterChip(
                        key: ValueKey(
                          'highlight-${widget.points[i].countryCode}',
                        ),
                        avatar: spec.fusion != null
                            ? null
                            : CircleAvatar(
                                backgroundColor: ChartPalette.at(i),
                                radius: 6,
                              ),
                        label: Text(
                          '${widget.points[i].axisLabel} · ${widget.points[i].label}',
                        ),
                        selected:
                            _highlightedCode == widget.points[i].countryCode,
                        onSelected: (selected) => setState(
                          () => _highlightedCode = selected
                              ? widget.points[i].countryCode
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FlChartRenderer(
                  definition: widget.definition,
                  points: widget.points,
                  highlightedCode: _highlightedCode,
                ),
                const SizedBox(height: 24),
                Text(
                  'Leyenda y valores',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Datos originales de la selección. Abre un país para revisar los valores '
                  'que alimentan las visualizaciones y sus unidades.',
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < widget.points.length; i++)
                  Card(
                    child: ExpansionTile(
                      key: ValueKey(
                        'source-values-${widget.points[i].countryCode}',
                      ),
                      leading: spec.fusion != null
                          ? null
                          : CircleAvatar(
                              radius: 7,
                              backgroundColor: ChartPalette.at(i),
                            ),
                      title: Text(widget.points[i].label),
                      subtitle: Text(widget.points[i].axisLabel),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        for (final metric in ChartMetric.values)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(metric.label)),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    '${formatNumber(widget.points[i].metrics[metric] ?? 0)} ${metric.unit}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Fuente: datos cargados de REST Countries o respaldo de demostración. '
                  'Todas las proporciones y referencias se calculan solo entre los siete elegidos. '
                  'Las líneas no representan evolución temporal.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
