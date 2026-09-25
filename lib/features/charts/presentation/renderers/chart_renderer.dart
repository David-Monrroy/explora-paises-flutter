import 'package:flutter/material.dart';

import '../../data/chart_data_transformer.dart';
import '../../domain/chart_definition.dart';
import '../../../../data/models/country.dart';
import 'fl_chart_renderer.dart';
import 'graphic_renderer.dart';
import 'maintained_renderer.dart';
import 'syncfusion_renderer.dart';

class ChartRenderer extends StatelessWidget {
  const ChartRenderer({
    super.key,
    required this.definition,
    required this.countries,
  });

  final ChartDefinition definition;
  final List<Country> countries;

  @override
  Widget build(BuildContext context) {
    final points = ChartDataTransformer.transform(definition, countries);
    if (points.isEmpty) {
      return const Center(
        child: Text('No hay datos suficientes para esta gráfica.'),
      );
    }
    return switch (definition.library) {
      ChartLibrary.flChart => FlChartRenderer(
        definition: definition,
        points: points,
      ),
      ChartLibrary.syncfusion => SyncfusionRenderer(
        definition: definition,
        points: points,
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
