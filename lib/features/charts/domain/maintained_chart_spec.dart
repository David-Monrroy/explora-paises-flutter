import 'country_chart_spec.dart';

/// Rare diagrams implemented through Maintained's native canvas decorator API.
enum MaintainedVisual {
  treemap,
  sunburst,
  sankey,
  chord,
  ternary,
  marimekko,
  icicle,
  circlePacking,
  pictogram,
  violin,
  ridgeline,
  rug,
  horizon,
  beeswarm,
  arcNetwork,
  // Existing primitives are only reused inside new, unique fused figures.
  dots,
  boxPlot,
  lollipop,
  dumbbell,
  bullet,
}

class MaintainedChartSpec implements CountryChartSpec {
  const MaintainedChartSpec(this.visuals);
  final List<MaintainedVisual> visuals;
  @override
  int get componentCount => visuals.length;
  @override
  bool get usesLayerColors => componentCount > 1;
  bool get isProfile => visuals.every((visual) => visual.isProfile);
  String get names => visuals.map((visual) => visual.label).join(' + ');
  @override
  String get title =>
      '$names: ${isProfile ? 'perfil de los siete países' : visuals.single.subject}';
  // No library, metric, color or component order can disguise a repeated figure.
  String get signature =>
      (visuals.map((visual) => visual.name).toList()..sort()).join('|');
  @override
  String get explanation => componentCount == 1
      ? visuals.single.explanation
      : 'Fusiona $names en una sola figura. Cada fila es un país y todas las capas '
            'comparten el eje horizontal de índices 0–100. Las formas y los colores '
            'de la leyenda distinguen las capas; no se suman unidades incompatibles.';
  String get axes => isProfile
      ? 'X: índice relativo (0–100) · Y: países en orden de código'
      : visuals.single.axes;
}

