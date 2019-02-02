#!/bin/bash
function showhelp()
{
    echo "Ayuda del programa"
    echo "-user     Nombre de usuario para conexion a mysql"
    echo "-pwd      Clave de usuario para conexion a mysql"
    echo "-folder   Directorio donde se colocaran los .sql"
    echo "-decrypt  Especifica si la clave esta encriptada y la decodigica"
    echo ""
    echo "Ejemplo"
    echo "./mysql_bacukup.sh -user root -pwd xYmnZjkk12&& -folder '/home/admin/db_backups'"
    exit 0
}

# Mientras el número de argumentos NO SEA 0
while [ $# -ne 0 ]
do
    case "$1" in
    -h|--help)
        # No hacemos nada más, porque showhelp se saldrá del programa
        showhelp
        ;;
    -u|-user)
        USERNAME="$2"
        shift
        ;;
    -p|-pwd)
        PWD="$2"
        shift
        ;;
    -f|-folder)
        FOLDER="$2"
        shift
        ;;
    -d|-decrypt)
        DECRYPT=1
        shift
        ;;
    *)
        echo "Especifique los argumentos"
        showhelp
        ;;
    esac
    shift
done

if [ -z "$USERNAME" ]
then
    echo "El nombre de usuario es OBLIGATORIO"
    exit 0
fi

if [ -z "$PWD" ]
then
    PWD=``
fi

if [ -z "$FOLDER" ]
then
    FOLDER='dumps'
fi

if [ -z "$DECRYPT" ]
then
    DECRYPT=0
fi

if [ ! $DECRYPT -ne 1 ]
then
    PWD=`python decode.py $PWD`
fi

args="-u"$USERNAME" -p"$PWD" --add-drop-database --add-locks --create-options --complete-insert --comments --disable-keys --dump-date --extended-insert --quick --routines --triggers"

# En esta linea puede personalizar la consulta SHOW DATABASES
# por una consulta cuyo resultado sea semejante a.
# +--------------------+
# | Database           |
# +--------------------+
# | admin_sistema      |
# | alguna_base        |
# +--------------------+
# en el comando grep - Ev los valores especificados entre ()
# son aquellos que se excluiran para generar la copia.

mysql -u$USERNAME -p$PWD -e 'SHOW DATABASES' | grep -Ev "(Database|information_schema|mysql|performance_schema|sys)" > databases.list

#echo "Se volcarán las siguientes bases de datos:"
#mysql -u$USERNAME -p$PWD -e 'SELECT table_schema "DATABASE",convert(sum(data_length+index_length)/1048576, decimal(6,2)) "SIZE (MB)" FROM information_schema.tables WHERE table_schema!="information_schema" AND table_schema!="performance_schema" AND table_schema!="sys" AND table_schema!="mysql" GROUP BY table_schema;'
#CONT=1
#while [ $CONT -eq 1 ]
#do
#        echo -n "¿Desea continuar? (S/N): "
#        read -n 1 K
#        [[ "$K" == "N" || "$K" == "n" ]] && { echo ""; exit 0; }
#        [[ "$K" == "S" || "$K" == "s" ]] && { CONT=0; }
#        echo ""
#done

while read DB
do
        fecha=`date '+%Y_%m_%d_%H_%M'`
        dump=$DB"_"$fecha".sql"
        if [ ! -d "$FOLDER/$DB" ]; then mkdir -p $FOLDER/$DB; fi
        echo -e -n $dump"...\n"
        mysqldump ${args} $DB | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*PROCEDURE/PROCEDURE/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*FUNCTION/FUNCTION/' > $FOLDER/$DB/$dump 2>1
        echo "OK."
        find $FOLDER/$DB/* -mtime +7 -exec rm {} \;
done < databases.list

rm databases.list
