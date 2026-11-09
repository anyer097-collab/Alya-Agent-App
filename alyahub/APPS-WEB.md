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
| `Alya.preguntar(texto)` | `{ok}` | Abre el chat de Alya con ese texto |
| `Alya.cerrar()` | `{ok}` | Cierra la app |

También está expuesto como `alya` y `AlyaNativo`, por si algún día hace falta otro nombre.

**Si la app se abre fuera de Alya** (un navegador normal) `window.Alya` no existe:
conviene comprobarlo y caer a `localStorage`, como hace el calendario.

---

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

## Que la cree Alya sola

En el chat: *«créame una app para Alya Hub: un cronómetro con vueltas»*. Alya usa la
herramienta `crear_app` con el HTML completo y la app queda instalada. La plantilla que
se le pasa está en **Alya Hub → Crear**, y el catálogo de funciones del puente está en
el prompt del motor (`assets/prompts/alya_core_v4.txt`), así que siempre sabe qué puede
usar.

> Regla que nos costó aprender: antes Alya contestaba con un manifiesto JSON y un HTML a
> medias en el chat y no guardaba nada. Ahora `crear_app` escribe el archivo de verdad:
> si no aparece en Mis apps, no se hizo.

---

*Última revisión: 28-10-2026 · Alya Agent 3.0.0*
