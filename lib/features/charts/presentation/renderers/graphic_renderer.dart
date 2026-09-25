import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../../domain/chart_definition.dart';
import '../../domain/chart_point.dart';
import '../chart_palette.dart';

class GraphicRenderer extends StatelessWidget {
  const GraphicRenderer({
    super.key,
    required this.definition,
    required this.points,
  });

  final ChartDefinition definition;
  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final data = [
      for (final point in points)
        {
          'label': point.axisLabel,
          'value': point.value,
          'secondary': point.secondaryValue,
        },
    ];
    final advanced = definition.level == ChartLevel.advanced;
    final circular =
        definition.kind == ChartKind.pie || definition.kind == ChartKind.donut;

    return Chart(
      data: data,
      variables: {
        'label': Variable(
          accessor: (Map<String, dynamic> item) => item['label'] as String,
        ),
        'value': Variable(
          accessor: (Map<String, dynamic> item) => item['value'] as num,
        ),
        'secondary': Variable(
          accessor: (Map<String, dynamic> item) => item['secondary'] as num,
        ),
      },
      transforms: circular
          ? [Proportion(variable: 'value', as: 'percent')]
          : const [],
      marks: circular
          ? [
              IntervalMark(
                position: Varset('percent') / Varset('label'),
                color: ColorEncode(
                  variable: 'label',
                  values: ChartPalette.colors,
                ),
                modifiers: [StackModifier()],
              ),
            ]
          : [
              switch (definition.kind) {
                ChartKind.bar => IntervalMark(
                  color: ColorEncode(
                    variable: 'label',
                    values: ChartPalette.colors,
                  ),
                ),
                ChartKind.area => AreaMark(
                  shape: ShapeEncode(value: BasicAreaShape(smooth: advanced)),
                  color: ColorEncode(value: const Color(0x660B7D6B)),
                ),
                ChartKind.scatter => PointMark(
                  position: Varset('secondary') * Varset('value'),
                  color: ColorEncode(
                    variable: 'label',
                    values: ChartPalette.colors,
                  ),
                  size: SizeEncode(value: advanced ? 10 : 7),
                ),
                _ => LineMark(
                  shape: ShapeEncode(value: BasicLineShape(smooth: advanced)),
                  size: SizeEncode(value: 3),
                ),
              },
            ],
      axes: circular
          ? const []
          : [Defaults.horizontalAxis, Defaults.verticalAxis],
      coord: circular
          ? PolarCoord(
              transposed: true,
              dimCount: 1,
              startRadius: definition.kind == ChartKind.donut ? 0.35 : 0,
            )
          : RectCoord(),
      selections: advanced
          ? {
              'tap': PointSelection(
                on: {GestureType.tap, GestureType.hover},
                dim: Dim.x,
              ),
            }
          : const {},
      tooltip: advanced ? TooltipGuide(variables: ['label', 'value']) : null,
      crosshair: advanced && !circular ? CrosshairGuide() : null,
    );
  }
}
