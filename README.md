# app_examen

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# App Examen — Computación Móvil (Flutter)

Aplicación móvil en Flutter que implementa **Login con Firebase** y **CRUD** para **Productos, Categorías y Proveedores** consumiendo una API REST externa con autenticación **Basic**. Diseño inspirado en el look & feel de **Líder** (azul primario y amarillo de acento), navegación por **Tabs** y validaciones de formularios.

---

## Tecnologías y versiones probadas

- **Flutter**: 3.35.4 (stable) · **Dart**: 3.9.2  
- **Android SDK**: 36.x (emulador Pixel/arm64)  
- **Firebase**: Auth (Email/Password) + `flutterfire`  
- **HTTP**: paquete `http` para consumir la API  
- **Fuentes/Estilos**: `google_fonts`, theming Material 3  
- **Formato moneda**: `intl` (CLP: `$9.000`)

> **Nota:** iOS no fue validado (Xcode/CocoaPods no instalados en el entorno actual).

---

## Requisitos previos

- Flutter instalado y en `PATH`.
- SDK de Android y emulador configurados.
- Cuenta de Firebase y proyecto con **Email/Password** habilitado  
  (ya incluido `lib/firebase_options.dart` generado con `flutterfire`).
- Conexión a internet (la API es HTTP externa).

---

## Configuración rápida

1. Instalar dependencias:
   ```bash
   flutter pub get
   ```
2. (Opcional) Reconfigurar Firebase en tu cuenta:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=android
   ```
   Esto generará/actualizará `lib/firebase_options.dart`.
3. Verificar permisos de red en Android (**ya incluidos**):
   - `android/app/src/main/AndroidManifest.xml` contiene:
     ```xml
     <uses-permission android:name="android.permission.INTERNET"/>
     <application
         android:usesCleartextTraffic="true" ... >
     ```
     Se habilita tráfico **HTTP** por ser un backend sin HTTPS.
4. Ejecutar:
   ```bash
   flutter run
   ```

---

## Credenciales y Endpoints (API del examen)

- **Host**: `143.198.118.203:8100`
- **Basic Auth**: `user = test`, `pass = test2023`
- La app construye el header `Authorization: Basic ...` automáticamente en `lib/shared/services/api_client.dart`.

### Productos
| Acción | Método | Path | Ejemplo body |
|---|---|---|---|
| Listar | GET | `ejemplos/product_list_rest/` | — |
| Agregar | POST | `ejemplos/product_add_rest/` | `{"product_name":"nombre","product_price":100,"product_image":"https://..."}` |
| Editar | POST | `ejemplos/product_edit_rest/` | `{"product_id":1,"product_name":"nombre","product_price":100,"product_image":"https://...","product_state":"Activo"}` |
| Eliminar | POST | `ejemplos/product_del_rest/` | `{"product_id":1}` |

### Categorías
| Acción | Método | Path | Ejemplo body |
|---|---|---|---|
| Listar | GET | `ejemplos/category_list_rest/` | — |
| Agregar | POST | `ejemplos/category_add_rest/` | `{"category_name":"nombre"}` |
| Editar | POST | `ejemplos/category_edit_rest/` | `{"category_id":1,"category_name":"nombre","category_state":"Activa"}` |
| Eliminar | POST | `ejemplos/category_del_rest/` | `{"category_id":1}` |

### Proveedores
| Acción | Método | Path | Ejemplo body |
|---|---|---|---|
| Listar | GET | `ejemplos/provider_list_rest/` | — |
| Agregar | POST | `ejemplos/provider_add_rest/` | `{"provider_name":"nombre","provider_last_name":"apellido","provider_mail":"correo@correo.cl","provider_state":"Activo"}` |
| Editar | POST | `ejemplos/provider_edit_rest/` | `{"provider_id":1,"provider_name":"nombre","provider_last_name":"apellido","provider_mail":"correo@correo.cl","provider_state":"Activo"}` |
| Eliminar | POST | `ejemplos/provider_del_rest/` | `{"provider_id":1}` |

---

## Cómo usar la app

1. **Login / Registro**
   - Pantalla inicial: ingresar con Email/Password o crear cuenta.
   - Recuperación de contraseña disponible.
2. **Navegación por Tabs**
   - `Productos`, `Categorías`, `Proveedores`.
   - FAB contextual: *Agregar producto/categoría/proveedor*.
3. **CRUD**
   - **Listar**: carga inicial + pull-to-refresh.
   - **Agregar/Editar**: formularios con validaciones.
   - **Eliminar**: diálogo de confirmación.
   - En Productos, se muestra imagen, nombre, **precio formateado CLP** (`$9.000`) y estado cuando aplique.
4. **Salir**
   - Menú `⋮` en Home → `Cerrar sesión` (Firebase Auth).

---

## Estructura relevante

```
lib/
  modules/
    home/home_page.dart                 # Tabs y FAB contextual
    login/login_page.dart               # Auth Firebase
    products/                           # Modelo, servicio, lista, formulario
    categories/                         # Modelo, servicio, lista, formulario
    providers/                          # Modelo, servicio, lista, formulario
  shared/
    services/api_client.dart            # HTTP + Basic Auth
    themes/app_theme.dart               # Look & feel Líder (M3)
  firebase_options.dart                 # Generado por flutterfire
```

---

## Criterios de evaluación (checklist)

- [x] **Login** con Firebase (registro, login, reset password).
- [x] **CRUD Productos** contra API con Basic Auth.
- [x] **CRUD Categorías** contra API con Basic Auth.
- [x] **CRUD Proveedores** contra API con Basic Auth.
- [x] **UI** inspirada en Líder (colores, tipografía, TabBar).
- [x] **Validaciones** de formularios y mensajes de error/éxito.
- [x] **Pull-to-refresh** en listados.
- [x] **Logs** de red en consola para GET/POST (útil para corrección).

---

## Troubleshooting

- **No carga la API / imágenes**  
  Verificar `INTERNET` y `android:usesCleartextTraffic="true"` en `AndroidManifest.xml`.
- **Formato de precio**  
  Se usa `intl` con `NumberFormat.decimalPattern('es_CL')` → `$9.000` (sin decimales).
- **Login falla en emulador**  
  Revisar conectividad de red del emulador; probar crear cuenta nueva si la existente no valida.
- **El TabBar no aparece al primer inicio**  
  Hacer `flutter clean && flutter pub get` si cambiaste el Home o el árbol de navegación recientemente.

---

## Comandos útiles

```bash
# Ejecutar
flutter run

# Limpiar cachés
flutter clean && flutter pub get

# Ver logs de llamadas a la API desde Flutter
flutter logs | egrep "\[POST\]|\[GET\]"
```

---

## Licencia

Uso académico para el examen de Computación Móvil.