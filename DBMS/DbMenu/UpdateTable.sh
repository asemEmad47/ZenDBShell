#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Update Table" --column="Tables" $(ls) --text="Select table to update:")

if [ -z "$TableName" ]; then
    exit 1
fi

TableFile="$HOME/.DataBases/$DBName/$TableName"
MetaFile="$HOME/.DataBases/$DBName/.$TableName-meta"
FilterScriptPath="$HOME/DBMS/DbMenu/FilterCols.sh"

"$FilterScriptPath" "$MetaFile" "$TableFile"
if [ $? -eq 1 ]; then
    zenity --question --title="Confirm" \
           --text="Are you sure you want to update ALL rows?"

    if [ $? -eq 0 ]; then
        cp "$TableFile" .search_res
    else
        exit 0
    fi
fi

if [ ! -s .search_res ]; then
    zenity --info --text="No rows matched your filter."
    rm -f .search_res
    exit 0
fi

ColNames=$(cut -d: -f1 "$MetaFile")
ColsToEdit=$(zenity --list \
    --title="Select Columns" \
    --text="Which column(s) do you want to update?" \
    --column="Columns" $ColNames \
    --multiple --separator="\n")

if [ -z "$ColsToEdit" ]; then
    rm -f .search_res
    exit 1
fi
while read ColToEdit
do
    FieldNum=1
    TargetColNum=0
    ColType=""
    IsNullable=""
    IsPKCol=""
    TablePKIndex=0

    while read line
    do
        CurrColName=$(echo $line | cut -d: -f1)
        CurrIsPK=$(echo $line | cut -d: -f4)

        if [ "$CurrIsPK" == "PK" ]; then
            TablePKIndex=$FieldNum
        fi

        if [ "$CurrColName" == "$ColToEdit" ]; then
            TargetColNum=$FieldNum
            ColType=$(echo $line | cut -d: -f2)
            IsNullable=$(echo $line | cut -d: -f3)
            IsPKCol=$(echo $line | cut -d: -f4)
        fi
        ((FieldNum++))
    done < "$MetaFile"

    while true
    do
        NewValue=$(zenity --entry --title="New Value" --text="Enter new value for ($ColToEdit) [$ColType]:")

        if [ $? -ne 0 ]; then
            rm -f .search_res
            exit 0
        fi

        if [ -z "$NewValue" ]; then
            if [ "$IsNullable" == "notNull" ]; then
                zenity --error --text="Invalid Input! ($ColToEdit) is not nullable."
                continue
            fi
            break
        fi

        if [ "$ColType" == "Integer" ]; then
            if ! [[ "$NewValue" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Invalid Input! ($ColToEdit) must be an Integer."
                continue
            fi
        fi

        if [ "$IsPKCol" == "PK" ]; then
            if grep -q "^$NewValue," "$TableFile"; then
                zenity --error --text="Primary Key Constraint Violated! Value '$NewValue' already exists."
                continue
            fi
        fi

        break
    done

    awk -F, -v col="$TablePKIndex" '{print $col}' .search_res | while read -r RowPK
    do
        awk -F, -v pkIdx="$TablePKIndex" -v targetIdx="$TargetColNum" -v searchPK="$RowPK" -v newVal="$NewValue" '
        BEGIN {OFS=","}
        {
            if ($pkIdx == searchPK) {
                $targetIdx = newVal
            }
            print
        }
        ' "$TableFile" > "$TableFile.tmp"

        mv "$TableFile.tmp" "$TableFile"
    done

done <<< "$ColsToEdit"

Counter=$(wc -l < .search_res)
rm -f .search_res

zenity --info --text="$Counter rows updated successfully!"

