import 'dart:math' as math;

import 'package:charts_flutter_maintained/charts_flutter_maintained.dart'
    as charts;
import 'package:flutter/material.dart' show Color, Colors;

import '../../data/maintained_chart_data.dart';
import '../../domain/chart_metric.dart';
import '../../domain/maintained_chart_spec.dart';
import '../chart_palette.dart';
import 'maintained_palette.dart';

/// Supported native renderer extension: all shapes share the same ChartCanvas.
class MaintainedSceneDecorator extends charts.PointRendererDecorator<num> {
  const MaintainedSceneDecorator(this.spec, this.data, this.highlightedCode);
  final MaintainedChartSpec spec;
  final MaintainedChartData data;
  final String? highlightedCode;
  @override
  bool get renderAbove => true;

  @override
  void decorate(
    charts.PointRendererElement<num> element,
    charts.ChartCanvas canvas,
    charts.GraphicsFactory factory, {
    required math.Rectangle drawBounds,
    required double animationPercent,
    bool rtl = false,
  }) {
    // Paint once per native canvas frame, not once per country.
    if (element.index != 0 || drawBounds.width <= 0 || drawBounds.height <= 0) {
      return;
    }
    _Scene(spec, data, highlightedCode, canvas, factory, drawBounds).paint();
  }
}

class _Scene {
  _Scene(
    this.spec,
    this.data,
    this.focus,
    this.canvas,
    this.factory,
    this.bounds,
  );
  final MaintainedChartSpec spec;
  final MaintainedChartData data;
  final String? focus;
  final charts.ChartCanvas canvas;
  final charts.GraphicsFactory factory;
  final math.Rectangle bounds;
  static const ink = Color(0xFF243A42);
  static const grid = Color(0xFFE0E8E9);
  double get scale => math.min(bounds.width, bounds.height).toDouble() / 100;
  math.Point<double> p(double x, double y) => math.Point(
    bounds.left + bounds.width * x / 100,
    bounds.top + bounds.height * y / 100,
  );
  math.Point<double> square(double x, double y) => math.Point(
    bounds.left + bounds.width / 2 + (x - 50) * scale,
    bounds.top + bounds.height / 2 + (y - 50) * scale,
  );
  charts.Color c(Color color) => charts.Color(
    r: (color.r * 255).round(),
    g: (color.g * 255).round(),
    b: (color.b * 255).round(),
    a: (color.a * 255).round(),
  );
  Color country(int i) => ChartPalette.at(i).withValues(
    alpha: focus == null || focus == data.source.points[i].countryCode
        ? 1
        : 0.2,
  );
  Color layer(int i, int countryIndex) => spec.usesLayerColors
      ? MaintainedPalette.at(i).withValues(
          alpha:
              focus == null ||
                  focus == data.source.points[countryIndex].countryCode
              ? 1
              : 0.18,
        )
      : country(countryIndex);
  String code(int i) => data.source.points[i].axisLabel;
  void line(List<math.Point> points, Color color, {double width = 1.5}) =>
      canvas.drawLine(points: points, stroke: c(color), strokeWidthPx: width);
  void polygon(
    List<math.Point> points,
    Color color, {
    Color? stroke,
    double width = 1,
  }) => canvas.drawPolygon(
    points: points,
    fill: c(color),
    stroke: stroke == null ? null : c(stroke),
    strokeWidthPx: width,
  );
  void rect(
    double x,
    double y,
    double width,
    double height,
    Color color, {
    Color? stroke,
  }) {
    final origin = p(x, y);
    canvas.drawRect(
      math.Rectangle(
        origin.x,
        origin.y,
        bounds.width * width / 100,
        bounds.height * height / 100,
      ),
      fill: c(color),
      stroke: stroke == null ? null : c(stroke),
      strokeWidthPx: 1,
    );
  }

