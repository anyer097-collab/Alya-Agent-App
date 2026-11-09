# 🌸 Alya Agent para Android

Repositorio público de descargas y recursos de Alya Agent.

## Descargar el APK más reciente

### [⬇️ Descargar Alya-Agent.apk](https://github.com/anyer097-collab/Alya-Agent-App/releases/download/apk-latest/Alya-Agent.apk)

[Ver versión, fecha y SHA-256](https://github.com/anyer097-collab/Alya-Agent-App/releases/tag/apk-latest)

El enlace es permanente: al publicar una actualización se reemplaza el APK del mismo
canal. No necesitas buscar otra publicación ni cambiar el enlace guardado.

- Descarga el `.apk` en el teléfono y ábrelo para instalar/actualizar.
- Las versiones de la línea 2.2.x mantienen su firma; puedes actualizar sin desinstalar.
- La versión exacta y el checksum del archivo se muestran en la publicación.

**Desde la 2.9.9 no hace falta venir aquí:** la app comprueba sola si hay versión nueva al
abrir **Alya Hub → Alya Store** y la instala con un botón. Lee la versión publicada de
[`alyahub/update.json`](alyahub/update.json).

## Alya Store 🛍️

La tienda de la app: scripts, apps y temas que se instalan sin publicar una versión nueva
del APK. El catálogo es [`alyahub/catalogo.json`](alyahub/catalogo.json) y los scripts
están en [`alyahub/scripts/`](alyahub/scripts/).

| Artículo | Qué hace | Comando |
|---|---|---|
| 📊 Estado del teléfono | Memoria, temperatura, batería y disco | `info-sistema` |
| 🔋 Salud de la batería | Nivel, temperatura y apps que gastan CPU | `estado-bateria` |
| 🧹 Limpiador de descargas | Borra APK y temporales viejos | `limpiar-descargas [dias]` |
| 📸 Ordenar fotos | Fotos de DCIM a carpetas por año y mes | `ordenar-fotos` |
| 🎵 Ordenar música | Limpia los nombres de las canciones | `ordenar-musica` |
| 🔐 Generador de claves | Contraseñas fuertes sin internet | `clave [longitud]` |
| 🌐 Página a Markdown | Guarda una web para leerla sin conexión | `web-a-markdown <url>` |

Al instalarse, cada script queda disponible como comando en la terminal de Alya.

### Publicar algo nuevo en la tienda

1. Sube el `.sh` a `alyahub/scripts/`.
2. Añade su ficha a `alyahub/catalogo.json`.

No hace falta compilar ni publicar versión nueva. Cómo funciona todo por dentro, en
[`alyahub/README.md`](alyahub/README.md).

## Recursos del asistente

- [Videos y multimedia](multimedia-Alya/video/)
- [Temas y fondos](pictures-Alya/temas/)

Estos recursos se conservan independientes del APK.

## Sobre el código fuente

El proyecto Android y los scripts de compilación/publicación permanecen en el repo
privado de desarrollo. Aquí se adjunta **solo el APK**, no un ZIP del proyecto.

GitHub puede mostrar enlaces automáticos «Source code» en la Release: corresponden
a este repositorio público de recursos, **no al proyecto Android privado**.
