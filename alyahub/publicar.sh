#!/bin/sh
# publicar.sh · Alya
# Sube un APK nuevo al repo público y actualiza alyahub/update.json en un solo paso.
#
# Uso:
#   ./publicar.sh <ruta-del-apk> <canal> <versionName> <versionCode> ["notas"]
#
# Ejemplo:
#   ./publicar.sh app-release.apk 4 2.9.9 86 "Alya Store y actualizaciones dentro de la app"
#
# Requisitos: `gh` autenticado (o GH_TOKEN), curl, sha256sum.
# El canal debe subir de uno en uno (v1 → v2 → … → v9) y es una sola cifra.

set -e

APK="$1"; CANAL="$2"; VERSION="$3"; CODIGO="$4"; NOTAS="${5:-Actualización de Alya Agent}"
REPO="anyer097-collab/Alya-Agent-App"
RAMA="main"

[ -z "$APK" ] || [ -z "$CANAL" ] || [ -z "$VERSION" ] || [ -z "$CODIGO" ] && {
    echo "Uso: ./publicar.sh <apk> <canal> <versionName> <versionCode> [notas]"
    exit 1
}
[ -f "$APK" ] || { echo "No existe el APK: $APK"; exit 1; }
[ "$CANAL" -ge 1 ] && [ "$CANAL" -le 9 ] || { echo "El canal debe ser una cifra del 1 al 9"; exit 1; }

TAMANO=$(wc -c < "$APK" | tr -d ' ')
SHA=$(sha256sum "$APK" | cut -d' ' -f1)
DESTINO="Alya-Agent-v$CANAL.apk"

echo "▶️  Publicando $APK como $DESTINO ($TAMANO bytes)"

# 1. El archivo del canal (histórico)
gh release upload apk-latest "$APK#$DESTINO" --clobber -R "$REPO"

# 2. El enlace permanente que ya tiene guardada la gente
gh release upload apk-latest "$APK#Alya-Agent.apk" --clobber -R "$REPO"

# 3. update.json: lo que lee la app para saber que hay versión nueva
cat > /tmp/update.json <<JSON
{
  "_comentario": "Estado del canal de actualizaciones. La app compara versionCode con el suyo.",
  "canal": $CANAL,
  "versionName": "$VERSION",
  "versionCode": $CODIGO,
  "apk": "https://github.com/$REPO/releases/download/apk-latest/$DESTINO",
  "apk_estable": "https://github.com/$REPO/releases/download/apk-latest/Alya-Agent.apk",
  "tamano": $TAMANO,
  "sha256": "$SHA",
  "fecha": "$(date +%Y-%m-%d)",
  "notas": "$NOTAS"
}
JSON

python3 - "$REPO" "$RAMA" <<'PY'
import sys, json, base64, urllib.request, os
repo, rama = sys.argv[1], sys.argv[2]
token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
if not token:
    sys.exit("Falta GH_TOKEN")
cuerpo = open("/tmp/update.json").read()
url = f"https://api.github.com/repos/{repo}/contents/alyahub/update.json"
pedido = urllib.request.Request(url, headers={
    "Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"})
sha_actual = ""
try:
    with urllib.request.urlopen(pedido) as r:
        sha_actual = json.load(r).get("sha", "")
except Exception:
    pass
datos = {"message": "update.json: nueva versión", "content": base64.b64encode(cuerpo.encode()).decode(), "branch": rama}
if sha_actual:
    datos["sha"] = sha_actual
req = urllib.request.Request(url, method="PUT",
    data=json.dumps(datos).encode(),
    headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"})
with urllib.request.urlopen(req) as r:
    print("✅ update.json actualizado" if r.status in (200, 201) else f"⚠️ {r.status}")
PY

echo "✅ Publicado: canal v$CANAL · $VERSION ($CODIGO) · sha256 $SHA"
echo "   La app lo verá la próxima vez que abra el Hub (o al pulsar «Buscar ahora»)."
