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

Cada librería contiene 31 gráficas básicas y 32 avanzadas. Las 252 combinaciones
de métrica, cálculo y geometría son únicas. Los detalles incluyen título,
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
Las otras tres librerías conservan su catálogo hasta la siguiente etapa.

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

`charts_flutter_maintained` se conserva en `third_party/` con tres ajustes
mínimos de compatibilidad para Dart 3.13. El código sigue perteneciendo a sus
autores originales y mantiene sus archivos de licencia.

## Verificación

```powershell
flutter analyze
flutter test
flutter build web
```
