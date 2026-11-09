#!/bin/sh
# ordenar-musica · v1.0 · Alya
# Limpia los nombres de las canciones descargadas (quita "Official Video", "Lyrics"...).

CARPETA="/sdcard/Music/AlyaMusic"
[ -d "$CARPETA" ] || { echo "No existe $CARPETA"; exit 1; }

echo "Ordenando $CARPETA"
cd "$CARPETA" || exit 1
for F in *.m4a *.mp3 *.webm *.opus; do
    [ -f "$F" ] || continue
    BASE=$(printf '%s' "$F" | sed 's/\.\(m4a\|mp3\|webm\|opus\)$//')
    NUEVO=$(printf '%s' "$BASE" \
        | sed 's/(Official Video)//Ig; s/\[Official Video\]//Ig; s/(Lyrics)//Ig; s/\[Lyrics\]//Ig' \
        | sed 's/  */ /g; s/^ //; s/ $//')
    EXT="${F##*.}"
    if [ "$NUEVO.$EXT" != "$F" ]; then
        mv -n "$F" "$NUEVO.$EXT" 2>/dev/null && printf '   -> %s.%s\n' "$NUEVO" "$EXT"
    else
        printf '   ok %s\n' "$F"
    fi
done
echo "Listo."
