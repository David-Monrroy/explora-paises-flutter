# Explora Países

Aplicación Flutter con diseño móvil para consultar países, buscar información,
ver detalles y administrar favoritos.

## Ejecutar en Chrome

```powershell
flutter run -d chrome
```

La aplicación utiliza REST Countries v5 cuando se proporciona una clave y el
dataset oficial del proyecto como fuente compatible para la demostración.

## Organización del código

```text
lib/
├── app/                    # Configuración global y tema
├── core/                   # Constantes, errores y utilidades
├── data/                   # Modelos, fuentes, repositorios y servicios HTTP
├── presentation/           # Pantallas, widgets y ViewModels
└── main.dart               # Punto de entrada
```

La capa de presentación depende de contratos de repositorio, mientras que el
servicio HTTP y las fuentes de respaldo permanecen aislados en la capa de datos.

## Módulo de gráficas

En la pestaña **Gráficas** primero se eligen exactamente siete países. El catálogo
permanece oculto hasta completar la selección. Después aparecen 252
visualizaciones construidas exclusivamente con esos siete países:

- 63 con `fl_chart`.
- 63 con `syncfusion_flutter_charts`.
- 63 con `charts_flutter_maintained`.
- 63 con `graphic`.

Cada librería contiene 31 gráficas básicas y 32 avanzadas. Las 252 figuras
tienen conjuntos de formas distintos, sin contar colores, orden, nombres o
métricas como diferencias. Los detalles incluyen título,
explicación, ejes, unidades, leyenda y los valores de cada país o grupo.

Las métricas son población, superficie, densidad, idiomas, países limítrofes,
zonas horarias y monedas. Los gráficos de línea y área muestran rankings o
acumulados, no una evolución histórica. Los datos se obtienen de REST Countries;
si falla la conexión se usa un pequeño conjunto de respaldo para la demostración.

El catálogo, las transformaciones de datos y los cuatro renderizadores están
separados dentro de `lib/features/charts/`.

### Renovación por etapas: FL Chart completado

La primera librería contiene 15 visualizaciones individuales, 16 combinaciones
de dos, 16 de tres y 16 de cuatro. Las primeras 31 se clasifican como básicas y
las 32 combinaciones de tres o cuatro como avanzadas. El conjunto de componentes
de cada combinación es único, incluso si se ignora su orden, nombre y color.
Las cuatro etapas están completadas, con verificación de conjuntos de geometrías
distintos entre librerías.

Las formas incluyen radar, paletas, mancuernas, pendientes, coordenadas paralelas,
burbujas, mapa de calor, waffle, curva de concentración, cascada, bala, barras
divergentes, distribución acumulada, tira de puntos y rosa polar. Las 48
combinaciones fusionan sus componentes en una sola figura, con un sistema de
coordenadas compartido. Incluyen columnas con líneas, áreas con burbujas,
mancuernas sobre franjas y radar con rosa polar y marcadores. Cada capa tiene
nombre, color y explicación propios en la leyenda. No hay paneles separados.

Las combinaciones cartesianas usan el mismo eje de países y escalas relativas
0–100; la cascada muestra porcentajes acumulados, identificados como tales.
Las seis combinaciones polares comparten centro y ángulos: cada radio corresponde
a un país. La rosa representa valores con áreas proporcionales y el radar con
radios lineales. Los colores de una combinación identifican capas; los códigos
identifican países. Las figuras individuales conservan su leyenda original.

La selección de siete países sigue siendo obligatoria. Resaltar un país en el
detalle solo cambia su énfasis visual: los siete permanecen en los cálculos.
Las escalas relativas, los rangos con empates y el redondeo de las cien casillas
se calculan en `data/creative_chart_data.dart` y `data/fusion_chart_data.dart`. Los valores cero se conservan;
si no existe un total positivo, la vista proporcional muestra un mensaje.

El catálogo de esta etapa está en `data/fl_creative_catalog.dart`, las definiciones
en `domain/creative_chart.dart` y la presentación en `presentation/`. Los datos
originales con sus unidades se pueden consultar al desplegar cada país.

### Segunda etapa: Syncfusion completado

