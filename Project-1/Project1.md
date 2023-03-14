# __Introduction__
A solution stack, also known as a software stack, is a group of software components that work together to provide a comprehensive solution for a specific task or application. It includes the operating system, a web server, a database server, and the programming languages, frameworks, and other software tools required for developing and deploying web applications or other software solutions.
A typical web solution stack might consist of an operating system such as Linux, a web server such as Apache or Nginx, a database server such as MySQL or PostgreSQL, and programming languages such as PHP, Python, or Ruby on Rails. Depending on the application's needs, other software components such as caching tools, load balancers, or monitoring tools may be included in the stack.
There are many different types of solution stacks, each of which is designed to meet specific needs and requirements. Here are a few examples:

1. The LAMP stack (Linux, Apache, MySQL, PHP): is a well-known solution stack for developing web applications. The Linux operating system, the Apache web server, the MySQL database server, and the PHP programming language are all included. This open-source stack is widely used for developing dynamic websites.
1. LEMP Stack (Linux, Nginx, MySQL, PHP/Python/Perl): LEMP stack is a variation of the LAMP stack that is used for building web applications. Instead of using the Apache web server that is used in LAMP stack, LEMP stack uses the Nginx web server. The name LEMP stands for Linux, Nginx, MySQL, and PHP/Python/Perl. LEMP stack is commonly used for building web applications that require high performance and scalability, such as e-commerce websites, social networking sites, and content management systems.
1. MEAN stack (MongoDB, Express.js, AngularJS, Node.js): This is another popular solution stack for building web applications is the MEAN stack. It includes the NoSQL database MongoDB, the web framework Express.js, the front-end framework AngularJS, and the Node.js runtime environment. This stack is frequently used to create real-time, single-page web applications.
1. The MERN stack (MongoDB, Express.js, React, Node.js) is a variant of the MEAN stack that employs the React front-end framework rather than AngularJS. Because of the popularity of React and its ease of use, this stack is becoming increasingly popular.
1. Some other commonly used stacks include Java Stack, .NET stack, WAMP stack.

This project focus on LAMP stack so I aim to explain how it works, its advantages and disadvantages.

__This article is sub divided into two sections: section 1 gives a theoritical explanation of LAMP stack while section 2 details how you can successfully deploy a LAMP stack on the AWS cloud__

# __SECTION 1: What is LAMP Stack?__
LAMP stack is a popular open-source software stack used for building web applications. The name LAMP stands for Linux, Apache, MySQL, and PHP. These four components work together to provide a complete solution for building dynamic web applications.
The LAMP stack is used to create a wide range of web applications, such as e-commerce websites, content management systems, and social networking websites. The stack is popular among both developers and system administrators due to its flexibility and ease of use.
One advantage of using the LAMP stack is that it is open source, which means that the individual components can be freely downloaded, used, and modified. This gives developers the freedom to tailor the stack to the specific requirements of their applications.
The LAMP stack is also well-known for its dependability, scalability, and security. Because the individual components are well-established and widely used, there is a large community of developers and system administrators familiar with the stack who can provide support and assistance.

### __LAMP Stack Architecture__
The components of the LAMP stack are:
1. Linux: The operating system used in the stack, which is typically a Linux distribution such as Ubuntu, Debian, or CentOS. Linux has been a free and open-source operating system since the mid-1990s. It now has a large global user base spanning several industries. Linux is popular because it offers more configuration and flexibility than other operating systems.
1. Apache: The Apache web server is used to serve web pages and handle HTTP requests. Apache is one of the most popular web servers in use today, and is known for its stability, flexibility, and security.
1. MySQL: The MySQL relational database management system is used to store and manage data for web applications. MySQL is one of the most widely used database systems and is known for its performance, scalability, and reliability.
1. PHP: The PHP scripting language is used to develop the application logic. PHP is a popular language for building web applications because of its ease of use, flexibility, and compatibility with other technologies.

Each component represents an essential layer of the stack. Together, the components are used to create database-driven, dynamic websites.

__The illustration below shows how the layers stack together:__

<-- Insert Picture -->

At a very high level, the process begins with the Apache web server receiving webpage requests from user’s browser. If the request is for a PHP file, Apache passes the request to PHP, which loads the file and executes the code contained in the file. PHP also communicates with the MySQL database layer to fetch any data referenced in the code. PHP then uses the code in the file and the data from the database to create the HTML that the browser requires to display webpages. After running the code, PHP then passes the resulting data back to the Apache web server to send to the browser and store any new data in the MySQL database. The Linux operating system helps enable these operations.

