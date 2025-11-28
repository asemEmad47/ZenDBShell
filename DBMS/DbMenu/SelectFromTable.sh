#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Select From Table" --column="Tables" $(ls) --text="Choose a table:")

if [ -z "$TableName" ]; then exit 1; fi

TableFile="$HOME/.DataBases/$DBName/$TableName"
MetaFile="$HOME/.DataBases/$DBName/.$TableName-meta"
FilterScriptPath="$HOME/DBMS/DbMenu/FilterCols.sh"
while true
do
Choice=$(zenity --list --title="Select Options" --column="Option" "Select All" "Select columns" )

if [ -z "$Choice" ]; then exit 1; fi

if [ "$Choice" == "Select All" ]; then

    "$FilterScriptPath" "$MetaFile" "$TableFile"
    if [ $? -eq 0 ]; then
        column -t .search_res | zenity --text-info --title="Filtered Table: $TableName" --width=600 --height=400
    else
        column -t "$TableFile" | zenity --text-info --title="Table: $TableName" --width=600 --height=400
    fi

elif [ "$Choice" == "Select columns" ]; then

    ColNames=$(cut -d: -f1 "$MetaFile")

    SelectedCols=$(zenity --list \
	--title="Select Columns" \
	--text="Which column(s) do you want to display?" \
	--column="Columns" $ColNames \
	--multiple --separator="\n")

    if [ -z "$SelectedCols" ]; then
        exit 1
    fi

    "$FilterScriptPath" "$MetaFile" "$TableFile"
    
    if [ $? -eq 0 ]; then
        InputFile=".search_res"
    else
	InputFile="$TableFile"
    fi

    Fields=""
    while read -r col; do
	FieldNum=1
	while read line; do
		ColName=$(echo "$line" | cut -d: -f1)
		if [ "$ColName" == "$col" ]; then
			break
		fi
		((FieldNum++))
	done < "$MetaFile"
	Fields="$Fields$FieldNum,"
    done <<< "$SelectedCols"

    Fields=${Fields::-1}

    cut -d, -f$Fields "$InputFile" | column -t | zenity --text-info --title="Selected Columns" --width=600 --height=400

fi
done
rm -f .search_res