Syncfusion contiene 63 propuestas: 15 individuales, 16 combinaciones de dos,
16 de tres y 16 de cuatro. Conserva 31 básicas y 32 avanzadas. Incluye columnas
de rango, bandas curvas, líneas y áreas escalonadas, splines, cajas y bigotes,
Hilo, OHLC adaptado, velas de características, columnas apiladas de complemento,
histograma, embudo, pirámide y barras radiales. Son tipos nativos distintos de
los usados en FL Chart; los conjuntos de formas se comparan sin considerar
nombre de librería, orden, colores o métricas para detectar duplicados.

Las 48 combinaciones usan un único `SfCartesianChart` con varias series, un eje
de países compartido y el índice 0–100. No son paneles ni múltiples gráficas
independientes. Las transparencias y anchos distintos permiten identificar
las capas, cuyos nombres y transformaciones aparecen en la leyenda.

Los rangos comparan características normalizadas, no intervalos de confianza.
Las cajas resumen los siete índices de cada país, no muestras de habitantes.
Las geometrías Hilo/OHLC/velas se adaptan a comparaciones de características,
sin inventar precios, aperturas, cierres ni series históricas. Los splines son
guías entre categorías, no observaciones intermedias. Las columnas apiladas
usan densidad y su complemento al máximo, sin sumar unidades incompatibles.
El histograma cuenta países por intervalos de densidad; el embudo compara
habitantes y la pirámide reparte superficie en modo área. Los arcos radiales
miden superficie respecto al máximo del grupo, no respecto al total.

La selección obligatoria de siete países no se modifica. El catálogo está en
`data/syncfusion_creative_catalog.dart`, los cálculos en
`data/syncfusion_chart_data.dart`, las especificaciones en
`domain/syncfusion_chart_spec.dart` y el dibujo en
`presentation/renderers/syncfusion_renderer.dart`. La pantalla de detalle es
compartida; los datos originales y sus unidades se conservan.

### Tercera etapa: Maintained Charts completado

63 figuras: 15 individuales, 16 fusiones de dos, 16 de tres y 16 de cuatro
geometrías; 31 básicas y 32 avanzadas. Incluye treemap, sunburst, Sankey,
cuerdas, ternario, Marimekko, icicle, empaquetado de círculos, pictograma,
violín, ridgeline, rug, horizonte, enjambre y red de arcos. Los conjuntos de
formas se comparan con las 126 figuras anteriores sin considerar librería,
orden, nombre, métrica o color. Los componentes conocidos solo se reutilizan
dentro de combinaciones nuevas; cada combinación contiene una geometría nueva.

Los diagramas poco comunes son extensiones del motor de Maintained, no tipos
incorporados de fábrica: `PointRendererDecorator` dibuja con su `ChartCanvas`
en **un único `ScatterPlotChart` nativo**. No se colocan dos gráficas lado a
lado ni se sustituye la librería por un `CustomPainter` independiente. Las
48 fusiones comparten un eje horizontal 0–100 y siete filas de países.
Contornos, transparencias, símbolos y pequeños desplazamientos dentro de
cada fila permiten leer las capas; estos desplazamientos no son datos.

Las redes usan monedas compartidas y fronteras registradas entre los siete;
sin coincidencias se muestran nodos sin inventar conexiones. El Sankey agrupa
habitantes por región, no migraciones. Treemap y círculos conservan áreas
proporcionales a km², y los círculos no se solapan. Sunburst e icicle conservan
los totales en ambos niveles de región y país. El ternario reparte la suma de
tres índices, no unidades físicas incompatibles. Marimekko usa cuota de
habitantes como ancho e idiomas relativos como altura; su área no representa
una nueva cantidad. Horizonte pliega densidad en tres bandas; no es historia.

Violín y ridgeline describen solo los siete índices de características por
país mediante una estimación gaussiana de ancho fijo 12, reflejada en los
límites 0 y 100. No son distribuciones de habitantes, inferencia estadística
ni intervalos de confianza. Rug conserva siete marcas incluso con empates;
las cajas usan cuartiles inclusivos y bigotes mínimo/máximo. El enjambre
mantiene densidades reales y separa los puntos verticalmente para evitar
colisiones, sin añadir observaciones. Los ceros y perfiles sin composición
se explican, y todos los países siguen disponibles en la leyenda y datos.

