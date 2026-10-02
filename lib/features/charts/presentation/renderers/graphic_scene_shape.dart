import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as g;

import '../../data/graphic_chart_data.dart';
import '../../domain/chart_metric.dart';
import '../../domain/graphic_chart_spec.dart';
import '../chart_palette.dart';
import 'graphic_palette.dart';

int graphicLayerPriority(GraphicVisual v) => switch (v) {
  GraphicVisual.triangleFan => 0,
  GraphicVisual.diamond => 1,
  GraphicVisual.bullet => 2,
  GraphicVisual.boxPlot => 3,
  GraphicVisual.lollipop || GraphicVisual.dumbbell => 4,
  GraphicVisual.vector => 5,
  _ => 6,
};

/// Graphic's public Shape extension. Outputs native MarkElements, not a painter
/// outside the chart. Each fused component is a mark in the SAME coordinate.
class GraphicSceneShape extends g.Shape {
  GraphicSceneShape({
    required this.spec,
    required this.data,
    required this.layer,
    required this.showAxes,
    this.highlightedCode,
  });
  final GraphicChartSpec spec;
  final GraphicChartData data;
  final int layer;
  final bool showAxes;
  final String? highlightedCode;
  @override
  double get defaultSize => 0;
  @override
  bool equalTo(Object other) =>
      other is GraphicSceneShape &&
      other.spec.signature == spec.signature &&
      other.layer == layer &&
      other.showAxes == showAxes &&
      other.highlightedCode == highlightedCode &&
      identical(other.data, data);
  @override
  List<g.MarkElement> drawGroupLabels(
    List<g.Attributes> group,
    g.CoordConv coord,
    Offset origin,
  ) => const [];
  @override
  List<g.MarkElement> drawGroupPrimitives(
    List<g.Attributes> group,
    g.CoordConv coord,
    Offset origin,
  ) {
    if (!data.source.valid || group.length != 7) return const [];
    return _GraphicScene(
      spec,
      data,
      layer,
      showAxes,
      highlightedCode,
      coord.region,
    ).draw();
  }
}

class _GraphicScene {
  _GraphicScene(
    this.spec,
    this.data,
    this.layerIndex,
    this.showAxes,
    this.focus,
    this.bounds,
  );
  final GraphicChartSpec spec;
  final GraphicChartData data;
  final int layerIndex;
  final bool showAxes;
  final String? focus;
  final Rect bounds;
  final elements = <g.MarkElement>[];
  static const ink = Color(0xFF243A42), grid = Color(0xFFE0E8E9);
  double get scale => math.min(bounds.width, bounds.height) / 100;
  Offset p(double x, double y) => Offset(
    bounds.left + x * bounds.width / 100,
    bounds.top + y * bounds.height / 100,
  );
  Offset square(double x, double y) =>
      bounds.center + Offset((x - 50) * scale, (y - 50) * scale);
  String code(int i) => data.source.points[i].axisLabel;
  Color country(int i) =>
      ChartPalette.at(i)
          .withValues(alpha: focus == null || focus == code(i) ? 1 : 0.16);
  Color color(int i) => spec.usesLayerColors
      ? GraphicPalette.at(layerIndex)
            .withValues(alpha: focus == null || focus == code(i) ? 1 : 0.16)
      : country(i);
  g.PaintStyle style({Color? fill, Color? stroke, double width = 1}) =>
      g.PaintStyle(
        fillColor: fill,
        strokeColor: stroke,
        strokeWidth: stroke == null ? null : width,
      );
  void line(List<Offset> points, Color color, {double width = 1.5}) {
    if (points.length < 2) return;
    elements.add(
      g.PolylineElement(
        points: points,
        style: style(stroke: color, width: width),
      ),
    );
  }

  void polygon(
    List<Offset> points,
    Color fill, {
    Color? stroke,
    double width = 1,
  }) {
    if (points.length < 3) return;
    elements.add(
      g.PolygonElement(
        points: points,
        style: style(fill: fill, stroke: stroke, width: width),
      ),
    );
  }

