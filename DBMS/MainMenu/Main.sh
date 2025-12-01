#!/usr/bin/bash

DBDirPath="$HOME/.DataBases"
if [ ! -d "$DBDirPath" ]; then
  mkdir -p "$DBDirPath"
fi

while true
do
    mainMenuChoice=$(zenity --list \
        --title="Main Menu" \
        --radiolist \
        --width=600 --height=400 \
        --column="Select" --column="Menu option" \
        TRUE "Create Database" \
        FALSE "List Databases" \
        FALSE "Connect To Databases" \
        FALSE "Drop Database")

    if [ $? -ne 0 ]; then
        break
    elif [ "$mainMenuChoice" == "Create Database" ]; then
        ./CreateDb.sh
    elif [ "$mainMenuChoice" == "List Databases" ]; then
        ./ListDbs.sh
    elif [ "$mainMenuChoice" == "Connect To Databases" ]; then
        source ./ConnectDb.sh
    elif [ "$mainMenuChoice" == "Drop Database" ]; then
        ./DropDb.sh
    fi

    echo "$mainMenuChoice"
done

