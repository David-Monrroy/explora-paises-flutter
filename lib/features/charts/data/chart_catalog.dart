import '../domain/chart_definition.dart';
import 'fl_creative_catalog.dart';
import 'syncfusion_creative_catalog.dart';
import 'maintained_creative_catalog.dart';

abstract final class ChartCatalog {
  // Cada receta cambia la pregunta, la geometría o el cálculo mostrado.
  static const recipes = <ChartRecipe>[
    // Graphic.
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.indexToAverage,
      question: 'índice frente a la media de los siete',
      explanation:
          'La media equivale a 100 %. Compara cada país con esa referencia.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.raw,
      ascending: true,
      question: 'perfil desde el menor hasta el mayor',
      explanation: 'Une los países de menor a mayor. Es un ranking, no una evolución temporal.',
    ),
    ChartRecipe(
      kind: ChartKind.area,
      analysis: ChartAnalysis.cumulative,
      ascending: true,
      question: 'total acumulado desde el menor',
      explanation: 'Suma primero los valores más pequeños y termina con el total de los siete.',
    ),
    ChartRecipe(
      kind: ChartKind.pie,
      analysis: ChartAnalysis.topGroup,
      groupSize: 4,
      question: 'cuatro líderes frente al resto',
      explanation:
          'Compara los cuatro países mayores contra los tres restantes.',
    ),
    ChartRecipe(
      kind: ChartKind.donut,
      analysis: ChartAnalysis.subregionGroup,
      question: 'aporte de cada subregión',
      explanation: 'Agrupa los siete países por subregión y suma sus valores. Permite ver cómo se distribuye el total geográficamente.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatterRank,
      secondaryOffset: 1,
      question: 'valor frente al puesto en otra métrica',
      explanation: 'El eje horizontal es la posición en otra característica; el vertical, el valor actual.',
    ),
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.aboveAverage,
      question: 'exceso sobre el promedio',
      explanation: 'Solo los países por encima de la media presentan una barra positiva.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.belowAverage,
      question: 'déficit frente al promedio',
      explanation: 'Muestra cuánto falta para alcanzar la media; los que la superan aparecen en cero.',
    ),
    ChartRecipe(
      kind: ChartKind.area,
      analysis: ChartAnalysis.cumulativePercent,
      ascending: true,
      question: 'porcentaje acumulado desde el menor',
      explanation:
          'Suma la participación de menor a mayor hasta llegar a 100 %.',
    ),
  ];

  static final List<ChartDefinition> all = _buildCatalog();

  static List<ChartDefinition> _buildCatalog() {
    assert(recipes.length == 9);
    final charts = <ChartDefinition>[
      ...FlCreativeCatalog.all,
      ...SyncfusionCreativeCatalog.all,
      ...MaintainedCreativeCatalog.all,
    ];
    for (final library in ChartLibrary.values.skip(3)) {
      for (final metric in ChartMetric.values) {
        for (var recipeIndex = 0; recipeIndex < 9; recipeIndex++) {
          final local = metric.index * 9 + recipeIndex;
          final basicRecipes = metric.index < 3 ? 5 : 4;
          charts.add(
            ChartDefinition(
              id: '${library.name}-${metric.name}-${recipeIndex + 1}',
              number: library.index * 63 + local + 1,
              library: library,
              level: recipeIndex < basicRecipes
                  ? ChartLevel.basic
                  : ChartLevel.advanced,
              metric: metric,
              recipe: recipes[(library.index - 3) * 9 + recipeIndex],
            ),
          );
        }
      }
    }
    return List.unmodifiable(charts);
  }
}
