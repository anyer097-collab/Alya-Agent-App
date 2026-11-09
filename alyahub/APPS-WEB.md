# 🧩 Apps web de Alya Hub

Una app del Hub ya no tiene que ser un guion de terminal. Puede ser **una página web**
(HTML + CSS + JS) que se dibuja dentro de Alya y **habla con el teléfono** a través de
`window.Alya`, que es lo que le da los permisos de Alya Agent.

```
/sdcard/AlyaHub/apps/calendario/
├── app.json      ← ficha (la genera la app al instalar)
├── index.html    ← la app
└── datos.json    ← lo que ella misma guarde (opcional)
```

Se pulsan en **Alya Hub → Mis apps**, con la etiqueta «Web», y se abren a pantalla
completa con su barra de volver y recargar. Los enlaces externos van al navegador.

---

## El puente `window.Alya`

Todas las funciones devuelven **JSON** y se usan con `await`:

```js
const r = await Alya.sh("ls -la /sdcard");
if (r.ok) console.log(r.salida);
```

| Función | Devuelve | Para qué |
|---|---|---|
| `Alya.info()` | `{app, version, alya, versionCode, android, modelo, permisosConcedidos, carpeta}` | Saber dónde corre y qué tiene |
| `Alya.sh(cmd, ms?)` | `{ok, salida}` | Shell real del **motor Linux de Alya** (bash 5, python3, curl…) |
| `Alya.leer(ruta)` | `{ok, contenido, ruta}` | Leer texto (relativa a la app o absoluta) |
| `Alya.escribir(ruta, txt)` | `{ok, ruta, tamano}` | Guardar (crea carpetas) |
| `Alya.listar(ruta)` | `{ok, items:[{nombre, ruta, carpeta, tamano, modificado}]}` | Ver una carpeta |
| `Alya.borrar(ruta)` · `Alya.existe(ruta)` | `{ok, …}` | — |
| `Alya.guardarEnDescargas(nombre, base64)` | `{ok, ruta}` | Exportar un CSV, una imagen… |
| `Alya.toast(t)` · `Alya.vibrar(ms)` | `{ok}` | Aviso corto y vibración |
| `Alya.copiar(t)` · `Alya.pegar()` | `{ok, texto?}` | Portapapeles |
| `Alya.notificar(titulo, texto)` | `{ok, enviada}` | Notificación del sistema |
| `Alya.hablar(texto)` | `{ok}` | Voz (TTS del teléfono) |
| `Alya.abrir(url)` · `Alya.compartir(t)` | `{ok}` | Navegador / hoja de compartir |
| `Alya.bateria()` | `{ok, nivel, cargando}` | — |
| `Alya.ubicacion()` | `{ok, lat, lon, precision}` | Última posición conocida |
| `Alya.permiso(nombre)` · `Alya.pedirPermiso(nombre)` | `{ok, concedido}` | camara, microfono, ubicacion, notificaciones… |
| `Alya.widget(texto)` | `{ok, texto}` | Cambia la línea que muestra su widget en el escritorio |
| `Alya.preguntar(texto)` | `{ok}` | Abre el chat de Alya con ese texto |
| `Alya.cerrar()` | `{ok}` | Cierra la app |

También está expuesto como `alya` y `AlyaNativo`, por si algún día hace falta otro nombre.

**Si la app se abre fuera de Alya** (un navegador normal) `window.Alya` no existe:
conviene comprobarlo y caer a `localStorage`, como hace el calendario.

---

## Widget en la pantalla de inicio

Cualquier app web se puede fijar como widget: **pulsación larga sobre la app → 📌 Widget**.
Android pide confirmación y aparece una tarjeta con el icono, el nombre y **una línea de
texto que la propia app controla**:

```js
await Alya.widget("3 tareas para hoy");
```

Al tocar el widget se abre Alya directamente en esa app. El texto se guarda en `app.json`
y sobrevive al reinicio; si nunca se llama, se muestra la descripción de la app o
«Toca para abrir».

> Un widget de Android no puede contener un WebView. Esto es su tarjeta, no la app dentro
> de la pantalla de inicio: la app se abre al tocarla.

## Nombre, icono y borrado

**Pulsación larga sobre cualquier app del Hub** abre su ficha:

- **Nombre** — el que se ve en la rejilla y en el widget.
- **Icono** — un emoji de la lista, o una **imagen de tu galería** (se recorta cuadrada y se
  guarda a 256 px dentro de la carpeta de la app, así viaja con ella).
