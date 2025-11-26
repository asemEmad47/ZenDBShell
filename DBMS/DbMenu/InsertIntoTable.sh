#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Insert into Table" --column="Tables" $(ls) --text="Select a table to insert data:")

if [ -z "$TableName" ]; then
    exit 1
fi

TableFile="$HOME/.DataBases/$DBName/$TableName"
MetaFile="$HOME/.DataBases/$DBName/.$TableName-meta"
CheckerPath="$HOME/DBMS/ConstraintsCheckers/NullabilityColumnConstraintChecker"

Row=""
Separator=""

cat "$MetaFile" | while read line
do
    ColName=$(echo $line | cut -d: -f1)
    ColType=$(echo $line | cut -d: -f2)
    IsNullable=$(echo $line | cut -d: -f3)
    IsPK=$(echo $line | cut -d: -f4)

    while true
    do
        Value=$(zenity --entry --title="Insert Data" --text="Enter value for column ($ColName) [$ColType]:")
        
        if [ $? -ne 0 ]; then
	    rm .temp_row
	    exit 0
        fi


        if [ -z "$Value" ]; then
            if [ "$IsNullable" == "notNull" ]; then
                zenity --error --text="Invalid Input! ($ColName) is not nullable."
                continue
            fi

	    break
        fi
        
        if [ "$ColType" == "Integer" ]; then
            if ! [[ "$Value" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Invalid Input! ($ColName) must be an Integer."
                continue 
            fi
        fi

        if [ "$IsPK" == "PK" ]; then
            if grep -q "^$Value," "$TableFile"; then
                zenity --error --text="Primary Key Constraint Violated! Value '$Value' already exists."
                continue
            fi
        fi

        break
    done

    echo -n "$Separator$Value" >> .temp_row
    Separator="," 
    
done

if [ -f .temp_row ]; then
    echo "" >> "$TableFile" 
    cat .temp_row >> "$TableFile"
    rm .temp_row
    zenity --info --text="Row inserted successfully!"
fi