### __Advantages of using LAMP Stack__
1. Open-source: The LAMP stack's components are all open-source, which means they can be freely downloaded, used, and modified. This makes it simple for developers to begin developing web applications without incurring high costs.
1. The LAMP stack is widely used, so there is a large community of developers and system administrators who are familiar with it and can offer support and assistance.
1. Flexibility: Because the LAMP stack is highly adaptable, developers can tailor it to meet the specific requirements of their applications. Because the stack is open-source, developers can add or remove components as needed.
1. Stability: The LAMP stack's individual components are well-established and widely used, which means they are stable and reliable.
1. Scalability: Because the LAMP stack is highly scalable, it can support a large number of users and a high volume of traffic. This makes it ideal for developing web applications that will grow and expand over time.
1. Security: The LAMP stack is well-known for its security, and there are numerous tools and techniques for securing web applications built with it.
1. Compatibility: Because the LAMP stack is highly compatible with other technologies, it can be used with a wide range of tools and platforms.

### __Disadvantages of using LAMP Stack__
1. Security: While the LAMP stack is generally thought to be secure, it can be vulnerable to security threats if not properly configured or maintained. Developers must be aware of potential security risks and take preventative measures.
1. Lack of Standardization: While the LAMP stack is widely used, there is no standardised set of tools or practises for using it. This can result in inconsistencies and disparities in how the stack is used across development teams.
1. Performance: The size and complexity of the application being built can have an impact on the performance of the LAMP stack. The stack may not be able to provide the required performance for very large or complex applications.
1. Complexity: The LAMP stack can be difficult to set up and configure, especially for new developers. This can result in a steep learning curve and additional time and resources.
1. Limited Windows support: LAMP stack is typically used on Linux-based operating systems, and while it can be used on Windows, it is not as well-supported.
1. Resources Usage: LAMP stack can consume a significant amount of system resources, especially if the application being developed is large or complex. This can make running on low-powered hardware or in resource-constrained environments difficult.

# SECTION 2: PRACTICAL IMPLEMENTATION: DEPLOYING A LAMP STACK ON AWS EC2 INSTANCE

