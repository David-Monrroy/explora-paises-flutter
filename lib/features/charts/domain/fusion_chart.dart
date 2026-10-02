import 'chart_metric.dart';

enum FusionProjection { cartesian, polar }

enum FusionMark {
  columns,
  line,
  area,
  dots,
  lollipop,
  dumbbell,
  bubble,
  waterfall,
  bullet,
  band,
  radar,
  rose,
}

class FusionLayer {
  const FusionLayer(this.mark, this.metric, {this.secondaryMetric});

  final FusionMark mark;
  final ChartMetric metric;
  final ChartMetric? secondaryMetric;

  String get label =>
      '${mark.label} · ${metric.label}'
      '${secondaryMetric == null ? '' : ' / ${secondaryMetric!.label}'}';

  String get explanation => switch (mark) {
    FusionMark.columns =>
      'Altura: ${metric.label.toLowerCase()} como porcentaje del mayor valor de los siete.',
    FusionMark.line =>
      'La línea conecta el índice relativo de ${metric.label.toLowerCase()} por país; 100 es el máximo de la selección.',
    FusionMark.area =>
      'El área bajo la curva muestra el índice relativo de ${metric.label.toLowerCase()}; 100 es el máximo.',
    FusionMark.dots =>
      'Cada punto sitúa el índice relativo de ${metric.label.toLowerCase()} de un país.',
    FusionMark.lollipop =>
      'El tallo parte de cero y el punto termina en el índice relativo de ${metric.label.toLowerCase()}. En la vista polar, el tallo sigue el radio del país.',
    FusionMark.dumbbell =>
      'Los extremos conectan los índices de ${metric.label.toLowerCase()} y ${secondaryMetric!.label.toLowerCase()}. El círculo es la primera métrica y el cuadrado la segunda; cada una se compara con su propio máximo.',
    FusionMark.bubble =>
      'La posición indica el índice relativo de ${metric.label.toLowerCase()}; el área del círculo es proporcional a ${secondaryMetric!.label.toLowerCase()} dentro de esta selección.',
    FusionMark.waterfall =>
      'Cada bloque suma el aporte porcentual de ${metric.label.toLowerCase()} al total de los siete. La altura del bloque es el aporte y su borde superior lo acumulado.',
    FusionMark.bullet =>
      'La barra mide el índice de ${metric.label.toLowerCase()}. El fondo llega al máximo y la línea discontinua indica el promedio del grupo en esta misma escala.',
    FusionMark.band =>
      'La franja une el menor y el mayor de los dos índices por país: ${metric.label.toLowerCase()} y ${secondaryMetric!.label.toLowerCase()}. Es una comparación entre características, no un intervalo estadístico.',
    FusionMark.radar =>
      'El polígono conecta los países según el índice relativo de ${metric.label.toLowerCase()}. El radio 100 representa el máximo del grupo.',
    FusionMark.rose =>
      'Los sectores tienen el mismo ángulo. Su área representa ${metric.label.toLowerCase()}; el radio es la raíz cuadrada del índice relativo. Lee el área de los pétalos, no su radio como un valor lineal.',
  };
}

class FusionChartSpec {
  const FusionChartSpec(
    this.layers, {
    this.projection = FusionProjection.cartesian,
  });

  final List<FusionLayer> layers;
  final FusionProjection projection;

  String get names => layers.map((layer) => layer.mark.label).join(' + ');
  // Names, metrics, palette and layer order cannot disguise duplicate shapes.
  String get signature =>
      '${projection.name}|'
      '${(layers.map((layer) => layer.mark.name).toList()..sort()).join('|')}';
  String get axes => projection == FusionProjection.cartesian
      ? 'X: países · Y: índice relativo o porcentaje acumulado (0–100). Consulta la transformación de cada capa en la leyenda.'
      : 'Ángulo: país · anillos: índice radial 0–100. La rosa usa área proporcional; el resto usa radio lineal.';
}

extension FusionMarkLabels on FusionMark {
  String get label => switch (this) {
    FusionMark.columns => 'Columnas',
    FusionMark.line => 'Línea de perfil',
    FusionMark.area => 'Área',
    FusionMark.dots => 'Dispersión',
    FusionMark.lollipop => 'Paletas',
    FusionMark.dumbbell => 'Mancuernas',
    FusionMark.bubble => 'Burbujas',
    FusionMark.waterfall => 'Cascada',
    FusionMark.bullet => 'Bala',
    FusionMark.band => 'Franja de comparación',
    FusionMark.radar => 'Radar',
    FusionMark.rose => 'Rosa polar',
  };
}
