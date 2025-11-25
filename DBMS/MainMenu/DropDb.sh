#! /usr/bin/bash

while [ true ]
do
	DBName=$(zenity --entry --title "Drop Database" --text "Please enter database name")
    	
	if [ $? -ne 0 ]; then
        	break
    	fi


	if [ -d "$HOME/.DataBases/$DBName" ]; then
		rm -rf $HOME/.DataBases/$DBName
		zenity --info --text="Database is dropped successfully!" --width=500
	else
		zenity --warning --title="Warning" --text="The database $DBName is not exist!" --width=200
	fi
done