- **🩺 Comprobar** — diagnóstico: si falta el `index.html`, si está vacío o si no parece
  HTML. Si encuentra otro `.html` en la carpeta, lo renombra y la app vuelve a cargar.
- **🗑️ Borrar** — pide confirmación y elimina la carpeta entera.

## Permisos reales

La web **no pide permisos propios**: usa los que ya tiene Alya Agent.

- **Cámara y micrófono:** `getUserMedia` funciona si Alya tiene CÁMARA / MICRÓFONO.
  El WebView concede solo esos dos recursos; lo demás se deniega.
- **Archivos:** `input type="file"` abre el selector de Android y devuelve la URI.
- **Notificaciones:** necesitan el permiso de notificaciones de Alya (Android 13+).
- **Almacenamiento:** todo `/ sdcard` que Alya ya puede tocar.
- **Shell:** lo que la terminal de Alya pueda hacer, sin límites añadidos.

---

## Estilo (para que no desentone)

```css
:root{
  --fondo:#171326; --tarjeta:#211b35; --tarjeta2:#2a2342;
  --acento:#bd93f9; --acento2:#ff79c6; --texto:#f4f1ff; --tenue:#a79fc4;
}
body{
  background:radial-gradient(120% 80% at 50% 0%, #241c3d 0%, var(--fondo) 55%);
  color:var(--texto); font-family:-apple-system,"Segoe UI",Roboto,system-ui,sans-serif;
  padding:16px 14px 28px; max-width:560px; margin:0 auto;
}
```

Botones grandes, `viewport` con `width=device-width`, sin scroll horizontal, sin CDN ni
fuentes externas (no hay red garantizada y el WebView carga desde archivo).

---

## Publicar una app en la tienda

1. Sube la carpeta a `alyahub/apps/<id>/index.html` (o un `.zip` con `index.html` dentro).
2. Añade su ficha a `alyahub/catalogo.json`:

```json
{
  "id": "calendario",
  "nombre": "Calendario",
  "descripcion": "Agenda mensual con eventos por día.",
  "categoria": "Utilidades",
  "tipo": "webapp",
  "emoji": "📅",
  "version": "1.0",
  "autor": "Alya",
  "archivo": "alyahub/apps/calendario/index.html",
  "permisos": ["almacenamiento", "notificaciones"],
  "color": "0xFFBD93F9"
}
```

3. En la app: **Alya Store → Añadir**. Aparece en Mis apps al instante.

**Sin compilar nada.**

---

## Crear una app desde el IDE (la forma recomendada)

**Alya Hub → Crear** ya no abre el chat: abre el **Alya IDE en modo app**, con el encargo
escrito para el asistente del IDE (que es quien sabe de código y tiene editor, vista previa
y consola). El flujo es:

1. El IDE arranca en lenguaje `html`, con el encargo puesto y el asistente abierto.
2. El asistente escribe la app (un solo archivo, sin CDN, con `window.Alya`).
3. La revisas y la ejecutas en la pestaña **Web Live**.
4. **🧩 A la tienda** (o menú de herramientas → *Instalar editor como app del Hub*): pones
   nombre y emoji, y la app aparece en **Mis apps**.

Desde el chat también existe la herramienta `crear_app`, con el mismo resultado: escribe el
archivo de verdad en `/sdcard/AlyaHub/apps/`.

> Regla que nos costó aprender: antes Alya contestaba con un manifiesto JSON y un HTML a
> medias en el chat y no guardaba nada. Si no aparece en Mis apps, no se hizo.

## Si una app se ve en blanco

La ventana ahora **dice qué falló** (código de error, descripción y la ruta del archivo) y
ofrece **Reintentar** y **🩺 Comprobar**. Las causas típicas:

| Síntoma | Causa | Arreglo |
|---|---|---|
| Todo negro, sin mensaje | `index.html` vacío o a medias | Volver a generarla en el IDE |
| `net::ERR_FILE_NOT_FOUND` | Falta el archivo o el nombre está mal | 🩺 Comprobar renombra otro `.html` si existe |
| Carga pero no hay datos | `fetch("datos.json")` bloqueado | Ya está permitido por el puente; usar `Alya.leer` |
| Se ve texto suelto | Se guardó un JSON con la página dentro | Regenerar: el HTML debe empezar por `<!DOCTYPE html>` |

---

*Última revisión: 28-10-2026 · Alya Agent 3.0.0*
