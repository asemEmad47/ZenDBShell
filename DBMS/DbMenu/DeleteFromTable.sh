#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Delete From Table" --column="Tables" $(ls) --text="Select table to delete from:")

if [ -z "$TableName" ]; then
    exit 1
fi

TableFile="$HOME/.DataBases/$DBName/$TableName"

PK=$(zenity --entry --title="Delete Record" --text="Enter Primary Key of the record to delete:")

if [ -z "$PK" ]; then
    exit 1
fi

if ! grep -q "^$PK," "$TableFile"; then
    zenity --error --text="Record with ID ($PK) not found!"
    exit 1
fi

grep -v "^$PK," "$TableFile" > "$TableFile.temp"

mv "$TableFile.temp" "$TableFile"

zenity --info --text="Record Deleted Successfully!"
