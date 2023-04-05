# IMPLEMENTING CLIENT-SERVER ARCHITECTURE WITH MYSQL

Client-server architecture is a common approach to building distributed software systems. In this architecture, there are two main components: the client and the server. The client is the user interface or front-end of the application, while the server is the back-end that handles data storage and processing.

One of the most widely used server-side technologies for data storage is MySQL, an open-source relational database management system. In this project, I will give a step by step guide on how to implement client-server architecture with MySQL.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*8hzywsbZpwZf537n7yYwwg.png)

__Prerequisites__
1. Basic knowledge of at least one programming language.
1. A server infrastructure to host the MySQL server and the client application.
1. Familiarity with SQL.
1. Know t basic Linux commands and knowledge of Linux server management
1. Install and set up MySQL on your Linux server.

Deploying a Client-Server using MySQL

Follow the below steps to implement a basic client-server architecture using MySQL RDBMS.

__Step 1: Create and configure two Linux-based virtual servers (EC2 instances in AWS).__ 

This involves creating two security groups that allow SSH connections on port 22. These instances will be launched in the default VPC. This can be done using the below commands:

SG Group for MySQL Client:
```SHELL
# Create security group
aws ec2 create-security-group --group-name ServerClientSG \
        --description "Security group for Server-Client project" \
        --vpc-id vpc-0344c6..... \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=ServerClientSG}]'

# Modify Security Group rules to allow SSH connection
aws ec2 authorize-security-group-ingress \
    --group-id "sg-242126....." \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=ServerClient}]' \
    --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=0.0.0.0/0}]" 
```

SG Group for MySQL Server:
```SHELL
# Create security group
aws ec2 create-security-group --group-name MySQLServerSG \
        --description "Security group for Server-client project" \
        --vpc-id vpc-0344c6 \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=MySQLServerSG}]'

# Modify Security Group rules to allow SSH connection
aws ec2 authorize-security-group-ingress \
    --group-id "sg-4252" \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=ServerClient}]' \
    --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=0.0.0.0/0}]"
```


![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*sreC5xKEfpLw50ylxIgotA.png)

Launch the client and server EC2 instances:
```SHELL
# Launch Server EC2 instance
aws ec2 run-instances --image-id ami-038d76c4d28805c09 \
        --count 1 \
        --instance-type t2.micro \
        --key-name <KeyPair Name> \
        --security-group-ids <mySQlServer SG ID> \
        --subnet-id subnet-0efc3d163\
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":80,\"DeleteOnTermination\":true}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mysqlserver}]' 'ResourceType=volume,Tags=[{Key=Name,Value=mysqlserver-disk}]'

# Launch Client EC2 instance
aws ec2 run-instances --image-id ami-038d76c \
        --count 1 \
        --instance-type t2.micro \
        --key-name <KeyPair Name> \
        --security-group-ids <MySQL Client SG ID> \
        --subnet-id subnet-0efc3d \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":80,\"DeleteOnTermination\":true}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mysqlclient}]' 'ResourceType=volume,Tags=[{Key=Name,Value=mysqlclient-disk}]'
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*UTF_G653Yp_SFPUmmQWJDg.png)


__Step 2: Install MySQL Server software on the MySQL Server and Client EC2 instances.__

Thanks to Digital Ocean, the steps to install MySQL on an Ubuntu server are detailed in [How to install mysql on ubuntu-20.04](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04).

To install it, update the package index on your server if you’ve not done so recently: To perform this task, ssh into both servers and run the below commands:

```SHELL
# Update ubuntu
sudo apt update
# Upgrade ubuntu 
sudo apt upgrade -y
```
Then install the mysql-server package and ensure that the server is running using the systemctl start command:

```SHELL
# Install MySQL Server
sudo apt install mysql-server -y
# Start server
sudo systemctl enable mysql
# Check the status to ensure it is running
sudo systemctl status mysql
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*paecIsDJFhMCXUjuFDomMA.png)

These commands will install and run MySQL without prompting you to set a password or make other configuration adjustments. This will leave your MySQL server insecure, so we will handle this next.

__Configuring MySQL__

For fresh installations of MySQL, you’ll want to run the DBMS’s included security script. This script modifies some of the less secure default settings, such as remote root logins and sample users. This script attempt to set a password for the installation’s root MySQL account, but, by default on Ubuntu installations, this account is not configured to connect using a password. To avoid having an error, we will first log in to MySQL and set the root user's password.

```SHELL
# First, open up the MySQL prompt:
sudo mysql
# Change the root user’s authentication method to one that uses a password.
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
# exit the MySQL prompt:
exit
```

Run the security script with sudo:
```SHELL
sudo mysql_secure_installation
```

The process involves a series of prompts that allow users to make changes. The first prompt is to enter the root user's password, the one set above, to continue.

The second prompt offers the option to set up the Validate Password Plugin, which tests the strength of new MySQL user passwords. Select “yes” and enter “2” which is the strongest password option. The strongest policy requires passwords to be at least eight characters long and include a mix of uppercase, lowercase, numeric, and special characters.

