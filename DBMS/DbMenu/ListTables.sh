#!/usr/bin/bash

DBName="$1"

cd "$HOME/.DataBases/$DBName/"
Tables=$(ls)

Table=$(zenity --list \
--title="Tables in $DBName" \
--width=500 --height=500 \
--column="Tables" \
--text="Please select a table:" \
--ok-label="Select" \
$Tables)

if [ $? -ne 0 ]; then
    exit 1
else
    echo "$Table"
fi

