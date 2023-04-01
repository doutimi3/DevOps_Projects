#! /bin/bash

# ECHO COMMAND
echo hello world!

# VARIABLES
# BY CONVENTION, VARIABLES SHOULD BE IN UPPER CASE
# IT ALLOWS LETTER, NUMBERS AND UNDERSCORES.
NAME="Jack"
# echo "My name is ${NAME}"

#USER INPUT
read -p "Enter your Name: " NAME
echo "Hello $NAME, Nice to meet you!"

# CONDITIONAL STATEMENTS
IF STATEMENT
if [ "$NAME" == "Maxwell" ]
then
   echo "Your name is Maxwell"
   echo "Your name is ${NAME}"
fi

# # IF-ELSE
if [ "$NAME" == "Maxwell" ]
then
   echo "Your name is Maxwell"
else
    echo "Your name is not Maxwell, Your name is ${NAME}"
fi

# # ELSE-IF (ELIF)
if [ "$NAME" == "Maxwell" ]
then
   echo "Your name is Maxwell"
elif [ "$NAME" = "Jack" ]
then
    echo "Your name is Jack"
else
    echo "Your name is not Maxwell or Jack"
fi

# COMPARISM OPERATIONS

################
# VAL1 -eq val2 Returns true if the values are equal
# val1 -ne val2 Returns true if the values are not equal
# val1 -gt val2 Return true if val1 is greater than val2
# val1 -ge val2 Return true is val1 is greater than or equal to val2
# val1 -lt val2 Return True is val1 is less than val2
# val1 -le val2 Return true if val1 is less than or equal to val2
####################

NUM1=31
NUM2=5

if [ "$NUM1" -gt "$NUM2" ]
then
    echo "$NUM1 is greater than $NUM2"
else
    echo "$NUM1 is less than $NUM2"
fi

# FILE CONDITIONS

#################
# -d filename   True if the file is a directory
# -e filename    True if the file exists (Note that this is not particularly portable, thus -f is generally used)
# -f filename    True if the provided string is a file
# -g filename    True if the group ID is set on a file
# -r filename    True if the file is readable
#################

# FILE="test.txt"
if [ -f "$FILE" ]
then 
    echo "$FILE is a file"
else
    echo "$FILE is not a file"
fi

#####################################################
# # CASE STATEMENTS
read -p "Are you 21 or over? Y/N " ANSWER
case "$ANSWER" in 
    [yY] | [yY][eE][sS])
        echo "You can have a beer :)"
        ;;
    [nN] | [nN][oO])
        echo "Sorry, no drinking"
        ;;
    *)
        echo "Please enter y/yes or n/no"
        ;;
esac


##############  LOOPS  ###################
# SIMPLE FOR LOOP
NAMES="Brad Kevin Alice Mark"
for NAME in $NAMES
    do 
        echo "Hello $NAME"
done

# # For loop to rename files
FILES=$(ls *.txt)

for FILE in $FILES
    do 
        echo "Renaming $FILE to new-$FILE"
        mv $FILE "New-$FILE"
done

# #WHILE LOOP
# Read through a file line by line and print out each line with the line number
LINE=1
while read -r CURRENT_LINE
    do
        echo "$LINE: $CURRENT_LINE"
        #Increment the variable LINE by 1
        ((LINE++))
done < "./New-1.txt"


######### FUNCTIONS ################
function sayHello() {
    echo "Hello World"
}

sayHello

# # Function with Parameters
function greet() {
    echo "Hello, I am $1 and I am $2 years old"
}
# Call function and pass in parameters
greet "Maxwell" "29"


# Create folder and write to a file
mkdir -p testfolder/hello
touch "testfolder/hello/world.txt"
echo "Hello Word" >> "testfolder/hello/world.txt"
echo "Created testfolder/hello/world.txt"





