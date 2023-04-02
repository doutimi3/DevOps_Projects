#! /usr/bin/bash

my_input="/home/vagrant/users.csv"
declare -a fname
declare -a lname
declare -a user
declare -a dept
declare -a passwd
declare -a pubkey

CurrentUser=$(id -u -n)

# Read the first line and save it as the header
read -r header < "$my_input"

# Process the remaining lines of the file using the header
while IFS=, read -r FirstName LastName UserName Department Password PublicKey _
do
    fname+=("$FirstName")
    lname+=("$LastName")
    user+=("$UserName")
    dept+=("$Department")
    passwd+=("$Password")
    pubkey+=("$(echo $PublicKey | cut -d',' -f6)")
done < <(tail -n +2 "$my_input")

for index in "${!user[@]}";
do
    # Check if group exists, if not create it
    if ! getent group "${dept[$index]}" >/dev/null; then
        sudo groupadd "${dept[$index]}"
    fi

    # Check if user already exists
    if id "${user[$index]}" >/dev/null 2>&1; then
        echo "User ${user[$index]} already exists"
    else
        # Create user with default home folder
        if sudo useradd -d "/home/${user[$index]}" \
                        -m \
                        -s "/bin/bash" \
                        -c "$fname" "$lname"
                        -p "$(echo "${passwd[$index]}" | openssl passwd -1 -stdin)" \
                        "${user[$index]}" && \
                        sudo usermod -aG "${dept[$index]}" "${user[$index]}"; then
            echo "User ${user[$index]} created"
            

            # Create .ssh folder if it does not exist
            if [ ! -d "/home/${user[$index]}/.ssh" ]; then
                sudo mkdir -p "/home/${user[$index]}/.ssh"
                sudo chown "${user[$index]}:${dept[$index]}" "/home/${user[$index]}/.ssh"
                sudo chmod 700 "/home/${user[$index]}/.ssh"
            fi

            # Create authorized_keys file if it does not exist and add the public key
            if [ ! -f "/home/${user[$index]}/.ssh/authorized_keys" ]; then
                sudo cp -r "/home/$CurrentUser/.ssh/authorized_keys" "/home/${user[$index]}/.ssh/"
                sudo chmod 600 "/home/${user[$index]}/.ssh/authorized_keys"
                sudo chown "${user[$index]}:${dept[$index]}" "/home/${user[$index]}/.ssh/authorized_keys"
            fi

        else
            echo "Failed to create user ${user[$index]}"
        fi
    fi
done
