# DEVOPS TOOLING WEBSITE SOLUTION

In a previous project, “Implementing a Three-Tier Web Solution with WordPress”, I implemented a WordPress-based solution that is now ready to be used as a fully functional website or blog. In this project, I will be adding more value to this solution by implementing a tooling website solution that makes access to DevOps tools within the corporate infrastructure easily accessible.

In this project, you will implement a solution that consists of the following components:

• Infrastructure: AWS
• Webserver Linux: Red Hat Enterprise Linux 8
• Database Server: Ubuntu 20.04 + MySQL
• Storage Server: Red Hat Enterprise Linux 8 + NFS Server
• Programming Language: PHP
• GitHub Code Repository.

__Prerequisites__

• Knowledge of AWS core services and CLI
• Basic knowledge of Linux commands and how to manage storage on a Linux server.
• Basic knowledge of Network-attached storage (NAS), Storage Area Networks (SAN), and related protocols like NFS, FPT, SFTP, SMB, iSCSI.
• Knowledge of Block-level storage and how it is used on the Cloud.

__Architecture__

We will be implementing a solution that comprises multiple web servers sharing a common database and also accessing the same files using Network File System (NFS) as shared file storage.

![](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*TuBk--fnY6ZDTbEKAfADRg.png)

__LAUNCH AN EC2 INSTANCE THAT WILL SERVE AS “NFS-SERVER"__

__Step 1: Create and configure a Linux-based virtual server (EC2 instances in AWS).__

This involves creating a security group that allows SSH connections on port 22. This instance will be launched in the default VPC. This can be done using the below commands:

SG for Nfs-Server
```
aws ec2 create-security-group --group-name NFS_SG \
        --description "Security group for DevOps Tooling project" \
        --vpc-id vpc-0344c69 \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=NFS_SG}]' \
        --query 'GroupId' --output text \
        | xargs -I {} aws ec2 authorize-security-group-ingress --group-id {} \
        --protocol tcp --port 22 --cidr 0.0.0.0/0
```
Launch an EC2 instance with RHEL Linux 8 operating system that will serve as an “NFS Server”. This instance should have three volumes in the same AZ as your EC2 instance, each of 10 GB.

```
aws ec2 run-instances --image-id ami-08d.......e5c2 \
        --count 1 \
        --instance-type t2.micro \
        --key-name <keyPair> \
        --security-group-ids sg-017.......84ff \
        --subnet-id subnet-0efc........4b4 \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}},{\"DeviceName\":\"/dev/sdg\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}},{\"DeviceName\":\"/dev/sdh\",\"Ebs\":{\"VolumeSize\":10,\"DeleteOnTermination\":false}}]" \
        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Nfs-Server}]' 'ResourceType=volume,Tags=[{Key=Name,Value=Nfs-Server-disk}]'
```

![](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*8Qgx9MhNzOgqcVeDxO66Jg.png)

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*yso9a7LCWl3Xy30MwrPV5A.png)

__Step 2: Prepare NFS Server__

Based on the steps documented in my previous project: Step 2: Configure the App and DB Servers, configure LVM on the server but in this case:
* Instead of formatting the disks as ext4, we will be formatting them as xfs.
* Ensure there are 3 Logical Volumes. lv-opt lv-apps, and lv-logs
* Create mount points on /mnt directory for the logical volumes as follows:
1. Mount lv-apps on /mnt/apps – To be used by web servers
1. Mount lv-logs on /mnt/logs – To be used by web server logs
1. Mount lv-opt on /mnt/opt – To be used by Jenkins server in a future project.

