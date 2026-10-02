import 'dart:math' as math;

import '../domain/chart_metric.dart';
import 'creative_chart_data.dart';

typedef PlanePoint = math.Point<double>;
typedef VoronoiCell = ({
  PlanePoint site,
  List<int> members,
  List<PlanePoint> polygon,
});
typedef ProfileEdge = ({int a, int b, double distance});
typedef LanguageSet = ({String name, List<int> members});
typedef LanguageIntersection = ({
  int mask,
  List<int> members,
  List<String> languages,
});
typedef HexCell = ({
  PlanePoint center,
  List<int> members,
  List<PlanePoint> polygon,
});
typedef TaylorPoint = ({
  int index,
  double standardDeviation,
  double correlation,
  double centeredRms,
});

class ProfileCluster {
  const ProfileCluster(this.members, this.distance, [this.left, this.right]);
  final List<int> members;
  final double distance;
  final ProfileCluster? left, right;
  bool get isLeaf => left == null;
  List<int> get leafOrder =>
      isLeaf ? members : [...left!.leafOrder, ...right!.leafOrder];
}

/// Computations depend exclusively on the seven selected REST Countries records.
class GraphicChartData {
  GraphicChartData(this.source);
  final CreativeChartData source;
  late final List<List<double>> profiles = List.unmodifiable([
    for (var i = 0; i < source.points.length; i++)
      List<double>.unmodifiable([
        for (final metric in ChartMetric.values) source.relative(i, metric),
      ]),
  ]);

  double quantile(int i, double fraction) {
    final sorted = List<double>.of(profiles[i])..sort();
    final p = fraction * (sorted.length - 1);
    return sorted[p.floor()] +
        (sorted[p.ceil()] - sorted[p.floor()]) * (p - p.floor());
  }

  PlanePoint site(int i) => PlanePoint(
    source.relative(i, ChartMetric.area),
    source.relative(i, ChartMetric.population),
  );
  double distance(int a, int b) => math.sqrt(
    List.generate(
          7,
          (k) => math.pow(profiles[a][k] - profiles[b][k], 2),
        ).fold<num>(0, (s, v) => s + v) /
        7,
  );

  late final ProfileCluster dendrogram = _cluster();
  ProfileCluster _cluster() {
    final groups = [
      for (var i = 0; i < source.points.length; i++) ProfileCluster([i], 0),
    ];
    while (groups.length > 1) {
      var best = double.infinity, a = 0, b = 1;
      for (var i = 0; i < groups.length; i++) {
        for (var j = i + 1; j < groups.length; j++) {
          var total = 0.0;
          for (final x in groups[i].members) {
            for (final y in groups[j].members) {
              total += distance(x, y);
            }
          }
          final average =
              total / (groups[i].members.length * groups[j].members.length);
          if (average < best) {
            best = average;
            a = i;
            b = j;
          }
        }
      }
      final left = groups[a], right = groups[b];
      final merged = ProfileCluster(
        List.unmodifiable([...left.members, ...right.members]),
        best,
        left,
        right,
      );
      groups.removeAt(b);
      groups.removeAt(a);
      groups.add(merged);
    }
    return groups.single;
  }

  late final List<ProfileEdge> spanningTree = _tree();
  List<ProfileEdge> _tree() {
    final candidates =
        [
          for (var a = 0; a < source.points.length; a++)
            for (var b = a + 1; b < source.points.length; b++)
              (a: a, b: b, distance: distance(a, b)),
        ]..sort((a, b) {
          final value = a.distance.compareTo(b.distance);
          return value != 0
              ? value
              : a.a != b.a
              ? a.a.compareTo(b.a)
              : a.b.compareTo(b.b);
        });
    final parents = List.generate(source.points.length, (i) => i);
    int root(int i) {
      while (parents[i] != i) {
        i = parents[i];
      }
      return i;
    }

    final result = <ProfileEdge>[];
    for (final edge in candidates) {
      final a = root(edge.a), b = root(edge.b);
      if (a == b) continue;
      parents[b] = a;
      result.add(edge);
      if (result.length == source.points.length - 1) break;
    }
    return List.unmodifiable(result);
  }

