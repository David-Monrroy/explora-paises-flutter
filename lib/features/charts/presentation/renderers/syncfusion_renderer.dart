import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartPoint;

import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../chart_palette.dart';

class SyncfusionRenderer extends StatelessWidget {
  const SyncfusionRenderer({
    super.key,
    required this.definition,
    required this.points,
  });

  final ChartDefinition definition;
  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final advanced = definition.level == ChartLevel.advanced;
    if (definition.kind == ChartKind.pie ||
        definition.kind == ChartKind.donut) {
      return SfCircularChart(
        tooltipBehavior: TooltipBehavior(enable: advanced),
        legend: const Legend(isVisible: false),
        series: <CircularSeries<ChartPoint, String>>[
          if (definition.kind == ChartKind.pie)
            PieSeries<ChartPoint, String>(
              dataSource: points,
              xValueMapper: (point, _) => point.axisLabel,
              yValueMapper: (point, _) => point.value,
              pointColorMapper: (_, index) => ChartPalette.at(index),
              dataLabelMapper: (point, _) => point.axisLabel,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          else
            DoughnutSeries<ChartPoint, String>(
              dataSource: points,
              xValueMapper: (point, _) => point.axisLabel,
              yValueMapper: (point, _) => point.value,
              pointColorMapper: (_, index) => ChartPalette.at(index),
              dataLabelMapper: (point, _) => point.axisLabel,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
        ],
      );
    }

    if (definition.kind == ChartKind.scatter) {
      return SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: advanced),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: advanced,
          enablePanning: advanced,
        ),
        series: <CartesianSeries<ChartPoint, double>>[
          ScatterSeries<ChartPoint, double>(
            dataSource: points,
            xValueMapper: (point, _) => point.secondaryValue,
            yValueMapper: (point, _) => point.value,
            pointColorMapper: (_, index) => ChartPalette.at(index),
            dataLabelMapper: (point, _) => point.axisLabel,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      );
    }

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(labelRotation: -45),
      tooltipBehavior: TooltipBehavior(enable: advanced),
      trackballBehavior: TrackballBehavior(
        enable: advanced,
        activationMode: ActivationMode.singleTap,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: advanced,
        enablePanning: advanced,
      ),
      series: <CartesianSeries<ChartPoint, String>>[
        switch (definition.kind) {
          ChartKind.bar => ColumnSeries<ChartPoint, String>(
            dataSource: points,
            xValueMapper: (point, _) => point.axisLabel,
            yValueMapper: (point, _) => point.value,
            pointColorMapper: (_, index) => ChartPalette.at(index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          ChartKind.area => AreaSeries<ChartPoint, String>(
            dataSource: points,
            xValueMapper: (point, _) => point.axisLabel,
            yValueMapper: (point, _) => point.value,
          ),
          _ => LineSeries<ChartPoint, String>(
            dataSource: points,
            xValueMapper: (point, _) => point.axisLabel,
            yValueMapper: (point, _) => point.value,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        },
      ],
    );
  }
}