### Prerequisite
1. Create an AWS free Tier account: The first step in this practical guide on how to deploy a LAMP stack on the AWS cloud is to create an AWS free tier account, enable MFA on the root user, modify account level setting to enable IAM users to view billing dashboard, create an admin user group with full access to all AWS services, create an admin user, login with this admin user and launch an ubuntu EC2 instance on the AWS cloud so serve as the linux machine to host our stack. Click the the link: [Getting Started on AWS](https://medium.com/@angalabiridortimiariyemaxwell/getting-started-on-aws-cb19990a7575 "Getting Started on AWS") for a detailed step by step guide on how to create an AWS account.

2. Basic SSH knowledge
3. Basic Linux command line knowledge
4. Access to a terminal
5. Basic knowledge of Vim edittor
6. Set up AWS CLI

## Step one: Launch a Virtual Server with Ubuntu Server OS
The operating system of our LAMP stack is a linux server and we need a linux machine with the right specifications to successfully deploy our LAMP stack. To navigate system limitations and to take advantage of the enumous benefit of the public cloud, we will be launching our linux instance on the AWS cloud. 

The easiest way to launch an ec2 instance is to login into the aws console as an IAM user with the right set of privilages. It is very important to stop using the root user account for everyday tasks. Best practice is to reserve your root user account and only use it to perform tasks that can only be done by the root user like enabling IAM users to view billing dashboard, closing the account etc. Follow the below steps to launch an Ubuntu linux instance on the AWS cloud:

1. Sign in to the AWS Management Console as an IAM user
2. Navigate to the EC2 dashboard by typing "EC2" on the search bar and click on EC2 to go to the EC2 dashboard.
3. Click on the "Launch Instance" button
4. Give your instance name (i.e., MyLinuxinstance)
4. Choose an Amazon Machine Image (AMI) for your instance. The AMI is a pre-configured virtual machine image that contains the operating system and other software required for your application. For the project, we will be launching an Ubuntu instance. Type "Ubuntu" on the search bar to show all available Ubuntu AMIs. Select "Ubuntu Server 20.04 LTS (HVM), SSD Volume Type, 64-bit (x86)" which is free tier eligible.
5. On the Instance Type, select "t2.micro", this is free tier eligible.
6. Select a key pair from your existing keypairs for the region you are in. If you don't have an existing keypair, click on "Create new key Pair" to create a new key pair.
    * Enter a name for your key pair
    * if you are using a MacOS or Windows 10 machine, select "RSA" as key pair type and ".pem" as Private key file format. Otherwise, select ".ppk" which works with PuTTY.
    * Click on "Create key pair" to create a new key pair. Note that key Pairs are bound to a region.
7. Under "Network settings", under "Firewall (Security Groups)", click on "Create security group"
8. Ensure "Allow SSH traffic from" is checked. This would enable us connect to our ec2 instance from our local machine via the ssh client.
9. Keep all other default configurations and click on "launch instance" and wait a little while for the launch to complete. The instance will show under "Instances" in a running state.

We have successfully launched an Ubuntu ec2 instance to server as our operating system, next we will connect to this instance to setup all other components of our LAMP stack.

This can also be done via the aws cli using the below code snippet
```
aws ec2 run-instance --image-id ami-038d76c4xxxxx --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids sg-903004f8 --subnet-id subnet-6e7f829exxx

NB: Details of the image-id, SG id, subnet id can be obtained from the AWS management console.
```

## Connect to EC2 Instance
We will be using ssh client to connect to our instance, this is automatically enable on your terminal if your are using MacOS or Windows 10. Follow the below steps to connect to your instance.
1. Cd to the directory where your key pair is stored (i.e., ~/downloads)
```
cd ~/downloads
```
2. Change permissions for the private key file (.pem) to be readable by the owner only of the file to ensure that only you can access your private key. This is done using the chmod command:
```
sudo chmod 0400 MykeyPair.pem
```
3. Connect to the ubuntu instance using the below command:
```
ssh -i <MyKeyPair>.pem ubuntu@<Public_IP-address>
Example:
ssh -i my_london-keypair.pem ubuntu@3.8.202.xxx
```
NB: you can get the public ip from the management console by clicking on your instance and copy the "Public IPv4 address". You can retrieve your public ip address by running the below command:
```
curl -s http://169.254.169.254/latest/meta-data/public-ipv4
```

__At this point, we have successfully create our linux server in the cloud__

## Step 2: INSTALLING APACHE AND UPDATING THE FIREWALL
1. Install Apache using Ubuntu’s package manager ‘apt’:
```
# Update all packages in package manager
sudo apt update

# Install apache2 package 
sudo apt install apache2

# Verify that apache2 is up and running in our OS after a successfully installation:
sudo systemctl status apache2
```
< Insert image>
NB: If this is green and running, it means our webserver was installed correctly.

2. Next we will edit our security group rule to open TCP port 80 to enable http connection from anywhere on the internet. Recall taht we only opened port 22 when we created our instance. This can be done by running the following command:
```
aws ec2 authorize-security-group-ingress --group-id <security-group-id> --protocol tcp --port 80 --cidr 0.0.0.0/0
```
In the above command, replace <security-group-id> with the ID of the security group you want to modify, you can get this from the aws management console. The --protocol option specifies the protocol to allow traffic for, which in this case is tcp. The --port option specifies the port number to allow traffic for, which in this case is 80. The --cidr option specifies the IP range to allow traffic from, which in this case is 0.0.0.0/0, meaning all IP addresses.

Alternatively, 
* Click on the id of your ec2 instance
* On the bottom pane click on "Security"
* Click on the Security group attached to your instance

<-Insert Image>

* On the bottom pane, click on “Inbound rules” and the click on “Edit Inbound rules” and enter the following:
    * Type: HTTP
    * Protocol: TCP
    * Port range: 80
    * Source: Custom
    * CIDR Blocks: 0.0.0.0/0 (any IP range)


__Note that allowing inbound traffic on port 80 can make your instance vulnerable to attacks if you don't take appropriate security measures. It's recommended to only allow inbound traffic on the ports you actually need for your application and to use additional security measures such as firewalls, access control lists (ACLs), and HTTPS encryption.__

3. Confirm that you can access the webpage via the http protocol by entering the below command on your browser:
```
http://<Public-IP-Address>:80
```
This will display the default apache2 server webpage
<- Insert Image>

## STEP 3: INSTALL MYSQL
At this point we have successfully set up our webserver, we now need to setup a database management system to be able to store and manage data for our website in a relational database. We will be using MySQL for this project. This is the most popular RDBMS used within PHP environments.

1. Install mysql-server:
```
sudo apt install mysql-server -y
```
When the installation is finished, log in to the MySQL console as an administrative database user **root** by typing:
```
# Login to MySQL
sudo mysql

# Set a password for the root user using mysql_native_password as default authentication method:
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PassWord.1';

#Exit MySQL shell
exit
```

It is recommended that we run a security script that comes pre-installed with MySQL to remove some insecure default settings and lock down access to your database system
```
# Start the interactive script by running:
sudo mysql_secure_installation
# You will be asked if you want to validate password plugin, enter "yes":
y
# Enter 0 or 1 as the level of password validation. Note that for a production grade system the level should be very high.
1
# You will be asked to select and confirm your password, enter your password twice to complete this step.
# You will be shown the password strenght if password validation was enabled. Enter "yes" to proceed.
# For the rest of the options select "Yes"
```

Test if you can log in to the MySQL console by typing:
```
sudo mysql -p
```
The -p flag would prompt you to enter your password. Enter your set password to proceed. If you are able to access it, you MySQL is now setup and secure. You can proceed to step 4.

Exit MySQL
```
exit
```
## STEP 4: INSTALL PHP
We now have an Apache2 server to servent content and MySQL to store and manage data. PHP is the component of our setup that will process code to display dynamic contents to end user. In addition to the php package, you will need php-mysql, a PHP model that allows PHP to communicate with mySQL-based databases. We will also need libapache2-mod-php to enable Apache to handle PHP files. Core PHP packages will automatically be installed as dependencies.
1. Install php, libapache2-mod-php and php-mysql:
```
sudo apt install php libapache2-mod-php php-mysql -y
```
1. Once the installation is finished, you can run the following command to confirm your PHP version:
```
php -v
```
<- Insert picture ->

At this point, your LAMP stack is completely installed and fully operational.
* Linux (Ubuntu)
* Apache HTTP Server
* MySQL
* PHP

We will be creating an Pache Virtual Host, a virtual host to enable us have multiple websites located on a single machine.

## STEP 5: CREATE A VIRTUAL HOST FOR YOUR WEBSITE USING APACHE
**In the project, we will set up a domain called “lampstackproject”**

Apache on Ubuntu 20.04 already has one server block enabled by default that is configured to serve documents from /var/www/html directory. We will leave this configuration as it is and add our own directory next to this default directory.

1. Create the directory for lampstackproject using “mkdir” command:
```
sudo mkdir /var/www/lampstackproject
```
2. Assign ownership of the directory with your current system user:
```
sudo chown -R $USER /var/www/lampstackproject
```
3. create and open a new configuration file in Apache’s sites-available directory located in /etc/apache2/ directory, using your preferred command-line editor. We will use vim in this instance. Run the following command to open VIM on the shell.
```
sudo vi /etc/apache2/sites-available/lampstackproject.conf
```
This would create a new file in the specified location, press “i” to change to insert mode, copy the below configuration and paste it on the file then press ‘esc’ and then :wq and hit enter to write, save and quite vim.

```
<VirtualHost *:80>
    ServerName lampstackproject
    ServerAlias www.lampstackproject 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/lampstackproject
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
4. Show the file in the sites-available directory:
```
sudo ls /etc/apache2/sites-available/
```
<- Insert picture ->

With this VirtualHost configuration, we’re telling Apache to serve “lampstackproject” using /var/www/lampstackproject as its web root directory. 

5. Enable the new virtual host using the a2ensite command:
```
sudo a2ensite lampstackproject
```
6. Disable the default website that comes installed with Apache. This is required if we want to use a custom domain name:
```
sudo a2dissite 000-default
```
7.	To make sure your configuration file doesn’t contain syntax errors, run:
```
sudo apache2ctl configtest
```
If this shows as "Syntax Ok" it means everything was properly setup.

8. Finally, reload Apache to effect these changes:
```
sudo systemctl reload apache2
```
9. The new website is now active, but the web root /var/www/lampstackproject is still empty. Create an index.html file in that location so that we can test that the virtual host works as expected by running the following command:
```
sudo echo 'Hello LAMP from hostname' $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) 'with public IP' $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) > /var/www/lampstackproject/index.html
```
You can also replace this with a proper html landing page.

10. Now go to your browser and try to open your website URL using the public IP address:
```
http://3.8.202.108:80
```
<- Insert picture ->

# STEP 6: ENABLE PHP ON THE WEBSITE
With the default DirectoryIndex settings on Apache, a file named index.html will always take precedence over an index.php file. To change this behaviour, you need to edit the /etc/apache2/mods-enabled/dir.conf file and change the order in which the index.php file is listed within the DirectoryIndex directive:
```
sudo vim /etc/apache2/mods-enabled/dir.conf
```
* Edit the script to reorder the position of index.php to come before index.html
```
<IfModule mod_dir.c>
        <IfModule mod_dir.c>
            DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
        </IfModule>
```
After saving and closing the file, you will need to reload Apache so the changes take effect:
```
sudo systemctl reload apache2
```

* Finally, we will create a PHP script to test that PHP is correctly installed and configured on your server. Create a new file named index.php inside your custom web root folder:

```
vim /var/www/lampstackproject/index.php

Enter the following line of php code:
<?php
phpinfo();

Save and close the file: “esc”, :wq
```
* When you are finished, save and close the file, refresh the page and you will see a page similar to this:

<- Insert Image >

This page provides information about your server from the perspective of PHP. It is useful for debugging and to ensure that your settings are being applied correctly.
If you can see this page in your browser, then your PHP installation is working as expected.

After checking the relevant information about your PHP server through that page, it’s best to remove the file you created as it contains sensitive information about your PHP environment -and your Ubuntu server. You can use rm to do so:
```
sudo rm /var/www/lampstackproject/index.php
```
























