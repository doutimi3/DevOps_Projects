# AUX PROJECT 1: SHELL SCRIPTING
In this project, I will be showing a guide on how to do shell scripting in linux by writing a shell script to onboard 20 new Linux users into a server.

I will be using an ubuntu server launched and managed using vagrant on vmware_fusion so I will include some details on how I spinned up this ubuntu server but the scripts in this repo will work in any environment.

__Prerequisites__

TBC


__1. Spin up the ubuntu server using Vagrant__
Create a new directory to contain files for this project, change to this directory, create a file called "Vagrantfile" in the directory and paste the text below into this Vagrantfile.

```SHELL
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true 
  config.hostmanager.manage_host = true
  
### fedora vm  ####
  config.vm.define "fedora" do |fedora|
    fedora.vm.box = "jacobw/fedora35-arm64"
    fedora.vm.hostname = "fedora"
    fedora.vm.network "private_network", ip: "192.168.56.15"  
  end
   
  
### Ubuntu VM ###
  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "spox/ubuntu-arm"
    ubuntu.vm.hostname = "ubuntu"
    ubuntu.vm.network "private_network", ip: "192.168.56.11"
  # ubuntu.vm.provision "shell", path: "nginx.sh"   
end 

end
```

This file above is a basic vagrant file to spin up an ubuntu or fedora linux server for machines using the arm architecture (Apple M1 and M2 Silicon processor). It also specify the ip address of this servers. There are a lot more options to further customize this servers but I will be keeping it basic for this project.

2. Next, spin up an ubuntu server and ssh into this server using the command below:

```SHELL
# Spin up server
vagrant up ubuntu

# Ssh into server
vagrant ssh ubuntu
```


3. Create a folder called "AUX-1-ShellScripting" and change to this folder
```SHELL
mkdir AUX-1-ShellScripting
cd AUX-1-ShellScripting
```
4. Create a csv file named "users.csv", open it and add some random user details, sample of this file is shown below:

```SHELL
touch users.csv
vim users.csv
```
Paste the below text into this file

```
FirstName,LastName,UserName,Department,Password
Jimmy,Paul,jpaul,developers,welcome123
Paul,Smith,psmith,developers,welcome123
Ellie,Samuel,esamuel,developers,welcome123
Chloe,Jessica,cjessica,developers,welcome123
Sophie Megan,smegan,developers,welcome123
Lucy,Olivia,loliver,developers,welcome123
Charlotte,Hannah,channah,developers,welcome123
Katie,Ella,kella,developers,welcome123
Grace,Mia,gmia,developers,welcome123
Amy,Holly,aholly,developers,welcome123
Lauren,Emma,lemma,developers,welcome123
Molly,Abigail,mabigail,developers,welcome123
Jack,Joshua,jjoshua,developers,welcome123
Thomas,James,tjames,developers,welcome123
Daniel,Oliver,doliver,developers,welcome123
Benjamin,Samuel,bsamuel,developers,welcome123
William,Joseph,wjoseph,developers,welcome123
Harry,Matthew,hmatthew,developers,welcome123
Lewis,Luke,lluke,developers,welcome123
Ethan,George,egeorge,developers,welcome123
Adam,Alfie,aalfie,developers,welcome123
Callum,Alexander,calexander,developers,welcome123
```
4. Next, Write a script to read the csv file created above, create a group on the server named "developers", and create and add each user in the csv file to this group. This script should take into consideration the follow:

    1. The script should first check for the existence of the user on the system, before it will attempt to create that it.
    1. Ensure that the user that is being created also has a default home folder
    1. Ensure that each user has a .ssh folder within its HOME folder. If it does not exist, then create it.
    1. For each user’s SSH configuration, create an authorized_keys file and add ensure it has the public key of your current user.

4.1 Create a key pair (accepting all default options) and also create an authorized_keys file which contains the public key values. This authorized_keys will be added to each user account to enable users access this server remotely using ssh.

```SHELL
#Create keypair
ssh-keygen
# Copy the contents in id_rsa.pub to the authorizated_key file
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

4.2 Create a bash script to perform the required tasks stated above:
Create a new file called "addusers_from_csv.sh" and add execution permission to this file
```SHELL
# Create adduser script file
sudo touch addusers_from_csv.sh

# Modify permissions of the file to make it executable
sudo chmod +x addusers_from_csv.sh
```
Add the below text into this file:
```SHELL
#! /usr/bin/bash

my_input="/home/vagrant/users.csv"
declare -a fname
declare -a lname
declare -a user
declare -a dept
declare -a passwd

CurrentUser=$(id -u -n)

# Read the first line and save it as the header
read -r header < "$my_input"

# Process the remaining lines of the file using the header
while IFS=, read -r FirstName LastName UserName Department Password
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
        if sudo groupadd "${dept[$index]}"; then
            echo "Group ${dept[$index]} created"
        else
            echo "Failed to create group ${dept[$index]}"
        fi
    else
        echo "Group ${dept[$index]} already exists"
    fi

    # Check if user already exists
    if id "${user[$index]}" >/dev/null 2>&1; then
        echo "User ${user[$index]} already exists"
    else
        # Create user with default home folder
        if sudo useradd -d "/home/${user[$index]}" \
                        -m \
                        -s "/bin/bash" \
                        -c "${fname[$index]} ${lname[$index]}" \
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

```

Verify that the new group "developers" and all users where created, added to this group and the bash shell was set as users default shell.
```SHELL
sudo less /etc/passwd
 ```
![picture](https://github.com/doutimi3/DevOps_Projects/blob/main/AUX-1-ShellScripting/img/groupcreated.png) 

Verify that the group "developers" was created and show all the users in this group

```SHELL
sudo cat /etc/group
```
![picture](DevOps_Projects/AUX-1-ShellScripting/img/groupcreated.png)

Verify that User Home directory as setup
![](DevOps_Projects/AUX-1-ShellScripting/img/VerifyDirSetup.png)

Login using any of the userid
```SHELL
sudo su - wjoseph
```
![](DevOps_Projects/AUX-1-ShellScripting/img/loggeduser.png)

Next, I will be accessing this server remotely using two randow users. Recall that we have already copied the public key to each users home directory and the private key is in the remote server. 

I will use my local machine as my client server and the ubuntu server managed by vagrant as the remote server. So to begin open the terminal in your local machine.

We can access this server remotely using the below block of code"


```SHELL
ssh wjoseph@192.168.56.11
ssh jpaul@192.168.56.11
```
To get the ip address of the remote server run the following command on the remote server:
```
ifconfig
```
![](DevOps_Projects/AUX-1-ShellScripting/img/RemoteUserAccess.png)
![](DevOps_Projects/AUX-1-ShellScripting/img/user2RemoteAccess.png)

__CONCLUSION__

We have successfully written a script to automate new users onboarding. This script reads the user details from a csv file and create all users and groups in the csv file which have not been created previously. The home directory of each user contains a .ssh directory which contains the public key that users can use to access the server remotely. We also verified that users are able to access the remote server remotely.


















