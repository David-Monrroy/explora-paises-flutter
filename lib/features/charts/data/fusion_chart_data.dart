import 'dart:math' as math;

import '../domain/fusion_chart.dart';
import 'creative_chart_data.dart';

class FusionLayerData {
  FusionLayerData(this.layer, CreativeChartData source) {
    values = [for (var i = 0; i < 7; i++) source.relative(i, layer.metric)];
    secondary = [
      for (var i = 0; i < 7; i++)
        layer.secondaryMetric == null
            ? 0.0
            : source.relative(i, layer.secondaryMetric!),
    ];
    bases = List.filled(7, 0.0);
    reference = source.maximum(layer.metric) == 0
        ? 0
        : source.mean(layer.metric) / source.maximum(layer.metric) * 100;
    hasTotal = source.total(layer.metric) > 0;
    if (layer.mark == FusionMark.waterfall) {
      var running = 0.0;
      for (var i = 0; i < 7; i++) {
        bases[i] = running;
        running += source.share(i, layer.metric);
        values[i] = running;
      }
    }
  }

  final FusionLayer layer;
  late final List<double> values;
  late final List<double> secondary;
  late final List<double> bases;
  late final double reference;
  late final bool hasTotal;

  double bubbleRadius(int country, {double maximum = 13}) =>
      maximum * math.sqrt(secondary[country] / 100);
  double roseRadius(int country) => 100 * math.sqrt(values[country] / 100);
}
