#!/bin/bash
apt update -y
apt install -y apache2 git
systemctl enable apache2
systemctl start apache2
cd /tmp
git clone https://github.com/razmiqayelyan/rm-portfolio.git
cp -r rm-portfolio/* /var/www/html/
chown -R www-data:www-data /var/www/html
systemctl restart apache2