extension MaintainedVisualInfo on MaintainedVisual {
  bool get isProfile => [
    MaintainedVisual.violin,
    MaintainedVisual.ridgeline,
    MaintainedVisual.rug,
    MaintainedVisual.dots,
    MaintainedVisual.boxPlot,
    MaintainedVisual.lollipop,
    MaintainedVisual.dumbbell,
    MaintainedVisual.bullet,
  ].contains(this);
  String get label => switch (this) {
    MaintainedVisual.treemap => 'Treemap',
    MaintainedVisual.sunburst => 'Sunburst',
    MaintainedVisual.sankey => 'Sankey',
    MaintainedVisual.chord => 'Diagrama de cuerdas',
    MaintainedVisual.ternary => 'Diagrama ternario',
    MaintainedVisual.marimekko => 'Marimekko',
    MaintainedVisual.icicle => 'Icicle',
    MaintainedVisual.circlePacking => 'Empaquetado de círculos',
    MaintainedVisual.pictogram => 'Pictograma',
    MaintainedVisual.violin => 'Violín',
    MaintainedVisual.ridgeline => 'Ridgeline',
    MaintainedVisual.rug => 'Rug de características',
    MaintainedVisual.horizon => 'Gráfico de horizonte',
    MaintainedVisual.beeswarm => 'Enjambre de puntos',
    MaintainedVisual.arcNetwork => 'Red de arcos',
    MaintainedVisual.dots => 'Puntos',
    MaintainedVisual.boxPlot => 'Cajas y bigotes',
    MaintainedVisual.lollipop => 'Paletas',
    MaintainedVisual.dumbbell => 'Mancuernas',
    MaintainedVisual.bullet => 'Bala',
  };
  String get subject => switch (this) {
    MaintainedVisual.treemap => 'mosaico territorial',
    MaintainedVisual.sunburst => 'habitantes por región y país',
    MaintainedVisual.sankey => 'habitantes agrupados por región',
    MaintainedVisual.chord => 'monedas compartidas',
    MaintainedVisual.ternary => 'equilibrio de tres índices',
    MaintainedVisual.marimekko => 'peso demográfico y diversidad lingüística',
    MaintainedVisual.icicle => 'jerarquía territorial',
    MaintainedVisual.circlePacking => 'tamaños del territorio',
    MaintainedVisual.pictogram => 'escala de habitantes',
    MaintainedVisual.horizon => 'bandas de densidad',
    MaintainedVisual.beeswarm => 'concentración de densidades',
    MaintainedVisual.arcNetwork => 'fronteras dentro de la selección',
    _ => 'perfil de los siete países',
  };
  String get axes => switch (this) {
    MaintainedVisual.treemap || MaintainedVisual.circlePacking => 'Área de cada figura: superficie (km²) · posición: solo disposición visual',
    MaintainedVisual.sunburst => 'Ángulo: porcentaje de habitantes · anillo interior: región · exterior: país',
    MaintainedVisual.sankey =>
      'Izquierda: países · derecha: regiones · grosor: habitantes',
    MaintainedVisual.chord =>
      'Nodos: países · cinta: monedas compartidas (cantidad)',
    MaintainedVisual.ternary =>
      'Vértices: población, superficie y densidad · mezcla de sus índices (%)',
    MaintainedVisual.marimekko =>
      'Ancho: cuota de habitantes (%) · altura: idiomas / máximo (%)',
    MaintainedVisual.icicle =>
      'Ancho: cuota territorial (%) · nivel superior: región · inferior: país',
    MaintainedVisual.pictogram =>
      'Filas: países · figuras humanas: habitantes (escala común)',
    MaintainedVisual.horizon =>
      'X: países por código · altura plegada: bandas del índice de densidad',
    MaintainedVisual.beeswarm => 'X: densidad (hab./km²) · Y: separación para evitar colisiones, sin unidad',
    MaintainedVisual.arcNetwork => 'Nodos: países · arco: frontera terrestre registrada entre dos seleccionados',
    _ => 'X: índice relativo (0–100) · Y: países',
  };
  String get explanation => switch (this) {
    MaintainedVisual.treemap => 'Cada rectángulo tiene un área proporcional a la superficie del país. El mosaico compara km², no es un mapa; la posición no representa ubicación geográfica.',
    MaintainedVisual.sunburst => 'El anillo interior agrupa habitantes por región; el exterior reparte ese mismo total entre sus países. Cada país aparece una sola vez y el ángulo es su cuota de población.',
    MaintainedVisual.sankey => 'Las cintas llevan la población de cada país a su región real. Su grosor conserva habitantes de entrada a salida. No son migraciones ni movimientos de personas.',
    MaintainedVisual.chord => 'Una cinta conecta dos países cuando sus listas de monedas comparten un nombre normalizado. El grosor indica cuántas comparten, no comercio ni tipo de cambio. Sin coincidencias no se inventan conexiones.',
    MaintainedVisual.ternary => 'Cada punto reparte a 100 % la suma de tres índices: población, superficie y densidad, cada uno relativo a su propio máximo. Es un equilibrio de características, no porcentajes de habitantes ni una relación causal. Un perfil totalmente cero no tiene composición y no se dibuja.',
    MaintainedVisual.marimekko => 'El ancho de cada columna es la cuota de habitantes del país; su altura coloreada es el índice de idiomas registrados y el fondo claro completa 100 %. El área combina dos codificaciones: no es una cantidad adicional ni porcentajes de hablantes.',
    MaintainedVisual.icicle => 'Dos niveles rectangulares reparten la superficie: regiones arriba y sus países debajo. El ancho conserva la cuota de km² del total de la selección. La región no añade superficie nueva.',
    MaintainedVisual.circlePacking => 'El área de cada círculo es proporcional a la superficie del país. Los círculos se acomodan sin solaparse; sus centros no representan coordenadas geográficas ni distancias reales.',
    MaintainedVisual.pictogram => 'Cada figura humana equivale a una décima parte de la población del país más poblado de la selección. Las fracciones se rellenan proporcionalmente. Son habitantes, no edades, géneros ni muestras individuales.',
    MaintainedVisual.violin => 'La silueta estima dónde se concentran los siete índices del país, con núcleos gaussianos de ancho fijo 12 y corrección en los límites 0 y 100. Anchura: densidad estimada del perfil, no habitantes. Solo son siete características, no una muestra estadística de población; la curva es una ayuda visual.',
    MaintainedVisual.ridgeline => 'Cada relieve muestra la misma estimación de concentración de los siete índices, como una curva de un solo lado sobre la fila del país. La altura describe el perfil de características, no relieve geográfico, tiempo ni incertidumbre.',
    MaintainedVisual.rug => 'Siete pequeñas marcas sitúan los índices de población, superficie, densidad, idiomas, fronteras, zonas horarias y monedas. Se escalonan ligeramente dentro de la fila para que los empates no oculten observaciones; esa separación vertical no es un dato.',
    MaintainedVisual.horizon => 'Pliega el índice de densidad en tres bandas: 0–33,3; 33,3–66,7; 66,7–100. La altura de cada banda muestra su excedente local y la intensidad identifica la banda. No es una evolución temporal; los países se ordenan por código.',
    MaintainedVisual.beeswarm => 'Siete puntos comparan densidades reales. Cuando quedan cerca, se separan verticalmente para no taparse. La posición vertical no codifica otro indicador; no se agregan observaciones artificiales.',
    MaintainedVisual.arcNetwork => 'Cada arco une dos países seleccionados si REST Countries registra una frontera entre ellos en al menos una de sus listas. Solo se muestran vínculos internos del grupo; no todos sus vecinos del mundo. Sin fronteras comunes la red muestra únicamente nodos.',
    MaintainedVisual.dots => 'El círculo sitúa el índice de densidad de cada país. Se lee en el mismo eje 0–100 de las otras capas.',
    MaintainedVisual.boxPlot => 'Caja: cuartiles inclusivos de los siete índices; línea: mediana; bigotes: mínimo y máximo. Resume características, no una muestra de habitantes ni un intervalo de confianza.',
    MaintainedVisual.lollipop => 'La paleta va desde cero hasta el índice de población; el extremo cuadrado distingue esta capa de los puntos de densidad.',
    MaintainedVisual.dumbbell => 'Une los índices de población y superficie. El extremo circular marca población y el rombo superficie, independientemente de cuál tenga el mayor valor.',
    MaintainedVisual.bullet => 'La barra muestra el índice de idiomas; el trazo perpendicular marca la media de ese índice entre los siete países. Es una referencia comparativa, no una meta.',
  };
}
