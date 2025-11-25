#!/usr/bin/bash

DbName="$1"

while [ -z "$DbName" ]; do
    DbName=$(zenity --entry \
        --title="Connect database" \
	--ok-label="Connect" \
        --text="Please enter database name")

    if [ -z "$DbName" ]; then
        break;
    fi
done

if [ -n "$DbName" ]; then
    DB_PATH="$HOME/.DataBases/$DbName"

    if [ -d "$DB_PATH" ]; then
        cd "$DB_PATH"
        zenity --info \
            --text="You are now successfully connected to the database: $DbName." \
            --width=500
    else
        zenity --warning \
            --text="Database '$DbName' does not exist in $HOME/.DataBases." \
            --width=500
    fi
fi

