# 🛠️ Cómo trabaja esta casa

Documento operativo del proyecto **Alya Agent para Android**: dónde va cada cosa, cómo se
publica, cómo se usa el repositorio y en qué momento se sube el APK.
Está escrito para mí (Lianarela) en la próxima sesión y para quien llegue después.

---

## 1. El mapa

| Sitio | Qué es | Quién puede verlo |
|---|---|---|
| **Repo privado de desarrollo** (`codespace`) | El código fuente real: `/workspaces/alya-252` | Solo el dueño |
| **`anyer097-collab/Alya-Agent-App`** (público) | APK, recursos (fondos, vídeos) y **Alya Store** (`alyahub/`) | Todo el mundo |
| **Telegram** (`@Alya2_my_bot`, chat `7953907047`) | Entrega de cada APK y de cada ZIP de fuente | Solo el dueño |
| **Google AI Studio / Gemini** | Cerebro de la app | — |

El repo público **no** lleva código fuente: solo el APK, los recursos y el catálogo de la
tienda. El código vive en el codespace privado.

```
Alya-Agent-App/
├── README.md                  ← lo que ve el usuario que entra al repo
├── Alya-Agent.apk (release)   ← enlace permanente del canal
├── multimedia-Alya/video/     ← vídeos que usa la app
├── pictures-Alya/
│   ├── temas/                 ← fondos (retro_N.jpg)
│   └── README.md
└── alyahub/                   ← ★ Alya Store
    ├── catalogo.json          ← la lista de la tienda (lo que lee la app)
    ├── update.json            ← versión publicada y enlace del APK
    ├── README.md              ← este archivo
    └── scripts/               ← los .sh que se instalan en el teléfono
        ├── info-sistema.sh
        ├── limpiar-descargas.sh
        └── …
```

---

## 2. Alya Store: cómo se publica algo nuevo

**No hay que compilar nada.** La app lee `alyahub/catalogo.json` (con caché de una hora y
copia local para funcionar sin conexión). Publicar una app nueva son dos pasos:

1. **Subir el script** a `alyahub/scripts/mi-app.sh`.
   - `#!/bin/sh` en la primera línea.
   - Cabecera con nombre, versión, autor y una línea de qué hace.
   - Todo lo que escriba va a `/sdcard/AlyaHub/` o `/sdcard/Download/`.
   - Mensajes en español, y `exit 1` con texto claro si falla algo.
   - Nada de dependencias raras: bash, grep, sed, awk, curl, python3.

2. **Añadir su ficha** al array `articulos` de `alyahub/catalogo.json`:

```json
{
  "id": "mi-app",
  "nombre": "Mi app",
  "descripcion": "Una frase de qué hace.",
  "categoria": "Sistema",
  "tipo": "script",
  "emoji": "🧪",
  "version": "1.0",
  "autor": "Alya",
  "archivo": "alyahub/scripts/mi-app.sh",
  "comando": "mi-app",
  "permisos": ["almacenamiento", "terminal"],
  "color": "0xFF50FA7B"
}
```

Categorías en uso: `Sistema`, `Utilidades`, `Multimedia`, `Juegos`.
`color` es ARGB en hexadecimal (`0xFF` + color). `comando` es el nombre con el que se
ejecuta en la terminal una vez instalado.

**Tipos válidos:** `script` (se instala en `/sdcard/AlyaHub/scripts` y se registra como
comando en `$PREFIX/bin`), `apk` (se baja y se abre el instalador; usa `url` en vez de
`archivo`), `tema` (fondo: se guarda en `Pictures/AlyaTemas`).

Al instalarse, el script queda también como comando del motor Linux:

```sh
alya -> terminal -> info-sistema
```

El lanzador que se crea en `$PREFIX/bin/<comando>` llama al bash del motor de Alya, así que
funciona desde cualquier carpeta y sin tener que escribir la ruta.

---

## 3. El APK: cuándo y cómo se actualiza

**Cuándo:** cada vez que se entrega una versión nueva por Telegram. No antes: el APK del
repo es el que la app ofrece instalarse, así que **solo se sube lo que ya está probado**.

**Un canal, un archivo por versión.** En la release `apk-latest`:

| Archivo | Para qué |
|---|---|
| `Alya-Agent-v1.apk`, `v2`, `v3`… | Histórico. Cada número mayor es una actualización. |
| `Alya-Agent.apk` | Enlace permanente: siempre apunta a la última. |

El número de canal es **una sola cifra** (v1 → v9) y sube de uno en uno. El `versionCode`
de Android sí es siempre creciente (85, 86, 87…): son dos numeraciones distintas y no
deben confundirse.

### Los tres pasos de una publicación