  void dot(
    math.Point point,
    double radius,
    Color color, {
    Color? stroke,
    double width = 1,
  }) => canvas.drawPoint(
    point: point,
    radius: radius,
    fill: c(color),
    stroke: stroke == null ? null : c(stroke),
    strokeWidthPx: width,
  );
  void text(
    String label,
    math.Point point, {
    Color color = ink,
    int size = 10,
    bool center = true,
  }) {
    final element = factory.createTextElement(label)
      ..textStyle = (factory.createTextPaint()
        ..color = c(color)
        ..fontSize = size
        ..fontFamily = 'Segoe UI'
        ..fontWeight = '600');
    final width = element.measurement.horizontalSliceWidth;
    final height = element.measurement.verticalSliceWidth;
    canvas.drawText(
      element,
      (point.x - (center ? width / 2 : 0))
          .clamp(bounds.left, math.max(bounds.left, bounds.right - width))
          .round(),
      (point.y - height / 2)
          .clamp(bounds.top, math.max(bounds.top, bounds.bottom - height))
          .round(),
    );
  }

  void sector(
    math.Point center,
    double radius,
    double inner,
    double start,
    double end,
    Color color,
  ) {
    if (end <= start) return;
    canvas.drawCircleSector(
      center,
      radius,
      inner,
      start,
      end,
      fill: c(color),
      stroke: c(Colors.white),
      strokeWidthPx: 1.5,
    );
  }

  double index(int i, ChartMetric metric) => data.source.relative(i, metric);
  double x(double index) => 17 + index * 0.76;
  double row(int i) => 12 + i * 12;

  void paint() {
    if (spec.isProfile) {
      profile();
      return;
    }
    switch (spec.visuals.single) {
      case MaintainedVisual.treemap:
        treemap();
      case MaintainedVisual.sunburst:
        sunburst();
      case MaintainedVisual.sankey:
        sankey();
      case MaintainedVisual.chord:
        chord();
      case MaintainedVisual.ternary:
        ternary();
      case MaintainedVisual.marimekko:
        marimekko();
      case MaintainedVisual.icicle:
        icicle();
      case MaintainedVisual.circlePacking:
        packing();
      case MaintainedVisual.pictogram:
        pictogram();
      case MaintainedVisual.horizon:
        horizon();
      case MaintainedVisual.beeswarm:
        beeswarm();
      case MaintainedVisual.arcNetwork:
        arcs();
      default:
        break;
    }
  }

