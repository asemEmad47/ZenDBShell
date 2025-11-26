#!/usr/bin/bash



TableName=$(zenity --entry --title "Create Table" --text "Enter table name")


DBName="$1"
IsPKChose=false
DBPath="$HOME/.DataBases/$DBName"
TableFile="$DBPath/$TableName"
MetaFile="$DBPath/.$TableName-meta"
CheckerPath="$HOME/DBMS/ConstraintsCheckers/ColumnExistenceChecker"

while [ -n "$TableName" ] && [ -f "$TableFile" ]; do
    zenity --warning --title="Warning" --text="Table '$TableName' already exists!" --width=400
    TableName=$(zenity --entry --title "Create Table" --text "Enter table name")
    TableFile="$DBPath/$TableName"
done

if [ -z "$TableName" ]; then
    exit 1
fi

cd "$HOME/.DataBases/$DBName"



touch "$TableFile"
touch "$MetaFile"

echo $TableFile
echo $MetaFile
while true
do
    ColName=$(zenity --entry --title "Add New Column" --text "Please enter column name")

    if [ $? -ne 0 ]; then
        if [ -n "$TableName" ] && [ "$IsPKChose" == "true" ]; then
	    sed -i '$ s/.$//' "$TableName"
            zenity --info --title="Success" --text="Your table \"$TableName\" has been created successfully!" --width=400
        elif [ -n "$TableName" ] && [ "$IsPKChose" != "true" ]; then
            zenity --warning --title="Warning" --text="No primary key was chosen. Table will not be created!" --width=400
            rm -f "$TableName" ".$TableName-meta"
        fi
	break
    fi

    if "$CheckerPath" "$MetaFile" "$ColName"; then
        zenity --warning --title="Warning" --text="Column '$ColName' already exists!" --width=400
        continue
    fi

    ColDataType=$(zenity --list \
        --title="Data Types Menu" \
        --radiolist \
        --width=600 --height=400 \
        --column="Select" --column="Data type option" \
        TRUE  "Integer" \
        FALSE "Float" \
        FALSE "String"
    )


    if [ "$IsPKChose" != "true" ]; then
        PK=$(zenity --list \
            --title="Primary Key" \
            --radiolist \
            --width=400 --height=400 \
            --column="Select" --column="Primary Key" \
            TRUE  "Yes" \
            FALSE "No"
        )

        if [ $? -ne 0 ]; then
            if [ -n "$TableName" ] && [ "$IsPKChose" == "true" ]; then
                zenity --info --title="Success" --text="Your table \"$TableName\" has been created successfully!" --width=400
                sed -i '$ s/.$//' "$TableName"
	    elif [ -n "$TableName" ] && [ "$IsPKChose" != "true" ]; then
                zenity --warning --title="Warning" --text="No primary key was chosen. Table will not be created!" --width=400
		rm -f "$TableName" ".$TableName-meta"
            fi
	    break
        fi

        if [ "$PK" == "Yes" ]; then
            IsPKChose=true
            echo "$ColName:$ColDataType:notNull:PK" >> "$MetaFile"
	else
	    echo "$ColName:$ColDataType" >> "$MetaFile"
        fi
	
    else
	Nullability=$(zenity --list \
    	--title="Nullability" \
    	--radiolist \
    	--width=400 --height=300 \
    	--column="Select" --column="Nullability" \
    	TRUE "Allow NULL" \
    	FALSE "NOT NULL"
	)

	if [ "$Nullability" == "NOT NULL" ]; then
    	    echo "$ColName:$ColDataType:notNull" >> "$MetaFile"
	else
            echo "$ColName:$ColDataType:null" >> "$MetaFile"
        fi

    fi

    echo -n "$ColName," >> "$TableFile"
done

