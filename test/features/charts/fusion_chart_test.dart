import 'dart:io';

import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/features/charts/data/creative_chart_data.dart';
import 'package:explora_paises/features/charts/data/fl_creative_catalog.dart';
import 'package:explora_paises/features/charts/data/fusion_chart_data.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:explora_paises/features/charts/domain/fusion_chart.dart';
import 'package:explora_paises/features/charts/presentation/renderers/fl_fusion_renderer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'creative_chart_data_test.dart' show samplePoints;

void main() {
  test(
    'la cascada conserva aportes y termina en cien sin inventar valores',
    () {
      final source = CreativeChartData(samplePoints([0, 1, 1, 1, 1, 1, 2]));
      final layer = FusionLayerData(
        const FusionLayer(FusionMark.waterfall, ChartMetric.population),
        source,
      );
      expect(layer.bases.first, 0);
      expect(layer.values.first, 0);
      expect(layer.values.last, closeTo(100, 1e-9));
      for (var i = 0; i < 7; i++) {
        expect(
          layer.values[i] - layer.bases[i],
          closeTo(source.share(i, ChartMetric.population), 1e-9),
        );
        if (i > 0) expect(layer.bases[i], layer.values[i - 1]);
      }
    },
  );

  test('la rosa y las burbujas usan áreas proporcionales', () {
    final source = CreativeChartData(samplePoints([1, 4, 1, 1, 1, 1, 1]));
    final rose = FusionLayerData(
      const FusionLayer(FusionMark.rose, ChartMetric.area),
      source,
    );
    final bubble = FusionLayerData(
      const FusionLayer(
        FusionMark.bubble,
        ChartMetric.population,
        secondaryMetric: ChartMetric.area,
      ),
      source,
    );
    expect(rose.roseRadius(1) / rose.roseRadius(0), 2);
    expect(bubble.bubbleRadius(1) / bubble.bubbleRadius(0), 2);
  });

  test('cada fusión declara marcas compatibles y las métricas secundarias necesarias', () {
    for (final chart in FlCreativeCatalog.all.skip(15)) {
      final spec = chart.creative!.fusion!;
      expect(spec.layers.length, inInclusiveRange(2, 4));
      for (final layer in spec.layers) {
        if ([
          FusionMark.bubble,
          FusionMark.band,
          FusionMark.dumbbell,
        ].contains(layer.mark)) {
          expect(layer.secondaryMetric, isNotNull, reason: chart.id);
          expect(layer.secondaryMetric, isNot(layer.metric), reason: chart.id);
        }
        if (spec.projection == FusionProjection.polar) {
          expect([
            FusionMark.radar,
            FusionMark.rose,
            FusionMark.bubble,
            FusionMark.lollipop,
          ], contains(layer.mark));
        } else {
          expect([
            FusionMark.radar,
            FusionMark.rose,
          ], isNot(contains(layer.mark)));
        }
      }
    }
  });

  testWidgets(
    'las 48 combinaciones tienen una sola figura y admiten ceros y empates en móvil',
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
      final variants = [
        ChartDataTransformer.transform(
          FlCreativeCatalog.all.first,
          emergencyCountries,
        ),
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ];
      for (var variant = 0; variant < variants.length; variant++) {
        for (final chart in FlCreativeCatalog.all.skip(15)) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: capture ? 'PreviewFont' : null),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: const Key('fusion-preview'),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: FlFusionRenderer(
                        key: ValueKey('${chart.id}-$variant'),
                        spec: chart.creative!.fusion!,
                        data: CreativeChartData(variants[variant]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(find.byType(FlFusionPlot), findsOneWidget, reason: chart.id);
          expect(find.byKey(const Key('fusion-canvas')), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '${chart.id}, variante $variant',
          );
          if (capture &&
              variant == 0 &&
              [16, 29, 32, 48, 63].contains(chart.number)) {
            await expectLater(
              find.byKey(const Key('fusion-preview')),
              matchesGoldenFile(
                '../../../build/chart_previews/fusion-${chart.number}.png',
              ),
            );
          }
        }
      }
    },
  );

  testWidgets(
    'barras, líneas y burbujas comparten coordenadas y siete posiciones',
    (tester) async {
      final chart = FlCreativeCatalog.all[31];
      final source = CreativeChartData(
        ChartDataTransformer.transform(chart, emergencyCountries),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 360,
            height: 360,
            child: FlFusionPlot(spec: chart.creative!.fusion!, data: source),
          ),
        ),
      );
      await tester.pump();
      for (final line in tester.widgetList<LineChart>(find.byType(LineChart))) {
        expect(line.data.minX, -0.5);
        expect(line.data.maxX, 6.5);
        expect(line.data.minY, FlFusionPlot.minY);
        expect(line.data.maxY, FlFusionPlot.maxY);
      }
      final bars = tester.widget<BarChart>(find.byType(BarChart));
      expect(bars.data.barGroups.map((group) => group.x), [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
      expect(bars.data.minY, FlFusionPlot.minY);
      expect(bars.data.maxY, FlFusionPlot.maxY);
      final scatter = tester.widget<ScatterChart>(find.byType(ScatterChart));
      expect(scatter.data.scatterSpots.map((spot) => spot.x), [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
      expect(scatter.data.minX, -0.5);
      expect(scatter.data.maxX, 6.5);
      expect(
        tester.getRect(find.byType(BarChart)),
        tester.getRect(find.byType(ScatterChart)),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