  void profile() {
    for (final tick in [0, 25, 50, 75, 100]) {
      line(
        [p(x(tick.toDouble()), 6), p(x(tick.toDouble()), 90)],
        grid,
        width: 1,
      );
      text('$tick', p(x(tick.toDouble()), 94));
    }
    for (var i = 0; i < 7; i++) {
      text(code(i), p(8, row(i)), color: focus == code(i) ? country(i) : ink);
      line([p(x(0), row(i)), p(x(100), row(i))], grid, width: 0.6);
    }
    final order = List.generate(spec.visuals.length, (i) => i)
      ..sort(
        (a, b) =>
            priority(spec.visuals[a]).compareTo(priority(spec.visuals[b])),
      );
    final peak = data.kernelMaximum;
    for (final l in order) {
      final visual = spec.visuals[l];
      for (var i = 0; i < 7; i++) {
        final y = row(i);
        final color = layer(l, i);
        switch (visual) {
          case MaintainedVisual.violin || MaintainedVisual.ridgeline:
            final upper = <math.Point>[];
            final lower = <math.Point>[];
            for (var t = 0.0; t <= 100; t += 2) {
              final height = peak == 0 ? 0.0 : data.kernel(i, t) / peak * 4.6;
              upper.add(p(x(t), y - height));
              lower.add(
                p(x(t), visual == MaintainedVisual.violin ? y + height : y),
              );
            }
            polygon(
              [...upper, ...lower.reversed],
              color.withValues(alpha: color.a * 0.24),
              stroke: color,
            );
          case MaintainedVisual.rug:
            final values = data.profile(i);
            for (var k = 0; k < values.length; k++) {
              final offset = (k - 3) * 0.7;
              line(
                [
                  p(x(values[k]), y + offset - 0.5),
                  p(x(values[k]), y + offset + 0.5),
                ],
                color,
                width: 2.2,
              );
            }
          case MaintainedVisual.boxPlot:
            final low = data.quantile(i, 0), q1 = data.quantile(i, 0.25);
            final mid = data.quantile(i, 0.5),
                q3 = data.quantile(i, 0.75),
                high = data.quantile(i, 1);
            final at = y - 1.7;
            line([p(x(low), at), p(x(high), at)], color, width: 1.6);
            for (final endpoint in [low, high]) {
              line([p(x(endpoint), at - 1), p(x(endpoint), at + 1)], color);
            }
            rect(
              x(q1),
              at - 1.4,
              (q3 - q1) * 0.76,
              2.8,
              color.withValues(alpha: color.a * 0.12),
              stroke: color,
            );
            line([p(x(mid), at - 1.4), p(x(mid), at + 1.4)], color, width: 2.4);
          case MaintainedVisual.bullet:
            final value = index(i, ChartMetric.languages);
            final mean =
                List.generate(
                  7,
                  (i) => index(i, ChartMetric.languages),
                ).reduce((a, b) => a + b) /
                7;
            rect(
              x(0),
              y + 1.8,
              value * 0.76,
              1.2,
              color.withValues(alpha: color.a * 0.65),
            );
            line([p(x(mean), y + 0.6), p(x(mean), y + 4)], color, width: 2.2);
          case MaintainedVisual.lollipop:
            final end = x(index(i, ChartMetric.population));
            line([p(x(0), y + 0.7), p(end, y + 0.7)], color, width: 2);
            rect(end - 0.8, y - 0.1, 1.6, 1.6, color);
          case MaintainedVisual.dumbbell:
            final pop = x(index(i, ChartMetric.population)),
                area = x(index(i, ChartMetric.area));
            line([p(pop, y - 0.4), p(area, y - 0.4)], color, width: 2.4);
            dot(p(pop, y - 0.4), 3.8, Colors.white, stroke: color, width: 2);
            polygon([
              p(area, y - 1.8),
              p(area + 1.2, y - 0.4),
              p(area, y + 1),
              p(area - 1.2, y - 0.4),
            ], color);
          case MaintainedVisual.dots:
            dot(
              p(x(index(i, ChartMetric.density)), y),
              4.2,
              color,
              stroke: Colors.white,
              width: 1.2,
            );
          default:
            break;
        }
      }
    }
  }

  int priority(MaintainedVisual visual) => switch (visual) {
    MaintainedVisual.violin || MaintainedVisual.ridgeline => 0,
    MaintainedVisual.bullet => 1,
    MaintainedVisual.boxPlot => 2,
    MaintainedVisual.lollipop || MaintainedVisual.dumbbell => 3,
    MaintainedVisual.rug => 4,
    _ => 5,
  };

  void treemap() {
    for (final item in data.treemap) {
      final b = item.bounds;
      rect(
        5 + b.left * 0.9,
        5 + b.top * 0.9,
        b.width * 0.9,
        b.height * 0.9,
        country(item.index),
        stroke: Colors.white,
      );
      if (b.width * bounds.width / 100 > 28 &&
          b.height * bounds.height / 100 > 18) {
        text(
          code(item.index),
          p(5 + (b.left + b.width / 2) * 0.9, 5 + (b.top + b.height / 2) * 0.9),
          color: Colors.white,
        );
      }
    }
  }

  void sunburst() {
    var angle = -math.pi / 2;
    final center = square(50, 50), r = scale * 38;
    final groups = data.regions;
    for (final group in groups) {
      final span =
          data.groupShare(group, ChartMetric.population) / 100 * 2 * math.pi;
      if (span == 0) continue;
      sector(
        center,
        r * 0.61,
        r * 0.29,
        angle,
        angle + span,
        ChartPalette.at(groups.indexOf(group)).withValues(alpha: 0.45),
      );
      for (final i in group.countries) {
        final child =
            data.source.share(i, ChartMetric.population) / 100 * 2 * math.pi;
        sector(center, r, r * 0.64, angle, angle + child, country(i));
        if (child > 0.15) {
          final mid = angle + child / 2;
          text(
            code(i),
            math.Point(
              center.x + math.cos(mid) * (r + 12),
              center.y + math.sin(mid) * (r + 12),
            ),
          );
        }
        angle += child;
      }
    }
    text('Región', square(50, 48), size: 9);
    text('→ país', square(50, 53), size: 9);
  }

