#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Update Table" --column="Tables" $(ls) --text="Select table to update:")

if [ -z "$TableName" ]; then exit 1; fi

TableFile="$HOME/.DataBases/$DBName/$TableName"
MetaFile="$HOME/.DataBases/$DBName/.$TableName-meta"

PK=$(zenity --entry --title="Update Record" --text="Enter Primary Key of record to update:")

if [ -z "$PK" ]; then exit 1; fi

if ! grep -q "^$PK," "$TableFile"; then
    zenity --error --text="Record not found!"
    exit 1
fi

ColNames=$(cut -d: -f1 "$MetaFile")

ColToEdit=$(zenity --list --title="Select Column" --column="Columns" $ColNames --text="Which column do you want to edit?")

if [ -z "$ColToEdit" ]; then exit 1; fi

FieldNum=1
ColType=""

while read line
do
    CurrColName=$(echo $line | cut -d: -f1)
    if [ "$CurrColName" == "$ColToEdit" ]; then
        ColType=$(echo $line | cut -d: -f2)
        break
    fi
    ((FieldNum++))
done < "$MetaFile"

NewValue=$(zenity --entry --title="New Value" --text="Enter new value for ($ColToEdit) [$ColType]:")

if [ -z "$NewValue" ]; then exit 1; fi

if [ "$ColType" == "Integer" ]; then
    if ! [[ "$NewValue" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Invalid Input! Must be Integer."
        exit 1
    fi
fi

if [ "$FieldNum" -eq 1 ]; then
    if grep -q "^$NewValue," "$TableFile"; then
        zenity --error --text="Primary Key exists! Choose another ID."
        exit 1
    fi
fi


awk -F, -v pk="$PK" -v f="$FieldNum" -v val="$NewValue" '
BEGIN {OFS=","}
{
    if ($1 == pk) {
        $f = val
    }
    print $0
}
' "$TableFile" > "$TableFile.temp"

mv "$TableFile.temp" "$TableFile"
zenity --info --text="Table Updated Successfully!"
