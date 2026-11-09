#!/bin/sh
# ordenar-fotos · v1.0 · Alya
# Mueve las fotos de DCIM a /sdcard/Pictures/Ordenadas/AAAA-MM
# Uso: ordenar-fotos [carpeta de origen]

ORIGEN="${1:-/sdcard/DCIM/Camera}"
DESTINO="/sdcard/Pictures/Ordenadas"
echo "Ordenando fotos de $ORIGEN"

[ -d "$ORIGEN" ] || { echo "No existe $ORIGEN"; exit 1; }

find "$ORIGEN" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \) 2>/dev/null | while read -r F; do
    ANIO=$(date -r "$F" +%Y 2>/dev/null || date +%Y)
    MES=$(date -r "$F" +%m 2>/dev/null || date +%m)
    mkdir -p "$DESTINO/$ANIO-$MES"
    mv -n "$F" "$DESTINO/$ANIO-$MES/" 2>/dev/null && printf '   -> %s-%s/%s\n' "$ANIO" "$MES" "$(basename "$F")"
done

echo "Fotos ordenadas en $DESTINO"
