#! /usr/bin/bash


cd "$HOME/.DataBases/"
DBs=$(ls -d *)



DB=$(zenity --list \
--title="DataBases" \
--width=500 --height=500 \
--column="DataBases" \
--text="Please select a database to connect:" \
--ok-label="Connect" \
$DBs)

if [ $? -ne 0 ]; then
    break

else
    source "$HOME/DBMS/MainMenu/ConnectDb.sh" "$DB"
fi



