import 'package:flutter/material.dart';

import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import 'fl_chart_renderer.dart';
import 'graphic_renderer.dart';
import 'maintained_renderer.dart';
import 'syncfusion_renderer.dart';

class ChartRenderer extends StatelessWidget {
  const ChartRenderer({
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
    if (points.isEmpty) {
      return const Center(
        child: Text('No hay datos suficientes para esta gráfica.'),
      );
    }
    return switch (definition.library) {
      ChartLibrary.flChart => FlChartRenderer(
        definition: definition,
        points: points,
        highlightedCode: highlightedCode,
      ),
      ChartLibrary.syncfusion => SyncfusionRenderer(
        definition: definition,
        points: points,
        highlightedCode: highlightedCode,
      ),
      ChartLibrary.maintained => MaintainedRenderer(
        definition: definition,
        points: points,
      ),
      ChartLibrary.graphic => GraphicRenderer(
        definition: definition,
        points: points,
      ),
    };
  }
}