```sh
# 1. Subir el APK con el número de canal siguiente (v3 -> v4)
gh release upload apk-latest app-release.apk#Alya-Agent-v4.apk --clobber -R anyer097-collab/Alya-Agent-App

# 2. Copiarlo también al nombre permanente
gh release upload apk-latest app-release.apk#Alya-Agent.apk --clobber -R anyer097-collab/Alya-Agent-App

# 3. Actualizar alyahub/update.json (canal, versionName, versionCode, tamaño, sha256, notas)
```

`update.json` es la fuente de verdad para la app:

```json
{
  "canal": 4,
  "versionName": "2.9.9",
  "versionCode": 86,
  "apk": "https://github.com/anyer097-collab/Alya-Agent-App/releases/download/apk-latest/Alya-Agent-v4.apk",
  "tamano": 35558494,
  "sha256": "…",
  "fecha": "2026-10-28",
  "notas": "Qué cambia, en dos líneas."
}
```

La app compara **su `versionCode`** con el de `update.json`. Si el del repo es mayor, sale
el aviso «Actualización disponible» en el Hub → Alya Store, con botón **Actualizar** que
descarga e instala sin salir de la app. Si `update.json` no se pudiera leer, la app cae a
la API de GitHub y coge el `Alya-Agent-vN.apk` de número más alto. Nunca actualiza hacia
atrás.

La comprobación se hace al abrir el Hub, como mucho **4 veces al día** (6 h de espera en
preferencias). El botón «Buscar ahora» de la tienda fuerza la consulta.

### Firma

El APK del repo y el que se instala por Telegram salen del **mismo keystore**. Si algún día
se cambia el keystore, quien tenga la app instalada tendrá que desinstalar y volver a
instalar: por eso el keystore vive fuera del repo y no se toca.

---

## 4. Tokens y credenciales

Nunca en el workspace, nunca en el repo, nunca en un commit. En esta mesa se usan así:

| Token | Para qué | Dónde vive |
|---|---|---|
| `ghp_…` (codespaces) | Entrar al codespace por SSH y compilar | Variable de entorno de la sesión |
| `ghp_…` (repo) | Subir APK, recursos y catálogo | Variable de entorno de la sesión |
| Bot de Telegram | Entregar APK y fuente | Variable de la sesión |
| Token del bot de Alya | Conectar la app con Telegram | Ajustes de la app, en el teléfono |

Reglas que ya nos costaron un susto:

- `chmod 600 ~/.ssh/*` **siempre** antes de `gh codespace ssh`; si no, «UNPROTECTED PRIVATE KEY FILE».
- Los archivos de `herramientas/` (el binario `gh`) **no persisten** entre sesiones: si falta,
  se reinstala (`gh_2.62.0_linux_amd64`).
- Cuando se pega un token en un comando, se hace en la misma llamada; no se escribe en un
  archivo del workspace.

---

## 5. Compilar y entregar

```sh
# Compilar (rápido, para ver errores)
./gradlew :app:compileDebugKotlin --no-daemon \
  -Dorg.gradle.jvmargs="-Xmx4g -XX:MaxMetaspaceSize=1g -Dfile.encoding=UTF-8"

# Release firmada (tarda ~10 min; con -Xmx5g el daemon muere)
GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g" ./gradlew :app:assembleRelease --no-daemon \
  -x lintVitalRelease --max-workers=1 -Pkotlin.daemon.jvmargs="-Xmx2g" \
  -Dorg.gradle.jvmargs="-Xmx4g -XX:MaxMetaspaceSize=1g -Dfile.encoding=UTF-8"
```

- Lanzar los builds con `nohup … & echo lanzado`; **nunca** `pkill -f gradlew` por SSH (mata la sesión).
- Antes de entregar: `aapt dump badging` para confirmar `versionCode` y `versionName`, y `md5sum`.
- Cada entrega va por Telegram con **APK y ZIP de fuente** en el mismo envío. El pie de
  foto **no puede pasar de 1024 caracteres** (si pasa, Telegram rechaza el mensaje entero).
- Versionar: subir `versionCode` +1 y `versionName` en `app/build.gradle.kts`.

---

## 6. Reglas de la casa

1. **Probar antes de importar.** Buscadores, descargas o cualquier motor nuevo se prueban
   fuera de la app (sandbox/codespace) y solo después se mete en el código.
2. **Nada de «✅ listo» falso.** Si no está compilado, no está terminado.
3. **Las capturas mandan.** Cuando el usuario enseña una pantalla con un error, ese es el
   problema a resolver, no otro.
4. **Cada versión se entrega** por Telegram sin preguntar, con su md5.
5. **El código no se borra.** Lo que se quita de la interfaz se oculta, no se elimina.
6. **Cero restricciones de ejecución.** Alya no bloquea comandos del usuario; solo protege
   la raíz del sistema.
7. **Los recursos del repo son del usuario.** No se reorganizan carpetas sin avisar.

---

*Última revisión: 28-10-2026 · Alya Agent 2.9.9*
