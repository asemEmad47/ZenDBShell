#!/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName"
TableName=$(zenity --list --title="Select From Table" --column="Tables" $(ls) --text="Choose a table:")

if [ -z "$TableName" ]; then exit 1; fi

TableFile="$HOME/.DataBases/$DBName/$TableName"
MetaFile="$HOME/.DataBases/$DBName/.$TableName-meta"
while true
do
Choice=$(zenity --list --title="Select Options" --column="Option" "Select All" "Select by Primary Key" "Filter by Column")

if [ -z "$Choice" ]; then exit 1; fi

if [ "$Choice" == "Select All" ]; then
    column -t -s ',' "$TableFile" | zenity --text-info --title="Table: $TableName" --width=600 --height=400

elif [ "$Choice" == "Select by Primary Key" ]; then
    PK=$(zenity --entry --title="Search" --text="Enter Primary Key value:")
    if [ -z "$PK" ]; then exit 1; fi
    
    Result=$(grep "^$PK," "$TableFile")
    
    if [ -z "$Result" ]; then
        zenity --error --text="Record not found!"
    else
        echo "$Result" | column -t -s ',' | zenity --text-info --title="Result" --width=600 --height=200
    fi

elif [ "$Choice" == "Filter by Column" ]; then
    
    ColNames=$(cut -d: -f1 "$MetaFile")
    SelectedCol=$(zenity --list --title="Select Column" --column="Columns" $ColNames --text="Filter by which column?")
    
    if [ -z "$SelectedCol" ]; then exit 1; fi

    FieldNum=1
    ColType=""
    while read line
    do
        currName=$(echo $line | cut -d: -f1)
        if [ "$currName" == "$SelectedCol" ]; then
            ColType=$(echo $line | cut -d: -f2)
            break
        fi
        ((FieldNum++))
    done < "$MetaFile"

    if [ "$ColType" == "Integer" ] || [ "$ColType" == "Float" ]; then
        Operator=$(zenity --list --title="Select Operator" --column="Op" --column="Description" "==" "Equals" "!=" "Not Equals" ">" "Greater Than" "<" "Less Than" ">=" "Greater or Equal" "<=" "Less or Equal")
            
        if [ -z "$Operator" ]; then exit 1; fi
        
        Value=$(zenity --entry --title="Filter Value" --text="Enter the number to compare:")
        
        if [ -z "$Value" ]; then exit 1; fi
        
        awk -F, "\$$FieldNum $Operator $Value {print \$0}" "$TableFile" > .search_res

    else
        Pattern=$(zenity --entry --title="String Filter" --text="Enter Regex Pattern: ")
        
        if [ -z "$Pattern" ]; then exit 1; fi
        
        awk -F, "\$$FieldNum ~ /$Pattern/ {print \$0}" "$TableFile" > .search_res
    fi

    if [ -s .search_res ]; then
        column -t -s ',' .search_res | zenity --text-info --title="Filter Results" --width=600 --height=400
    else
        zenity --info --text="No records found matching criteria."
    fi
    rm -f .search_res
fi
done
