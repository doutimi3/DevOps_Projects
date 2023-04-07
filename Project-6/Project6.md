# IMPLEMENTING A THREE-TIER WEB SOLUTION WITH WORDPRESS

In this project, I will present a step-by-step guide to preparing storage infrastructure on two Linux servers and implementing a basic web solution using WordPress. You will have the hands-on experience that showcases Three-tier Architecture while also ensuring that the disks used to store files on the Linux servers are adequately partitioned and managed through programs such as gdisk and LVM respectively.

WordPress is a free and open-source content management system written in PHP and paired with MySQL or MariaDB as its backend relational database management system (RDBMS).


__Three-tier Architecture__

Generally, web or mobile solutions are implemented based on what is called the "three-tier architecture."

Three-tier architecture is a client-server software architecture pattern that comprises three separate layers.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*nhzBjnaMn-r14ARI-5JzFA.png)

__Presentation Layer (PL):__ This is the user interface such as the client-server or browser on your laptop.

__Business Layer (BL):__ This is the backend program that implements business logic. Application or Webserver

__Data Access or Management Layer (DAL):__ This is the layer for computer data storage and data access. Database Server or File System Server such as FTP server, or NFS Server.

In this project,

1. A laptop or PC will server as the client
1. A RHEL EC2 instance will serve as the web server (WordPress will be installed on this server).
1. A RHEL EC2 instance will server as the db-server.

__LAUNCH AN EC2 INSTANCE THAT WILL SERVE AS “WEB SERVER AND APP SERVER”__

__Step 1: Create and configure two Linux-based virtual servers (EC2 instances in AWS):__ 

This involves creating two security groups that allow SSH connections on port 22. These instances will be launched in the default VPC. This can be done using the below commands:

SG for DB-Server
```SHELL
aws ec2 create-security-group --group-name DBSG \
        --description "Security group for 3-tier webapp project" \
        --vpc-id vpc-0344c69 \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=DBSG}]' \
        --query 'GroupId' --output text \
        | xargs -I {} aws ec2 authorize-security-group-ingress --group-id {} \
        --protocol tcp --port 22 --cidr 0.0.0.0/0
```

SG for App-Server
```SHELL
aws ec2 create-security-group --group-name AppSG \
        --description "Security group for 3-tier webapp project" \
        --vpc-id vpc-0344c....6086 \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=AppSG}]' \
        --query 'GroupId' --output text \
        | xargs -I {} aws ec2 authorize-security-group-ingress --group-id {} \
        --protocol tcp --port 22 --cidr 0.0.0.0/0
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*Erh4vCVmcubsiyXIP8uCIw.png)

Launch the client and server EC2 instances

Launch two RHEL EC2 instances that will serve as “Web Server” and “App-Server” respectively. For each of these instances, create three volumes in the same AZ as your EC2 instance, each of 10 GB.

```SHELL
# Launch App-Server EC2 Instance
aws ec2 run-instances --image-id ami-08d9.....e5c2 \
        --count 1 \
        --instance-type t2.micro \
        --key-name <Key Pair> \
        --security-group-ids sg-0be.....d0d \
        --subnet-id subnet-0ef.....14b4 \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}},{\"DeviceName\":\"/dev/sdg\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}},{\"DeviceName\":\"/dev/sdh\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=App-Server}]' 'ResourceType=volume,Tags=[{Key=Name,Value=App-Server-disk}]'

# Launch DB-Server EC2 Instance
aws ec2 run-instances --image-id ami-08d9.....e5c2 \
        --count 1 \
        --instance-type t2.micro \
        --key-name <Key Pair> \
        --security-group-ids sg-0be.....hgd00 \
        --subnet-id subnet-0ef.....14b4 \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}},{\"DeviceName\":\"/dev/sdg\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}},{\"DeviceName\":\"/dev/sdh\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB-Server}]' 'ResourceType=volume,Tags=[{Key=Name,Value=DB-Server-disk}]'
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*SwlkVuN9jT9CijT-WfeLEw.png)

__Volumes__
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*NiIm11OGJPebCAGrUSTWJQ.png)

__Step 2: Configure the App and DB Servers__

1. Open up the terminal of the app server to begin configuration.
1. Use lsblk command to inspect what block devices are attached to the server. Notice names of your newly created devices. All devices in Linux reside in /dev/ directory. Inspect it with ls /dev/ and make sure you see all 3 newly created block devices there – their names will likely be xvdf, xvdh, xvdg.

