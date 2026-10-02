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
  final _searchController = TextEditingController();
  final _selectedCodes = <String>[];
  ChartLibrary? _library;
  ChartLevel? _level;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Country> get _selectedCountries {
    final byCode = {
      for (final country in widget.countries) country.code: country,
    };
    return [
      for (final code in _selectedCodes)
        if (byCode[code] != null) byCode[code]!,
    ];
  }

  List<ChartDefinition> get _filtered => ChartCatalog.all
      .where(
        (chart) =>
            (_library == null || chart.library == _library) &&
            (_level == null || chart.level == _level),
      )
      .toList(growable: false);

  void _toggleCountry(Country country) {
    setState(() {
      if (_selectedCodes.contains(country.code)) {
        _selectedCodes.remove(country.code);
      } else if (_selectedCodes.length < 7) {
        _selectedCodes.add(country.code);
      }
      if (_selectedCodes.length == 7) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  void _open(ChartDefinition definition) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChartDetailScreen(
          definition: definition,
          countries: _selectedCountries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedCountries;
    final ready = selected.length == 7;
    final available =
        widget.countries
            .where(
              (country) =>
                  !_selectedCodes.contains(country.code) &&
                  country.matches(_query),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final charts = ready ? _filtered : const <ChartDefinition>[];

    return CustomScrollView(
      key: const Key('charts-tab'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: _SelectionHeader(count: selected.length, ready: ready),
          ),
        ),
        if (selected.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Wrap(
                spacing: 7,
                runSpacing: 6,
                children: [
                  for (final country in selected)
                    InputChip(
                      key: Key('selected-${country.code}'),
                      label: Text(country.name),
                      onDeleted: () => _toggleCountry(country),
                      deleteButtonTooltipMessage: 'Quitar ${country.name}',
                    ),
                ],
              ),
            ),
          ),
        if (!ready) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
              child: TextField(
                key: const Key('country-chart-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Busca un país para comparar',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (widget.countries.length < 7)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No hay siete países disponibles. Actualiza los datos para continuar.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverList.separated(
                itemCount: available.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final country = available[index];
                  return Card(
                    child: ListTile(
                      key: Key('select-country-${country.code}'),
                      leading: const Icon(
                        Icons.public_rounded,
                        color: AppConstants.primaryColor,
                      ),
                      title: Text(country.name),
                      subtitle: Text('${country.region} · ${country.code}'),
                      trailing: const Icon(Icons.add_circle_outline_rounded),
                      onTap: () => _toggleCountry(country),
                    ),
                  );
                },
              ),
            ),
        ] else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
              child: Text(
                'Todas las gráficas usan exclusivamente estos siete países. '
                'Quita uno para cambiar la selección.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
                  ButtonSegment(
                    value: ChartLevel.basic,
                    label: Text('Básicas'),
                  ),
                  ButtonSegment(
                    value: ChartLevel.advanced,
                    label: Text('Avanzadas'),
                  ),
                ],
                selected: {_level},
                onSelectionChanged: (value) =>
                    setState(() => _level = value.first),
                showSelectedIcon: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                '${charts.length} gráficas visibles',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            sliver: SliverList.separated(
              itemCount: charts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chart = charts[index];
                return Card(
                  child: ListTile(
                    key: Key('chart-${chart.id}'),
                    leading: Icon(
                      _iconFor(chart.kind),
                      color: AppConstants.primaryColor,
                    ),
                    title: Text(
                      '${chart.number}. ${chart.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${chart.library.label} · ${chart.level.label} · ${chart.kind.label}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _open(chart),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconFor(ChartKind kind) => switch (kind) {
    ChartKind.bar => Icons.bar_chart_rounded,
    ChartKind.line => Icons.show_chart_rounded,
    ChartKind.area => Icons.area_chart_rounded,
    ChartKind.pie => Icons.pie_chart_rounded,
    ChartKind.donut => Icons.donut_large_rounded,
    ChartKind.scatter => Icons.scatter_plot_rounded,
    ChartKind.creative => Icons.auto_graph_rounded,
  };
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({required this.count, required this.ready});

  final int count;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConstants.darkGreen,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ready ? 'Comparación lista' : 'Elige 7 países',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '$count/7',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ready
                  ? 'Ya puedes explorar 252 comparaciones basadas en tu selección.'
                  : 'Las gráficas aparecerán cuando completes los siete países.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: count / 7,
              backgroundColor: Colors.white24,
              color: const Color(0xFF91E5C8),
            ),
          ],
        ),
      ),
    );
  }
}
