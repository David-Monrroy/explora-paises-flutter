import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/creative_chart_data.dart';
import '../../data/fusion_chart_data.dart';
import '../../domain/fusion_chart.dart';

abstract final class FusionPalette {
  static const colors = [
    Color(0xFF087F8C),
    Color(0xFF8557B5),
    Color(0xFFD96C06),
    Color(0xFF2952A3),
  ];
  static Color at(int index) => colors[index % colors.length];
}

/// A combination has exactly one canvas and one coordinate system.
class FlFusionRenderer extends StatelessWidget {
  const FlFusionRenderer({
    super.key,
    required this.spec,
    required this.data,
    this.highlightedCode,
  });

  final FusionChartSpec spec;
  final CreativeChartData data;
  final String? highlightedCode;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Figura combinada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(spec.names, style: const TextStyle(fontSize: 13, height: 1.4)),
          const SizedBox(height: 18),
          RepaintBoundary(
            key: const Key('fusion-canvas'),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 8),
              child: AspectRatio(
                aspectRatio: spec.projection == FusionProjection.polar
                    ? 1
                    : 1.05,
                child: FlFusionPlot(
                  spec: spec,
                  data: data,
                  highlightedCode: highlightedCode,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            spec.axes,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 18),
          const Text(
            'Qué representa cada capa',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < spec.layers.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    margin: const EdgeInsets.only(top: 4, right: 9),
                    decoration: BoxDecoration(
                      color: FusionPalette.at(i),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spec.layers[i].label,
                          style: TextStyle(
                            color: FusionPalette.at(i),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          spec.layers[i].explanation,
                          style: const TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          const Text(
            'Los índices permiten comparar características con unidades diferentes. '
            'Un valor 100 significa el máximo de cada métrica entre estos siete países. '
            'El porcentaje acumulado de la cascada se refiere al total de su métrica.',
            style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    ),
  );
}

class FlFusionPlot extends StatelessWidget {
  const FlFusionPlot({
    super.key,
    required this.spec,
    required this.data,
    this.highlightedCode,
  });

  final FusionChartSpec spec;
  final CreativeChartData data;
  final String? highlightedCode;
  static const _grid = Color(0xFFDDE7E3);
  static const minY = -8.0;
  static const maxY = 108.0;
  static const polarLimit = 128.0;

  List<FusionLayerData> get layers => [
    for (final layer in spec.layers) FusionLayerData(layer, data),
  ];

  double _alpha(int country) =>
      highlightedCode == null ||
          highlightedCode == data.points[country].countryCode
      ? 1
      : 0.18;
  Color _color(int layer, int country) =>
      FusionPalette.at(layer).withValues(alpha: _alpha(country));

  @override
  Widget build(BuildContext context) {
    if (!data.valid) {
      return const Center(child: Text('Se requieren siete países diferentes.'));
    }
    return spec.projection == FusionProjection.polar ? _polar() : _cartesian();
  }

  Widget _line(
    List<LineChartBarData> lines, {
    List<BetweenBarsData> between = const [],
    List<HorizontalLine> references = const [],
    bool polar = false,
  }) => LineChart(
    LineChartData(
      minX: polar ? -polarLimit : -0.5,
      maxX: polar ? polarLimit : 6.5,
      minY: polar ? -polarLimit : minY,
      maxY: polar ? polarLimit : maxY,
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: lines,
      betweenBarsData: between,
      extraLinesData: ExtraLinesData(horizontalLines: references),
    ),
    duration: Duration.zero,
  );

  LineChartBarData _series(
    List<FlSpot> spots,
    Color color, {
    double width = 2,
    bool dots = false,
    bool area = false,
    List<int>? dash,
  }) => LineChartBarData(
    spots: spots,
    color: color,
    barWidth: width,
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
    belowBarData: BarAreaData(
      show: area,
      color: color.withValues(alpha: 0.13),
      cutOffY: 0,
      applyCutOffY: true,
    ),
  );

  Widget _scatter(List<ScatterSpot> spots, {bool polar = false}) =>
      ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
          minX: polar ? -polarLimit : -0.5,
          maxX: polar ? polarLimit : 6.5,
          minY: polar ? -polarLimit : minY,
          maxY: polar ? polarLimit : maxY,
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          scatterTouchData: ScatterTouchData(enabled: false),
        ),
        duration: Duration.zero,
      );

  Widget _cartesian() {
    final computed = layers;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 34,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      for (final value in [0, 25, 50, 75, 100])
                        Positioned(
                          top:
                              constraints.maxHeight *
                                  (maxY - value) /
                                  (maxY - minY) -
                              7,
                          right: 5,
                          child: Text(
                            '$value',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _line(
                        [],
                        references: [
                          for (final value in [0.0, 25.0, 50.0, 75.0, 100.0])
                            HorizontalLine(
                              y: value,
                              color: _grid,
                              strokeWidth: 1,
                            ),
                        ],
                      ),
                      for (var i = 0; i < computed.length; i++)
                        if (computed[i].layer.mark == FusionMark.area ||
                            computed[i].layer.mark == FusionMark.band)
                          _background(computed[i], i),
                      if (computed.any((item) => _isBar(item.layer.mark)))
                        _bars(computed),
                      for (var i = 0; i < computed.length; i++)
                        if ([
                          FusionMark.line,
                          FusionMark.lollipop,
                          FusionMark.dumbbell,
                        ].contains(computed[i].layer.mark))
                          _foreground(computed[i], i),
                      for (var i = 0; i < computed.length; i++)
                        if (computed[i].layer.mark == FusionMark.dots ||
                            computed[i].layer.mark == FusionMark.bubble)
                          _points(computed[i], i),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.only(left: 34),
          child: Row(
            children: [
              for (final point in data.points)
                Expanded(
                  child: Text(
                    point.axisLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: highlightedCode == point.countryCode
                          ? FontWeight.w900
                          : FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  List<FlSpot> _spots(List<double> values) => [
    for (var i = 0; i < 7; i++) FlSpot(i.toDouble(), values[i]),
  ];

  Widget _background(FusionLayerData item, int index) {
    final color = FusionPalette.at(index);
    if (item.layer.mark == FusionMark.area) {
      return _line([
        _series(_spots(item.values), color, area: true, width: 1.5),
      ]);
    }
    return _line(
      [
        _series(
          _spots([
            for (var i = 0; i < 7; i++)
              math.min(item.values[i], item.secondary[i]),
          ]),
          color,
          width: 1,
          dash: [3, 3],
        ),
        _series(
          _spots([
            for (var i = 0; i < 7; i++)
              math.max(item.values[i], item.secondary[i]),
          ]),
          color,
          width: 1,
          dash: [3, 3],
        ),
      ],
      between: [
        BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          color: color.withValues(alpha: 0.13),
        ),
      ],
    );
  }

  bool _isBar(FusionMark mark) => [
    FusionMark.columns,
    FusionMark.waterfall,
    FusionMark.bullet,
  ].contains(mark);

  Widget _bars(List<FusionLayerData> computed) {
    final indexes = [
      for (var i = 0; i < computed.length; i++)
        if (_isBar(computed[i].layer.mark)) i,
    ];
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: minY,
        maxY: maxY,
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(enabled: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            for (final index in indexes)
              if (computed[index].layer.mark == FusionMark.bullet)
                HorizontalLine(
                  y: computed[index].reference,
                  color: FusionPalette.at(index),
                  strokeWidth: 1.5,
                  dashArray: [5, 4],
                ),
          ],
        ),
        barGroups: [
          for (var country = 0; country < 7; country++)
            BarChartGroupData(
              x: country,
              barsSpace: 2,
              barRods: [
                for (final index in indexes)
                  BarChartRodData(
                    fromY: computed[index].bases[country],
                    toY: computed[index].values[country],
                    width: indexes.length == 1 ? 15 : 8,
                    borderRadius: BorderRadius.circular(2),
                    color: _color(
                      index,
                      country,
                    ).withValues(alpha: _alpha(country) * 0.65),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: computed[index].layer.mark == FusionMark.bullet,
                      toY: computed[index].hasTotal ? 100 : 0,
                      color: FusionPalette.at(index).withValues(alpha: 0.06),
                    ),
                  ),
              ],
            ),
        ],
      ),
      duration: Duration.zero,
    );
  }

  Widget _foreground(FusionLayerData item, int index) {
    if (item.layer.mark == FusionMark.line) {
      return _line([
        _series(
          _spots(item.values),
          FusionPalette.at(index),
          width: 2.5,
          dots: true,
        ),
      ]);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _line([
          for (var i = 0; i < 7; i++)
            _series(
              [
                FlSpot(
                  i.toDouble(),
                  item.layer.mark == FusionMark.lollipop
                      ? 0
                      : item.secondary[i],
                ),
                FlSpot(i.toDouble(), item.values[i]),
              ],
              _color(index, i),
              width: item.layer.mark == FusionMark.dumbbell ? 3 : 1.5,
            ),
        ]),
        _scatter([
          for (var i = 0; i < 7; i++)
            ScatterSpot(
              i.toDouble(),
              item.values[i],
              dotPainter: FlDotCirclePainter(
                radius: 4,
                color: _color(index, i),
                strokeWidth: 1,
                strokeColor: Colors.white,
              ),
            ),
          if (item.layer.mark == FusionMark.dumbbell)
            for (var i = 0; i < 7; i++)
              ScatterSpot(
                i.toDouble(),
                item.secondary[i],
                dotPainter: FlDotSquarePainter(
                  size: 7,
                  color: _color(index, i),
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
              ),
        ]),
      ],
    );
  }

  Widget _points(FusionLayerData item, int index) => _scatter([
    for (var i = 0; i < 7; i++)
      ScatterSpot(
        i.toDouble(),
        item.values[i],
        dotPainter: FlDotCirclePainter(
          radius: item.layer.mark == FusionMark.bubble
              ? item.bubbleRadius(i)
              : 4,
          color: _color(index, i).withValues(
            alpha: _alpha(i) * (item.layer.mark == FusionMark.bubble ? 0.4 : 1),
          ),
          strokeWidth: 1.5,
          strokeColor: _color(index, i),
        ),
      ),
  ]);

  FlSpot _polarPoint(int country, double radius) {
    final angle = -math.pi / 2 + country * 2 * math.pi / 7;
    return FlSpot(radius * math.cos(angle), -radius * math.sin(angle));
  }

  Widget _polar() {
    final computed = layers;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final unit = size / (2 * polarLimit);
        return Center(
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _line([
                  for (final radius in [25.0, 50.0, 75.0, 100.0])
                    _series(
                      [
                        for (var i = 0; i <= 64; i++)
                          FlSpot(
                            radius * math.cos(i * 2 * math.pi / 64),
                            radius * math.sin(i * 2 * math.pi / 64),
                          ),
                      ],
                      _grid,
                      width: 1,
                    ),
                  for (var i = 0; i < 7; i++)
                    _series(
                      [const FlSpot(0, 0), _polarPoint(i, 100)],
                      _grid,
                      width: 1,
                    ),
                ], polar: true),
                for (var layer = 0; layer < computed.length; layer++)
                  if (computed[layer].layer.mark == FusionMark.rose)
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 0,
                        sectionsSpace: 0,
                        startDegreeOffset: -90 - 180 / 7,
                        pieTouchData: PieTouchData(enabled: false),
                        sections: [
                          for (var country = 0; country < 7; country++)
                            PieChartSectionData(
                              value: 1,
                              radius:
                                  unit * computed[layer].roseRadius(country),
                              showTitle: false,
                              color: _color(
                                layer,
                                country,
                              ).withValues(alpha: _alpha(country) * 0.24),
                              borderSide: BorderSide(
                                color: _color(
                                  layer,
                                  country,
                                ).withValues(alpha: _alpha(country) * 0.65),
                                width: 1,
                              ),
                            ),
                        ],
                      ),
                      duration: Duration.zero,
                    ),
                for (var layer = 0; layer < computed.length; layer++)
                  if (computed[layer].layer.mark == FusionMark.lollipop)
                    _line([
                      for (var country = 0; country < 7; country++)
                        _series(
                          [
                            const FlSpot(0, 0),
                            _polarPoint(
                              country,
                              computed[layer].values[country],
                            ),
                          ],
                          _color(layer, country),
                          width: 1.5,
                          dots: true,
                        ),
                    ], polar: true),
                for (var layer = 0; layer < computed.length; layer++)
                  if (computed[layer].layer.mark == FusionMark.radar)
                    _line([
                      _series(
                        [
                          for (var country = 0; country <= 7; country++)
                            _polarPoint(
                              country % 7,
                              computed[layer].values[country % 7],
                            ),
                        ],
                        FusionPalette.at(layer),
                        width: 2.5,
                        dots: true,
                      ),
                    ], polar: true),
                for (var layer = 0; layer < computed.length; layer++)
                  if (computed[layer].layer.mark == FusionMark.bubble)
                    _scatter([
                      for (var country = 0; country < 7; country++)
                        ScatterSpot(
                          _polarPoint(
                            country,
                            computed[layer].values[country],
                          ).x,
                          _polarPoint(
                            country,
                            computed[layer].values[country],
                          ).y,
                          dotPainter: FlDotCirclePainter(
                            radius: computed[layer].bubbleRadius(
                              country,
                              maximum: 10,
                            ),
                            color: _color(
                              layer,
                              country,
                            ).withValues(alpha: _alpha(country) * 0.35),
                            strokeWidth: 1.5,
                            strokeColor: _color(layer, country),
                          ),
                        ),
                    ], polar: true),
                for (var country = 0; country < 7; country++)
                  Positioned(
                    left: size / 2 + _polarPoint(country, 116).x * unit - 15,
                    top: size / 2 - _polarPoint(country, 116).y * unit - 7,
                    width: 30,
                    child: Text(
                      data.points[country].axisLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            highlightedCode == data.points[country].countryCode
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                for (final radius in [25.0, 50.0, 75.0, 100.0])
                  Positioned(
                    left: size / 2 + radius * unit - 7,
                    top: size / 2 + 3,
                    child: Text(
                      '${radius.toInt()}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
