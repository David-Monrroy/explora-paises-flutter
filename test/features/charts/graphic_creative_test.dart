import 'dart:io';
import 'dart:math' as math;

import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_catalog.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/features/charts/data/creative_chart_data.dart';
import 'package:explora_paises/features/charts/data/graphic_chart_data.dart';
import 'package:explora_paises/features/charts/data/graphic_creative_catalog.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:explora_paises/features/charts/domain/chart_point.dart';
import 'package:explora_paises/features/charts/domain/graphic_chart_spec.dart';
import 'package:explora_paises/features/charts/presentation/renderers/graphic_renderer.dart';
import 'package:explora_paises/features/charts/presentation/renderers/graphic_scene_shape.dart';
import 'package:explora_paises/features/charts/presentation/screens/chart_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart' as g;

import 'creative_chart_data_test.dart' show samplePoints;

List<ChartPoint> get selectedPoints => ChartDataTransformer.transform(
  GraphicCreativeCatalog.all.first,
  emergencyCountries,
);
List<ChartPoint> withLanguages(List<List<String>> languages) => [
  for (var i = 0; i < 7; i++)
    ChartPoint(
      label: 'País $i',
      countryCode: 'P$i',
      value: 1,
      secondaryValue: 0,
      metrics: {for (final m in ChartMetric.values) m: 1},
      languageNames: languages[i],
    ),
];

