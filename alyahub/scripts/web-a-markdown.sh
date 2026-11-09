#!/bin/sh
# web-a-markdown · v1.0 · Alya
# Guarda una página como Markdown para leerla sin conexión. Uso: web-a-markdown <url>

URL="$1"
[ -z "$URL" ] && { echo "Uso: web-a-markdown <url>"; exit 1; }

CARPETA="/sdcard/AlyaHub/webs"
mkdir -p "$CARPETA"
NOMBRE=$(printf '%s' "$URL" | sed 's#^https\?://##; s#[/?=&]#_#g' | cut -c1-80)
SALIDA="$CARPETA/$NOMBRE.md"

echo "Bajando $URL"
if command -v python3 >/dev/null 2>&1; then
    python3 - "$URL" "$SALIDA" <<'PY'
import sys, re, html, urllib.request
url, salida = sys.argv[1], sys.argv[2]
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Alya)"})
crudo = urllib.request.urlopen(req, timeout=30).read().decode("utf-8", "ignore")
m = re.search(r"<title[^>]*>(.*?)</title>", crudo, re.S)
titulo = html.unescape(m.group(1)).strip() if m else url
cuerpo = re.sub(r"(?is)<(script|style|nav|footer)[^>]*>.*?</\1>", " ", crudo)
texto = html.unescape(re.sub(r"(?s)<[^>]+>", "\n", cuerpo))
lineas = [l.strip() for l in texto.splitlines() if l.strip()]
with open(salida, "w", encoding="utf-8") as f:
    f.write("# " + titulo + "\n\n" + url + "\n\n")
    f.write("\n\n".join(lineas))
PY
else
    curl -sL -A "Mozilla/5.0 (Alya)" "$URL" | sed 's/<[^>]*>//g' > "$SALIDA"
fi

echo "Guardado en $SALIDA"
