import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/country.dart';
import '../../data/chart_catalog.dart';
import '../../domain/chart_definition.dart';
import 'chart_detail_screen.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key, required this.countries});

  final List<Country> countries;

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  ChartLibrary? _library;
  ChartLevel? _level;

  List<ChartDefinition> get _filtered => ChartCatalog.all
      .where((chart) {
        return (_library == null || chart.library == _library) &&
            (_level == null || chart.level == _level);
      })
      .toList(growable: false);

  void _open(ChartDefinition definition) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChartDetailScreen(
          definition: definition,
          countries: widget.countries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final charts = _filtered;
    return CustomScrollView(
      key: const Key('charts-tab'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
            child: _SummaryCard(visibleCount: charts.length),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: _library == null,
                  onSelected: (_) => setState(() => _library = null),
                ),
                const SizedBox(width: 8),
                for (final library in ChartLibrary.values) ...[
                  ChoiceChip(
                    label: Text(library.label),
                    selected: _library == library,
                    onSelected: (_) => setState(() => _library = library),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: SegmentedButton<ChartLevel?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Todas')),
                ButtonSegment(value: ChartLevel.basic, label: Text('Básicas')),
                ButtonSegment(
                  value: ChartLevel.advanced,
                  label: Text('Avanzadas'),
                ),
              ],
              selected: {_level},
              onSelectionChanged: (value) {
                setState(() => _level = value.first);
              },
              showSelectedIcon: false,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          sliver: SliverList.separated(
            itemCount: charts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final chart = charts[index];
              return _ChartCard(chart: chart, onTap: () => _open(chart));
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.visibleCount});

  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConstants.darkGreen,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF2A5B53),
              child: Icon(Icons.insights_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$visibleCount gráficas visibles',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '252 análisis únicos · 4 librerías',
                    style: TextStyle(color: Colors.white70),
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.chart, required this.onTap});

  final ChartDefinition chart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: _color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${chart.number}. ${chart.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chart.library.label} · ${chart.level.label} · ${chart.kind.label}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (chart.kind) {
    ChartKind.bar => Icons.bar_chart_rounded,
    ChartKind.line => Icons.show_chart_rounded,
    ChartKind.area => Icons.area_chart_rounded,
    ChartKind.pie => Icons.pie_chart_rounded,
    ChartKind.donut => Icons.donut_large_rounded,
    ChartKind.scatter => Icons.scatter_plot_rounded,
  };

  Color get _color => switch (chart.library) {
    ChartLibrary.flChart => const Color(0xFF0B7D6B),
    ChartLibrary.syncfusion => const Color(0xFF4361EE),
    ChartLibrary.maintained => const Color(0xFFF59E0B),
    ChartLibrary.graphic => const Color(0xFF9B5DE5),
  };
}
