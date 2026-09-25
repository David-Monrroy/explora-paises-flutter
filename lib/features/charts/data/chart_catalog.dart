import '../domain/chart_definition.dart';

abstract final class ChartCatalog {
  // Cada receta cambia la pregunta, la geometría o el cálculo mostrado.
  static const recipes = <ChartRecipe>[
    // FL Chart: 9 perspectivas por cada una de las 7 métricas.
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.raw,
      question: 'valores de los siete países',
      explanation: 'Cada barra representa el valor original de un país.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.raw,
      question: 'perfil de mayor a menor',
      explanation: 'Une los países ordenados por valor. El eje horizontal es un ranking, no tiempo.',
    ),
    ChartRecipe(
      kind: ChartKind.area,
      analysis: ChartAnalysis.cumulative,
      question: 'total acumulado desde el mayor',
      explanation: 'Suma progresivamente los valores, desde el país mayor hasta completar los siete.',
    ),
    ChartRecipe(
      kind: ChartKind.pie,
      analysis: ChartAnalysis.share,
      question: 'participación de cada país',
      explanation: 'Cada sector representa la parte porcentual de un país en el total de los siete.',
    ),
    ChartRecipe(
      kind: ChartKind.donut,
      analysis: ChartAnalysis.topGroup,
      groupSize: 1,
      question: 'el líder frente a los demás',
      explanation:
          'Compara el país de mayor valor con la suma de los otros seis.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatter,
      secondaryOffset: 1,
      question: 'relación con la siguiente métrica',
      explanation: 'Cada punto es un país: la posición horizontal muestra otra métrica y la vertical esta.',
    ),
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.percentOfMaximum,
      question: 'porcentaje respecto al líder',
      explanation:
          'El valor más alto equivale a 100 %; los demás se comparan con él.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.indexToAverage,
      question: 'comparación con el promedio',
      explanation: 'El promedio de los siete equivale a 100 %. Los puntos muestran su posición relativa.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatter,
      secondaryOffset: 2,
      question: 'relación con otra característica',
      explanation: 'Cruza dos valores reales de cada país para reconocer posibles relaciones.',
    ),

    // Syncfusion.
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.gapToMaximum,
      question: 'distancia respecto al líder',
      explanation:
          'Cada barra indica cuánto le falta al país para alcanzar al líder.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.cumulativePercent,
      question: 'participación acumulada por ranking',
      explanation: 'Suma porcentajes desde el mayor valor; el último punto alcanza 100 %.',
    ),
    ChartRecipe(
      kind: ChartKind.area,
      analysis: ChartAnalysis.remainingPercent,
      question: 'participación pendiente por agregar',
      explanation: 'Muestra qué porcentaje queda después de incorporar cada país del ranking.',
    ),
    ChartRecipe(
      kind: ChartKind.pie,
      analysis: ChartAnalysis.topGroup,
      groupSize: 2,
      question: 'dos líderes frente al resto',
      explanation:
          'Compara la suma de los dos países mayores con los otros cinco.',
    ),
    ChartRecipe(
      kind: ChartKind.donut,
      analysis: ChartAnalysis.bottomGroup,
      groupSize: 2,
      question: 'dos menores frente al resto',
      explanation:
          'Compara la suma de los dos países menores con los otros cinco.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatter,
      secondaryOffset: 3,
      question: 'cruce con una tercera variable',
      explanation:
          'Sitúa los siete países según dos características distintas.',
    ),
    ChartRecipe(
      kind: ChartKind.bar,
      analysis: ChartAnalysis.share,
      question: 'aporte porcentual por país',
      explanation:
          'Las siete barras muestran porcentajes que juntos suman 100 %.',
    ),
    ChartRecipe(
      kind: ChartKind.line,
      analysis: ChartAnalysis.gapToMaximum,
      question: 'brecha descendente respecto al líder',
      explanation: 'Recorre las distancias al líder en el orden del ranking.',
    ),
    ChartRecipe(
      kind: ChartKind.scatter,
      analysis: ChartAnalysis.scatter,
      secondaryOffset: 4,
      question: 'relación con una cuarta variable',
      explanation: 'Permite observar si dos características de los países varían juntas.',
    ),

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
    assert(recipes.length == 36);
    final charts = <ChartDefinition>[];
    for (final library in ChartLibrary.values) {
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
              recipe: recipes[library.index * 9 + recipeIndex],
            ),
          );
        }
      }
    }
    return List.unmodifiable(charts);
  }
}
