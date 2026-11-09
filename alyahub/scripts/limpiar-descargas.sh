#!/bin/sh
# limpiar-descargas · v1.0 · Alya
# Borra APK y temporales viejos de Download. No toca fotos ni música.
# Uso: limpiar-descargas [dias]   (por defecto 30)

DESTINO="/sdcard/Download"
DIAS="${1:-30}"
echo "Limpiando $DESTINO (archivos de mas de $DIAS dias)"

ANTES=$(df -k /sdcard 2>/dev/null | awk 'NR==2 {print $4}')

find "$DESTINO" -type f \( -name "*.apk" -o -name "*.part" -o -name "*.downloading" -o -name "*.tmp" \) \
    -mtime +"$DIAS" -print 2>/dev/null | while read -r F; do
    printf '   borrado: %s\n' "$F"
    rm -f "$F"
done

find "$DESTINO/AlyaDownloads" -type f -name "*.tmp_*" -mtime +7 -delete 2>/dev/null

DESPUES=$(df -k /sdcard 2>/dev/null | awk 'NR==2 {print $4}')
LIBERADO=$(( (DESPUES - ANTES) / 1024 ))
[ "$LIBERADO" -lt 0 ] && LIBERADO=0
echo "Listo. Liberados ${LIBERADO} MB."
