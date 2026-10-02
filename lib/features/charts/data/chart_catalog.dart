import '../domain/chart_definition.dart';
import 'fl_creative_catalog.dart';
import 'syncfusion_creative_catalog.dart';

abstract final class ChartCatalog {
  // Cada receta cambia la pregunta, la geometría o el cálculo mostrado.
  static const recipes = <ChartRecipe>[
    // Maintained Charts.
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.distanceToAverage,
      question: 'distancia absoluta al promedio',
      explanation: 'Indica cuánto se aleja cada país de la media, por arriba o por abajo.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.rank,
      question: 'posición en el ranking',
      explanation: 'Da posición 1 al país mayor y 7 al menor.',
    ),
    ChartRecipe(
      kind: ChartKind.area,
      analysis: ChartAnalysis.runningAverage,
      question: 'promedio acumulado del ranking',
      explanation:
          'Calcula el promedio de los países agregados hasta cada posición.',
    ),
    ChartRecipe(
      kind: ChartKind.pie,
      analysis: ChartAnalysis.topGroup,
      groupSize: 3,
      question: 'tres líderes frente al resto',
      explanation: 'Compara la suma de los tres países mayores con los cuatro restantes.',
    ),
    ChartRecipe(
      kind: ChartKind.donut,
      analysis: ChartAnalysis.regionGroup,
      question: 'aporte de cada región',
      explanation: 'Agrupa los siete países por región y suma sus valores. Cada país participa una sola vez.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatter,
      secondaryOffset: 5,
      question: 'relación con una quinta variable',
      explanation: 'Cada punto compara dos valores distintos de uno de los siete países.',
    ),
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.gapToMinimum,
      question: 'ventaja respecto al menor',
      explanation: 'Muestra cuánto supera cada país al valor más pequeño.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.percentOfMaximum,
      question: 'perfil relativo al valor más alto',
      explanation:
          'El líder vale 100 % y la línea revela cómo disminuye el resto.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatter,
      secondaryOffset: 6,
      question: 'relación con una sexta variable',
      explanation:
          'Cruza dos características diferentes para los siete países.',
    ),

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
    assert(recipes.length == 18);
    final charts = <ChartDefinition>[
      ...FlCreativeCatalog.all,
      ...SyncfusionCreativeCatalog.all,
    ];
    for (final library in ChartLibrary.values.skip(2)) {
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
              recipe: recipes[(library.index - 2) * 9 + recipeIndex],
            ),
          );
        }
      }
    }
    return List.unmodifiable(charts);
  }
}
