import 'dart:io';

import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/features/charts/data/creative_chart_data.dart';
import 'package:explora_paises/features/charts/data/fl_creative_catalog.dart';
import 'package:explora_paises/features/charts/data/syncfusion_chart_data.dart';
import 'package:explora_paises/features/charts/data/syncfusion_creative_catalog.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:explora_paises/features/charts/domain/syncfusion_chart_spec.dart';
import 'package:explora_paises/features/charts/presentation/renderers/syncfusion_renderer.dart';
import 'package:explora_paises/features/charts/presentation/screens/chart_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartPoint;

import 'creative_chart_data_test.dart' show samplePoints;

void main() {
  test('63 geometrías únicas y sin repetir las formas de FL Chart', () {
    final specs = SyncfusionCreativeCatalog.specs;
    expect(specs, hasLength(63));
    expect(specs.map((spec) => spec.signature).toSet(), hasLength(63));
    expect(specs.where((spec) => spec.componentCount == 1), hasLength(15));
    for (final count in [2, 3, 4]) {
      expect(
        specs.where((spec) => spec.componentCount == count),
        hasLength(16),
      );
    }
    // Compare shape sets without library names, metrics, colors or layer order.
    final fl = FlCreativeCatalog.specs
        .map(
          (spec) =>
              (spec.signature
                      .split('|')
                      .where((part) => part != 'cartesian' && part != 'polar')
                      .toList()
                    ..sort())
                  .join('|'),
        )
        .toSet();
    expect(
      specs.map((spec) => spec.signature).toSet().intersection(fl),
      isEmpty,
    );
    for (final spec in specs) {
      expect(spec.visuals.toSet(), hasLength(spec.componentCount));
      if (spec.componentCount > 1) {
        expect(spec.visuals.every((visual) => visual.isCartesian), isTrue);
      }
      for (final visual in spec.visuals) {
        expect(spec.title, contains(visual.label));
        expect(visual.explanation, isNotEmpty);
      }
    }
  });

  test(
    'las 63 vistas conservan las métricas y exigen siete países distintos',
    () {
      for (final chart in SyncfusionCreativeCatalog.all) {
        final points = ChartDataTransformer.transform(
          chart,
          emergencyCountries,
        );
        expect(points, hasLength(7));
        for (final point in points) {
          final country = emergencyCountries.singleWhere(
            (country) => country.code == point.countryCode,
          );
          for (final metric in ChartMetric.values) {
            expect(
              point.metrics[metric],
              ChartDataTransformer.metricValue(country, metric),
            );
          }
        }
        expect(
          ChartDataTransformer.transform(
            chart,
            emergencyCountries.take(6).toList(),
          ),
          isEmpty,
        );
        expect(
          ChartDataTransformer.transform(chart, [
            ...emergencyCountries.take(6),
            emergencyCountries.first,
          ]),
          isEmpty,
        );
      }
    },
  );

  test(
    'los rangos contienen indicadores reales y el complemento no inventa datos',
    () {
      for (final points in [
        ChartDataTransformer.transform(
          SyncfusionCreativeCatalog.all.first,
          emergencyCountries,
        ),
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ]) {
        final data = SyncfusionChartData(CreativeChartData(points));
        expect(data.histogramInterval, greaterThan(0));
        for (final country in data.countries) {
          for (final metric in ChartMetric.values) {
            expect(country.relative(metric), inInclusiveRange(0, 100));
            expect(
              country.relative(metric),
              inInclusiveRange(
                country.low(ChartMetric.values),
                country.high(ChartMetric.values),
              ),
            );
          }
          expect(
            country.relative(ChartMetric.languages),
            inInclusiveRange(
              country.low(discreteProfileMetrics),
              country.high(discreteProfileMetrics),
            ),
          );
          expect(
            country.relative(ChartMetric.borders),
            inInclusiveRange(
              country.low(discreteProfileMetrics),
              country.high(discreteProfileMetrics),
            ),
          );
          expect(
            country.relative(ChartMetric.density) + country.densityComplement,
            data.source.maximum(ChartMetric.density) == 0
                ? 0
                : closeTo(100, 1e-9),
          );
        }
      }
    },
  );

  testWidgets(
    'las 63 figuras aceptan datos normales, ceros y empates en móvil',
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
          await (FontLoader(
            'PreviewFont',
          )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
        });
      }
      final datasets = [
        ChartDataTransformer.transform(
          SyncfusionCreativeCatalog.all.first,
          emergencyCountries,
        ),
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ];
      for (var variant = 0; variant < datasets.length; variant++) {
        for (
          var index = 0;
          index < SyncfusionCreativeCatalog.all.length;
          index++
        ) {
          final chart = SyncfusionCreativeCatalog.all[index];
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: capture ? 'PreviewFont' : null),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: const Key('syncfusion-preview'),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: SyncfusionRenderer(
                        key: ValueKey('${chart.id}-$variant'),
                        definition: chart,
                        points: datasets[variant],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(SyncfusionCountryPlot),
            findsOneWidget,
            reason: chart.id,
          );
          expect(find.byKey(const Key('syncfusion-canvas')), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '${chart.id}, variante $variant',
          );
          if (chart.syncfusionCreative!.componentCount > 1) {
            expect(find.byType(SfCartesianChart), findsOneWidget);
            final native = tester.widget<SfCartesianChart>(
              find.byType(SfCartesianChart),
            );
            expect((native.primaryYAxis as NumericAxis).minimum, 0);
            expect((native.primaryYAxis as NumericAxis).maximum, 100);
            expect(native.enableSideBySideSeriesPlacement, isFalse);
            for (final series in native.series) {
              expect(series.dataSource, hasLength(7));
            }
          }
          if (capture &&
              variant == 0 &&
              (index < 15 || [15, 31, 47, 62].contains(index))) {
            await expectLater(
              find.byKey(const Key('syncfusion-preview')),
              matchesGoldenFile(
                '../../../build/chart_previews/syncfusion-${index + 1}.png',
              ),
            );
          }
        }
      }
    },
  );

  testWidgets(
    'histograma, embudo, pirámide y arcos usan fuentes y unidades correctas',
    (tester) async {
      for (var index = 11; index < 15; index++) {
        final definition = SyncfusionCreativeCatalog.all[index];
        final data = SyncfusionChartData(
          CreativeChartData(
            ChartDataTransformer.transform(definition, emergencyCountries),
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 350,
                child: SyncfusionCountryPlot(
                  key: ValueKey(index),
                  spec: definition.syncfusionCreative!,
                  data: data,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (index == 11) {
          final native = tester.widget<SfCartesianChart>(
            find.byType(SfCartesianChart),
          );
          final histogram =
              native.series.single
                  as HistogramSeries<SyncfusionCountryDatum, double>;
          expect(histogram.dataSource, hasLength(7));
          expect(histogram.showNormalDistributionCurve, isFalse);
          for (final point in histogram.dataSource!) {
            expect(
              histogram.yValueMapper!(point, point.index),
              point.raw(ChartMetric.density),
            );
          }
        } else if (index == 12) {
          final series =
              tester.widget<SfFunnelChart>(find.byType(SfFunnelChart)).series
                  as FunnelSeries<SyncfusionCountryDatum, String>;
          final values = [
            for (final point in series.dataSource!)
              series.yValueMapper!(point, point.index)!.toDouble(),
          ];
          // Native funnel paint order is reversed: ascending source means descending on screen.
          expect(values, List.of(values)..sort());
          expect(
            values.fold<double>(0, (sum, value) => sum + value),
            data.source.total(ChartMetric.population),
          );
        } else if (index == 13) {
          final series =
              tester.widget<SfPyramidChart>(find.byType(SfPyramidChart)).series
                  as PyramidSeries<SyncfusionCountryDatum, String>;
          expect(series.pyramidMode, PyramidMode.surface);
          final values = [
            for (final point in series.dataSource!)
              series.yValueMapper!(point, point.index)!.toDouble(),
          ];
          expect(
            values.fold<double>(0, (sum, value) => sum + value),
            data.source.total(ChartMetric.area),
          );
        } else {
          final series =
              tester
                      .widget<SfCircularChart>(find.byType(SfCircularChart))
                      .series
                      .single
                  as RadialBarSeries<SyncfusionCountryDatum, String>;
          expect(series.dataSource, hasLength(7));
          expect(series.maximumValue, 100);
          for (final point in series.dataSource!) {
            expect(
              series.yValueMapper!(point, point.index),
              point.relative(ChartMetric.area),
            );
          }
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'resaltar no filtra países y el detalle funciona en móvil y escritorio',
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
              definition: SyncfusionCreativeCatalog.all.last,
              countries: emergencyCountries,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final chip = find.byKey(const ValueKey('highlight-COL'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        final plot = tester.widget<SyncfusionCountryPlot>(
          find.byType(SyncfusionCountryPlot),
        );
        expect(plot.highlightedCode, 'COL');
        expect(plot.data.countries, hasLength(7));
        expect(plot.spec.componentCount, 4);
        expect(find.byType(SfCartesianChart), findsOneWidget);
        final axis = tester
            .widget<SfCartesianChart>(find.byType(SfCartesianChart))
            .primaryXAxis;
        expect(axis.plotBands, hasLength(1));
        expect(axis.plotBands.single.start, 1.7);
        expect(axis.plotBands.single.end, 2.3);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
