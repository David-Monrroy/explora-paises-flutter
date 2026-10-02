import 'dart:io';
import 'dart:math' as math;

import 'package:charts_flutter_maintained/charts_flutter_maintained.dart'
    as charts;
import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/features/charts/data/creative_chart_data.dart';
import 'package:explora_paises/features/charts/data/fl_creative_catalog.dart';
import 'package:explora_paises/features/charts/data/maintained_chart_data.dart';
import 'package:explora_paises/features/charts/data/maintained_creative_catalog.dart';
import 'package:explora_paises/features/charts/data/syncfusion_creative_catalog.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:explora_paises/features/charts/domain/chart_point.dart';
import 'package:explora_paises/features/charts/domain/maintained_chart_spec.dart';
import 'package:explora_paises/features/charts/presentation/renderers/maintained_renderer.dart';
import 'package:explora_paises/features/charts/presentation/screens/chart_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'creative_chart_data_test.dart' show samplePoints;

List<ChartPoint> get selectedPoints => ChartDataTransformer.transform(
  MaintainedCreativeCatalog.all.first,
  emergencyCountries,
);

void main() {
  test('63 figuras únicas, sin repetir FL Chart ni Syncfusion', () {
    final specs = MaintainedCreativeCatalog.specs;
    expect(specs, hasLength(63));
    expect(specs.map((s) => s.signature).toSet(), hasLength(63));
    expect(specs.where((s) => s.componentCount == 1), hasLength(15));
    for (final count in [2, 3, 4]) {
      expect(specs.where((s) => s.componentCount == count), hasLength(16));
    }
    String canonical(String signature) =>
        (signature
                .split('|')
                .where((part) => part != 'polar' && part != 'cartesian')
                .toList()
              ..sort())
            .join('|');
    final previous = {
      ...FlCreativeCatalog.specs.map((s) => canonical(s.signature)),
      ...SyncfusionCreativeCatalog.specs.map((s) => canonical(s.signature)),
    };
    expect(
      specs.map((s) => canonical(s.signature)).toSet().intersection(previous),
      isEmpty,
    );
    for (final spec in specs) {
      expect(spec.visuals.toSet(), hasLength(spec.componentCount));
      if (spec.componentCount > 1) {
        expect(spec.isProfile, isTrue);
        expect(
          spec.visuals.any(
            (v) => [
              MaintainedVisual.violin,
              MaintainedVisual.ridgeline,
              MaintainedVisual.rug,
            ].contains(v),
          ),
          isTrue,
        );
      }
      for (final visual in spec.visuals) {
        expect(spec.title, contains(visual.label));
        expect(visual.explanation, isNotEmpty);
      }
    }
  });

  test(
    'la selección conserva métricas, regiones, monedas y fronteras originales',
    () {
      for (final definition in MaintainedCreativeCatalog.all) {
        final points = ChartDataTransformer.transform(
          definition,
          emergencyCountries,
        );
        expect(points, hasLength(7));
        for (final point in points) {
          final country = emergencyCountries.singleWhere(
            (c) => c.code == point.countryCode,
          );
          expect(point.region, country.region);
          expect(point.currencyNames, country.currencies);
          expect(point.borderCodes, country.borders);
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
    },
  );

  test('las relaciones solo conectan registros reales de los siete países', () {
    final data = MaintainedChartData(CreativeChartData(selectedPoints));
    Set<String> pairs(List<CountryRelation> relations) => {
      for (final relation in relations)
        ([
          data.source.points[relation.a].axisLabel,
          data.source.points[relation.b].axisLabel,
        ]..sort()).join('-'),
    };
    expect(pairs(data.currencyRelations), {'DEU-FRA'});
    expect(pairs(data.borderRelations), {'BRA-COL', 'BRA-FRA', 'DEU-FRA'});
    expect(data.currencyRelations.single.weight, 1);
    expect(data.regions.expand((g) => g.countries).toSet(), {
      0,
      1,
      2,
      3,
      4,
      5,
      6,
    });
    for (final metric in [ChartMetric.population, ChartMetric.area]) {
      expect(
        data.regions.fold<double>(
          0,
          (sum, g) => sum + data.groupShare(g, metric),
        ),
        closeTo(100, 1e-9),
      );
    }
    final empty = MaintainedChartData(
      CreativeChartData(samplePoints(List.filled(7, 1))),
    );
    expect(empty.currencyRelations, isEmpty);
    expect(empty.borderRelations, isEmpty);
    expect(empty.regions.single.name, 'Sin región');
    // Parentheses are symbols/codes, not a distinct currency. Case and whitespace
    // do not fabricate multiple relationships or double-count duplicated names.
    final metadata = [
      for (var i = 0; i < 7; i++)
        ChartPoint(
          label: 'P$i',
          countryCode: 'P$i',
          value: 1,
          secondaryValue: 0,
          metrics: {for (final m in ChartMetric.values) m: 1},
          currencyNames: i == 0
              ? [' Euro (€) ', 'Euro (€)']
              : i == 1
              ? ['euro (EUR)']
              : [],
          borderCodes: i == 1 ? ['P0', 'OUTSIDE'] : [],
        ),
    ];
    final clean = MaintainedChartData(CreativeChartData(metadata));
    expect(clean.currencyRelations, [(a: 0, b: 1, weight: 1)]);
    expect(clean.borderRelations, [(a: 0, b: 1, weight: 1)]);
  });

  test('treemap y círculos conservan proporciones sin solapamientos', () {
    for (final points in [
      selectedPoints,
      samplePoints([0, 0, 1, 1, 10, 10, 100]),
      samplePoints(List.filled(7, 1)),
    ]) {
      final data = MaintainedChartData(CreativeChartData(points));
      for (final item in data.treemap) {
        expect(
          item.bounds.width * item.bounds.height / 100,
          closeTo(data.source.share(item.index, ChartMetric.area), 1e-9),
        );
        for (final other in data.treemap.where((o) => o.index != item.index)) {
          final width =
              math.min(item.bounds.right, other.bounds.right) -
              math.max(item.bounds.left, other.bounds.left);
          final height =
              math.min(item.bounds.bottom, other.bounds.bottom) -
              math.max(item.bounds.top, other.bounds.top);
          expect(width <= 1e-9 || height <= 1e-9, isTrue);
        }
      }
      final circles = data.packedCircles;
      final r2sum = circles.fold<double>(
        0,
        (sum, c) => sum + c.radius * c.radius,
      );
      for (final circle in circles) {
        expect(
          circle.radius * circle.radius / r2sum * 100,
          closeTo(data.source.share(circle.index, ChartMetric.area), 1e-9),
        );
        expect(circle.center.x - circle.radius, greaterThanOrEqualTo(0));
        expect(circle.center.x + circle.radius, lessThanOrEqualTo(100));
        expect(circle.center.y - circle.radius, greaterThanOrEqualTo(0));
        expect(circle.center.y + circle.radius, lessThanOrEqualTo(100));
        for (final other in circles.where((o) => o.index != circle.index)) {
          expect(
            circle.center.distanceTo(other.center),
            greaterThanOrEqualTo(circle.radius + other.radius),
          );
        }
      }
    }
    final zero = MaintainedChartData(
      CreativeChartData(samplePoints(List.filled(7, 0))),
    );
    expect(zero.treemap, isEmpty);
    expect(zero.packedCircles, isEmpty);
    expect(List.generate(7, zero.ternary), everyElement(isNull));
  });

  test('perfiles, composición y enjambre conservan valores y empates', () {
    for (final points in [
      selectedPoints,
      samplePoints(List.filled(7, 0)),
      samplePoints(List.filled(7, 1)),
    ]) {
      final data = MaintainedChartData(CreativeChartData(points));
      expect(data.kernelMaximum, greaterThan(0));
      for (var i = 0; i < 7; i++) {
        expect(data.profile(i), hasLength(7));
        expect(data.profile(i), everyElement(inInclusiveRange(0, 100)));
        final profile = data.profile(i)..sort();
        expect(data.quantile(i, 0.5), profile[3]);
        final ternary = data.ternary(i);
        if (ternary != null) {
          expect(
            ternary.population + ternary.area + ternary.density,
            closeTo(1, 1e-9),
          );
        }
        // Numerical integral of the reflected KDE, including boundary samples.
        var integral = 0.0;
        for (var x = 0.0; x < 100; x += 0.5) {
          integral += (data.kernel(i, x) + data.kernel(i, x + 0.5)) / 2 * 0.5;
        }
        expect(integral, closeTo(1, 0.001));
      }
      expect(data.swarm.map((p) => p.index).toSet(), {0, 1, 2, 3, 4, 5, 6});
      for (final point in data.swarm) {
        expect(point.x, data.source.relative(point.index, ChartMetric.density));
        for (final other in data.swarm.where((p) => p.index != point.index)) {
          expect(
            math.sqrt(
              math.pow(point.x - other.x, 2) + math.pow(point.y - other.y, 2),
            ),
            greaterThanOrEqualTo(10),
          );
        }
      }
    }
  });

  testWidgets(
    '63 figuras en un solo canvas, con datos normales, ceros y empates',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
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
        for (var i = 0; i < MaintainedCreativeCatalog.all.length; i++) {
          final definition = MaintainedCreativeCatalog.all[i];
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: capture ? 'PreviewFont' : null),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: const Key('maintained-preview'),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: MaintainedRenderer(
                        key: ValueKey('${definition.id}-$variant'),
                        definition: definition,
                        points: datasets[variant],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(charts.ScatterPlotChart), findsOneWidget);
          expect(find.byKey(const Key('maintained-canvas')), findsOneWidget);
          final native = tester.widget<charts.ScatterPlotChart>(
            find.byType(charts.ScatterPlotChart),
          );
          expect(native.seriesList.single.data, [0, 1, 2, 3, 4, 5, 6]);
          expect(native.animate, isFalse);
          expect(
            tester.takeException(),
            isNull,
            reason: '${definition.id}: variante $variant',
          );
          if (variant == 1 && [0, 1, 2, 5, 6, 7, 8].contains(i)) {
            expect(
              find.text(
                'No hay un total positivo para repartir. Los siete países y sus ceros permanecen en la leyenda.',
              ),
              findsOneWidget,
            );
          }
          if (capture &&
              variant == 0 &&
              (i < 15 || [15, 31, 47, 62].contains(i))) {
            await expectLater(
              find.byKey(const Key('maintained-canvas')),
              matchesGoldenFile(
                '../../../build/chart_previews/maintained-${i + 1}.png',
              ),
            );
          }
        }
      }
    },
  );

  testWidgets(
    'resaltar conserva los siete países, datos originales y figura única',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [320.0, 1024.0]) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: ChartDetailScreen(
              key: ValueKey(width),
              definition: MaintainedCreativeCatalog.all.last,
              countries: emergencyCountries,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final chip = find.byKey(const ValueKey('highlight-COL'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        final plot = tester.widget<MaintainedCountryPlot>(
          find.byType(MaintainedCountryPlot),
        );
        expect(plot.highlightedCode, 'COL');
        expect(plot.data.source.points, hasLength(7));
        expect(plot.spec.componentCount, 4);
        expect(find.byType(charts.ScatterPlotChart), findsOneWidget);
        final tile = find.byKey(const ValueKey('source-values-COL'));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(
          find.text('Fronteras registradas (códigos): PAN, VEN, BRA, PER, ECU'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}
