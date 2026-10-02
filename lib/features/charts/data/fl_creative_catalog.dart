import '../domain/chart_definition.dart';
import '../domain/creative_chart.dart';
import '../domain/fusion_chart.dart';

/// Fifteen standalone plots and 48 genuine shared-canvas fusions.
/// Combinations share country positions and declare each layer's scale.
abstract final class FlCreativeCatalog {
  static const specs = <CreativeChartSpec>[
    CreativeChartSpec(
      'Perfil de los siete países',
      'Reconoce fortalezas relativas de tamaño y densidad en una sola figura.',
      [CreativeVisual.radar],
    ),
    CreativeChartSpec(
      'Diversidad de idiomas',
      'Compara cuántos idiomas registra cada país.',
      [CreativeVisual.lollipop],
    ),
    CreativeChartSpec(
      'Habitantes frente a territorio',
      'Identifica países cuya participación poblacional supera su participación territorial.',
      [CreativeVisual.dumbbell],
    ),
    CreativeChartSpec(
      'Dos formas de ordenar los países',
      'Observa qué países cambian de puesto al pasar de superficie a población.',
      [CreativeVisual.slope],
    ),
    CreativeChartSpec(
      'Perfil de características discretas',
      'Compara idiomas, fronteras, zonas horarias y monedas sin mezclar sus unidades originales.',
      [CreativeVisual.parallel],
    ),
    CreativeChartSpec(
      'Territorio, habitantes y densidad',
      'Relaciona tres características de los siete países en un plano.',
      [CreativeVisual.bubble],
    ),
    CreativeChartSpec(
      'Atlas de características',
      'Detecta máximos y contrastes entre las siete métricas disponibles.',
      [CreativeVisual.heatmap],
    ),
    CreativeChartSpec(
      'Reparto del territorio',
      'Traduce la participación territorial a una cuadrícula de cien casillas.',
      [CreativeVisual.waffle],
    ),
    CreativeChartSpec(
      'Concentración de habitantes',
      'Comprueba si la población está repartida o concentrada en pocos países del grupo.',
      [CreativeVisual.lorenz],
    ),
    CreativeChartSpec(
      'Construcción del total poblacional',
      'Sigue el aporte de cada país hasta completar la población de la selección.',
      [CreativeVisual.waterfall],
    ),
    CreativeChartSpec(
      'Zonas horarias frente a la media',
      'Compara los valores individuales con una referencia calculada para el grupo.',
      [CreativeVisual.bullet],
    ),
    CreativeChartSpec(
      'Densidades por encima y por debajo',
      'Distingue las densidades superiores e inferiores al promedio seleccionado.',
      [CreativeVisual.diverging],
    ),
    CreativeChartSpec(
      'Distribución de fronteras',
      'Lee cuántos países tienen como máximo un número determinado de vecinos terrestres.',
      [CreativeVisual.ecdf],
    ),
    CreativeChartSpec(
      'Coincidencias monetarias',
      'Identifica países que registran el mismo número de monedas.',
      [CreativeVisual.strip],
    ),
    CreativeChartSpec(
      'Superficies en pétalos',
      'Compara el tamaño territorial mediante sectores de área proporcional.',
      [CreativeVisual.rose],
    ),
    CreativeChartSpec(
      'Tamaño territorial y poblacional',
      'Las columnas de población y la línea de superficie comparten país y escala relativa.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
      ]),
    ),
    CreativeChartSpec(
      'Tamaño y densidad',
      'El área de densidad y las burbujas de población relacionan dos índices; el tamaño del círculo añade fronteras.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.population,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Idiomas y territorio',
      'Las paletas de idiomas se leen junto al perfil de superficie del mismo país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(FusionMark.line, ChartMetric.area),
      ]),
    ),
    CreativeChartSpec(
      'Participación y densidad',
      'Las mancuernas comparan índices de población y superficie sobre el área de densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.area, ChartMetric.density),
      ]),
    ),
    CreativeChartSpec(
      'Aportes y superficie',
      'La cascada acumula población y la línea compara el tamaño territorial relativo por país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
      ]),
    ),
    CreativeChartSpec(
      'Zonas horarias y vecindad',
      'Las barras bala muestran zonas horarias y los puntos indican fronteras sobre la misma escala relativa.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Intervalo entre tamaños y densidad',
      'La franja de población y superficie se cruza con burbujas de densidad y fronteras.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Tamaño y contraste por país',
      'Las columnas destacan población y las mancuernas conectan su índice con el territorial.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Densidad y fronteras',
      'La superficie sombreada de densidad y los puntos de fronteras coinciden en un eje de países.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Lenguas y densidad',
      'Paletas y burbujas relacionan los índices de idiomas y densidad; las fronteras determinan el tamaño del círculo.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Tiempo y territorio',
      'El gráfico bala sitúa zonas horarias frente a su media y la línea muestra superficie relativa.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.line, ChartMetric.area),
      ]),
    ),
    CreativeChartSpec(
      'Tamaños y vecindad',
      'Los puntos de fronteras se leen sobre una franja entre índices poblacionales y territoriales.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Acumulación y contraste',
      'La cascada permite leer el total poblacional acumulado mientras las mancuernas comparan índices de tamaño.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Perfil radial del territorio',
      'Un polígono poblacional y pétalos territoriales se superponen alrededor de los siete países.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.radar, ChartMetric.population),
        FusionLayer(FusionMark.rose, ChartMetric.area),
      ], projection: FusionProjection.polar),
    ),
    CreativeChartSpec(
      'Densidad sobre el perfil radial',
      'Las burbujas de densidad se ubican en los mismos radios que el perfil de población; su tamaño añade fronteras.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.radar, ChartMetric.population),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ], projection: FusionProjection.polar),
    ),
    CreativeChartSpec(
      'Idiomas dentro del territorio',
      'Las paletas radiales de idiomas atraviesan los pétalos de superficie de cada país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.rose, ChartMetric.area),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
      ], projection: FusionProjection.polar),
    ),
    CreativeChartSpec(
      'Población, superficie y densidad',
      'Columnas, perfil territorial y burbujas muestran tres características en una sola figura.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Densidad, territorio y vecinos',
      'La línea territorial y los puntos de fronteras se superponen al área de densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Lenguas y contraste de tamaño',
      'Las paletas, mancuernas y línea conectan idiomas con las diferencias de tamaño relativo.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.line, ChartMetric.area),
      ]),
    ),
    CreativeChartSpec(
      'Aportes, territorio y fronteras',
      'La cascada poblacional comparte eje con la línea de superficie y los puntos de vecindad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Tiempo, tamaño y densidad',
      'Las barras bala, la línea territorial y las burbujas combinan tres lecturas del mismo país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Franja territorial y vecindad',
      'Una franja de tamaños, una línea territorial y puntos de fronteras forman una comparación integrada.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Tamaño y densidad en capas',
      'La población en columnas y burbujas se lee sobre el área de densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.population,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Zonas y diferencias de tamaño',
      'Bala, mancuernas y puntos relacionan zonas horarias, tamaños y vecinos.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Aportes y diversidad',
      'La acumulación poblacional se combina con paletas de idiomas y burbujas de densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Rango relativo del tamaño',
      'Las columnas, mancuernas y franja identifican las diferencias entre índices de población y superficie.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Idiomas, densidad y vecinos',
      'Paletas de idiomas y puntos de fronteras se apoyan en el área de densidad del grupo.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Población, tiempo y territorio',
      'Columnas, barras bala y perfil de superficie comparan tres índices por país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.line, ChartMetric.area),
      ]),
    ),
    CreativeChartSpec(
      'Franja y diversidad',
      'Una franja de tamaño comparte la figura con idiomas y densidad en burbujas.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Aportes, densidad y tamaños',
      'La cascada poblacional y las mancuernas se superponen a la densidad sombreada.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Perfil, tierra y densidad radial',
      'Radar, rosa y burbujas comparten el centro y el radio de cada país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.radar, ChartMetric.population),
        FusionLayer(FusionMark.rose, ChartMetric.area),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ], projection: FusionProjection.polar),
    ),
    CreativeChartSpec(
      'Perfil, tierra y lenguas radial',
      'Radar, rosa y paletas usan el mismo conjunto de radios para relacionar tamaños e idiomas.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.radar, ChartMetric.population),
        FusionLayer(FusionMark.rose, ChartMetric.area),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
      ], projection: FusionProjection.polar),
    ),
    CreativeChartSpec(
      'Cuatro lecturas del tamaño',
      'Columnas poblacionales, línea territorial, área de densidad y burbujas ocupan una sola figura.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.population,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Tamaños con puntos de vecindad',
      'Columnas, línea, mancuernas y dispersión comparan población, superficie y fronteras por país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Total, territorio, idiomas y vecinos',
      'Cascada, perfil, paletas y puntos cruzan aportes poblacionales con tres características de cada país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Zonas horarias dentro de los tamaños',
      'Bala, línea, franja y burbujas relacionan tiempo, superficie y densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Población, densidad y diversidad',
      'Columnas, área, paletas y mancuernas muestran cuatro señales legibles en el mismo eje de países.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Densidad dentro de una franja territorial',
      'Franja, área, línea y puntos conectan tamaño relativo, densidad y vecindad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Población individual y acumulada',
      'Cascada y columnas distinguen el aporte acumulado del índice individual; línea y burbujas añaden territorio y densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Zonas, densidad, tamaños y fronteras',
      'Bala, área, mancuernas y puntos forman una comparación multivariable dentro de una figura.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Tamaño y diversidad del país',
      'Franja, columnas, paletas y burbujas conectan tamaño, idiomas y densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Acumulación y contraste territorial',
      'Cascada, línea, mancuernas y burbujas muestran aportes, diferencias de tamaño y densidad.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Población, tiempo, fronteras e idiomas',
      'Dos clases de barra se combinan con puntos y paletas para comparar cuatro características.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
      ]),
    ),
    CreativeChartSpec(
      'Perfil territorial y diversidad',
      'Área, línea, paletas y burbujas relacionan densidad, territorio e idiomas.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.area, ChartMetric.density),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.population,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Franja del aporte acumulado',
      'Franja, cascada, línea y puntos conectan tamaños y acumulación poblacional con vecinos.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(FusionMark.waterfall, ChartMetric.population),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.dots, ChartMetric.borders),
      ]),
    ),
    CreativeChartSpec(
      'Tiempo, territorio e idiomas',
      'Bala, línea, paletas y mancuernas permiten comparar zonas horarias, superficie, lenguas y tamaños.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.bullet, ChartMetric.timezones),
        FusionLayer(FusionMark.line, ChartMetric.area),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Cuatro señales del contraste de tamaño',
      'Columnas, franja, mancuernas y burbujas ofrecen medidas complementarias por país.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.columns, ChartMetric.population),
        FusionLayer(
          FusionMark.band,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(
          FusionMark.dumbbell,
          ChartMetric.population,
          secondaryMetric: ChartMetric.area,
        ),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
      ]),
    ),
    CreativeChartSpec(
      'Atlas radial integrado',
      'Radar, rosa polar, burbujas y paletas se fusionan en los mismos siete radios para mostrar población, superficie, densidad e idiomas.',
      [],
      fusion: FusionChartSpec([
        FusionLayer(FusionMark.radar, ChartMetric.population),
        FusionLayer(FusionMark.rose, ChartMetric.area),
        FusionLayer(
          FusionMark.bubble,
          ChartMetric.density,
          secondaryMetric: ChartMetric.borders,
        ),
        FusionLayer(FusionMark.lollipop, ChartMetric.languages),
      ], projection: FusionProjection.polar),
    ),
  ];

  static final List<ChartDefinition> all = List.unmodifiable([
    for (var index = 0; index < specs.length; index++)
      ChartDefinition(
        id: 'flChart-creative-${index + 1}',
        number: index + 1,
        library: ChartLibrary.flChart,
        level: index < 31 ? ChartLevel.basic : ChartLevel.advanced,
        metric: ChartMetric.population,
        recipe: const ChartRecipe(
          kind: ChartKind.creative,
          analysis: ChartAnalysis.raw,
          question: 'Exploración de siete países',
          explanation: 'Comparaciones con datos de la selección.',
        ),
        creative: specs[index],
      ),
  ]);
}