  List<math.Point> bezier(
    math.Point a,
    math.Point b,
    math.Point c1,
    math.Point c2,
  ) => [
    for (var step = 0; step <= 32; step++)
      math.Point(
        math.pow(1 - step / 32, 3) * a.x +
            3 * math.pow(1 - step / 32, 2) * step / 32 * c1.x +
            3 * (1 - step / 32) * math.pow(step / 32, 2) * c2.x +
            math.pow(step / 32, 3) * b.x,
        math.pow(1 - step / 32, 3) * a.y +
            3 * math.pow(1 - step / 32, 2) * step / 32 * c1.y +
            3 * (1 - step / 32) * math.pow(step / 32, 2) * c2.y +
            math.pow(step / 32, 3) * b.y,
      ),
  ];

  void sankey() {
    if (data.source.total(ChartMetric.population) == 0) return;
    final starts = <int, double>{};
    var leftY = 12.0;
    for (var i = 0; i < 7; i++) {
      final height = data.source.share(i, ChartMetric.population) * 0.7;
      starts[i] = leftY;
      rect(17, leftY, 3, height, country(i));
      text(code(i), p(8, leftY + height / 2), size: 9);
      leftY += height + 2;
    }
    var rightY = 12.0;
    for (final group in data.regions) {
      final height = data.groupShare(group, ChartMetric.population) * 0.7;
      rect(77, rightY, 3, height, ink.withValues(alpha: 0.5));
      text(regionShort(group.name), p(88, rightY + height / 2), size: 9);
      var running = rightY;
      for (final i in group.countries) {
        final h = data.source.share(i, ChartMetric.population) * 0.7;
        if (h > 0) {
          final top = bezier(
            p(20, starts[i]!),
            p(77, running),
            p(43, starts[i]!),
            p(54, running),
          );
          final bottom = bezier(
            p(20, starts[i]! + h),
            p(77, running + h),
            p(43, starts[i]! + h),
            p(54, running + h),
          );
          polygon([
            ...top,
            ...bottom.reversed,
          ], country(i).withValues(alpha: country(i).a * 0.5));
        }
        running += h;
      }
      rightY += height + 2;
    }
    text('Países', p(15, 4));
    text('Regiones', p(82, 4));
  }

  String regionShort(String name) => switch (name) {
    'Americas' => 'Américas',
    'Europe' => 'Europa',
    'Africa' => 'África',
    'Asia' => 'Asia',
    'Oceania' => 'Oceanía',
    'Antarctic' => 'Antártida',
    _ => name.length > 9 ? '${name.substring(0, 8)}…' : name,
  };

  void chord() {
    final center = square(50, 50), radius = scale * 34;
    math.Point<double> at(int i, double r) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 7;
      return math.Point(
        center.x + math.cos(angle) * r,
        center.y + math.sin(angle) * r,
      );
    }

