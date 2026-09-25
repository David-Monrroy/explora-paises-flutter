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

La pestaña **Gráficas** incluye 252 visualizaciones construidas con información
de REST Countries:

- 63 con `fl_chart`.
- 63 con `syncfusion_flutter_charts`.
- 63 con `charts_flutter_maintained`.
- 63 con `graphic`.

Cada librería contiene 31 gráficas básicas y 32 avanzadas. El catálogo, las
transformaciones de datos y los cuatro renderizadores están separados dentro de
`lib/features/charts/`. Las visualizaciones se diferencian por tipo, métrica,
agrupación, alcance, orden, cantidad de datos e interacción.

`charts_flutter_maintained` se conserva en `third_party/` con tres ajustes
mínimos de compatibilidad para Dart 3.13. El código sigue perteneciendo a sus
autores originales y mantiene sus archivos de licencia.

## Verificación

```powershell
flutter analyze
flutter test
flutter build web
```