The next prompt will be to set a password for the MySQL root user. Enter “yes” and then confirm a secure password of your choice. The script will then prompt you to continue using the password you just entered or to enter a new one. Assuming you’re OK with the strength of the password you just typed, press Y to proceed with the script.

You can press Y and then ENTER to accept the defaults for all the subsequent questions. This will remove some anonymous users and the test database, disable remote root logins, and load these new rules so that MySQL immediately respects the changes you have made.


![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*ZrXpTAH3R1SPMJfdnsT9Iw.png)

Creating a Dedicated MySQL User and Granting Privileges

```SHELL
# Login to MySQL
sudo mysql -u root -p
# Create new user
CREATE USER 'remote_user'@'%' IDENTIFIED WITH mysql_native_password BY 'Password@123';
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*trziSt7bT_dS2DeNcW83Tw.png)

__NB:__ If you want to be very specific about the IP address to allow, you should specify the private IP address of the client-server as the hostname. In this case the create user command would be as follow:

```SHELL
CREATE USER 'remote_user'@'<private IP of client-server' IDENTIFIED WITH mysql_native_password BY 'Password@123';
```

After creating your new user, you can grant them the appropriate privileges. In this project, I will grant the user created above all privileges to all databases, but in a real-world scenario, users should be granted privileges using the least privilege principle. Run the flush privilege command to free up any memory that the server cached as a result of the preceding CREATE USER and GRANT statements and exit MySQL.

```SHELL
# Grant Privillages
GRANT ALL PRIVILEGES ON *.* TO 'remote_user'@'%' WITH GRANT OPTION;

# Flush privileges 
FLUSH PRIVILEGES;

# exit MySQL:
exit
```

Replace ‘%’ with the private IP address of the client server if you choose this option while creating the user.

Test login into mysql using the user created above using **“sudo mysql -u remote_user -p”**

![](https://miro.medium.com/v2/resize:fit:1268/format:webp/1*yzOoDYEWVfF26yGXCkKqgQ.png)

You might need to configure MySQL server to allow connections from remote hosts. To do this, open the MySQL config file and replace 127.0.0.1’ to ‘0.0.0.0’ in the “binding-address”

```SHELL
sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*qmKaz_oS6Mpwkn4i5Syodw.png)

Exit MySQL and restart the MySQL service using:
```SHELL
sudo systemctl restart mysql
```

__Next, ssh into the client-server and repeat step 2 above on the client-server also.__

__STEP 3: CONNECT TO THE MYSQL SERVER FROM THE MYSQL CLIENT-SERVER__

Both EC2 instances were launched in the same VPC, so by default they can communicate with each other using their local IP addresses. We will be using the MySQL server's local IP address (private IP) to connect from the MySQL client. MySQL server uses TCP port 3306 by default, so you will have to open it by creating a new entry in ‘Inbound Rules in ‘MySQL Server Security Groups. For extra security, do not allow all IP addresses to reach your ‘MySQL server—allow access only to the specific local IP address of your ‘MySQL client’.

Modify the MySQL server security group as follows:
```SHELL
# Modify SG of server to allow the local ip of the client on port 3306
aws ec2 authorize-security-group-ingress \
    --group-id "<mysqlserver security group id>" \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=MySQLServer}]' \
    --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges="[{<CidrIp=CIDR of mysql client server>}]"
```

Modify the MySQL client security group as follows:
```SHELL
# Modify SG of server to allow the local ip of the client on port 3306
aws ec2 authorize-security-group-ingress \
    --group-id "<mysqlclient security group id>" \
    --tag-specifications 'ResourceType=security-group-rule,Tags=[{Key=Name,Value=MySQLServer}]' \
    --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges="[{<CidrIp=CIDR of mysqlserver>}]"
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*OmDW_yHv0VmDwWlRQa7eBg.png)

From MySQL client server connects remotely to the MySQL server database engine without using SSH. You must use the MySQL utility to perform this action.

```
sudo mysql -h 172.31.38.119 -u remote_user -p
```

![](https://miro.medium.com/v2/resize:fit:1346/format:webp/1*thIDH4j_NWcpKnD448taog.png)

Confirm that you have successfully perform SQL queries from the client server:

![](https://miro.medium.com/v2/resize:fit:1346/format:webp/1*Cp03TYE3MW-eCSct1Me21Q.png)

If you get the above output, it means you have successfully logged into the MySQL server from a client server and performed query successfully.

__CONCLUSION__

In this project, we have successfully gone through the steps to set up MySQL server on two ubuntu servers (MySQL server and client), secure the MySQL instances, and created users, and also configured MySQL to allow remote connection by editing the MySQL config file. We also modified the security groups of both instance to allow communication between the the MySQL server and client, and we successfully logged into the MySQL server from the client server using the private IP address of the MySQL server.



