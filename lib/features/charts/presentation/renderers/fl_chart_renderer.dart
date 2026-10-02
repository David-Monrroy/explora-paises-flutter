import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatters.dart';
import '../../data/creative_chart_data.dart';
import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../../domain/creative_chart.dart';
import '../chart_palette.dart';
import 'fl_fusion_renderer.dart';

/// Standalone visualizations and genuine single-canvas combinations.
class FlChartRenderer extends StatelessWidget {
  const FlChartRenderer({
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
    final data = CreativeChartData(points);
    if (!data.valid) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Selecciona siete países diferentes para ver esta comparación.',
        ),
      );
    }
    final spec = definition.creative!;
    if (spec.fusion != null) {
      return FlFusionRenderer(
        spec: spec.fusion!,
        data: data,
        highlightedCode: highlightedCode,
      );
    }
    final visual = spec.visuals.single;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              visual.label,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF173C36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              visual.explanation,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 290,
              child: FlCreativePlot(
                key: ValueKey('plot-${visual.name}'),
                visual: visual,
                data: data,
                highlightedCode: highlightedCode,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              visual.axes,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (visual == CreativeVisual.heatmap) ...[
              const SizedBox(height: 8),
              const Text(
                'Pob: población · Sup: superficie · Den: densidad · Idi: idiomas · Fro: fronteras · Zon: zonas horarias · Mon: monedas',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 6),
              Container(
                height: 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8F3EE), Color(0xFF086B59)],
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0', style: TextStyle(fontSize: 11)),
                  Text('100', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Every plot is drawn by FL Chart primitives, with no invented observations.
class FlCreativePlot extends StatelessWidget {
  const FlCreativePlot({
    super.key,
    required this.visual,
    required this.data,
    this.highlightedCode,
  });

  final CreativeVisual visual;
  final CreativeChartData data;
  final String? highlightedCode;
  static const _green = Color(0xFF0B7D6B);
  static const _purple = Color(0xFF7954B3);
  static const _grid = Color(0xFFE8EEEB);
  static const _radarMetrics = [
    ChartMetric.population,
    ChartMetric.area,
    ChartMetric.density,
    ChartMetric.borders,
  ];
  static const _discrete = [
    ChartMetric.languages,
    ChartMetric.borders,
    ChartMetric.timezones,
    ChartMetric.currencies,
  ];
  static const _metricLabels = [
    'Pob',
    'Sup',
    'Den',
    'Idi',
    'Fro',
    'Zon',
    'Mon',
  ];

  Color _color(int index) => ChartPalette.at(index).withValues(
    alpha:
        highlightedCode == null ||
            highlightedCode == data.points[index].countryCode
        ? 1
        : 0.15,
  );
  String _code(double value) =>
      value == value.roundToDouble() && value >= 0 && value < 7
      ? data.points[value.toInt()].axisLabel
      : '';
  String _number(double value) => compactNumber(
    value.abs() < 0.00001 ? 0 : double.parse(value.toStringAsFixed(1)),
  );
  String _integer(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '';

  AxisTitles _axis(
    String Function(double) label, {
    double? interval,
    double space = 35,
  }) => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      interval: interval,
      reservedSize: space,
      minIncluded: false,
      maxIncluded: false,
      getTitlesWidget: (value, meta) => SideTitleWidget(
        meta: meta,
        space: 6,
        child: Text(
          label(value),
          style: const TextStyle(fontSize: 10, color: Color(0xFF43544F)),
        ),
      ),
    ),
  );

  FlTitlesData _titles({
    String Function(double)? x,
    String Function(double)? y,
    double? xInterval,
    double? yInterval,
  }) => FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    bottomTitles: _axis(x ?? _number, interval: xInterval, space: 30),
    leftTitles: _axis(y ?? _number, interval: yInterval, space: 42),
  );

  Widget _line(
    List<LineChartBarData> lines, {
    double minX = -0.5,
    double maxX = 6.5,
    double minY = 0,
    double maxY = 100,
    FlTitlesData? titles,
  }) => LineChart(
    LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: lines,
      titlesData: titles ?? _titles(x: _code, xInterval: 1),
      gridData: const FlGridData(drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
    ),
    duration: Duration.zero,
  );

  LineChartBarData _series(
    List<FlSpot> spots,
    Color color, {
    bool dots = true,
    bool fill = false,
    List<int>? dash,
  }) => LineChartBarData(
    spots: spots,
    color: color,
    barWidth: 2,
    dashArray: dash,
    dotData: FlDotData(
      show: dots,
      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
        radius: 3,
        color: color,
        strokeWidth: 1,
        strokeColor: Colors.white,
      ),
    ),
    belowBarData: BarAreaData(show: fill, color: color.withValues(alpha: 0.12)),
  );

  Widget _scatter(
    List<ScatterSpot> spots, {
    required double minX,
    required double maxX,
    double minY = -0.6,
    double maxY = 6.6,
    FlTitlesData? titles,
    bool grid = true,
  }) => ScatterChart(
    ScatterChartData(
      scatterSpots: spots,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      titlesData: titles ?? _titles(),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: grid,
        getDrawingHorizontalLine: (_) => const FlLine(color: _grid),
        getDrawingVerticalLine: (_) => const FlLine(color: _grid),
      ),
      scatterTouchData: ScatterTouchData(enabled: false),
    ),
    duration: Duration.zero,
  );

  Widget _empty(String message) =>
      Center(child: Text(message, textAlign: TextAlign.center));

  @override
  Widget build(BuildContext context) {
    if (!data.valid) return _empty('Selecciona siete países diferentes.');
    return switch (visual) {
      CreativeVisual.radar => _radar(),
      CreativeVisual.lollipop => _lollipop(),
      CreativeVisual.dumbbell => _dumbbell(),
      CreativeVisual.slope => _slope(),
      CreativeVisual.parallel => _parallel(),
      CreativeVisual.bubble => _bubble(),
      CreativeVisual.heatmap => _heatmap(),
      CreativeVisual.waffle => _waffle(),
      CreativeVisual.lorenz => _lorenz(),
      CreativeVisual.waterfall => _waterfall(),
      CreativeVisual.bullet => _bullet(),
      CreativeVisual.diverging => _diverging(),
      CreativeVisual.ecdf => _ecdf(),
      CreativeVisual.strip => _strip(),
      CreativeVisual.rose => _rose(),
    };
  }

  Widget _radar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
    child: RadarChart(
      RadarChartData(
        isMinValueAtCenter: true,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 9, color: Colors.black54),
        titleTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        getTitle: (index, _) => RadarChartTitle(
          text: ['Población', 'Área', 'Densidad', 'Fronteras'][index],
        ),
        gridBorderData: const BorderSide(color: _grid),
        tickBorderData: const BorderSide(color: _grid),
        radarBorderData: const BorderSide(color: _grid),
        radarTouchData: RadarTouchData(enabled: false),
        dataSets: [
          // Invisible anchors define the same 0–100 scale, even for all-zero data.
          for (final anchor in [0.0, 100.0])
            RadarDataSet(
              dataEntries: [
                for (var i = 0; i < 4; i++) RadarEntry(value: anchor),
              ],
              borderColor: Colors.transparent,
              fillColor: Colors.transparent,
              entryRadius: 0,
            ),
          for (var i = 0; i < 7; i++)
            RadarDataSet(
              dataEntries: [
                for (final metric in _radarMetrics)
                  RadarEntry(value: data.relative(i, metric)),
              ],
              borderColor: _color(i),
              fillColor: _color(i).withValues(
                alpha: highlightedCode == data.points[i].countryCode
                    ? 0.14
                    : 0.025,
              ),
              borderWidth: highlightedCode == data.points[i].countryCode
                  ? 3
                  : 1.5,
              entryRadius: 2,
            ),
        ],
      ),
      duration: Duration.zero,
    ),
  );

  Widget _lollipop() => _line(
    [
      for (var i = 0; i < 7; i++)
        LineChartBarData(
          spots: [
            FlSpot(i.toDouble(), 0),
            FlSpot(i.toDouble(), data.value(i, ChartMetric.languages)),
          ],
          color: _color(i),
          barWidth: 2,
          dotData: FlDotData(
            checkToShowDot: (_, _) => true,
            getDotPainter: (_, _, _, index) => FlDotCirclePainter(
              radius: index == 0 ? 0 : 6,
              color: _color(i),
              strokeWidth: 0,
            ),
          ),
        ),
    ],
    maxY: math.max(1, data.maximum(ChartMetric.languages) * 1.15),
    titles: _titles(
      x: _code,
      xInterval: 1,
      y: _integer,
      yInterval: math.max(
        1,
        (data.maximum(ChartMetric.languages) / 4).ceilToDouble(),
      ),
    ),
  );

  Widget _dumbbell() => _line(
    [
      for (var i = 0; i < 7; i++)
        LineChartBarData(
          spots: [
            FlSpot(data.share(i, ChartMetric.population), (6 - i).toDouble()),
            FlSpot(data.share(i, ChartMetric.area), (6 - i).toDouble()),
          ],
          color: _color(i).withValues(alpha: 0.45),
          barWidth: 3,
          dotData: FlDotData(
            getDotPainter: (_, _, _, index) => FlDotCirclePainter(
              radius: 5,
              color: index == 0 ? _green : _purple,
              strokeWidth: 1,
              strokeColor: Colors.white,
            ),
          ),
        ),
    ],
    minX: -3,
    maxX: 103,
    minY: -0.7,
    maxY: 6.7,
    titles: _titles(
      x: (value) => value >= 0 && value <= 100 ? _number(value) : '',
      xInterval: 25,
      y: (value) => _code(6 - value),
      yInterval: 1,
    ),
  );

  Widget _slope() => _line(
    [
      for (var i = 0; i < 7; i++)
        _series([
          FlSpot(0, 8 - data.rank(i, ChartMetric.area)),
          FlSpot(1, 8 - data.rank(i, ChartMetric.population)),
        ], _color(i)),
    ],
    minX: -0.25,
    maxX: 1.25,
    minY: 0.5,
    maxY: 7.5,
    titles: _titles(
      x: (value) => value == 0
          ? 'Superficie'
          : value == 1
          ? 'Población'
          : '',
      xInterval: 1,
      y: (value) => _integer(8 - value),
      yInterval: 1,
    ),
  );

  Widget _parallel() => _line(
    [
      for (var i = 0; i < 7; i++)
        _series([
          for (var j = 0; j < _discrete.length; j++)
            FlSpot(j.toDouble(), data.relative(i, _discrete[j])),
        ], _color(i)),
    ],
    minX: -0.3,
    maxX: 3.3,
    maxY: 105,
    titles: _titles(
      x: (value) => value == value.roundToDouble() && value >= 0 && value < 4
          ? ['Idiomas', 'Fronteras', 'Zonas', 'Monedas'][value.toInt()]
          : '',
      xInterval: 1,
      yInterval: 25,
    ),
  );

  Widget _bubble() => _scatter(
    [
      for (var i = 0; i < 7; i++)
        ScatterSpot(
          data.relative(i, ChartMetric.area),
          data.relative(i, ChartMetric.population),
          dotPainter: FlDotCirclePainter(
            radius: 18 * math.sqrt(data.relative(i, ChartMetric.density) / 100),
            color: _color(i).withValues(
              alpha:
                  highlightedCode == null ||
                      highlightedCode == data.points[i].countryCode
                  ? 0.65
                  : 0.12,
            ),
            strokeWidth: 1,
            strokeColor: _color(i),
          ),
        ),
    ],
    minX: -10,
    maxX: 110,
    minY: -10,
    maxY: 110,
    titles: _titles(
      x: (v) => v >= 0 && v <= 100 ? _number(v) : '',
      y: (v) => v >= 0 && v <= 100 ? _number(v) : '',
      xInterval: 25,
      yInterval: 25,
    ),
  );

  Widget _heatmap() => LayoutBuilder(
    builder: (context, constraints) {
      final size = math.min((constraints.maxWidth - 44) / 7.3, 30.0);
      return _scatter(
        [
          for (var i = 0; i < 7; i++)
            for (var j = 0; j < 7; j++)
              ScatterSpot(
                j.toDouble(),
                (6 - i).toDouble(),
                dotPainter: FlDotSquarePainter(
                  size: size,
                  strokeWidth: 0,
                  color:
                      Color.lerp(
                        const Color(0xFFE8F3EE),
                        const Color(0xFF086B59),
                        data.relative(i, ChartMetric.values[j]) / 100,
                      )!.withValues(
                        alpha:
                            highlightedCode == null ||
                                highlightedCode == data.points[i].countryCode
                            ? 1
                            : 0.2,
                      ),
                ),
              ),
        ],
        minX: -0.5,
        maxX: 6.5,
        grid: false,
        titles: _titles(
          x: (v) => v == v.roundToDouble() && v >= 0 && v < 7
              ? _metricLabels[v.toInt()]
              : '',
          y: (v) => _code(6 - v),
          xInterval: 1,
          yInterval: 1,
        ),
      );
    },
  );

  Widget _waffle() {
    final cells = data.waffle();
    if (cells.isEmpty) {
      return _empty('No hay superficie registrada para calcular proporciones.');
    }
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) => _scatter(
            [
              for (var i = 0; i < cells.length; i++)
                ScatterSpot(
                  (i % 10).toDouble(),
                  (9 - i ~/ 10).toDouble(),
                  dotPainter: FlDotSquarePainter(
                    size: constraints.maxWidth / 10 - 3,
                    color: _color(cells[i]),
                    strokeWidth: 0,
                  ),
                ),
            ],
            minX: -0.5,
            maxX: 9.5,
            minY: -0.5,
            maxY: 9.5,
            titles: const FlTitlesData(show: false),
            grid: false,
          ),
        ),
      ),
    );
  }

  Widget _lorenz() {
    final coordinates = data.concentration();
    if (coordinates.isEmpty) {
      return _empty(
        'No hay población registrada para calcular la concentración.',
      );
    }
    return _line(
      [
        _series(
          const [FlSpot(0, 0), FlSpot(100, 100)],
          Colors.grey,
          dots: false,
          dash: [5, 5],
        ),
        _series(
          [for (final point in coordinates) FlSpot(point.x, point.y)],
          _green,
          fill: true,
        ),
      ],
      minX: -2,
      maxX: 102,
      maxY: 105,
      titles: _titles(xInterval: 25, yInterval: 25),
    );
  }

  Widget _bars(
    List<BarChartGroupData> groups, {
    double minY = 0,
    double maxY = 100,
    double? reference,
  }) => BarChart(
    BarChartData(
      minY: minY,
      maxY: maxY,
      barGroups: groups,
      titlesData: _titles(x: _code, xInterval: 1),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(drawVerticalLine: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (reference != null)
            HorizontalLine(
              y: reference,
              color: _purple,
              strokeWidth: 2,
              dashArray: [5, 4],
            ),
        ],
      ),
      barTouchData: BarTouchData(enabled: false),
    ),
    duration: Duration.zero,
  );

  Widget _waterfall() {
    if (data.total(ChartMetric.population) == 0) {
      return _empty('No hay población registrada para calcular aportes.');
    }
    var running = 0.0;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < 7; i++) {
      final start = running;
      running += data.share(i, ChartMetric.population);
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: start,
              toY: running,
              color: _color(i),
              width: 22,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }
    return _bars(groups, maxY: 105);
  }

  Widget _bullet() {
    final maximum = data.maximum(ChartMetric.timezones);
    return _bars(
      [
        for (var i = 0; i < 7; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data.value(i, ChartMetric.timezones),
                color: _color(i),
                width: 18,
                borderRadius: BorderRadius.circular(2),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maximum,
                  color: _grid,
                ),
              ),
            ],
          ),
      ],
      maxY: math.max(1, maximum * 1.15),
      reference: data.mean(ChartMetric.timezones),
    );
  }

  Widget _diverging() {
    final numbers = [
      for (var i = 0; i < 7; i++) data.deviation(i, ChartMetric.density),
    ];
    final limit = math.max(
      10.0,
      numbers.map((v) => v.abs()).reduce(math.max) * 1.15,
    );
    return _bars(
      [
        for (var i = 0; i < 7; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: numbers[i],
                color: (numbers[i] >= 0 ? _green : _purple).withValues(
                  alpha:
                      highlightedCode == null ||
                          highlightedCode == data.points[i].countryCode
                      ? 1
                      : 0.2,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
      ],
      minY: -limit,
      maxY: limit,
      reference: 0,
    );
  }

  Widget _ecdf() {
    final distribution = data.distribution(ChartMetric.borders);
    final end = math.max(1.0, data.maximum(ChartMetric.borders) + 1);
    final spots = <FlSpot>[const FlSpot(-0.2, 0)];
    var previous = 0.0;
    for (final point in distribution) {
      spots.addAll([FlSpot(point.x, previous), FlSpot(point.x, point.y)]);
      previous = point.y;
    }
    spots.add(FlSpot(end, 100));
    return _line(
      [_series(spots, _green, dots: false)],
      minX: -0.5,
      maxX: end,
      maxY: 105,
      titles: _titles(
        x: _integer,
        xInterval: math.max(1, (end / 5).ceilToDouble()),
        yInterval: 25,
      ),
    );
  }

  Widget _strip() {
    final values = data.values(ChartMetric.currencies);
    return _scatter(
      [
        for (var i = 0; i < 7; i++)
          ScatterSpot(
            values[i],
            values.take(i).where((v) => v == values[i]).length.toDouble() -
                (values.where((v) => v == values[i]).length - 1) / 2,
            dotPainter: FlDotCirclePainter(
              radius: 6,
              color: _color(i),
              strokeWidth: 1,
              strokeColor: Colors.white,
            ),
          ),
      ],
      minX: -0.5,
      maxX: math.max(1.5, data.maximum(ChartMetric.currencies) + 0.5),
      minY: -4,
      maxY: 4,
      titles: _titles(x: _integer, xInterval: 1, y: (_) => ''),
      grid: false,
    );
  }

  Widget _rose() {
    if (data.total(ChartMetric.area) == 0) {
      return _empty('No hay superficie registrada para dibujar los sectores.');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxRadius =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.42;
        return PieChart(
          PieChartData(
            centerSpaceRadius: 0,
            sectionsSpace: 1,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(enabled: false),
            sections: [
              for (var i = 0; i < 7; i++)
                PieChartSectionData(
                  value: 1,
                  radius:
                      maxRadius *
                      math.sqrt(data.relative(i, ChartMetric.area) / 100),
                  color: _color(i),
                  showTitle: false,
                ),
            ],
          ),
          duration: Duration.zero,
        );
      },
    );
  }
}