    for (final link in data.currencyRelations) {
      final a = at(link.a, radius * 0.91), b = at(link.b, radius * 0.91);
      final thickness = scale * link.weight * 1.7;
      final top = bezier(
        math.Point(a.x, a.y - thickness),
        math.Point(b.x, b.y - thickness),
        center,
        center,
      );
      final bottom = bezier(
        math.Point(a.x, a.y + thickness),
        math.Point(b.x, b.y + thickness),
        center,
        center,
      );
      final active =
          focus == null || focus == code(link.a) || focus == code(link.b);
      polygon([
        ...top,
        ...bottom.reversed,
      ], ChartPalette.at(link.a).withValues(alpha: active ? 0.45 : 0.1));
    }
    for (var i = 0; i < 7; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 7;
      sector(
        center,
        radius,
        radius * 0.92,
        angle - 0.27,
        angle + 0.27,
        country(i),
      );
      text(code(i), at(i, radius + 12));
    }
  }

  void ternary() {
    final a = square(50, 14), b = square(11, 83), c = square(89, 83);
    for (final fraction in [0.25, 0.5, 0.75]) {
      math.Point mix(math.Point p1, math.Point p2, double f) =>
          p1 * (1 - f) + p2 * f;
      line([mix(a, b, fraction), mix(a, c, fraction)], grid, width: 1);
      line([mix(b, a, fraction), mix(b, c, fraction)], grid, width: 1);
      line([mix(c, a, fraction), mix(c, b, fraction)], grid, width: 1);
    }
    line([a, b, c, a], ink);
    text('Población', square(50, 7));
    text('Superficie', square(14, 91));
    text('Densidad', square(85, 91));
    final coincident = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final t = data.ternary(i);
      if (t == null) continue;
      final point = a * t.population + b * t.area + c * t.density;
      final key = '${point.x.toStringAsFixed(2)}:${point.y.toStringAsFixed(2)}';
      final order = coincident.update(key, (n) => n + 1, ifAbsent: () => 0);
      dot(
        point,
        4 + order * 1.8,
        Colors.white.withValues(alpha: 0),
        stroke: country(i),
        width: 1.8,
      );
      if (order == 0) text(code(i), math.Point(point.x, point.y - 10), size: 9);
    }
  }

  void marimekko() {
    var left = 13.0;
    for (var i = 0; i < 7; i++) {
      final width = data.source.share(i, ChartMetric.population) * 0.8;
      final height = index(i, ChartMetric.languages) * 0.73;
      rect(
        left,
        10,
        width,
        73,
        country(i).withValues(alpha: country(i).a * 0.12),
        stroke: Colors.white,
      );
      rect(left, 83 - height, width, height, country(i), stroke: Colors.white);
      if (width * bounds.width / 100 > 25) {
        text(code(i), p(left + width / 2, 89), size: 9);
      }
      left += width;
    }
    for (final value in [0, 50, 100]) {
      text('$value', p(5, 83 - value * 0.73), size: 9);
    }
    text('Cuota de población →', p(55, 96), size: 9);
  }

  void icicle() {
    var left = 5.0;
    for (final group in data.regions) {
      final width = data.groupShare(group, ChartMetric.area) * 0.9;
      rect(
        left,
        12,
        width,
        28,
        ink.withValues(alpha: 0.35),
        stroke: Colors.white,
      );
      if (width * bounds.width / 100 > 42) {
        text(
          regionShort(group.name),
          p(left + width / 2, 26),
          color: Colors.white,
          size: 9,
        );
      }
      var childLeft = left;
      for (final i in group.countries) {
        final childWidth = data.source.share(i, ChartMetric.area) * 0.9;
        rect(childLeft, 41, childWidth, 44, country(i), stroke: Colors.white);
        if (childWidth * bounds.width / 100 > 24) {
          text(
            code(i),
            p(childLeft + childWidth / 2, 63),
            color: Colors.white,
            size: 9,
          );
        }
        childLeft += childWidth;
      }
      left += width;
    }
    text('Región → país · misma superficie', p(50, 94), size: 9);
  }

  void packing() {
    for (final item in data.packedCircles) {
      final center = square(item.center.x, item.center.y);
      dot(
        center,
        item.radius * scale,
        country(item.index),
        stroke: Colors.white,
        width: 1,
      );
      if (item.radius * scale > 12) {
        text(code(item.index), center, color: Colors.white, size: 9);
      }
    }
  }

  void human(double atX, double y, double fraction, Color color) {
    final base = color.withValues(alpha: color.a * 0.13);
    final center = p(atX, y - 1.8);
    dot(center, 1.6 * scale, base);
    rect(atX - 1.6, y, 3.2, 5.4, base);
    line([p(atX - 1, y + 4), p(atX - 1, y + 7)], base, width: 2 * scale);
    line([p(atX + 1, y + 4), p(atX + 1, y + 7)], base, width: 2 * scale);
    if (fraction <= 0) return;
    final top = p(atX - 3, y - 3.5), bottom = p(atX + 3, y + 7.5);
    canvas.setClipBounds(
      math.Rectangle(
        top.x.floor(),
        (bottom.y - (bottom.y - top.y) * fraction).floor(),
        (bottom.x - top.x).ceil(),
        ((bottom.y - top.y) * fraction).ceil(),
      ),
    );
    dot(center, 1.6 * scale, color);
    rect(atX - 1.6, y, 3.2, 5.4, color);
    line([p(atX - 1, y + 4), p(atX - 1, y + 7)], color, width: 2 * scale);
    line([p(atX + 1, y + 4), p(atX + 1, y + 7)], color, width: 2 * scale);
    canvas.resetClipBounds();
  }

  void pictogram() {
    for (var i = 0; i < 7; i++) {
      final y = 8 + i * 12.0;
      text(code(i), p(8, y + 2), size: 9);
      final icons = index(i, ChartMetric.population) / 10;
      for (var n = 0; n < 10; n++) {
        human(20 + n * 7.5, y, (icons - n).clamp(0.0, 1.0), country(i));
      }
    }
  }

  void horizon() {
    for (final value in [0, 16.7, 33.3]) {
      final y = 79 - value * 1.65;
      line([p(12, y), p(94, y)], grid, width: 1);
      text(value.toStringAsFixed(1), p(6, y), size: 9);
    }
    for (var band = 0; band < 3; band++) {
      final points = <math.Point>[p(16, 79)];
      for (var i = 0; i < 7; i++) {
        final height = (index(i, ChartMetric.density) - band * 100 / 3).clamp(
          0.0,
          100 / 3,
        );
        points.add(p(16 + i * 12.0, 79 - height * 1.65));
      }
      points.add(p(88, 79));
      polygon(
        points,
        [
          const Color(0xFFB3DDDB),
          const Color(0xFF57A9A5),
          const Color(0xFF006B67),
        ][band],
      );
    }
    for (var i = 0; i < 7; i++) {
      text(code(i), p(16 + i * 12.0, 86), size: 9);
      text(
        index(i, ChartMetric.density).toStringAsFixed(1),
        p(16 + i * 12.0, 92),
        size: 8,
      );
      if (focus == code(i)) {
        line(
          [p(16 + i * 12.0, 20), p(16 + i * 12.0, 79)],
          country(i),
          width: 2.5,
        );
      }
    }
  }

  void beeswarm() {
    final maximum = data.source.maximum(ChartMetric.density);
    for (final tick in [0, 25, 50, 75, 100]) {
      line(
        [p(x(tick.toDouble()), 15), p(x(tick.toDouble()), 83)],
        grid,
        width: 1,
      );
      text(
        (maximum * tick / 100).toStringAsFixed(maximum < 10 ? 1 : 0),
        p(x(tick.toDouble()), 91),
        size: 9,
      );
    }
    for (final item in data.swarm) {
      dot(p(x(item.x), item.y), 4.5, country(item.index), stroke: Colors.white);
      text(code(item.index), p(x(item.x), item.y - 5), size: 9);
    }
  }

  void arcs() {
    for (final link in data.borderRelations) {
      final a = 12 + link.a * 12.0, b = 12 + link.b * 12.0;
      final height = 15 + (link.b - link.a) * 5.0;
      final active =
          focus == null || focus == code(link.a) || focus == code(link.b);
      line(
        bezier(p(a, 78), p(b, 78), p(a, 78 - height), p(b, 78 - height)),
        ink.withValues(alpha: active ? 0.6 : 0.1),
        width: 2,
      );
    }
    line([p(8, 78), p(92, 78)], grid, width: 1);
    for (var i = 0; i < 7; i++) {
      dot(p(12 + i * 12.0, 78), 5.5, country(i), stroke: Colors.white);
      text(code(i), p(12 + i * 12.0, 86), size: 9);
    }
  }
}
