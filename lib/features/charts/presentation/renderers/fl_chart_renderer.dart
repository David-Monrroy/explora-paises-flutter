import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../chart_palette.dart';

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
    titlesData: _titles(),
    borderData: FlBorderData(show: false),
    barGroups: [
      for (var i = 0; i < points.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: points[i].value,
              color: ChartPalette.at(i),
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
    titlesData: _titles(),
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
          title: points[i].countryCode ?? _short(points[i].label),
          radius: donut ? 62 : 92,
          color: ChartPalette.at(i),
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
    titlesData: FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              _shortValue(value),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: _verticalTitle,
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
    scatterSpots: [
      for (var i = 0; i < points.length; i++)
        ScatterSpot(
          points[i].secondaryValue,
          points[i].value,
          dotPainter: FlDotCirclePainter(
            radius: definition.level == ChartLevel.advanced ? 8 : 6,
            color: ChartPalette.at(i),
          ),
        ),
    ],
  );

  static String _short(String value) =>
      value.length <= 8 ? value : '${value.substring(0, 7)}…';

  FlTitlesData _titles() => FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 48,
        getTitlesWidget: _verticalTitle,
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if (value != index || index < 0 || index >= points.length) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            child: Text(
              points[index].axisLabel,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    ),
  );

  Widget _verticalTitle(double value, TitleMeta meta) => SideTitleWidget(
    meta: meta,
    child: Text(_shortValue(value), style: const TextStyle(fontSize: 10)),
  );

  static String _shortValue(double value) {
    final absolute = value.abs();
    if (absolute >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (absolute >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (absolute >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(absolute < 10 ? 1 : 0);
  }
}
