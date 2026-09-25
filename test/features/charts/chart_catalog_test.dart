import 'package:explora_paises/features/charts/data/chart_catalog.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el catálogo contiene exactamente 252 gráficas únicas', () {
    final charts = ChartCatalog.all;

    expect(charts, hasLength(252));
    expect(charts.map((chart) => chart.id).toSet(), hasLength(252));
    expect(charts.map((chart) => chart.semanticKey).toSet(), hasLength(252));
    expect(charts.map((chart) => chart.title).toSet(), hasLength(252));
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

  test('ninguna gráfica se calcula antes de seleccionar siete países', () {
    final chart = ChartCatalog.all.first;
    expect(
      ChartDataTransformer.transform(
        chart,
        emergencyCountries.take(6).toList(),
      ),
      isEmpty,
    );
  });

  test('las 252 gráficas usan los siete países seleccionados', () {
    final selected = emergencyCountries.take(7).toList();
    for (final chart in ChartCatalog.all) {
      final points = ChartDataTransformer.transform(chart, selected);
      expect(points, isNotEmpty, reason: chart.id);
      expect(
        points.length,
        chart.kind == ChartKind.pie || chart.kind == ChartKind.donut
            ? inInclusiveRange(1, 7)
            : 7,
        reason: chart.id,
      );
      expect(
        points.every((point) => point.value.isFinite && point.value >= 0),
        isTrue,
        reason: chart.id,
      );
      if (chart.kind == ChartKind.pie || chart.kind == ChartKind.donut) {
        final represented = points
            .expand(
              (point) => point.members.isEmpty ? [point.label] : point.members,
            )
            .toSet();
        expect(
          represented,
          selected.map((country) => country.name).toSet(),
          reason: chart.id,
        );
      } else {
        expect(
          points.map((point) => point.countryCode).toSet(),
          selected.map((country) => country.code).toSet(),
          reason: chart.id,
        );
      }
    }
  });
}
