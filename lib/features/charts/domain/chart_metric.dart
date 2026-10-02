enum ChartMetric {
  population,
  area,
  density,
  languages,
  borders,
  timezones,
  currencies,
}

extension ChartMetricLabels on ChartMetric {
  String get meaning => switch (this) {
    ChartMetric.population => 'Número de habitantes registrado por la API.',
    ChartMetric.area => 'Superficie terrestre en kilómetros cuadrados.',
    ChartMetric.density => 'Habitantes divididos entre kilómetros cuadrados.',
    ChartMetric.languages => 'Número de idiomas registrados para el país.',
    ChartMetric.borders => 'Número de países vecinos con frontera terrestre, aunque no estén entre los siete elegidos.',
    ChartMetric.timezones =>
      'Número de zonas horarias registradas para el país.',
    ChartMetric.currencies => 'Número de monedas registradas para el país.',
  };

  String get label => switch (this) {
    ChartMetric.population => 'Población',
    ChartMetric.area => 'Superficie',
    ChartMetric.density => 'Densidad poblacional',
    ChartMetric.languages => 'Idiomas registrados',
    ChartMetric.borders => 'Países limítrofes',
    ChartMetric.timezones => 'Zonas horarias',
    ChartMetric.currencies => 'Monedas registradas',
  };

  String get unit => switch (this) {
    ChartMetric.population => 'habitantes',
    ChartMetric.area => 'km²',
    ChartMetric.density => 'hab./km²',
    ChartMetric.languages => 'idiomas',
    ChartMetric.borders => 'fronteras',
    ChartMetric.timezones => 'zonas horarias',
    ChartMetric.currencies => 'monedas',
  };
}
