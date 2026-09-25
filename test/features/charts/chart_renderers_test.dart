import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_catalog.dart';
import 'package:explora_paises/features/charts/presentation/screens/chart_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('los 252 renderizadores aceptan siete países', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final chart in ChartCatalog.all) {
      await tester.pumpWidget(
        MaterialApp(
          home: ChartDetailScreen(
            key: ValueKey(chart.id),
            definition: chart,
            countries: emergencyCountries,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: chart.id);
    }
  });
}