  /// Sutherland–Hodgman half-plane clipping; no jitter for duplicate positions.
  static List<PlanePoint> clip(
    List<PlanePoint> polygon,
    double a,
    double b,
    double c,
  ) {
    if (polygon.isEmpty) return const [];
    final result = <PlanePoint>[];
    for (var i = 0; i < polygon.length; i++) {
      final from = polygon[i], to = polygon[(i + 1) % polygon.length];
      final f = a * from.x + b * from.y - c, t = a * to.x + b * to.y - c;
      final insideF = f <= 1e-9, insideT = t <= 1e-9;
      if (insideF) result.add(from);
      if (insideF != insideT) {
        final ratio = f / (f - t);
        result.add(from + (to - from) * ratio);
      }
    }
    return result;
  }

  late final List<VoronoiCell> voronoi = _voronoi();
  List<VoronoiCell> _voronoi() {
    final sites = <String, ({PlanePoint point, List<int> members})>{};
    for (var i = 0; i < source.points.length; i++) {
      final p = site(i);
      sites
          .putIfAbsent('${p.x}:${p.y}', () => (point: p, members: []))
          .members
          .add(i);
    }
    final result = <VoronoiCell>[];
    for (final entry in sites.values) {
      var polygon = [
        const PlanePoint(0, 0),
        const PlanePoint(100, 0),
        const PlanePoint(100, 100),
        const PlanePoint(0, 100),
      ];
      for (final other in sites.values) {
        if (identical(entry.members, other.members)) continue;
        polygon = clip(
          polygon,
          2 * (other.point.x - entry.point.x),
          2 * (other.point.y - entry.point.y),
          other.point.x * other.point.x +
              other.point.y * other.point.y -
              entry.point.x * entry.point.x -
              entry.point.y * entry.point.y,
        );
      }
      result.add((
        site: entry.point,
        members: List<int>.unmodifiable(entry.members),
        polygon: List<PlanePoint>.unmodifiable(polygon),
      ));
    }
    return List.unmodifiable(result);
  }

  late final List<({String name, List<int> members})> regions = _regions();
  List<({String name, List<int> members})> _regions() {
    final groups = <String, List<int>>{};
    for (var i = 0; i < source.points.length; i++) {
      final name = source.points[i].region.trim();
      groups.putIfAbsent(name.isEmpty ? 'Sin región' : name, () => []).add(i);
    }
    return List.unmodifiable([
      for (final e in groups.entries)
        (name: e.key, members: List<int>.unmodifiable(e.value)),
    ]);
  }

