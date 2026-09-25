import 'package:explora_paises/features/charts/data/chart_catalog.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el catálogo contiene exactamente 252 gráficas únicas', () {
    final charts = ChartCatalog.all;

    expect(charts, hasLength(252));
    expect(charts.map((chart) => chart.id).toSet(), hasLength(252));
    expect(charts.map((chart) => chart.semanticKey).toSet(), hasLength(252));
  });

  for (final library in ChartLibrary.values) {
    test('${library.name} tiene 31 básicas y 32 avanzadas', () {
      final charts = ChartCatalog.all
          .where((chart) => chart.library == library)
          .toList();

      expect(charts, hasLength(63));
      expect(
        charts.where((chart) => chart.level == ChartLevel.basic),
        hasLength(31),
      );
      expect(
        charts.where((chart) => chart.level == ChartLevel.advanced),
        hasLength(32),
      );
    });
  }
}
