#!/bin/bash

# Ruta del csv
ENTRADA="ASUL_25-1_Datos_debian.csv"
SALIDA="laboratorio_datos_limpios.csv"

# verificamos si csvkit esta instalado
if ! command -v csvformat &> /dev/null; then
    echo "Instalar csvkit para usar este script con sudo apt instal csvkit"
    exit 1
fi

# pasar a un formato CSV bien definido
csvformat -U "$ENTRADA" > tmp.csv

# Procesamiento linea por linea
{
    read encabezado
    echo "Nombre,IPv4,IPv6,Usuarios,Lllaves SSH"

    while IFS=',' read -r nombre ipv4 ipv6 usuarios llaves_ssh resto; do
	# limpiamos usuarios
	usuarios_limpios=$(echo "$usuarios" | sed -E 's/[0-9]+\.\s*//g' | tr '\n' ',' | sed 's/,,*/,/g' | sed 's/^,//;s/,$//')
	# limpiamos los campos IPv6
	ipv6_limpio=$(echo "$ipv6" | awk -F "::" '{ if (NF>2) print $1 "::" $2 $3; else print $0}')
	echo "\"$nombre\",\"$ipv4\",\"$ipv6_limpio\",\"$usuarios_limpios\",\"$llaves_ssh\""
} < tmp.csv > "$SALIDA"

rm tmp.csv

echo "Archivo limpio: $SALIDA"
