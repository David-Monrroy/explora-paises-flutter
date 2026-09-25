import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';

class FlChartRenderer extends StatelessWidget {
  const FlChartRenderer({
    super.key,
    required this.definition,
    required this.points,
  });

  final ChartDefinition definition;
  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return switch (definition.kind) {
      ChartKind.bar => BarChart(_barData()),
      ChartKind.line => LineChart(_lineData(false)),
      ChartKind.area => LineChart(_lineData(true)),
      ChartKind.pie => PieChart(_pieData(false)),
      ChartKind.donut => PieChart(_pieData(true)),
      ChartKind.scatter => ScatterChart(_scatterData()),
    };
  }

  BarChartData _barData() => BarChartData(
    alignment: BarChartAlignment.spaceAround,
    barTouchData: BarTouchData(
      enabled: definition.level == ChartLevel.advanced,
    ),
    titlesData: const FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    borderData: FlBorderData(show: false),
    barGroups: [
      for (var i = 0; i < points.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: points[i].value,
              color: _colors[i % _colors.length],
              width: 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
    ],
  );

  LineChartData _lineData(bool area) => LineChartData(
    gridData: const FlGridData(show: true),
    titlesData: const FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    borderData: FlBorderData(show: false),
    lineTouchData: LineTouchData(
      enabled: definition.level == ChartLevel.advanced,
    ),
    lineBarsData: [
      LineChartBarData(
        spots: [
          for (var i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), points[i].value),
        ],
        isCurved: definition.level == ChartLevel.advanced,
        color: const Color(0xFF0B7D6B),
        barWidth: 4,
        dotData: FlDotData(show: !area),
        belowBarData: BarAreaData(show: area, color: const Color(0x440B7D6B)),
      ),
    ],
  );

  PieChartData _pieData(bool donut) => PieChartData(
    centerSpaceRadius: donut ? 48 : 0,
    sectionsSpace: 3,
    pieTouchData: PieTouchData(
      enabled: definition.level == ChartLevel.advanced,
    ),
    sections: [
      for (var i = 0; i < points.length; i++)
        PieChartSectionData(
          value: points[i].value,
          title: _short(points[i].label),
          radius: donut ? 62 : 92,
          color: _colors[i % _colors.length],
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
    ],
  );

  ScatterChartData _scatterData() => ScatterChartData(
    scatterTouchData: ScatterTouchData(
      enabled: definition.level == ChartLevel.advanced,
    ),
    titlesData: const FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    borderData: FlBorderData(show: false),
    scatterSpots: [
      for (var i = 0; i < points.length; i++)
        ScatterSpot(
          points[i].secondaryValue,
          points[i].value,
          dotPainter: FlDotCirclePainter(
            radius: definition.level == ChartLevel.advanced ? 8 : 6,
            color: _colors[i % _colors.length],
          ),
        ),
    ],
  );

  static String _short(String value) =>
      value.length <= 8 ? value : '${value.substring(0, 7)}…';

  static const _colors = [
    Color(0xFF0B7D6B),
    Color(0xFF38A3A5),
    Color(0xFFFFB703),
    Color(0xFFEF6F6C),
    Color(0xFF6C63FF),
    Color(0xFF2D6A4F),
    Color(0xFFF4A261),
    Color(0xFF577590),
    Color(0xFF9B5DE5),
  ];
}
