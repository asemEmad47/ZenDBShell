#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Select From Table" --column="Tables" $(ls) --text="Choose a table to select from:")

if [ -z "$TableName" ]; then
    exit 1
fi

TableFile="$HOME/.DataBases/$DBName/$TableName"

Choice=$(zenity --list \
    --title="Select Options" \
    --column="Option" \
    "Select All" \
    "Select by Primary Key")

if [ -z "$Choice" ]; then
    exit 1
fi

if [ "$Choice" == "Select All" ]; then
    zenity --text-info --title="Table: $TableName" --filename="$TableFile" --width=600 --height=400

elif [ "$Choice" == "Select by Primary Key" ]; then
    PK=$(zenity --entry --title="Search" --text="Enter Primary Key value:")
    
    if [ -z "$PK" ]; then
        exit 1
    fi

    Result=$(grep "^$PK," "$TableFile")

    if [ -z "$Result" ]; then
        zenity --error --text="Record not found!"
    else
        echo "$Result" | zenity --text-info --title="Record Found" --width=500 --height=200
    fi
fi
