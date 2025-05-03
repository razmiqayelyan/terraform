#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

echo "<h1>Hello from $(hostname) 🌐</h1><br><h3>By Razo M.</h3>" | sudo tee /var/www/html/index.html > /dev/null
