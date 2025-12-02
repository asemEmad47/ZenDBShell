#!/usr/bin/bash

MetaFile="$1"
TableFile="$2"

Choice=$(zenity --list --radiolist --title="Action Choice" \
    --text="Do you want to apply filters to this table?" \
    --column="Select" --column="Option" \
    TRUE "Yes, apply filter(s)" \
    FALSE "No, exit")

if [ "$Choice" != "Yes, apply filter(s)" ]; then
    exit 1
fi

ColNames=$(cut -d: -f1 "$MetaFile")

SelectedCols=$(zenity --list \
  --title="Select Column(s)" \
  --text="Filter by which column(s)?" \
  --column="Columns" $ColNames \
  --multiple --separator="\n")

if [ -z "$SelectedCols" ]; then
    exit 1
fi

AwkFilters=""

while read -r col; do
    FieldNum=1
    while read line; do
        currName=$(echo "$line" | cut -d: -f1)
        if [ "$currName" = "$col" ]; then
            ColType=$(echo "$line" | cut -d: -f2)
            break
        fi
        ((FieldNum++))
    done < "$MetaFile"

    if [[ "$ColType" == "Integer" || "$ColType" == "Float" ]]; then
        Operator=$(zenity --list --radiolist --title="Operator for column $col" \
                        --column="Pick" --column="Op" \
                        TRUE "==" FALSE "!=" FALSE ">" FALSE "<" FALSE ">=" FALSE "<=")
        Value=$(zenity --entry --title="Value" --text="Enter number:")
        AwkFilters="$AwkFilters \$$FieldNum $Operator $Value &&"
    else
        Pattern=$(zenity --entry --title="Text Filter" --text="Enter regex:")
        AwkFilters="$AwkFilters \$$FieldNum ~ /$Pattern/ &&"
    fi

done <<< "$SelectedCols"

AwkFilters=${AwkFilters::-3}
AwkFilters="($AwkFilters) && NF {print \$0}"

awk -F, "$AwkFilters" "$TableFile" > .search_res

if [ -s .search_res ]; then
    exit 0
else
    exit 1
fi

