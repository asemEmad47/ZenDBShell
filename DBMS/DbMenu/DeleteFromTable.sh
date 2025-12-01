#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Delete From Table" --column="Tables" $(ls) --text="Select table to delete from:")

if [ -z "$TableName" ]; then
    exit 1
fi

TableFile="$HOME/.DataBases/$DBName/$TableName"
MetaFile="$HOME/.DataBases/$DBName/.$TableName-meta"

FilterScriptPath="$HOME/DBMS/DbMenu/FilterCols.sh"

"$FilterScriptPath" "$MetaFile" "$TableFile"
if [ $? -eq 1 ]; then
    zenity --question --title="Confirm" \
           --text="Are you sure you want to delete all rows?"

    if [ $? -eq 0 ]; then
        
        sed -i '1!d' "$TableFile"

        zenity --info --title="Done" \
               --text="Table $TableName is truncated successfully."

	exit 0

    else
	zenity --info --title="Done" \
             --text="No rows deleted for the Table $TableName"

        exit 0
    fi

fi

Index=0

while read line; do
    ((Index++))
    IsPK=$(echo "$line" | cut -d: -f4)
    if [ "$IsPK" == "PK" ]; then
        break
    fi
done < "$MetaFile"


echo "index is $Index"

awk -F, -v col="$Index" '{print $col}' .search_res | while read -r PK
do
    echo $PK
    awk -F, -v col="$Index" -v pk="$PK" '$col != pk {print $0}' "$TableFile" > "$TableFile.temp"
    mv "$TableFile.temp" "$TableFile"
done

Counter=$(wc -l < .search_res)
((Counter--))
rm -rf .search_res
zenity --info --text="$Counter rows are deleted!"
