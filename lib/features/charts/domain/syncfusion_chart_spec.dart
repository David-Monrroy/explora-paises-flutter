import 'country_chart_spec.dart';

/// Native geometries not used by the FL Chart stage.
enum SyncfusionVisual {
  rangeColumn,
  splineRange,
  stepLine,
  stepArea,
  spline,
  splineArea,
  boxPlot,
  hilo,
  ohlc,
  candle,
  stackedColumn,
  histogram,
  funnel,
  pyramid,
  radialBar,
}

class SyncfusionChartSpec implements CountryChartSpec {
  const SyncfusionChartSpec(
    this.visuals, {
    this.subject = 'Contrastes entre los siete países',
  });
  final List<SyncfusionVisual> visuals;
  final String subject;
  @override
  int get componentCount => visuals.length;
  @override
  bool get usesLayerColors => visuals.every(
    (visual) => visual.isCartesian || visual == SyncfusionVisual.histogram,
  );
  String get names => visuals.map((visual) => visual.label).join(' + ');
  @override
  String get title => '$names: $subject';
  // Deliberately no library, metrics, colors or ordering in the signature.
  String get signature =>
      (visuals.map((visual) => visual.name).toList()..sort()).join('|');
  @override
  String get explanation => componentCount == 1
      ? visuals.single.explanation
      : 'Relaciona ${visuals.map((visual) => visual.focus).join(', ')} '
            'en una sola figura. Los colores distinguen capas sobre los mismos siete países '
            'y el índice 0–100; la leyenda explica cada transformación.';
  String get axes => visuals.singleOrNull == SyncfusionVisual.histogram
      ? 'X: densidad (hab./km²) · Y: número de países por intervalo'
      : visuals.singleOrNull == SyncfusionVisual.radialBar
      ? 'Longitud del arco: superficie / máximo de la selección (%)'
      : !usesLayerColors
      ? 'Segmentos: países · valores y unidades en la leyenda'
      : 'X: países en orden de código · Y: índice relativo (0–100)';
}

