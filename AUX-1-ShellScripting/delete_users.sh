#! /usr/bin/bash

my_input="/home/vagrant/users.csv"
declare -a fname
declare -a lname
declare -a user
declare -a dept
declare -a passwd

# Read the first line and save it as the header
read -r header < "$my_input"

# Process the remaining lines of the file using the header
while IFS=, read -r FirstName LastName UserName Department Password PublicKey;
do
    fname+=("$FirstName")
    lname+=("$LastName")
    user+=("$UserName")
    dept+=("$Department")
    passw+=("$Password")

done < <(tail -n +2 "$my_input")

for index in "${!user[@]}";
do
    # Check if user already exists, if yes delete user
    if id "${user[$index]}" >/dev/null 2>&1; then
        echo "User ${user[$index]} already exists so it will be deleted"
        sudo userdel -r "${user[$index]}"
    else
        echo "User does not exist"
    fi

    # Check if group exists, if yes delete it
    if getent group "${dept[$index]}" >/dev/null; then
        sudo groupdel "${dept[$index]}"
    fi
done