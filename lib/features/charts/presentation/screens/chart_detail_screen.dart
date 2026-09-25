import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/country.dart';
import '../../domain/chart_definition.dart';
import '../renderers/chart_renderer.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text('Gráfica ${definition.number}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
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
          const SizedBox(height: 8),
          Text(
            definition.description,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
              child: SizedBox(
                height: 360,
                child: ChartRenderer(
                  definition: definition,
                  countries: countries,
                ),
              ),
            ),
          ),
          if (definition.level == ChartLevel.advanced) ...[
            const SizedBox(height: 14),
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
                        'Gráfica interactiva: toca, desliza o acerca para explorar los datos.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Fuente: REST Countries · Los valores se transforman localmente y no representan una serie histórica.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
}
