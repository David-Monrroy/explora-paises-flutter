import 'package:explora_paises/data/sources/emergency_countries.dart';
import 'package:explora_paises/features/charts/data/chart_data_transformer.dart';
import 'package:explora_paises/features/charts/data/creative_chart_data.dart';
import 'package:explora_paises/features/charts/data/fl_creative_catalog.dart';
import 'package:explora_paises/features/charts/domain/chart_definition.dart';
import 'package:explora_paises/features/charts/domain/chart_point.dart';
import 'package:flutter_test/flutter_test.dart';

List<ChartPoint> samplePoints(List<double> numbers) => [
  for (var i = 0; i < numbers.length; i++)
    ChartPoint(
      label: 'País $i',
      countryCode: 'P$i',
      value: numbers[i],
      secondaryValue: 0,
      metrics: {for (final metric in ChartMetric.values) metric: numbers[i]},
    ),
];

void main() {
  test('las combinaciones son únicas aun ignorando orden, nombre y color', () {
    final specs = FlCreativeCatalog.specs;
    expect(specs.map((spec) => spec.signature).toSet(), hasLength(63));
    expect(specs.where((spec) => spec.componentCount == 1), hasLength(15));
    for (final count in [2, 3, 4]) {
      expect(
        specs.where((spec) => spec.componentCount == count),
        hasLength(16),
      );
    }
    for (final spec in specs) {
      expect(spec.visuals.toSet(), hasLength(spec.visuals.length));
      if (spec.fusion != null) {
        expect(spec.visuals, isEmpty);
        expect(
          spec.fusion!.layers.map((layer) => layer.mark).toSet(),
          hasLength(spec.componentCount),
        );
      } else {
        expect(spec.visuals, hasLength(1));
      }
    }
  });

  test(
    'se conserva cada métrica de los siete elegidos y se rechazan duplicados',
    () {
      final chart = FlCreativeCatalog.all.first;
      final points = ChartDataTransformer.transform(chart, emergencyCountries);
      expect(points, hasLength(7));
      for (final point in points) {
        final country = emergencyCountries.singleWhere(
          (c) => c.code == point.countryCode,
        );
        for (final metric in ChartMetric.values) {
          expect(
            point.metrics[metric],
            ChartDataTransformer.metricValue(country, metric),
          );
        }
      }
      expect(
        ChartDataTransformer.transform(chart, [
          ...emergencyCountries.take(6),
          emergencyCountries.first,
        ]),
        isEmpty,
      );
      expect(
        ChartDataTransformer.transform(
          chart,
          emergencyCountries.take(6).toList(),
        ),
        isEmpty,
      );
    },
  );

  test(
    'waffle conserva 100 casillas y error de redondeo menor a una casilla',
    () {
      final data = CreativeChartData(samplePoints([0, 0, 1, 1, 1, 1, 2]));
      final cells = data.waffle();
      expect(cells, hasLength(100));
      expect(cells.where((i) => i == 0 || i == 1), isEmpty);
      for (var i = 0; i < 7; i++) {
        expect(
          (cells.where((cell) => cell == i).length -
                  data.share(i, ChartMetric.area))
              .abs(),
          lessThan(1),
        );
      }
    },
  );

  test('los empates comparten rango y no se rompen alfabéticamente', () {
    final data = CreativeChartData(samplePoints([10, 10, 5, 5, 0, 0, 0]));
    expect(data.rank(0, ChartMetric.population), 1.5);
    expect(data.rank(1, ChartMetric.population), 1.5);
    expect(data.rank(2, ChartMetric.population), 3.5);
    expect(data.rank(6, ChartMetric.population), 6);
  });

  test('la distribución agrupa empates y termina en el 100 por ciento', () {
    final data = CreativeChartData(samplePoints([0, 0, 2, 2, 2, 4, 8]));
    final cdf = data.distribution(ChartMetric.borders);
    expect(cdf.map((point) => point.x), [0, 2, 4, 8]);
    expect(cdf[0].y, closeTo(2 / 7 * 100, 1e-9));
    expect(cdf[1].y, closeTo(5 / 7 * 100, 1e-9));
    expect(cdf.last.y, 100);
  });

  test('igual población produce la diagonal de igualdad', () {
    final data = CreativeChartData(samplePoints(List.filled(7, 20)));
    for (final point in data.concentration()) {
      expect(point.y, closeTo(point.x, 1e-9));
    }
    expect(data.deviation(0, ChartMetric.density), 0);
  });

  test('ceros no generan divisiones inválidas ni proporciones inventadas', () {
    final data = CreativeChartData(samplePoints(List.filled(7, 0)));
    expect(data.waffle(), isEmpty);
    expect(data.concentration(), isEmpty);
    expect(data.relative(0, ChartMetric.area), 0);
    expect(data.share(0, ChartMetric.population), 0);
    expect(data.deviation(0, ChartMetric.density), 0);
    expect(data.distribution(ChartMetric.borders).single.y, 100);
  });
}
