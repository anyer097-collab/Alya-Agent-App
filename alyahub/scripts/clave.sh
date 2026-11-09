#!/bin/sh
# clave · v1.0 · Alya
# Genera una contraseña fuerte sin usar internet. Uso: clave [longitud]

LARGO="${1:-20}"
case "$LARGO" in ''|*[!0-9]*) echo "Uso: clave [longitud entre 8 y 128]"; exit 1 ;; esac
[ "$LARGO" -lt 8 ] && LARGO=8
[ "$LARGO" -gt 128 ] && LARGO=128

ALFABETO='ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%&*+-=?'
TOTAL=${#ALFABETO}
CLAVE=""
I=0
while [ "$I" -lt "$LARGO" ]; do
    POS=$(od -An -N2 -tu2 /dev/urandom 2>/dev/null | tr -d ' ')
    [ -z "$POS" ] && POS=$((I * 7919 + 13))
    IDX=$((POS % TOTAL))
    CLAVE="$CLAVE$(printf '%s' "$ALFABETO" | cut -c $((IDX + 1)))"
    I=$((I + 1))
done

echo "Contraseña de $LARGO caracteres:"
echo "   $CLAVE"
echo "Cópiala y guárdala en un lugar seguro."
