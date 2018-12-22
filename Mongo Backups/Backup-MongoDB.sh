#!/bin/bash
function showhelp()
{
    echo "Ayuda del programa"
    echo "-f   Directorio donde se archivara el backup"
    echo "-n   Numero de dias ha mantener 30 por defecto"
    echo ""
    echo "Ejemplo"
    echo "./Backup-MongoDB.sh -f '/home/admin/db_backups'"
    exit 0
}

while [ $# -ne 0 ]
do
    case "$1" in
    -h|--help)
        # No hacemos nada más, porque showhelp se saldrá del programa
        showhelp
        ;;
    -f|-folder)
        FOLDER="$2"
        shift
        ;;
    -n|-numero)
        NUMERO=$2
        shift
        ;;
    *)
        echo "Especifique los argumentos"
        showhelp
        ;;
    esac
    shift
done

if [ $NUMERO ]
then
    echo "Limpiando backups de $NUMERO dias anteriores"
    find $FOLDER/$fecha/* -type d -mtime +$NUMERO -exec rm {} -rf \; > /dev/null 2>&1
    echo
fi


fecha=`date '+%Y_%m_%d_%H_%M'`

if [ ! -d "$FOLDER/$fecha" ]; then mkdir -p $FOLDER/$fecha; fi

printf "Generando Backup \t"
mongodump -o "$FOLDER/$fecha" > /dev/null 2>&1
echo "[-OK-]"

find $FOLDER/$fecha -type d > databases.list

echo "=======Comprimiendo Backups======="
while read DB
do
        if [ $DB != "$FOLDER/$fecha" ]
        then
            printf "$DB   \t"
            gzip -9 $DB/*.*
            printf "[-OK-]"
            echo ""
        fi
done < databases.list
rm databases.list

echo "Backup generado en $FOLDER/$fecha"