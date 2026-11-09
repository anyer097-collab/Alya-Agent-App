#!/bin/sh
# estado-bateria · v1.0 · Alya
# Batería, temperatura y procesos que más CPU gastan.

echo "Alya · batería"
echo "----------------------------------------"
if [ -r /sys/class/power_supply/battery/capacity ]; then
    echo "Nivel      : $(cat /sys/class/power_supply/battery/capacity)%"
fi
if [ -r /sys/class/power_supply/battery/status ]; then
    echo "Estado     : $(cat /sys/class/power_supply/battery/status)"
fi
if [ -r /sys/class/power_supply/battery/temp ]; then
    echo "Temperatura: $(cat /sys/class/power_supply/battery/temp | awk '{printf "%d C", $1/10}')"
fi
echo "Procesos que más CPU usan:"
top -n 1 -b -o %CPU 2>/dev/null | head -8 | tail -6
