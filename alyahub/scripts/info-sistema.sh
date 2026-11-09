#!/bin/sh
# info-sistema · v1.0 · Alya
# Muestra el estado del teléfono: memoria, temperatura, batería y almacenamiento.

echo "Alya · estado del teléfono"
echo "----------------------------------------"

MODELO=$(getprop ro.product.model 2>/dev/null || echo "Android")
ANDROID=$(getprop ro.build.version.release 2>/dev/null || echo "?")
echo "[equipo]   $MODELO (Android $ANDROID)"
echo "[kernel]   $(uname -r 2>/dev/null || echo '?')"

if [ -r /proc/meminfo ]; then
    TOTAL=$(awk '/MemTotal/ {printf "%.1f", $2/1048576}' /proc/meminfo)
    LIBRE=$(awk '/MemAvailable/ {printf "%.1f", $2/1048576}' /proc/meminfo)
    echo "[memoria]  $LIBRE GB libres de $TOTAL GB"
fi

if [ -r /sys/class/thermal/thermal_zone0/temp ]; then
    T=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [ -n "$T" ]; then echo "[temp]     $((T / 1000)) C"; fi
fi

if [ -r /sys/class/power_supply/battery/capacity ]; then
    echo "[bateria]  $(cat /sys/class/power_supply/battery/capacity 2>/dev/null)%"
fi

echo "[disco]"
df -h /sdcard 2>/dev/null | tail -n +2 | awk '{print "   "$4" libres de "$2" ("$5" usado)"}'

echo "----------------------------------------"
echo "Listo."