void main() {
  test('las 252 figuras tienen firmas únicas sin librería, orden, color o métricas', () {
    String canonical(ChartDefinition chart) {
      final signature =
          chart.creative?.signature ??
          chart.syncfusionCreative?.signature ??
          chart.maintainedCreative?.signature ??
          chart.graphicCreative!.signature;
      return (signature
              .split('|')
              .where((p) => p != 'polar' && p != 'cartesian')
              .toList()
            ..sort())
          .join('|');
    }

    expect(ChartCatalog.all.map(canonical).toSet(), hasLength(252));
    expect(GraphicCreativeCatalog.specs, hasLength(63));
    expect(
      GraphicCreativeCatalog.specs.where((s) => s.componentCount == 1),
      hasLength(15),
    );
    for (final n in [2, 3, 4]) {
      expect(
        GraphicCreativeCatalog.specs.where((s) => s.componentCount == n),
        hasLength(16),
      );
    }
    expect(
      ChartCatalog.all.map((c) => c.number),
      List.generate(252, (i) => i + 1),
    );
    for (final spec in GraphicCreativeCatalog.specs) {
      expect(spec.visuals.toSet(), hasLength(spec.componentCount));
      if (spec.componentCount > 1) expect(spec.isProfile, isTrue);
      for (final visual in spec.visuals) {
        expect(spec.title, contains(visual.label));
        expect(visual.explanation, isNotEmpty);
      }
    }
  });

  test('63 vistas exigen siete códigos únicos y conservan la API original', () {
    for (final definition in GraphicCreativeCatalog.all) {
      final points = ChartDataTransformer.transform(
        definition,
        emergencyCountries,
      );
      expect(points, hasLength(7));
      for (final point in points) {
        final country = emergencyCountries.singleWhere(
          (c) => c.code == point.countryCode,
        );
        expect(point.languageNames, country.languages);
        expect(point.currencyNames, country.currencies);
        expect(point.region, country.region);
        for (final metric in ChartMetric.values) {
          expect(
            point.metrics[metric],
            ChartDataTransformer.metricValue(country, metric),
          );
        }
      }
      expect(
        ChartDataTransformer.transform(
          definition,
          emergencyCountries.take(6).toList(),
        ),
        isEmpty,
      );
      expect(
        ChartDataTransformer.transform(definition, [
          ...emergencyCountries.take(6),
          emergencyCountries.first,
        ]),
        isEmpty,
      );
    }
  });

  test(
    'Voronoi conserva el plano, no altera empates y cada celda es de su sitio',
    () {
      for (final points in [
        selectedPoints,
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ]) {
        final data = GraphicChartData(CreativeChartData(points));
        expect(data.voronoi.expand((c) => c.members).toSet(), {
          0,
          1,
          2,
          3,
          4,
          5,
          6,
        });
        var area = 0.0;
        for (final cell in data.voronoi) {
          var cross = 0.0;
          for (var k = 0; k < cell.polygon.length; k++) {
            final a = cell.polygon[k],
                b = cell.polygon[(k + 1) % cell.polygon.length];
            cross += a.x * b.y - a.y * b.x;
            expect(a.x, inInclusiveRange(-1e-8, 100 + 1e-8));
            expect(a.y, inInclusiveRange(-1e-8, 100 + 1e-8));
            for (final other in data.voronoi) {
              expect(
                a.distanceTo(cell.site),
                lessThanOrEqualTo(a.distanceTo(other.site) + 1e-7),
              );
            }
          }
          area += cross.abs() / 2;
          for (final i in cell.members) {
            expect(cell.site, data.site(i));
          }
        }
        expect(area, closeTo(10000, 1e-6));
        if (data.source.maximum(ChartMetric.area) == 0) {
          expect(data.voronoi, hasLength(1));
        }
      }
    },
  );

  test(
    'dendrograma de enlace promedio y árbol mínimo preservan siete perfiles',
    () {
      final data = GraphicChartData(
        CreativeChartData(samplePoints([0, 0, 25, 50, 75, 100, 100])),
      );
      expect(data.distance(0, 6), 100);
      expect(data.distance(0, 1), 0);
      expect(data.dendrogram.leafOrder.toSet(), {0, 1, 2, 3, 4, 5, 6});
      void check(ProfileCluster c) {
        if (c.isLeaf) {
          expect(c.members, hasLength(1));
          return;
        }
        final left = c.left!, right = c.right!;
        final average =
            [
              for (final a in left.members)
                for (final b in right.members) data.distance(a, b),
            ].reduce((a, b) => a + b) /
            (left.members.length * right.members.length);
        expect(c.distance, closeTo(average, 1e-9));
        expect(c.distance, greaterThanOrEqualTo(left.distance));
        expect(c.distance, greaterThanOrEqualTo(right.distance));
        check(left);
        check(right);
      }

      check(data.dendrogram);
      expect(data.spanningTree, hasLength(6));
      expect(
        data.spanningTree.fold<double>(0, (sum, e) => sum + e.distance),
        100,
      );
      final visited = <int>{0};
      while (true) {
        final old = visited.length;
        for (final e in data.spanningTree) {
          if (visited.contains(e.a) || visited.contains(e.b)) {
            visited.addAll([e.a, e.b]);
          }
        }
        if (visited.length == old) break;
      }
      expect(visited, hasLength(7));
    },
  );

  test(
    'UpSet y Venn cuentan membresías exactas sin inventar idiomas ni países',
    () {
      final data = GraphicChartData(
        CreativeChartData(
          withLanguages([
            ['English', ' French ', 'English'],
            ['english'],
            ['French'],
            ['Spanish'],
            ['Spanish', 'French'],
            [],
            ['German'],
          ]),
        ),
      );
      expect(data.languages, hasLength(4));
      expect(data.intersections.expand((g) => g.languages), hasLength(4));
      for (final intersection in data.intersections) {
        for (final language in intersection.languages) {
          expect(
            intersection.members,
            data.languages.singleWhere((l) => l.name == language).members,
          );
        }
      }
      expect(data.vennSets.first.name, 'French');
      expect(data.vennSets.first.members, [0, 2, 4]);
      expect(data.vennBuckets.values.expand((v) => v).toList()..sort(), [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
      expect(data.vennBuckets[0], containsAll([5, 6]));
      final zero = GraphicChartData(
        CreativeChartData(samplePoints(List.filled(7, 0))),
      );
      expect(zero.languages, isEmpty);
      expect(zero.intersections, isEmpty);
      expect(zero.vennBuckets, {
        0: [0, 1, 2, 3, 4, 5, 6],
      });
    },
  );

  test(
    'hexágonos, funciones y Taylor se calculan solo de las observaciones',
    () {
      for (final points in [
        selectedPoints,
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ]) {
        final data = GraphicChartData(CreativeChartData(points));
        expect(data.hexagons.expand((g) => g.members).toList()..sort(), [
          0,
          1,
          2,
          3,
          4,
          5,
          6,
        ]);
        for (var i = 0; i < 7; i++) {
          final v = data.profiles[i].map((v) => v / 100).toList();
          expect(
            data.andrews(i, 0),
            closeTo(v[0] / math.sqrt2 + v[2] + v[4] + v[6], 1e-9),
          );
          expect(
            data.andrews(i, -math.pi),
            closeTo(data.andrews(i, math.pi), 1e-9),
          );
          final point = data.taylor(i);
          if (point != null) {
            expect(point.correlation, inInclusiveRange(-1, 1));
            expect(
              point.centeredRms * point.centeredRms,
              closeTo(
                math.pow(point.standardDeviation, 2) +
                    math.pow(data.referenceDeviation, 2) -
                    2 *
                        point.standardDeviation *
                        data.referenceDeviation *
                        point.correlation,
                1e-7,
              ),
            );
          }
          expect(data.quantile(i, 0.5), (List.of(data.profiles[i])..sort())[3]);
        }
      }
      final flat = GraphicChartData(
        CreativeChartData(samplePoints(List.filled(7, 1))),
      );
      expect(List.generate(7, flat.taylor), everyElement(isNull));
      expect(flat.hexagons, hasLength(1));
    },
  );

  testWidgets(
    '63 vistas tienen un único Chart nativo y soportan ceros y empates en móvil',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const capture = bool.fromEnvironment('CAPTURE_CHART_PREVIEWS');
      if (capture) {
        await tester.runAsync(() async {
          final bytes = await File('C:/Windows/Fonts/segoeui.ttf')
              .readAsBytes();
          for (final name in ['Segoe UI', 'PreviewFont']) {
            await (FontLoader(
              name,
            )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
          }
        });
      }
      final datasets = [
        selectedPoints,
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ];
      for (var variant = 0; variant < datasets.length; variant++) {
        for (var i = 0; i < 63; i++) {
          final definition = GraphicCreativeCatalog.all[i];
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: capture ? 'PreviewFont' : null),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: GraphicRenderer(
                      key: ValueKey('${definition.id}-$variant'),
                      definition: definition,
                      points: datasets[variant],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final nativeFinder = find.byWidgetPredicate(
            (w) => w is g.Chart<GraphicCountryDatum>,
          );
          expect(nativeFinder, findsOneWidget);
          final native = tester.widget<g.Chart<GraphicCountryDatum>>(
            nativeFinder,
          );
          expect(
            native.data.map((d) => d.point.countryCode).toSet(),
            datasets[variant].map((p) => p.countryCode).toSet(),
          );
          expect(
            native.marks,
            hasLength(definition.graphicCreative!.componentCount),
          );
          expect(native.marks.every((m) => m is g.CustomMark), isTrue);
          expect(
            tester.takeException(),
            isNull,
            reason: '${definition.id} / $variant',
          );
          // Test actual native mark output too: a blank chart must not pass merely
          // because the widget tree exists. Every layer has seven native tuples.
          final data = GraphicChartData(CreativeChartData(datasets[variant]));
          for (
            var layer = 0;
            layer < definition.graphicCreative!.componentCount;
            layer++
          ) {
            final shape = GraphicSceneShape(
              spec: definition.graphicCreative!,
              data: data,
              layer: layer,
              showAxes: layer == 0,
            );
            final attributes = [
              for (var k = 0; k < 7; k++)
                g.Attributes(
                  index: k,
                  position: [const Offset(0.5, 0.5)],
                  shape: shape,
                  color: Colors.black,
                ),
            ];
            final coord = g.RectCoordConv(
              const Rect.fromLTWH(0, 0, 268, 330),
              2,
              0.5,
              false,
              [0, 1],
              [0, 1],
            );
            expect(
              shape.drawGroupPrimitives(attributes, coord, Offset.zero),
              isNotEmpty,
              reason: '${definition.id} / capa $layer / $variant',
            );
          }
          if (capture &&
              variant == 0 &&
              (i < 15 || [15, 31, 47, 62].contains(i))) {
            await expectLater(
              find.byKey(const Key('graphic-canvas')),
              matchesGoldenFile(
                '../../../build/chart_previews/graphic-${i + 1}.png',
              ),
            );
          }
        }
      }
    },
  );

  testWidgets(
    'el detalle conserva siete países al resaltar en móvil y escritorio',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [320.0, 1024.0]) {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: ChartDetailScreen(
              key: ValueKey(width),
              definition: GraphicCreativeCatalog.all.last,
              countries: emergencyCountries,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final chip = find.byKey(const ValueKey('highlight-COL'));
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(chip);
        await tester.pumpAndSettle();
        final plot = tester.widget<GraphicCountryPlot>(
          find.byType(GraphicCountryPlot),
        );
        expect(plot.highlightedCode, 'COL');
        expect(plot.data.source.points, hasLength(7));
        expect(plot.spec.componentCount, 4);
        final tile = find.byKey(const ValueKey('source-values-COL'));
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(find.text('Idiomas registrados: Español'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
