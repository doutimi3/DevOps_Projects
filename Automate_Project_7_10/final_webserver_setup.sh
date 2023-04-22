#!/usr/bin/bash

git clone https://github.com/doutimi3/devops_tooling.git
sudo cp -R ~/devops_tooling/html/. /var/www/html/
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo systemctl restart httpd
sudo yum install mysql -y
# sudo sed -i "s/'mysql.tooling.svc.cluster.local', 'admin', 'admin'/'{{ db_private_ip }}', '{{ db_username }}', '{{ db_password }}', '{{ db_database }}'/g" /var/www/html/functions.php
