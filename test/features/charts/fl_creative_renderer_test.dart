import 'dart:io';

import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/features/charts/data/creative_chart_data.dart';
import 'package:explora_paises/features/charts/data/fl_creative_catalog.dart';
import 'package:explora_paises/features/charts/domain/creative_chart.dart';
import 'package:explora_paises/features/charts/presentation/renderers/fl_chart_renderer.dart';
import 'package:explora_paises/features/charts/presentation/renderers/fl_fusion_renderer.dart';
import 'package:explora_paises/features/charts/presentation/screens/chart_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'creative_chart_data_test.dart' show samplePoints;

void main() {
  testWidgets(
    'las 15 formas se dibujan en móvil con datos normales, ceros y empates',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
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
          FlCreativeCatalog.all.first,
          emergencyCountries,
        ),
        samplePoints(List.filled(7, 0)),
        samplePoints(List.filled(7, 1)),
      ];
      for (var variant = 0; variant < datasets.length; variant++) {
        for (final visual in CreativeVisual.values) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(fontFamily: capture ? 'PreviewFont' : null),
              home: Scaffold(
                body: RepaintBoundary(
                  key: const Key('preview'),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          visual.label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          visual.explanation,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 290,
                          child: FlCreativePlot(
                            key: ValueKey('${visual.name}-$variant'),
                            visual: visual,
                            data: CreativeChartData(datasets[variant]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(visual.axes, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${visual.name}, variante $variant',
          );
          if (capture && variant == 0) {
            await expectLater(
              find.byKey(const Key('preview')),
              matchesGoldenFile(
                '../../../build/chart_previews/${visual.name}.png',
              ),
            );
          }
        }
      }
    },
  );

  testWidgets(
    'una combinación de cuatro mantiene los siete países al resaltar',
    (tester) async {
      final chart = FlCreativeCatalog.all[47];
      for (final width in [320.0, 1024.0]) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: ChartDetailScreen(
              key: ValueKey(width),
              definition: chart,
              countries: emergencyCountries,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FlCreativePlot), findsNothing);
        expect(find.byType(FlFusionPlot), findsOneWidget);
        expect(find.byKey(const Key('fusion-canvas')), findsOneWidget);
        final chip = find.byKey(const ValueKey('highlight-COL'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pump();
        final plot = tester.widget<FlFusionPlot>(find.byType(FlFusionPlot));
        expect(plot.highlightedCode, 'COL');
        expect(plot.data.points, hasLength(7));
        expect(plot.spec.layers, hasLength(4));
        expect(tester.takeException(), isNull);
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
