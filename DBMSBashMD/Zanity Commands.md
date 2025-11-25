### User inputs
- **Create a multi-column dialogue**: 
		mainMenuChoice=$(zenity --list \
		  --title="Main Menu" \
		  --width=600 --height=400 \
		  --radiolist \
		  --column="Select" --column="ID" --column="Menu option" \
		  TRUE 1 "Create Database" \
		  FALSE 2 "List Databases" \
		  FALSE 3 "Connect To Databases" \
		  FALSE 4 "Drop Database")
	 Now user you have user choice at mainMenuChoice variable![[Pasted image 20251123234017.png]]

- Take input from user: 
	DBName=$(zenity --entry --title "Create new database" --text "Please enter database name")
     ![[Pasted image 20251123234207.png]] 
     


