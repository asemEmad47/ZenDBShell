#! /usr/bin/bash

while [ true ]
do
	DBName=$(zenity --entry --title "Create new database" --text "Please enter database name")

    	if [ $? -ne 0 ]; then
	
		break
	fi

	if [ -d "$HOME/.DataBases/$DBName" ]; then
		zenity --warning --title="Forbiden action" --text="The database $DBName is exist!" --width=200
	else
		mkdir $HOME/.DataBases/$DBName
		zenity --info --text="Database is created successfully" --width=500
	fi
done