  List<PlanePoint> hull(List<int> members) {
    final points = members.map(site).toSet().toList()
      ..sort((a, b) => a.x == b.x ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
    if (points.length < 3) return points;
    double cross(PlanePoint a, PlanePoint b, PlanePoint c) =>
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    List<PlanePoint> half(Iterable<PlanePoint> items) {
      final result = <PlanePoint>[];
      for (final point in items) {
        while (result.length >= 2 &&
            cross(result[result.length - 2], result.last, point) <= 0) {
          result.removeLast();
        }
        result.add(point);
      }
      return result;
    }

    final lower = half(points), upper = half(points.reversed);
    return [...lower.take(lower.length - 1), ...upper.take(upper.length - 1)];
  }

  late final List<HexCell> hexagons = _hexagons();
  List<HexCell> _hexagons() {
    const radius = 9.0;
    final centers = [
      for (var q = -1; q <= 9; q++)
        for (var r = -6; r <= 9; r++)
          PlanePoint(1.5 * radius * q, math.sqrt(3) * radius * (r + q / 2)),
    ];
    final groups = <int, List<int>>{};
    for (var i = 0; i < source.points.length; i++) {
      var best = double.infinity, selected = 0;
      for (var j = 0; j < centers.length; j++) {
        final dist = centers[j].distanceTo(site(i));
        if (dist < best) {
          best = dist;
          selected = j;
        }
      }
      groups.putIfAbsent(selected, () => []).add(i);
    }
    return List.unmodifiable([
      for (final group in groups.entries)
        (
          center: centers[group.key],
          members: List<int>.unmodifiable(group.value),
          polygon: List<PlanePoint>.unmodifiable([
            for (var k = 0; k < 6; k++)
              centers[group.key] +
                  PlanePoint(
                        math.cos(k * math.pi / 3),
                        math.sin(k * math.pi / 3),
                      ) *
                      radius,
          ]),
        ),
    ]);
  }

  late final List<LanguageSet> languages = _languages();
  List<LanguageSet> _languages() {
    final membership = <String, Set<int>>{}, display = <String, String>{};
    for (var i = 0; i < source.points.length; i++) {
      for (final value in source.points[i].languageNames) {
        final name = value.trim(), key = name.toLowerCase();
        if (key.isEmpty) continue;
        display.putIfAbsent(key, () => name);
        membership.putIfAbsent(key, () => {}).add(i);
      }
    }
    final result =
        [
          for (final e in membership.entries)
            (
              name: display[e.key]!,
              members: List<int>.unmodifiable(e.value.toList()..sort()),
            ),
        ]..sort((a, b) {
          final count = b.members.length.compareTo(a.members.length);
          return count == 0 ? a.name.compareTo(b.name) : count;
        });
    return List.unmodifiable(result);
  }

  late final List<LanguageIntersection> intersections = _intersections();
  List<LanguageIntersection> _intersections() {
    final groups = <int, List<String>>{};
    for (final language in languages) {
      final mask = language.members.fold<int>(0, (mask, i) => mask | (1 << i));
      groups.putIfAbsent(mask, () => []).add(language.name);
    }
    final result =
        [
          for (final e in groups.entries)
            (
              mask: e.key,
              members: List<int>.unmodifiable([
                for (var i = 0; i < 7; i++)
                  if (e.key & (1 << i) != 0) i,
              ]),
              languages: List<String>.unmodifiable(e.value),
            ),
        ]..sort((a, b) {
          final count = b.languages.length.compareTo(a.languages.length);
          return count == 0 ? a.mask.compareTo(b.mask) : count;
        });
    return List.unmodifiable(result);
  }

  List<LanguageSet> get vennSets => languages.take(3).toList();
  Map<int, List<int>> get vennBuckets {
    final sets = vennSets;
    final result = <int, List<int>>{};
    for (var i = 0; i < 7; i++) {
      var mask = 0;
      for (var k = 0; k < sets.length; k++) {
        if (sets[k].members.contains(i)) mask |= 1 << k;
      }
      result.putIfAbsent(mask, () => []).add(i);
    }
    return Map.unmodifiable(
      result.map(
        (mask, values) => MapEntry(mask, List<int>.unmodifiable(values)),
      ),
    );
  }

  double andrews(int i, double t) {
    final v = profiles[i].map((v) => v / 100).toList();
    return v[0] / math.sqrt2 +
        v[1] * math.sin(t) +
        v[2] * math.cos(t) +
        v[3] * math.sin(2 * t) +
        v[4] * math.cos(2 * t) +
        v[5] * math.sin(3 * t) +
        v[6] * math.cos(3 * t);
  }

  late final List<double> referenceProfile = List.unmodifiable([
    for (var k = 0; k < 7; k++)
      profiles.fold<double>(0, (sum, v) => sum + v[k]) / profiles.length,
  ]);
  static double mean(List<double> v) => v.reduce((a, b) => a + b) / v.length;
  static double standardDeviation(List<double> v) {
    final m = mean(v);
    return math.sqrt(
      v.fold<double>(0, (sum, x) => sum + math.pow(x - m, 2)) / (v.length - 1),
    );
  }

  double get referenceDeviation => standardDeviation(referenceProfile);
  TaylorPoint? taylor(int i) {
    final values = profiles[i], reference = referenceProfile;
    final sd = standardDeviation(values), ref = referenceDeviation;
    if (sd == 0 || ref == 0) return null;
    final m = mean(values), mr = mean(reference);
    final cov =
        List.generate(
          7,
          (k) => (values[k] - m) * (reference[k] - mr),
        ).reduce((a, b) => a + b) /
        6;
    final corr = (cov / (sd * ref)).clamp(-1.0, 1.0);
    final centered =
        List.generate(
          7,
          (k) => math.pow((values[k] - m) - (reference[k] - mr), 2),
        ).fold<num>(0, (a, b) => a + b) /
        6;
    return (
      index: i,
      standardDeviation: sd,
      correlation: corr,
      centeredRms: math.sqrt(centered),
    );
  }
}
