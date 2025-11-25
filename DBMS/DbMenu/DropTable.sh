#!/usr/bin/bash

DBName="$1"

while true
do
    TableName=$(zenity --entry --title "Drop Table" --text "Enter table name")
    zenity_status=$?

    if [ $zenity_status -ne 0 ]; then
        break
    fi

    if [ -f "$HOME/.DataBases/$DBName/$TableName" ]; then
        rm -f "$HOME/.DataBases/$DBName/$TableName"
        rm -f "$HOME/.DataBases/$DBName/.$TableName-meta"
        zenity --info --text="Table dropped successfully!" --width=500
    else
        zenity --warning --title="Warning" --text="The table $TableName does not exist!" --width=300
    fi
done

