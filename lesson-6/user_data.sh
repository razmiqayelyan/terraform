#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

echo "<h1>Hello from $(hostname) 🌐</h1><br><h1>By Razo M.</h1>" | sudo tee /var/www/html/index.html > /dev/null
