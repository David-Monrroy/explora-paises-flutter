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
