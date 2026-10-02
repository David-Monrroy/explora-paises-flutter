// Visual forms are independent of library names and palette choices.
// Sorting them gives a signature that also detects reordered duplicates.
import 'fusion_chart.dart';

enum CreativeVisual {
  radar,
  lollipop,
  dumbbell,
  slope,
  parallel,
  bubble,
  heatmap,
  waffle,
  lorenz,
  waterfall,
  bullet,
  diverging,
  ecdf,
  strip,
  rose,
}

class CreativeChartSpec {
  const CreativeChartSpec(
    this.subject,
    this.explanation,
    this.visuals, {
    this.fusion,
  });

  final String subject;
  final String explanation;
  final List<CreativeVisual> visuals;
  final FusionChartSpec? fusion;

  int get componentCount => fusion?.layers.length ?? visuals.length;

  String get title =>
      '${fusion?.names ?? visuals.map((item) => item.label).join(' + ')}: $subject';
  String get signature =>
      fusion?.signature ??
      (visuals.map((item) => item.name).toList()..sort()).join('|');
}

extension CreativeVisualLabels on CreativeVisual {
  String get label => switch (this) {
    CreativeVisual.radar => 'Radar',
    CreativeVisual.lollipop => 'Paletas',
    CreativeVisual.dumbbell => 'Mancuernas',
    CreativeVisual.slope => 'Pendientes',
    CreativeVisual.parallel => 'Coordenadas paralelas',
    CreativeVisual.bubble => 'Burbujas',
    CreativeVisual.heatmap => 'Mapa de calor',
    CreativeVisual.waffle => 'Waffle',
    CreativeVisual.lorenz => 'Curva de concentración',
    CreativeVisual.waterfall => 'Cascada',
    CreativeVisual.bullet => 'Bala',
    CreativeVisual.diverging => 'Barras divergentes',
    CreativeVisual.ecdf => 'Distribución acumulada',
    CreativeVisual.strip => 'Tira de puntos',
    CreativeVisual.rose => 'Rosa polar',
  };

  String get explanation => switch (this) {
    CreativeVisual.radar => 'Cada polígono es un país. Compara población, superficie, densidad y fronteras. En cada eje, el mayor valor de la selección equivale a 100; no es una puntuación de calidad.',
    CreativeVisual.lollipop => 'La altura de cada paleta indica cuántos idiomas registra el país. El punto señala el valor y el tallo parte de cero.',
    CreativeVisual.dumbbell => 'En cada fila, el punto verde indica el porcentaje de población y el violeta el porcentaje de superficie. La distancia muestra el desequilibrio entre ambas participaciones.',
    CreativeVisual.slope => 'Conecta la posición por superficie con la posición por población. El puesto 1 aparece arriba. Los valores iguales comparten puesto; la pendiente no representa el paso del tiempo.',
    CreativeVisual.parallel => 'Una línea por país recorre idiomas, fronteras, zonas horarias y monedas. Cada eje usa una escala relativa: 100 es el máximo de esa característica entre los siete.',
    CreativeVisual.bubble => 'La posición cruza superficie y población, ambas relativas a su máximo. El área de la burbuja representa la densidad relativa; usa la leyenda para identificar los países superpuestos.',
    CreativeVisual.heatmap => 'Cada fila es un país y cada columna una característica. Un verde más intenso significa un valor más próximo al máximo de esa columna. El color no compara unidades diferentes directamente.',
    CreativeVisual.waffle => 'Cien casillas reparten la superficie total de la selección. Una casilla representa aproximadamente 1 %. Se redondea conservando las 100 casillas; participaciones menores pueden no ocupar una casilla.',
    CreativeVisual.lorenz => 'Ordena los países de menor a mayor población. Compara el porcentaje acumulado de países con el de habitantes. Alejarse de la diagonal indica mayor concentración dentro de esta selección.',
    CreativeVisual.waterfall => 'Cada bloque añade la participación de un país en la población total. El final alcanza 100 %. La altura del bloque es el aporte; su posición muestra lo acumulado.',
    CreativeVisual.bullet => 'Cada barra cuenta las zonas horarias del país. El fondo llega al máximo observado y la línea violeta marca la media de los siete, una referencia y no una meta.',
    CreativeVisual.diverging => 'Compara la densidad con la media de la selección. Verde significa por encima y violeta por debajo; cero coincide con la media. El eje usa diferencia porcentual respecto a esa media.',
    CreativeVisual.ecdf => 'Para cada número de fronteras terrestres, muestra qué porcentaje de los siete países tiene ese número o menos. Los saltos agrupan empates y el último alcanza 100 %.',
    CreativeVisual.strip => 'Cada punto es un país situado según su número de monedas. La altura solo separa países con el mismo valor: no representa otra variable.',
    CreativeVisual.rose => 'Cada sector tiene el mismo ángulo. Su área representa la superficie del país, por eso el radio crece con la raíz cuadrada del valor. Los sectores de superficie cero no tienen área.',
  };

  String get axes => switch (this) {
    CreativeVisual.radar => 'Radios: índice 0–100 · vértices: características',
    CreativeVisual.lollipop => 'X: países · Y: número de idiomas',
    CreativeVisual.dumbbell => 'X: participación (%) · Y: países · verde: población · violeta: superficie',
    CreativeVisual.slope => 'X: superficie → población · Y: puesto (1 = mayor)',
    CreativeVisual.parallel => 'X: características · Y: índice 0–100',
    CreativeVisual.bubble =>
      'X: superficie (0–100) · Y: población (0–100) · área: densidad',
    CreativeVisual.heatmap =>
      'Columnas: características · filas: países · intensidad: 0–100',
    CreativeVisual.waffle =>
      '100 casillas = superficie total de los siete países',
    CreativeVisual.lorenz =>
      'X: países acumulados (%) · Y: población acumulada (%)',
    CreativeVisual.waterfall => 'X: países · Y: población acumulada (%)',
    CreativeVisual.bullet =>
      'X: países · Y: zonas horarias · violeta: promedio',
    CreativeVisual.diverging =>
      'X: países · Y: diferencia de densidad respecto a la media (%)',
    CreativeVisual.ecdf => 'X: fronteras terrestres · Y: países acumulados (%)',
    CreativeVisual.strip => 'X: número de monedas · altura: separación visual',
    CreativeVisual.rose => 'Ángulo: país · área del sector: superficie (km²)',
  };
}
