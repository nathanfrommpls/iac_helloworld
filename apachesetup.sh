#!/bin/bash
sudo apt -y install apache2
echo "<html><body><h1>Welcome to $( hostname )</h1></body></html>" > /tmp/index.html
sudo cp -f /tmp/index.html /var/www/html/index.html
rm /tmp/index.html
