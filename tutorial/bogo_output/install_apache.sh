#!/bin/bash
sudo apt-get -y update
sudo apt-get -y install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Deployed by Terraform</h1>" | sudo tee /var/www/html/index.html