  void rect(
    double x,
    double y,
    double width,
    double height,
    Color fill, {
    Color? stroke,
  }) => elements.add(
    g.RectElement(
      rect: Rect.fromLTWH(
        p(x, y).dx,
        p(x, y).dy,
        width * bounds.width / 100,
        height * bounds.height / 100,
      ),
      style: style(fill: fill, stroke: stroke),
    ),
  );
  void dot(
    Offset center,
    double radius,
    Color fill, {
    Color? stroke,
    double width = 1,
  }) => elements.add(
    g.CircleElement(
      center: center,
      radius: radius,
      style: style(fill: fill, stroke: stroke, width: width),
    ),
  );
  void label(
    String text,
    Offset center, {
    Color color = ink,
    double size = 10,
    double maxWidth = 78,
  }) => elements.add(
    g.LabelElement(
      text: text,
      anchor: center,
      style: g.LabelStyle(
        textStyle: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        maxWidth: maxWidth,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    ),
  );
  double value(int i, ChartMetric metric) => data.source.relative(i, metric);

  /// Move labels only: observation coordinates always retain their real values.
  void callouts(
    List<({String text, Offset point})> items, {
    List<Rect> reserved = const [],
  }) {
    final occupied = [...reserved];
    final markers = [
      for (final item in items)
        Rect.fromCenter(center: item.point, width: 11, height: 11),
    ];
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(
          text: item.text,
          style: const TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final width = painter.width + 6, height = painter.height + 4;
      painter.dispose();
      final safe = bounds.deflate(5);
      Rect? chosen;
      var bestScore = double.infinity;
      for (var ring = 0; ring < 8; ring++) {
        for (final direction in [
          const Offset(0, -1),
          const Offset(1, -0.6),
          const Offset(-1, -0.6),
          const Offset(1, 0.6),
          const Offset(-1, 0.6),
          const Offset(0, 1),
        ]) {
          final raw = item.point + direction * (14 + ring * 10);
          final center = Offset(
            raw.dx.clamp(safe.left + width / 2, safe.right - width / 2),
            raw.dy.clamp(safe.top + height / 2, safe.bottom - height / 2),
          );
          final candidate = Rect.fromCenter(
            center: center,
            width: width,
            height: height,
          );
          final collisions = [
            ...occupied,
            ...markers,
          ].where((area) => area.overlaps(candidate)).length;
          final score = collisions * 10000 + (center - item.point).distance;
          if (score < bestScore) {
            bestScore = score;
            chosen = candidate;
          }
        }
        if (bestScore < 10000) break;
      }
      final area = chosen!;
      occupied.add(area);
      if ((area.center - item.point).distance > 18) {
        line([item.point, area.center], ink.withValues(alpha: 0.4), width: 0.8);
      }
      elements.add(
        g.RectElement(
          rect: area,
          style: style(fill: Colors.white.withValues(alpha: 0.85)),
        ),
      );
      label(item.text, area.center, size: 9, maxWidth: width);
    }
  }

  double x(double index) => 17 + index * 0.76;
  double row(int i) => 12 + i * 12;
  Offset plane(PlanePoint site) => p(14 + site.x * 0.78, 85 - site.y * 0.72);
  List<Rect> get planeAxisLabels => [
    Rect.fromLTRB(bounds.left, bounds.top, p(11, 0).dx, bounds.bottom),
    Rect.fromLTRB(bounds.left, p(0, 89).dy, bounds.right, bounds.bottom),
  ];
  List<int> get paintOrder => [
    for (var i = 0; i < 7; i++)
      if (code(i) != focus) i,
    for (var i = 0; i < 7; i++)
      if (code(i) == focus) i,
  ];

  List<g.MarkElement> draw() {
    if (spec.isProfile) {
      if (showAxes) profileAxes();
      profile(spec.visuals[layerIndex]);
      return elements;
    }
    switch (spec.visuals.single) {
      case GraphicVisual.voronoi:
        voronoi();
      case GraphicVisual.dendrogram:
        dendrogram();
      case GraphicVisual.minimumSpanningTree:
        tree();
      case GraphicVisual.upset:
        upset();
      case GraphicVisual.venn:
        venn();
      case GraphicVisual.chernoff:
        chernoff();
      case GraphicVisual.andrews:
        andrews();
      case GraphicVisual.petals:
        petals();
      case GraphicVisual.convexHull:
        hull();
      case GraphicVisual.hexbin:
        hexbin();
      case GraphicVisual.taylor:
        taylor();
      default:
        break;
    }
    return elements;
  }

  void profileAxes() {
    for (final tick in [0, 25, 50, 75, 100]) {
      line(
        [p(x(tick.toDouble()), 6), p(x(tick.toDouble()), 90)],
        grid,
        width: 1,
      );
      label('$tick', p(x(tick.toDouble()), 95));
    }
    for (var i = 0; i < 7; i++) {
      label(code(i), p(8, row(i)), color: focus == code(i) ? country(i) : ink);
      line([p(x(0), row(i)), p(x(100), row(i))], grid, width: 0.6);
    }
  }

  void profile(GraphicVisual visual) {
    for (var i = 0; i < 7; i++) {
      final y = row(i), c = color(i);
      final low = data.quantile(i, 0), q1 = data.quantile(i, 0.25);
      final med = data.quantile(i, 0.5),
          q3 = data.quantile(i, 0.75),
          high = data.quantile(i, 1);
      switch (visual) {
        case GraphicVisual.diamond:
          final middle = x((q1 + q3) / 2);
          polygon(
            [p(x(q1), y), p(middle, y - 3.8), p(x(q3), y), p(middle, y + 3.8)],
            c.withValues(alpha: c.a * 0.18),
            stroke: c,
          );
          line([p(x(med), y - 1.4), p(x(med), y + 1.4)], c, width: 2.2);
        case GraphicVisual.triangleFan:
          polygon(
            [p(x(low), y + 3.9), p(x(med), y - 4.8), p(x(high), y + 3.9)],
            c.withValues(alpha: c.a * 0.12),
            stroke: c,
          );
        case GraphicVisual.vector:
          final a = x(value(i, ChartMetric.population)),
              b = x(value(i, ChartMetric.area)),
              at = y - 0.4;
          line([p(a, at), p(b, at)], c, width: 2.5);
          line([p(a, at - 1), p(a, at + 1)], c, width: 2);
          if ((a - b).abs() > 1e-9) {
            final sign = b > a ? 1.0 : -1.0;
            polygon([
              p(b, at),
              p(b - sign * 2, at - 1.5),
              p(b - sign * 2, at + 1.5),
            ], c);
          } else {
            line([p(b - 0.7, at - 0.7), p(b + 0.7, at + 0.7)], c, width: 2);
            line([p(b - 0.7, at + 0.7), p(b + 0.7, at - 0.7)], c, width: 2);
          }
        case GraphicVisual.boxen:
          final intervals = [0.0625, 0.125, 0.25];
          for (var k = 0; k < intervals.length; k++) {
            final l = data.quantile(i, intervals[k]),
                r = data.quantile(i, 1 - intervals[k]);
            final h = 1.2 + k * 1.3;
            rect(
              x(l),
              y - h,
              (r - l) * 0.76,
              h * 2,
              c.withValues(alpha: c.a * (0.13 + k * 0.12)),
              stroke: c,
            );
          }
          line([p(x(med), y - 3.8), p(x(med), y + 3.8)], c, width: 2.2);
        case GraphicVisual.boxPlot:
          final at = y + 1.5;
          line([p(x(low), at), p(x(high), at)], c);
          for (final end in [low, high]) {
            line([p(x(end), at - 0.8), p(x(end), at + 0.8)], c);
          }
          rect(
            x(q1),
            at - 1,
            (q3 - q1) * 0.76,
            2,
            c.withValues(alpha: c.a * 0.14),
            stroke: c,
          );
          line([p(x(med), at - 1), p(x(med), at + 1)], c, width: 2.2);
        case GraphicVisual.dots:
          dot(
            p(x(value(i, ChartMetric.density)), y),
            4.4,
            c,
            stroke: Colors.white,
          );
        case GraphicVisual.lollipop:
          final end = x(value(i, ChartMetric.population));
          line([p(x(0), y + 2.8), p(end, y + 2.8)], c, width: 2);
          rect(end - 0.8, y + 2, 1.6, 1.6, c);
        case GraphicVisual.dumbbell:
          final a = x(value(i, ChartMetric.languages)),
              b = x(value(i, ChartMetric.timezones));
          line([p(a, y - 2.4), p(b, y - 2.4)], c, width: 2);
          dot(p(a, y - 2.4), 3.5, c);
          dot(p(b, y - 2.4), 3.5, Colors.white, stroke: c, width: 2);
        case GraphicVisual.bullet:
          final idx = value(i, ChartMetric.borders);
          final average =
              List.generate(
                7,
                (i) => value(i, ChartMetric.borders),
              ).reduce((a, b) => a + b) /
              7;
          rect(x(0), y + 0.4, idx * 0.76, 1, c.withValues(alpha: c.a * 0.6));
          line([p(x(average), y - 0.6), p(x(average), y + 2.3)], c, width: 2);
        default:
          break;
      }
    }
  }

  void planeAxes() {
    for (final tick in [0, 25, 50, 75, 100]) {
      final v = tick.toDouble();
      line(
        [plane(PlanePoint(v, 0)), plane(PlanePoint(v, 100))],
        grid,
        width: 1,
      );
      line(
        [plane(PlanePoint(0, v)), plane(PlanePoint(100, v))],
        grid,
        width: 1,
      );
      label('$tick', p(14 + v * 0.78, 92), size: 9);
      label('$tick', p(6, 85 - v * 0.72), size: 9);
    }
  }

  void planeCountries() {
    for (final i in paintOrder) {
      final point = plane(data.site(i));
      dot(point, 4, country(i), stroke: Colors.white);
    }
    callouts([
      for (final i in paintOrder) (text: code(i), point: plane(data.site(i))),
    ], reserved: planeAxisLabels);
  }

  void voronoi() {
    for (final cell in data.voronoi) {
      final active = focus == null || cell.members.any((i) => code(i) == focus);
      polygon(
        cell.polygon.map(plane).toList(),
        ChartPalette.at(cell.members.first)
            .withValues(alpha: active ? 0.18 : 0.04),
        stroke: Colors.white,
      );
    }
    planeAxes();
    for (final cell in data.voronoi) {
      for (var k = cell.members.length - 1; k >= 0; k--) {
        dot(
          plane(cell.site),
          4 + k * 1.4,
          Colors.white.withValues(alpha: 0),
          stroke: country(cell.members[k]),
          width: 2,
        );
      }
    }
    callouts([
      for (final cell in data.voronoi)
        (
          text: cell.members.length == 1
              ? code(cell.members.single)
              : '${cell.members.length} países',
          point: plane(cell.site),
        ),
    ], reserved: planeAxisLabels);
  }

  void hull() {
    planeAxes();
    for (var k = 0; k < data.regions.length; k++) {
      final points = data.hull(data.regions[k].members).map(plane).toList();
      final c = GraphicPalette.at(k);
      if (points.length >= 3) {
        polygon(points, c.withValues(alpha: 0.12), stroke: c);
      }
      if (points.length == 2) line(points, c, width: 2);
    }
    planeCountries();
  }

  void hexbin() {
    planeAxes();
    for (var k = 0; k < data.hexagons.length; k++) {
      final cell = data.hexagons[k];
      final c = Color.lerp(
        const Color(0xFFCFE8E6),
        const Color(0xFF006C67),
        cell.members.length / 7,
      )!;
      final points = cell.polygon.map(plane).toList();
      polygon(
        points,
        c,
        stroke: focus != null && cell.members.any((i) => code(i) == focus)
            ? ink
            : Colors.white,
        width: 2,
      );
      label(
        '${cell.members.length} · #${k + 1}',
        plane(cell.center),
        size: 8,
        maxWidth: 35,
      );
    }
  }

  void dendrogram() {
    final root = data.dendrogram, order = data.dendrogram.leafOrder;
    final positions = {
      for (var i = 0; i < order.length; i++) order[i]: 12 + i * 12.0,
    };
    double y(ProfileCluster cluster) => cluster.isLeaf
        ? positions[cluster.members.single]!
        : (y(cluster.left!) + y(cluster.right!)) / 2;
    void branch(ProfileCluster cluster) {
      if (cluster.isLeaf) return;
      final at = 17 + cluster.distance * 0.76;
      final left = cluster.left!, right = cluster.right!;
      final active =
          focus == null || cluster.members.any((i) => code(i) == focus);
      final c = ink.withValues(alpha: active ? 0.75 : 0.15);
      line(
        [
          p(17 + left.distance * 0.76, y(left)),
          p(at, y(left)),
          p(at, y(right)),
          p(17 + right.distance * 0.76, y(right)),
        ],
        c,
        width: 2,
      );
      branch(left);
      branch(right);
    }

    for (final tick in [0, 25, 50, 75, 100]) {
      line([p(17 + tick * 0.76, 7), p(17 + tick * 0.76, 89)], grid, width: 1);
      label('$tick', p(17 + tick * 0.76, 95), size: 9);
    }
    branch(root);
    for (final i in order) {
      dot(p(17, positions[i]!), 3, country(i));
      label(code(i), p(8, positions[i]!), size: 9);
    }
  }

  void tree() {
    final nodes = [
      for (var i = 0; i < 7; i++)
        square(
          50 + 34 * math.cos(-math.pi / 2 + i * 2 * math.pi / 7),
          50 + 34 * math.sin(-math.pi / 2 + i * 2 * math.pi / 7),
        ),
    ];
    for (final edge in data.spanningTree) {
      final active =
          focus == null || focus == code(edge.a) || focus == code(edge.b);
      line(
        [nodes[edge.a], nodes[edge.b]],
        ink.withValues(alpha: active ? 0.5 : 0.1),
        width: 1.8,
      );
    }
    for (var i = 0; i < 7; i++) {
      dot(nodes[i], 6, country(i), stroke: Colors.white, width: 1.5);
      final direction = (nodes[i] - bounds.center) / 34 / scale;
      label(code(i), nodes[i] + direction * 15, size: 9);
    }
    label('6 enlaces', square(50, 97), size: 9);
  }

  void upset() {
    final groups = data.intersections.take(7).toList();
    final maximum = groups.isEmpty
        ? 1
        : groups.map((g) => g.languages.length).reduce(math.max);
    for (var i = 0; i < 7; i++) {
      label(code(i), p(8, 51 + i * 5.8), size: 9);
    }
    for (var k = 0; k < groups.length; k++) {
      final at = 23 + k * 10.8;
      final height = groups[k].languages.length / maximum * 24;
      rect(at - 2.8, 43 - height, 5.6, height, GraphicPalette.at(0));
      label('${groups[k].languages.length}', p(at, 39 - height), size: 9);
      label('#${k + 1}', p(at, 95), size: 9);
      final members = groups[k].members;
      if (members.length > 1) {
        line([
          p(at, 51 + members.first * 5.8),
          p(at, 51 + members.last * 5.8),
        ], ink);
      }
      for (var i = 0; i < 7; i++) {
        dot(p(at, 51 + i * 5.8), 3.5, members.contains(i) ? country(i) : grid);
      }
    }
    line([p(17, 43), p(94, 43)], grid, width: 1);
    label('Idiomas distintos', p(55, 4), size: 10);
  }

  void venn() {
    final sets = data.vennSets;
    final centers = sets.length == 3
        ? [square(40, 43), square(60, 43), square(50, 62)]
        : sets.length == 2
        ? [square(39, 48), square(61, 48)]
        : [square(50, 50)];
    for (var k = 0; k < sets.length; k++) {
      dot(
        centers[k],
        24 * scale,
        GraphicPalette.at(k).withValues(alpha: 0.14),
        stroke: GraphicPalette.at(k),
        width: 1.5,
      );
      label(
        String.fromCharCode(65 + k),
        centers[k].translate(0, -19 * scale),
        color: GraphicPalette.at(k),
        size: 12,
      );
    }
    final anchors = sets.length == 3
        ? <int, Offset>{
            0: square(50, 94),
            1: square(24, 35),
            2: square(76, 35),
            3: square(50, 27),
            4: square(50, 82),
            5: square(32, 65),
            6: square(68, 65),
            7: square(50, 49),
          }
        : sets.length == 2
        ? <int, Offset>{
            0: square(50, 91),
            1: square(25, 48),
            2: square(75, 48),
            3: square(50, 48),
          }
        : <int, Offset>{0: square(50, 91), 1: square(50, 50)};
    for (var mask = 0; mask < (1 << sets.length); mask++) {
      final count = data.vennBuckets[mask]?.length ?? 0;
      label(mask == 0 ? 'Fuera: $count' : '$count', anchors[mask]!, size: 12);
    }
  }

  void andrews() {
    var extent = 1.0;
    for (var i = 0; i < 7; i++) {
      for (var k = 0; k <= 96; k++) {
        extent = math.max(
          extent,
          data.andrews(i, -math.pi + 2 * math.pi * k / 96).abs(),
        );
      }
    }
    extent = extent.ceilToDouble();
    for (final fraction in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
      final y = 50 - fraction * 36;
      line([p(13, y), p(93, y)], grid, width: 1);
      label((extent * fraction).toStringAsFixed(1), p(6, y), size: 8);
    }
    final ticks = ['−π', '−π/2', '0', 'π/2', 'π'];
    for (var k = 0; k < 5; k++) {
      label(ticks[k], p(13 + k * 20.0, 93), size: 9);
    }
    for (final i in paintOrder) {
      line(
        [
          for (var k = 0; k <= 96; k++)
            p(
              13 + k / 96 * 80,
              50 -
                  data.andrews(i, -math.pi + 2 * math.pi * k / 96) /
                      extent *
                      36,
            ),
        ],
        country(i),
        width: 1.8,
      );
    }
  }

  Offset glyphCenter(int i) =>
      square(i % 2 == 0 ? 28 : 72, 15 + (i ~/ 2) * 23.0);
  void chernoff() {
    for (var i = 0; i < 7; i++) {
      final center = glyphCenter(i), v = data.profiles[i], c = country(i);
      final w = 6 + v[0] / 100 * 5, h = 6.5 + v[1] / 100 * 4;
      elements.add(
        g.OvalElement(
          oval: Rect.fromCenter(
            center: center,
            width: w * 2 * scale,
            height: h * 2 * scale,
          ),
          style: style(
            fill: c.withValues(alpha: c.a * 0.12),
            stroke: c,
            width: 1.5,
          ),
        ),
      );
      final gap = (2.5 + v[2] / 100 * 2) * scale,
          eye = (0.5 + v[3] / 100) * scale;
      for (final sign in [-1, 1]) {
        dot(center.translate(sign * gap, -2.5 * scale), eye, c);
        final tilt = (v[6] / 100 - 0.5) * 1.8 * scale;
        line([
          center.translate(sign * gap - scale, -4 * scale - tilt),
          center.translate(sign * gap + scale, -4 * scale + tilt),
        ], c);
      }
      line([
        center.translate(0, -scale),
        center.translate(0, (0.5 + v[4] / 100 * 2) * scale),
      ], c);
      final curve = (v[5] / 100 - 0.5) * 3;
      line([
        for (var k = 0; k <= 12; k++)
          center +
              Offset(
                (-3 + k * 0.5) * scale,
                (4 + curve * (1 - math.pow(-1 + k / 6, 2))) * scale,
              ),
      ], c);
      label(code(i), center.translate(0, (h + 4) * scale), size: 9);
    }
  }

  void petals() {
    for (var i = 0; i < 7; i++) {
      final center = glyphCenter(i);
      for (var k = 0; k < 7; k++) {
        final length = data.profiles[i][k] / 100 * 9 * scale;
        if (length == 0) continue;
        final angle = -math.pi / 2 + k * 2 * math.pi / 7;
        final middle =
            center + Offset(math.cos(angle), math.sin(angle)) * length / 2;
        elements.add(
          g.OvalElement(
            oval: Rect.fromCenter(
              center: middle,
              width: length,
              height: length * 0.36,
            ),
            rotation: angle,
            rotationAxis: middle,
            style: style(
              fill: ChartPalette.at(k).withValues(
                alpha: focus == null || focus == code(i) ? 0.8 : 0.15,
              ),
            ),
          ),
        );
      }
      dot(center, 2.4, country(i));
      label(code(i), center.translate(0, 12 * scale), size: 9);
    }
  }

  void taylor() {
    final points = [
      for (var i = 0; i < 7; i++)
        if (data.taylor(i) != null) data.taylor(i)!,
    ];
    var extent = math.max(10.0, data.referenceDeviation);
    for (final point in points) {
      extent = math.max(extent, point.standardDeviation);
    }
    extent = (extent / 10).ceilToDouble() * 10;
    final center = square(50, 78), radius = 40 * scale;
    Offset polar(double deviation, double angle) =>
        center +
        Offset(math.cos(angle), -math.sin(angle)) *
            (deviation / extent * radius);
    for (var k = 1; k <= 4; k++) {
      final sd = extent * k / 4;
      line(
        [for (var step = 0; step <= 64; step++) polar(sd, step / 64 * math.pi)],
        grid,
        width: 1,
      );
      label(
        sd.toStringAsFixed(0),
        polar(sd, math.pi / 2).translate(0, -7),
        size: 8,
      );
    }
    for (final correlation in [-1.0, -0.5, 0.0, 0.5, 1.0]) {
      final angle = math.acos(correlation);
      line([center, polar(extent, angle)], grid, width: 1);
      label(
        correlation.toStringAsFixed(1),
        polar(extent * 1.09, angle).translate(0, correlation == 0 ? -10 : 0),
        size: 9,
      );
    }
    line([polar(extent, math.pi), polar(extent, 0)], ink);
    final reference = polar(data.referenceDeviation, 0);
    polygon([
      reference.translate(0, -4),
      reference.translate(4, 0),
      reference.translate(0, 4),
      reference.translate(-4, 0),
    ], ink);
    label('Referencia', reference.translate(0, 14), size: 9);
    for (final point in points) {
      final at = polar(point.standardDeviation, math.acos(point.correlation));
      dot(at, 4.1, country(point.index), stroke: Colors.white);
    }
    callouts(
      [
        for (final point in points)
          (
            text: code(point.index),
            point: polar(point.standardDeviation, math.acos(point.correlation)),
          ),
      ],
      reserved: [
        Rect.fromCenter(
          center: reference.translate(0, 14),
          width: 60,
          height: 15,
        ),
        for (var k = 1; k <= 4; k++)
          Rect.fromCenter(
            center: polar(extent * k / 4, math.pi / 2).translate(0, -7),
            width: 18,
            height: 14,
          ),
      ],
    );
  }
}