extension SyncfusionVisualInfo on SyncfusionVisual {
  String get focus => switch (this) {
    SyncfusionVisual.rangeColumn => 'contrastes de población y territorio',
    SyncfusionVisual.splineRange => 'amplitud de características discretas',
    SyncfusionVisual.stepLine => 'idiomas',
    SyncfusionVisual.stepArea => 'zonas horarias',
    SyncfusionVisual.spline => 'densidades',
    SyncfusionVisual.splineArea => 'fronteras',
    SyncfusionVisual.boxPlot => 'dispersión del perfil de siete índices',
    SyncfusionVisual.hilo => 'extremos de tamaño y densidad',
    SyncfusionVisual.ohlc =>
      'población y superficie dentro del perfil completo',
    SyncfusionVisual.candle => 'contrastes de idiomas y fronteras',
    SyncfusionVisual.stackedColumn => 'distancia de la densidad al máximo',
    SyncfusionVisual.histogram => 'frecuencia de densidades',
    SyncfusionVisual.funnel => 'habitantes por país',
    SyncfusionVisual.pyramid => 'reparto territorial',
    SyncfusionVisual.radialBar => 'superficie relativa',
  };
  bool get isCartesian => ![
    SyncfusionVisual.histogram,
    SyncfusionVisual.funnel,
    SyncfusionVisual.pyramid,
    SyncfusionVisual.radialBar,
  ].contains(this);
  bool get isBackground => [
    SyncfusionVisual.splineRange,
    SyncfusionVisual.stepArea,
    SyncfusionVisual.splineArea,
    SyncfusionVisual.stackedColumn,
  ].contains(this);
  String get label => switch (this) {
    SyncfusionVisual.rangeColumn => 'Columnas de rango',
    SyncfusionVisual.splineRange => 'Banda curva de rangos',
    SyncfusionVisual.stepLine => 'Línea escalonada',
    SyncfusionVisual.stepArea => 'Área escalonada',
    SyncfusionVisual.spline => 'Curva spline',
    SyncfusionVisual.splineArea => 'Área spline',
    SyncfusionVisual.boxPlot => 'Cajas y bigotes',
    SyncfusionVisual.hilo => 'Barras de extremos (Hilo)',
    SyncfusionVisual.ohlc => 'Marcas de cuatro indicadores (OHLC)',
    SyncfusionVisual.candle => 'Velas de características',
    SyncfusionVisual.stackedColumn => 'Columnas apiladas de complemento',
    SyncfusionVisual.histogram => 'Histograma',
    SyncfusionVisual.funnel => 'Embudo',
    SyncfusionVisual.pyramid => 'Pirámide',
    SyncfusionVisual.radialBar => 'Barras radiales',
  };
  String get explanation => switch (this) {
    SyncfusionVisual.rangeColumn => 'Cada rectángulo une el menor y el mayor de los índices de población y superficie. No es incertidumbre estadística: muestra la distancia entre dos características.',
    SyncfusionVisual.splineRange => 'La banda encierra el mínimo y máximo de los índices de idiomas, fronteras, zonas horarias y monedas de cada país. Las curvas son guías entre categorías, no datos intermedios ni intervalos de confianza.',
    SyncfusionVisual.stepLine => 'Cada peldaño muestra el índice de idiomas registrados. Los cambios ocurren al pasar al siguiente país; no representan fechas ni duración.',
    SyncfusionVisual.stepArea => 'El área en escalones muestra el índice de zonas horarias. La altura es el dato; no interpretes el área como una cantidad física adicional.',
    SyncfusionVisual.spline => 'Los puntos muestran el índice de densidad. Una curva monotónica guía la lectura entre países; la API no proporciona valores entre ellos ni una evolución temporal.',
    SyncfusionVisual.splineArea => 'El área suave muestra el índice de fronteras terrestres. Lee la altura en cada país; el relleno y las curvas no representan datos geográficos o históricos adicionales.',
    SyncfusionVisual.boxPlot => 'Cada caja resume los siete índices de un país: población, superficie, densidad, idiomas, fronteras, zonas horarias y monedas. Línea: mediana; caja: cuartiles inclusivos; bigotes: valores hasta 1,5 veces el rango intercuartílico; puntos: atípicos. Describe contrastes del perfil, no una muestra de habitantes ni incertidumbre.',
    SyncfusionVisual.hilo => 'El trazo vertical muestra el mínimo y máximo de los índices de población, superficie y densidad. Resume la amplitud de ese perfil, no precios ni cambios en el tiempo.',
    SyncfusionVisual.ohlc => 'El trazo va del mínimo al máximo de los siete índices. La marca izquierda indica población y la derecha superficie. Se adapta la geometría OHLC para comparar características: no son aperturas, cierres ni datos financieros.',
    SyncfusionVisual.candle => 'El cuerpo une los índices de idiomas y fronteras; las mechas alcanzan el mínimo y máximo de idiomas, fronteras, zonas horarias y monedas. Todos son datos del mismo país, no precios ni una serie histórica.',
    SyncfusionVisual.stackedColumn => 'La parte sólida muestra el índice de densidad; la parte clara es 100 menos ese índice, la distancia al máximo del grupo. No suma variables incompatibles ni representa una meta. Si toda la densidad es cero, ambas partes valen cero.',
    SyncfusionVisual.histogram => 'Agrupa las densidades de los siete países en intervalos del mismo ancho. La altura cuenta países, no habitantes. Solo hay siete observaciones; no se supone una distribución normal.',
    SyncfusionVisual.funnel => 'Los segmentos representan habitantes de cada país, ordenados de mayor a menor. Es una comparación poblacional en forma de embudo, no un proceso de conversión ni pérdida de personas entre etapas.',
    SyncfusionVisual.pyramid => 'El área de cada segmento representa la superficie de un país, ordenados de menor a mayor. Es una distribución territorial en modo área, no una pirámide de edades ni una jerarquía social.',
    SyncfusionVisual.radialBar => 'Cada anillo es un país. El arco recorre el porcentaje de su superficie respecto al país más grande de la selección; una vuelta completa equivale a 100 %. No es porcentaje del total ni una puntuación de calidad.',
  };
}