Catálogo: `data/maintained_creative_catalog.dart`; cálculos y relaciones:
`data/maintained_chart_data.dart`; especificaciones:
`domain/maintained_chart_spec.dart`; renderizador y extensión nativa:
`presentation/renderers/maintained_renderer.dart` y
`presentation/renderers/maintained_scene_decorator.dart`. El detalle conserva
títulos, unidades, explicaciones y valores originales, y permite consultar
regiones, monedas y fronteras. Resaltar nunca reduce la selección de siete.

`charts_flutter_maintained` se conserva en `third_party/` con tres ajustes
mínimos de compatibilidad para Dart 3.13. El código sigue perteneciendo a sus
autores originales y mantiene sus archivos de licencia.

### Cuarta etapa: Graphic completado

63 figuras: 15 individuales, 16 fusiones de dos, 16 de tres y 16 de cuatro
componentes; 31 básicas y 32 avanzadas. Incluye Voronoi, dendrograma, árbol de
expansión mínima, UpSet, Venn, caras de Chernoff, curvas de Andrews, pétalos,
envolventes convexas, hexbin, Taylor, diamantes intercuartílicos, abanicos
triangulares, flechas de contraste y boxen. Las 252 figuras se comparan por
sus conjuntos de formas, ignorando biblioteca, orden, nombre, color y métrica.
Los componentes conocidos solo aparecen en combinaciones nuevas, nunca como
gráficas individuales repetidas.

Son extensiones públicas de Graphic, no tipos incorporados de fábrica:
`CustomMark` y `Shape` generan sus `MarkElement` nativos dentro de **un único
`Chart`**. Cada combinación añade dos, tres o cuatro marcas al mismo lienzo,
con siete filas y un eje relativo 0–100 compartido. Cada capa conserva su nombre,
color y explicación. Las etiquetas cercanas se separan con llamadas; los puntos
no se desplazan y los siete países siguen en los cálculos al resaltar uno.

Voronoi, envolventes y hexbin usan índices de superficie y población: no son
mapas ni áreas territoriales. Las coordenadas idénticas comparten celda. Las
envolventes agrupan por región y el hexbin cuenta países, no habitantes.
El dendrograma usa enlace promedio sobre la distancia cuadrática media de los
siete índices; el árbol conecta los siete perfiles con seis enlaces mínimos,
sin inventar fronteras. UpSet cuenta idiomas con membresía exacta y Venn cuenta
países para hasta tres idiomas; sus círculos son esquemáticos y la lista detalla
todos los miembros. Se conservan los nombres originales de idiomas de la API.

Chernoff y pétalos codifican los siete índices y explican cada rasgo; las caras
no valoran felicidad y los pétalos tienen longitudes, no áreas, proporcionales.
Andrews transforma esos índices en funciones matemáticas, no series temporales.
Taylor compara cada perfil con el perfil medio mediante correlación y desviación
estándar muestral; su discrepancia centrada usa divisor 6, no representa error
total ni calidad. Una correlación indefinida no se dibuja y se explica.
Diamantes, abanicos y boxen resumen cuantiles de siete características, sin
afirmar distribuciones poblacionales ni intervalos de confianza. Las flechas
comparan población y superficie relativas, no movimientos históricos.

Catálogo: `data/graphic_creative_catalog.dart`; cálculos:
`data/graphic_chart_data.dart`; especificaciones: `domain/graphic_chart_spec.dart`;
presentación y extensión nativa: `presentation/renderers/graphic_renderer.dart`
y `presentation/renderers/graphic_scene_shape.dart`. La selección obligatoria
de siete países y los valores originales con sus unidades permanecen intactos.

## Verificación

```powershell
flutter analyze
flutter test --concurrency=1
flutter build web --release --no-wasm-dry-run
```

Las pruebas comprueban conteos, unicidad entre las cuatro bibliotecas, cálculos,
selección de siete países, datos originales, figuras compartidas y renderizado
móvil, incluidos perfiles con valores cero o empatados.
