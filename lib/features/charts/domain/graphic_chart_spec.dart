import 'country_chart_spec.dart';

enum GraphicVisual {
  voronoi,
  dendrogram,
  minimumSpanningTree,
  upset,
  venn,
  chernoff,
  andrews,
  petals,
  convexHull,
  hexbin,
  taylor,
  diamond,
  triangleFan,
  vector,
  boxen,
  // Familiar components may occur only in novel, shared-coordinate fusions.
  dots,
  boxPlot,
  lollipop,
  dumbbell,
  bullet,
}

class GraphicChartSpec implements CountryChartSpec {
  const GraphicChartSpec(this.visuals);
  final List<GraphicVisual> visuals;
  @override
  int get componentCount => visuals.length;
  @override
  bool get usesLayerColors => componentCount > 1;
  bool get isProfile => visuals.every((v) => v.isProfile);
  String get names => visuals.map((v) => v.label).join(' + ');
  @override
  String get title =>
      '$names: ${isProfile ? 'contrastes del perfil de países' : visuals.single.subject}';
  String get signature =>
      (visuals.map((v) => v.name).toList()..sort()).join('|');
  @override
  String get explanation => componentCount == 1
      ? visuals.single.explanation
      : 'Une $names en una sola figura. Las capas comparten el eje de índices 0–100 '
            'y las siete filas de países. Cada color y forma identifica un tipo en la '
            'leyenda; sus pequeños desplazamientos dentro de una fila solo evitan que se tapen.';
  String get axes => isProfile
      ? 'X: índice relativo (0–100) · Y: países por código'
      : visuals.single.axes;
}

