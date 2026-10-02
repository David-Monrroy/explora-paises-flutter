import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/number_formatters.dart';
import '../../../../data/models/country.dart';
import '../../data/chart_data_transformer.dart';
import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../chart_palette.dart';
import '../renderers/chart_renderer.dart';
import 'creative_chart_detail_screen.dart';

class ChartDetailScreen extends StatelessWidget {
  const ChartDetailScreen({
    super.key,
    required this.definition,
    required this.countries,
  });

  final ChartDefinition definition;
  final List<Country> countries;

  @override
  Widget build(BuildContext context) {
    final points = ChartDataTransformer.transform(definition, countries);
    if (definition.exploration != null) {
      return CreativeChartDetailScreen(definition: definition, points: points);
    }
    final circular =
        definition.kind == ChartKind.pie || definition.kind == ChartKind.donut;
    final total = points.fold<double>(0, (sum, point) => sum + point.value);

    return Scaffold(
      appBar: AppBar(title: Text('Gráfica ${definition.number}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: definition.library.label),
              _Badge(label: definition.level.label),
              _Badge(label: definition.kind.label),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            definition.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppConstants.darkGreen,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            definition.description,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Qué muestra',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  Text('Horizontal: ${definition.horizontalLabel}'),
                  const SizedBox(height: 3),
                  Text('Vertical: ${definition.verticalLabel}'),
                  const SizedBox(height: 5),
                  Text(
                    'Métrica: ${definition.metric.meaning}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  if (definition.kind == ChartKind.line ||
                      definition.kind == ChartKind.area) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'La posición de los países no representa fechas.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 15),
              child: Column(
                children: [
                  SizedBox(
                    height: 340,
                    child: points.isEmpty
                        ? const Center(
                            child: Text(
                              'Los siete países tienen valor cero para esta métrica; '
                              'no hay proporciones que se puedan dibujar.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ChartRenderer(definition: definition, points: points),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    definition.horizontalLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Leyenda y valores',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            circular
                ? 'Cada color corresponde al país o grupo indicado. El porcentaje se calcula sobre estos siete países.'
                : 'Los países aparecen en el mismo orden de la gráfica. Los valores tienen las unidades indicadas arriba.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 9),
          for (var index = 0; index < points.length; index++)
            _LegendRow(
              point: points[index],
              color:
                  definition.kind == ChartKind.line ||
                      definition.kind == ChartKind.area
                  ? AppConstants.primaryColor
                  : ChartPalette.at(index),
              valueText: circular
                  ? '${_format(points[index].value)} ${definition.metric.unit} · '
                        '${_format(total == 0 ? 0 : points[index].value / total * 100)} %'
                  : '${_format(points[index].value)} ${definition.valueUnit}',
              subtitle: definition.kind == ChartKind.scatter
                  ? '${definition.secondaryMetric!.label}: '
                        '${_format(points[index].secondaryValue)} '
                        '${definition.analysis == ChartAnalysis.scatterRank ? "puesto" : definition.secondaryMetric!.unit}'
                  : points[index].members.isNotEmpty
                  ? points[index].members.join(', ')
                  : points[index].originalValue != null &&
                        points[index].originalValue != points[index].value
                  ? 'Valor original: ${_format(points[index].originalValue!)} ${definition.metric.unit}'
                  : null,
            ),
          if (definition.level == ChartLevel.advanced) ...[
            const SizedBox(height: 12),
            const Card(
              color: Color(0xFFE5F4EF),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: AppConstants.primaryColor,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Toca los datos para explorar la interacción de esta librería.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Fuente: REST Countries. Las medidas describen un estado actual; '
            'no son una serie histórica.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  static String _format(double value) {
    if (!value.isFinite) return '—';
    if (value.abs() >= 1000 || value == value.roundToDouble()) {
      return formatNumber(value);
    }
    return value.toStringAsFixed(value.abs() < 1 ? 2 : 1).replaceAll('.', ',');
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.point,
    required this.color,
    required this.valueText,
    this.subtitle,
  });

  final ChartPoint point;
  final Color color;
  final String valueText;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    point.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                valueText,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppConstants.navigationIndicatorColor,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppConstants.darkGreen,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