![](https://miro.medium.com/v2/resize:fit:878/format:webp/1*-zuPu-GOQ5AlhwTSTwZCWA.png)

3. Use df -h command to see all mounts and free space on your server

![](https://miro.medium.com/v2/resize:fit:878/format:webp/1*HuDE7zV1l8yFwnkZvig-8Q.png)

4. Use gdisk utility to create a single partition on each of the 3 disks by running the below command to open up an interactive shell and responding to the prompts as follow:

```SHELL
sudo gdisk /dev/xvdf
sudo gdisk /dev/xvdh
sudo gdisk /dev/xvdg
```
* Enter “n” to create a new partition, press “Enter” to accept the default Partition number (i.e., Partition number 1), or enter your preferred partition number, Select the size of the First sector (press Enter to accept the default of 2048GB) and press Enter to assign the remaining free space to the Last sector. Enter the Hexadecimal code of the volume (i.e., enter 8300 to select the Linux Filesystem)
* Enter “p” to print out the partition table.
* Enter “w” to write the disk.
* Enter “yes” to save this change and exit the interactive shell.

![](https://miro.medium.com/v2/resize:fit:1314/format:webp/1*voEKJKqV8Y6QYBG4XiiywA.png)

5. Install lvm2 package using sudo yum install lvm2 -y. Run sudo lvmdiskscan command to check for available partitions.

![](https://miro.medium.com/v2/resize:fit:878/format:webp/1*Yl127LGD0HpmlBLInotLdA.png)

6. Use pvcreate utility to mark each of 3 disks as physical volumes (PVs) to be used by LVM.

```SHELL
sudo pvcreate /dev/xvdf1
sudo pvcreate /dev/xvdg1
sudo pvcreate /dev/xvdh1
```
![](https://miro.medium.com/v2/resize:fit:974/format:webp/1*xbmmkRuJj_7HYv_lNQoPFA.png)

7. Verify that your Physical volume has been created successfully by running "sudo pvs"
![](https://miro.medium.com/v2/resize:fit:832/format:webp/1*zmGQGFQwK5nJFd8i0dpdXQ.png)

8. Use vgcreate utility to add all 3 PVs to a volume group (VG). Name the VG webdata-vg and Verify that your VG has been created successfully by running "sudo vgs"

```SHELL
sudo vgcreate webdata-vg /dev/xvdh1 /dev/xvdg1 /dev/xvdf1
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*SUz67Gl8ZrjMYGxHNhxjUw.png)

9. Use lvcreate utility to create 2 logical volumes. apps-lv (Use half of the PV size), and logs-lv Use the remaining space of the PV size. NOTE: apps-lv will be used to store data for the Website while, logs-lv will be used to store data for logs.

```SHELL
sudo lvcreate -n apps-lv -L 14G webdata-vg
sudo lvcreate -n logs-lv -L 14G webdata-vg
```
10. Verify that your Logical Volume has been created successfully by running "sudo lvs"

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*MixVedEP2E6IBRNYFpI8fA.png)

11. Verify the entire setup

```SHELL
sudo vgdisplay -v #view complete setup - VG, PV, and LV
sudo lsblk
```


![](https://miro.medium.com/v2/resize:fit:1110/format:webp/1*lEBAr-tTu-q_uWgFr0-4lA.png)

12. Use mkfs.ext4 to format the logical volumes with ext4 filesystem

```SHELL
sudo mkfs -t ext4 /dev/webdata-vg/apps-lv
sudo mkfs -t ext4 /dev/webdata-vg/logs-lv
```

![](https://miro.medium.com/v2/resize:fit:1360/format:webp/1*mu0rhucPIuZdj5OO-AdUpQ.png)

13. Create /var/www/html directory to store website files and Create /home/recovery/logs to store backup of log data.

```SHELL
# Create directory to store website files
sudo mkdir -p /var/www/html

# Create directory to store backup of log data
sudo mkdir -p /home/recovery/logs
```

14. Mount /var/www/html on apps-lv logical volume
```SHELL
sudo mount /dev/webdata-vg/apps-lv /var/www/html/
```

15. Use rsync utility to backup all the files in the log directory /var/log into /home/recovery/logs (This is required before mounting the file system)
```SHELL
sudo rsync -av /var/log/. /home/recovery/logs/
```
16. Mount /var/log on logs-lv logical volume. (Note that all the existing data on /var/log will be deleted. That is why step 15 above is very important)

```SHELL
sudo mount /dev/webdata-vg/logs-lv /var/log
```
17. Restore log files back into /var/log directory

```SHELL
sudo rsync -av /home/recovery/logs/. /var/log
```
Run “sudo lsblk” to see the present setup

![](https://miro.medium.com/v2/resize:fit:1280/format:webp/1*PqYWhSkYGVkRCo5Q8MakcA.png)

18. Update /etc/fstab file so that the mount configuration will persist after restart of the server. To do this, first run “sudo blkid” to get the UUID of the logical volume and add these to the /etc/fstab/ file as follow:

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*go3Zz3Y73h5ZN79CzFRK8g.png)

19. Test the configuration and reload the daemon
```SHELL
sudo mount -a
sudo systemctl daemon-reload
```
20. Verify your setup by running df -h, output must look like this:
![](https://miro.medium.com/v2/resize:fit:1280/format:webp/1*qY27DPe2y2RPL2-xLYHLiw.png)

__Step 3: Prepare the Database Server__

Ssh into the db-server and repeat the same steps as for the Web Server, but instead of apps-lv create db-lv and mount it to /db directory instead of /var/www/html/.

![](https://miro.medium.com/v2/resize:fit:1104/format:webp/1*FTNPOTe61h3R04svbq_zqw.png)

Edit /etc/fstab file and verify setup by running “df -h”

![](https://miro.medium.com/v2/resize:fit:1204/format:webp/1*c5AgEyNWNcuBt0PG3iEmNg.png)

__Step 4: Install WordPress on your Web Server EC2__
We will be installing wget, httpd, php, php-mysqlnd, php-fpm, and php-json.

```SHELL
# Update the repository
sudo yum -y update

# Install wget, Apache and it’s dependencies
sudo yum -y install wget httpd php php-mysqlnd php-fpm php-json

# Start Apache
sudo systemctl enable httpd
sudo systemctl start httpd

# Install PHP and its Dependencies
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum install yum-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo yum module list php
sudo yum module reset php
sudo yum module enable php:remi-7.4
sudo yum install php php-opcache php-gd php-curl php-mysqlnd
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo setsebool -P httpd_execmem 1
```

Restart Apache server

```SHELL
sudo systemctl restart httpd
```

Create a new directory called “wordpress”, change to this directory, Download WordPress, extract the contents of the zip file and copy wordpress to var/www/html.

```SHELL
  mkdir wordpress
  cd   wordpress
  sudo wget http://wordpress.org/latest.tar.gz
  sudo tar xzvf latest.tar.gz
  sudo rm -rf latest.tar.gz
  sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php
  sudo cp -R wordpress /var/www/html/
  ```

Configure SELinux Policies. SELinux (Security-Enhanced Linux) is a security mechanism implemented in the Linux kernel to provide mandatory access control (MAC) for the system. SELinux policies define how processes and users can access various system resources such as files, directories, and ports.

```SHELL
sudo chown -R apache:apache /var/www/html/wordpress
sudo chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R
sudo setsebool -P httpd_can_network_connect=1
```

__Step 5: Install MySQL on your DB Server EC2__
Update the server and install mysql-server and verify that the MySQL service is running.

```SHELL
sudo yum update -y
sudo yum install mysql-server -y
sudo systemctl restart mysqld
sudo systemctl enable mysqld
sudo systemctl start mysqld
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*tAyoz6Xhws7ENBCVVIWlVA.png)

__Step 6: Configure DB to work with WordPress__

Login to MySQL and create a database called “wordpress” and also create a new user called “wordpress”. The host address of this user should be the private IP address of the web-server. This is the user which worpress would use to remotely access the db-server.

```SHELL
sudo mysql
CREATE DATABASE wordpress;
CREATE USER 'wordpress'@'172.31.37.194' IDENTIFIED BY 'Password@123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'172.31.37.194' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SHOW DATABASES;
exit
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*qmVaM519amVOaQDpoAGFeg.png)

__Step 7: Configure WordPress to connect to the remote database.__

1. Open MySQL Port 3306 on the DB-server EC2 to allow traffic between the App-server and DB-server. For extra security, we will only be allowing the IP address of the App-server.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*bcLq2VuW9_Eszuys-pOcog.png)

2. Install MySQL client on the web-server and test that you can connect from your Web Server to your DB server by using mysql-client.

```SHELL
sudo yum install mysql -y
sudo mysql -u wordpress -p -h 172.31.35.54
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*7TI7QQlQIamd1sXF_iOg9A.png)

3. Change permissions and configuration so Apache can use WordPress:

Go to https://api.wordpress.org/secret-key/1.1/salt/ to generate new Authentication unique keys and salts, and update the /wordpress/wp-config.php file with these keys and the username, database, and password Wordpress would use to access the database.

```SHELL
sudo vi /var/www/html/wordpress/wp-config.php
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*yxPL5t9ICejY_A7JPDo0rw.png)

4. Restart the webserver to apply the changes made to the wp-config file.

```SHELL
sudo systemctl restart httpd
```

4. Enable TCP port 80 in Inbound Rules configuration for your Web Server EC2 (enable from everywhere 0.0.0.0/0 or from your workstation’s IP).

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*E41TAK6EuhriIHOi7nhp9A.png)

5. Try to access from your browser the link to your WordPress : http://13.42.46.226/wordpress/ and install it.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*fQS4O13H3HNxKWR3N5cidA.png)

Login to Wordpress

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*lCaSIf9NmGhmfB9ecoCPzw.png)

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*hsTtezhC9k9UJUPLe5WBvw.png)

Verify that the database connection is okay. On the menu bar, click on “Tools” , then “Site Health”, and on the top of the page, click on “info”. If the test show “Good” then the connection is okay.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*CkasOpC5PH48AwvF_cwzlQ.png)

__Conclusion__

We have successfully gone through the steps for configuring Linux storage system and have also deployed a full-scale Web Solution using WordPress CMS and MySQL RDBMS!






