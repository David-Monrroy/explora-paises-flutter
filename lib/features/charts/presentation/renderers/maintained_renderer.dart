import 'package:charts_flutter_maintained/charts_flutter_maintained.dart'
    as charts;
import 'package:flutter/material.dart';

import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';

class MaintainedRenderer extends StatelessWidget {
  const MaintainedRenderer({
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
      final series = [
        charts.Series<ChartPoint, String>(
          id: definition.id,
          domainFn: (point, _) => point.label,
          measureFn: (point, _) => point.value,
          data: points,
        ),
      ];
      return charts.PieChart<String>(
        series,
        animate: true,
        defaultRenderer: charts.ArcRendererConfig(
          arcWidth: definition.kind == ChartKind.donut ? 45 : null,
          arcRendererDecorators: [charts.ArcLabelDecorator()],
        ),
        behaviors: _behaviors<String>(advanced),
      );
    }

    if (definition.kind == ChartKind.scatter) {
      final series = [
        charts.Series<ChartPoint, num>(
          id: definition.id,
          domainFn: (point, _) => point.secondaryValue,
          measureFn: (point, _) => point.value,
          radiusPxFn: (point, _) => advanced ? 7 : 5,
          data: points,
        ),
      ];
      return charts.ScatterPlotChart(
        series,
        animate: true,
        behaviors: _behaviors<num>(advanced),
      );
    }

    if (definition.kind == ChartKind.bar) {
      final series = [
        charts.Series<ChartPoint, String>(
          id: definition.id,
          domainFn: (point, _) => point.label,
          measureFn: (point, _) => point.value,
          data: points,
        ),
      ];
      return charts.BarChart(
        series,
        animate: true,
        behaviors: _behaviors<String>(advanced),
      );
    }

    final series = [
      charts.Series<ChartPoint, num>(
        id: definition.id,
        domainFn: (_, index) => index ?? 0,
        measureFn: (point, _) => point.value,
        data: points,
      ),
    ];
    return charts.LineChart(
      series,
      animate: true,
      defaultRenderer: charts.LineRendererConfig(
        includeArea: definition.kind == ChartKind.area,
        includePoints: true,
      ),
      behaviors: _behaviors<num>(advanced),
    );
  }

  List<charts.ChartBehavior<T>> _behaviors<T>(bool advanced) {
    if (!advanced) return <charts.ChartBehavior<T>>[];
    return <charts.ChartBehavior<T>>[
      charts.SeriesLegend<T>(position: charts.BehaviorPosition.bottom),
      charts.SelectNearest<T>(eventTrigger: charts.SelectionTrigger.tapAndDrag),
    ];
  }
}