extension GraphicVisualInfo on GraphicVisual {
  bool get isProfile => [
    GraphicVisual.diamond,
    GraphicVisual.triangleFan,
    GraphicVisual.vector,
    GraphicVisual.boxen,
    GraphicVisual.dots,
    GraphicVisual.boxPlot,
    GraphicVisual.lollipop,
    GraphicVisual.dumbbell,
    GraphicVisual.bullet,
  ].contains(this);
  String get label => switch (this) {
    GraphicVisual.voronoi => 'Voronoi',
    GraphicVisual.dendrogram => 'Dendrograma',
    GraphicVisual.minimumSpanningTree => 'Árbol de expansión mínima',
    GraphicVisual.upset => 'UpSet de idiomas',
    GraphicVisual.venn => 'Venn de idiomas',
    GraphicVisual.chernoff => 'Caras de Chernoff',
    GraphicVisual.andrews => 'Curvas de Andrews',
    GraphicVisual.petals => 'Glifos de pétalos',
    GraphicVisual.convexHull => 'Envolventes convexas',
    GraphicVisual.hexbin => 'Hexbin',
    GraphicVisual.taylor => 'Diagrama de Taylor',
    GraphicVisual.diamond => 'Diamantes intercuartílicos',
    GraphicVisual.triangleFan => 'Abanicos triangulares',
    GraphicVisual.vector => 'Flechas de contraste',
    GraphicVisual.boxen => 'Boxen de características',
    GraphicVisual.dots => 'Puntos',
    GraphicVisual.boxPlot => 'Cajas y bigotes',
    GraphicVisual.lollipop => 'Paletas',
    GraphicVisual.dumbbell => 'Mancuernas',
    GraphicVisual.bullet => 'Bala',
  };
  String get subject => switch (this) {
    GraphicVisual.voronoi => 'vecindad en el plano de índices',
    GraphicVisual.dendrogram => 'agrupación por semejanza',
    GraphicVisual.minimumSpanningTree => 'conexión mínima de perfiles',
    GraphicVisual.upset => 'intersecciones exactas de idiomas',
    GraphicVisual.venn => 'idiomas compartidos entre países',
    GraphicVisual.chernoff => 'siete rasgos por país',
    GraphicVisual.andrews => 'perfiles convertidos en funciones',
    GraphicVisual.petals => 'flores de características',
    GraphicVisual.convexHull => 'extremos por región',
    GraphicVisual.hexbin => 'frecuencia de países en el plano',
    GraphicVisual.taylor => 'semejanza con el perfil medio',
    _ => 'contrastes del perfil de países',
  };
  String get axes => switch (this) {
    GraphicVisual.voronoi || GraphicVisual.convexHull || GraphicVisual.hexbin =>
      'X: índice de superficie · Y: índice de población (0–100)',
    GraphicVisual.dendrogram =>
      'X: distancia entre perfiles (0–100) · hojas: países',
    GraphicVisual.minimumSpanningTree => 'Nodos: países · enlaces: semejanza de siete índices · posición: solo disposición',
    GraphicVisual.upset => 'Columnas: conjuntos exactos de países · barras: número de idiomas distintos',
    GraphicVisual.venn => 'Círculos: hasta tres idiomas más compartidos · números: países de cada intersección',
    GraphicVisual.chernoff =>
      'Una cara por país · rasgos: siete índices, sin unidades físicas',
    GraphicVisual.andrews => 'X: parámetro matemático t (−π a π) · Y: función del perfil, sin unidad física',
    GraphicVisual.petals =>
      'Centro: país · pétalos: métricas · longitud: índice 0–100',
    GraphicVisual.taylor => 'Ángulo: correlación con perfil medio (−1 a 1) · radio: desviación estándar en puntos de índice',
    _ => 'X: índice relativo (0–100) · Y: países',
  };
  String get explanation => switch (this) {
    GraphicVisual.voronoi => 'Cada punto cruza superficie y población relativas. Su celda contiene las posiciones más próximas a ese punto en este plano de índices. El área de la celda NO representa km² ni habitantes y no es una frontera geográfica. Las coordenadas iguales comparten una celda, sin mover ni inventar observaciones.',
    GraphicVisual.dendrogram => 'Agrupa los siete perfiles por enlace promedio: la separación de dos grupos es la media de las distancias entre sus países. Cada distancia es la raíz del promedio de diferencias al cuadrado de los siete índices. La altura de unión mide disimilitud, no parentesco, calidad ni historia.',
    GraphicVisual.minimumSpanningTree => 'Conecta todos los países con seis enlaces cuya suma de distancias de perfil es mínima. Usa los mismos siete índices normalizados y distancia cuadrática media. Las posiciones de los nodos solo organizan la red; los enlaces no son fronteras, carreteras ni comercio.',
    GraphicVisual.upset => 'Cada columna identifica un conjunto exacto de países que registra un mismo idioma; la barra cuenta cuántos idiomas distintos tienen exactamente ese conjunto. Los puntos conectados identifican sus miembros. Se muestran hasta siete conjuntos principales; el resto se detalla en la leyenda. No son hablantes ni idiomas necesariamente oficiales.',
    GraphicVisual.venn => 'Usa hasta tres idiomas con presencia en más países de la selección. Las cifras cuentan países en cada intersección exacta; los que no registran ninguno se muestran fuera. Las áreas de los círculos son esquemáticas, no proporcionales. Todos los siete países se contabilizan una vez.',
    GraphicVisual.chernoff => 'Ancho de cara: población; altura: superficie; separación de ojos: densidad; tamaño de ojos: idiomas; nariz: fronteras; curvatura de boca: zonas horarias; inclinación de cejas: monedas. Todos usan índices 0–100. Una sonrisa NO significa felicidad ni valoración del país; el tamaño mínimo solo permite ver rasgos con valor cero.',
    GraphicVisual.andrews => 'Transforma los siete índices, divididos por 100, en una función: población/√2 + superficie·sen(t) + densidad·cos(t) + idiomas·sen(2t) + fronteras·cos(2t) + zonas·sen(3t) + monedas·cos(3t). Compara formas del perfil, no tiempo ni datos que la API haya medido entre países. Los perfiles iguales producen curvas superpuestas.',
    GraphicVisual.petals => 'Cada flor es un país; sus siete pétalos elípticos tienen longitudes proporcionales a los siete índices, no áreas proporcionales. El centro identifica al país y cada color de pétalo una métrica. Un índice cero no dibuja pétalo; no es un radar ni una distribución de flores reales.',
    GraphicVisual.convexHull => 'Los puntos comparan superficie y población relativas. Una envolvente une los extremos de los países de una misma región: con dos países se muestra un segmento y con uno un punto. No es un mapa, una frontera, intervalo de confianza ni estimación de países no seleccionados.',
    GraphicVisual.hexbin => 'Agrupa los siete puntos de superficie y población en celdas hexagonales de tamaño fijo. El número y la intensidad cuentan países dentro de cada celda, no habitantes. La leyenda lista sus miembros; los hexágonos vacíos no se dibujan y su área no representa territorio.',
    GraphicVisual.taylor => 'Compara el perfil de siete índices de cada país con el perfil medio de la selección. El radio es su desviación estándar muestral; el ángulo representa la correlación de Pearson. La distancia al marcador de referencia es la discrepancia centrada (RMS con divisor 6), no el error total ni una evaluación de calidad. Con variación cero la correlación es indefinida y ese país no se posiciona.',
    GraphicVisual.diamond => 'Los vértices laterales del diamante señalan los cuartiles 25 % y 75 % de los siete índices del país; el trazo señala la mediana. La anchura muestra el rango intercuartílico y la altura es decorativa. No son intervalos de confianza ni distribución de habitantes.',
    GraphicVisual.triangleFan => 'La base une el mínimo y máximo de los siete índices, y el vértice superior sitúa su mediana. La altura es constante y solo dibuja el abanico. No supone una distribución triangular ni probabilidades: resume tres posiciones del perfil real.',
    GraphicVisual.vector => 'La cola de la flecha está en el índice de población y su punta en el de superficie. Su dirección permite ver cuál supera al otro y su longitud la diferencia, siempre en el mismo país. No indica movimiento, geografía ni paso del tiempo; un empate se muestra con una marca sin dirección.',
    GraphicVisual.boxen => 'Tres cajas anidadas muestran cuantiles interpolados de los siete índices: 6,25–93,75 %, 12,5–87,5 % y 25–75 %. El trazo indica la mediana. Es un resumen visual de siete características, no estimación de colas poblacionales, incertidumbre ni una gran muestra estadística.',
    GraphicVisual.dots =>
      'El círculo sitúa el índice de densidad en el eje 0–100 compartido.',
    GraphicVisual.boxPlot => 'Caja: cuartiles inclusivos de los siete índices; trazo: mediana; bigotes: mínimo y máximo. Son características normalizadas, no muestras de habitantes.',
    GraphicVisual.lollipop => 'El tallo va de cero al índice de población; su extremo cuadrado permite distinguirlo del punto de densidad.',
    GraphicVisual.dumbbell => 'Une los índices de idiomas (extremo circular) y zonas horarias (extremo hueco). Lee sus posiciones en el eje relativo común.',
    GraphicVisual.bullet => 'La barra muestra el índice de fronteras; el trazo vertical la media de ese índice entre los siete países. No representa una meta.',
  };
}
