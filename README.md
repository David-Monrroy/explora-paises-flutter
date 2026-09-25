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

`charts_flutter_maintained` se conserva en `third_party/` con tres ajustes
mínimos de compatibilidad para Dart 3.13. El código sigue perteneciendo a sus
autores originales y mantiene sus archivos de licencia.

## Verificación

```powershell
flutter analyze
flutter test
flutter build web
```
