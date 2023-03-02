#!/bin/bash

apt update && apt install apache2 -y

echo "Hello from Terraform !!!" > /var/www/html/index.html

systemctl restart apache2