```
sudo lsblk
sudo df -h
```
![](https://miro.medium.com/v2/resize:fit:824/format:webp/1*mdv4O0PsBvxI6QHHt9XYEQ.png)

![](https://miro.medium.com/v2/resize:fit:936/format:webp/1*A3DPFSo9JaKcjxHUvn57-w.png)

Create Partitions by running the below commands and follow the prompts as documented previously to partition all three block storages.

```SHELL
sudo gdisk /dev/xvdf
sudo gdisk /dev/xvdh
sudo gdisk /dev/xvdg
```
![](https://miro.medium.com/v2/resize:fit:1346/format:webp/1*pyZWqZPsrub-ccMp4m-fcg.png)

Install lvm2 package using sudo yum install lvm2 -y and run the below commands to create the physical volumes:

```SHELL
sudo pvcreate /dev/xvdf1
sudo pvcreate /dev/xvdg1
sudo pvcreate /dev/xvdh1
```

Create a volume group called “nfsdata-vg” comprising of all three disks

```SHELL
sudo vgcreate nfsdata-vg /dev/xvdh1 /dev/xvdg1 /dev/xvdf1
```

__Note:__ If you made a mistake with the disk specification and you wish to delete any of the disks from the volume group at this point, go to the aws ec2 console and detach the disks from the instances, create new disks with your desired specifications, and attach the new disks to the instance, then run the below commands:

```SHELL
# Delete missing physical volume from a volume group
sudo vgreduce --removemissing nfsdata-vg

# Modify an existing vg to add new physical volumes
sudo vgextend nfsdata-vg /dev/xvdh1 /dev/xvdg1
```
Use lvcreate utility to create 3 logical volumes of equal sizes. Run “sudo vgs” to see the available volume group size.

```SHELL
sudo lvcreate -n apps-lv -L 9G nfsdata-vg
sudo lvcreate -n logs-lv -L 9G nfsdata-vg
sudo lvcreate -n opt-lv -L 9G nfsdata-vg
```
![](https://miro.medium.com/v2/resize:fit:1070/format:webp/1*i84O3zMm4-xHhsbx0sM03A.png)

Use mkfs.xfs to format the logical volumes with xfs filesystem

```SHELL
sudo mkfs -t xfs /dev/nfsdata-vg/apps-lv
sudo mkfs -t xfs /dev/nfsdata-vg/logs-lv
sudo mkfs -t xfs /dev/nfsdata-vg/opt-lv
```

Mount logical volumes

```SHELL
sudo mkdir -p /mnt/logs
sudo mkdir -p /mnt/opt
sudo mkdir -p /mnt/apps

# mount directories
sudo mount /dev/nfsdata-vg/opt-lv /mnt/opt
sudo mount /dev/nfsdata-vg/logs-lv /mnt/logs
sudo mount /dev/nfsdata-vg/logs-lv /mnt/apps
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*sw5tCziYolqIQnRv2tXRLw.png)

Once mount is completed run sudo blkid to get the UUID of the mount part, open and paste the UUID in the fstab file.

```SHELL
sudo vi /etc/fstab
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*jS137f95mkIZYKEv9yG0YQ.png)

Reload daemon

```
sudo mount -a 
sudo systemctl daemon-reload
```

2. Install the NFS server, configure it to start on reboot, and make sure it is up and running
```SHELL
sudo yum -y update
sudo yum install nfs-utils -y
sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service
sudo systemctl status nfs-server.service
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*Z66pXmtwWT2RVr5Pbr138w.png)

__Note:__ If the output of the systemctl status nfs-server.service command shows that the NFS service is "active (exited)", it means that the service is running, but it is not currently doing anything. This is normal behavior for the NFS service when there are no active NFS client connections.

3. Export the mounts for webservers’ subnet cidr to connect as clients. In this project, we will keep things simple by installing all three webservers inside the same subnet, but in production, these will probably be kept in different subnets for a higher level of security.

To check the subnet cidr, open the properties of your EC2 instance on the AWS console and click on the “Network” tab, open the “Subnet ID” link in a new tab, and locate “IPv4 CIDR”

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*f3E9Z1o7wZoJkOoFOawd1g.png)

Set up permissions that will allow our Web servers to read, write, and execute files on NFS:

```SHELL
sudo chown -R nobody: /mnt/apps
sudo chown -R nobody: /mnt/logs
sudo chown -R nobody: /mnt/opt

sudo chmod -R 777 /mnt/apps
sudo chmod -R 777 /mnt/logs
sudo chmod -R 777 /mnt/opt

sudo systemctl restart nfs-server.service
```

![](https://miro.medium.com/v2/resize:fit:922/format:webp/1*q5BasVMM0irPHeib8RCGTg.png)

Configure access to NFS for clients within the same subnet (example of Subnet CIDR — Cidr ):

```SHELL
sudo vi /etc/exports

/mnt/apps 172.31.32.0/20(rw,sync,no_all_squash,no_root_squash)
/mnt/logs 172.31.32.0/20(rw,sync,no_all_squash,no_root_squash)
/mnt/opt 172.31.32.0/20(rw,sync,no_all_squash,no_root_squash)

Esc + :wq!

sudo exportfs -arv
```

![](https://miro.medium.com/v2/resize:fit:910/format:webp/1*nRohdFsaOiJ285MbxX_CHw.png)

4. Check which port is used by NFS and open it using Security Groups. In order for NFS server to be accessible from your client, you must also open the following ports: TCP 111, UDP 111 in addition to the NFS port.

```SHELL
rpcinfo -p | grep nfs
```

![](https://miro.medium.com/v2/resize:fit:910/format:webp/1*1ckMPRtCZDj9uOhSQNmfSg.png)

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*O1zYh7mKBID74QlvRlOP-A.png)

__Step 3: Configure the Database Server__

Based on the steps documented in Step 2: Install MySQL Server software on the MySQL Server and Client EC2 instances,. If you want to continue using RHEL for this step also see the steps to install and configure MySQL on RHEL 9

1. Launch a new EC2 instance and install MySQL server in this instance.
1. Create a database and name it “tooling”
1. Create a database user called “webaccess”
1. Grant permission to this “webaccess” user to have full permissions on the “tooling” database only from the subnet cidr.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*xZdJpElIeP8BeHjh0ZmJgA.png)

Test if you can access the db-server remotely with this webaccess user.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*gi02JHcoN4pR_ZEi8HZ8Yw.png)

__Step 4: Prepare the Web Servers__
In this step, we will be launching three web servers. We need to make sure that the web servers can serve the same content from shared storage solutions, which in this case are the MySQL database and NFS server.

For storing shared files that our Web Servers will use, we will utilize NFS and mount previously created logical Volume lv-apps to the folder where Apache stores files to be served to the users (/var/www).

This approach will make our Web Servers stateless, which means we will be able to add new ones or remove them whenever we need, and the integrity of the data (in the database and on NFS) will be preserved.

1. Launch a new EC2 instance with RHEL 8 Operating System
1. Install NFS client

```SHELL
sudo yum update -y
sudo yum install nfs-utils nfs4-acl-tools -y
```

3. Mount /var/www/ and target the NFS server’s export for apps

```SHELL
sudo mkdir /var/www
sudo mount -t nfs -o rw,nosuid 172.31.43.80:/mnt/apps /var/www
```

4. Verify that NFS was mounted successfully by running df -h. Make sure that the changes will persist on the Web Server after reboot by adding the below text to the /etc/fstab file and reload daemon:

```SHELL
<NFS-Server-Private-IP-Address>:/mnt/apps /var/www nfs defaults 0 0
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*TgRw4IFmTl6_ARXg15sVtg.png)

5. Install Remi’s repository, Apache and PHP

```SHELL
sudo yum install git -y

sudo yum install httpd -y

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y

sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

sudo dnf module reset php -y -y

sudo dnf module enable php:remi-7.4 -y

sudo dnf install php php-opcache php-gd php-curl php-mysqlnd -y -y

sudo systemctl start php-fpm

sudo systemctl enable php-fpm

sudo setsebool -P httpd_execmem 1
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*PhjqviKC5-1H1Dm5Z_ztkA.png)

__Repeat steps 1–5 for another 2 Web servers.__

6. Verify that Apache files and directories are available on the Web Server in /var/www and also on the NFS server in /mnt/apps. If you see the same files, it means NFS is mounted correctly. You can test this by creating a new file from one web server and check if it is accessible from other web servers.

![](https://miro.medium.com/v2/resize:fit:1274/format:webp/1*_mzJI-F6FhSYaHa0SCS-lQ.png)

![](https://miro.medium.com/v2/resize:fit:1130/format:webp/1*Ag7UCnyJksVwHhczWp3D0g.png)

7. Locate the log folder for Apache on the Web Server and mount it to NFS server’s export for logs. Repeat step 4 to make sure the mount point will persist after reboot.

```SHELL
sudo mount -t nfs -o rw,nosuid 172.31.43.80:/mnt/logs /var/log/httpd
```

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*7ilhH0xMv85zUyYc2741uQ.png)

__Step 5: Deploy a Tooling Application to our Web Server into a Shared NFS Folder__

1. Fork the tooling source code from [Darey.io Github Account](https://github.com/darey-io/tooling.git)
1. Deploy the tooling website’s code to the Webserver. Ensure that the html folder from the repository is deployed to /var/www/html

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*zYwspoOd6aEa8M_fWBW0aw.png)

3. Open TCP port 80 on the Web Server.

4. attempt to restart httpd service, it very likely that it will fail to start at this point stating that httpd service is unable to write to the log directory. If you encounter this error, check permissions to your /var/www/html folder to ensure that it is own by root.

* Disable SELinux by running sudo setenforce 0
To make this change permanent, open following config file sudo vi /etc/sysconfig/selinux and set SELINUX=disabledthen restart httpd.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*m6QhzkbJ00J2OUTTPQ5aEw.png)

Then restart httpd service by running:

```SHELL
sudo systemctl restart httpd
```
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*pA2XrTJik-E8yi-yTENHaw.png)

4. Update the website’s configuration file (/var/www/html/functions.php) to connect to the database. 

![](https://cdn-images-1.medium.com/max/1600/1*Zs0vRHGita2Hxhf24kgycQ.png)

5. Apply tooling-db.sql script to your database using this command

```SHELL
sudo mysql -h 172.31.47.152 -u webaccess -p -D tooling < tooling-db.sql
```

6. Create in MySQL a new admin user with the username: myuser and password: password:

* Change to the Devops_tooling directory
* Ensure MySQL client is installed (sudo yum install mysql)
* Connect to the mySQL server from the webserver using the 'webaccess' user created earlier and the private IP of the DB server.

```SHELL
sudo mysql -h 172.31.47.152 -u webaccess -p
```

![](https://cdn-images-1.medium.com/max/1600/1*yeb2F6x-TRUTxh1pymkCnQ.png)

Create in MySQL a new admin user by running the following SQL query

```SHELL
INSERT INTO tooling.users (id, username, password, email, user_type, status) VALUES (2, 'webaccess_user', '5f4dcc3b5aa765d61d8327deb882cf99', 'webaccess_user@mail.com', 'admin', 1);
```

6. Open the website in your browser http://3.9.23.206/index.php and make sure you can login into the website with myuser user.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*JbmXeZvKjJfXmpY3ib_1jw.png)

![](https://cdn-images-1.medium.com/max/1600/1*73g7IOiWj5C4AznYBRY1zA.png)

__Conclusion__

We have successfully implemented and deployed a DevOps tooling website solution that makes access to DevOps tools within the corporate infrastructure easily accessible. This comprises multiple web servers sharing a common database and also accessing the same files using Network File System (NFS) as shared file storage.

__Credit__

[Darey.io DevOps Master Class](darey.io)




