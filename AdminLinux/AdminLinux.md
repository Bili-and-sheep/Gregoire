# Admin Linux

**OS :** macOS\
**Architecture :** ARM\
**Hyperviseur :** VMware Fusion

``` bash
sudo apt-get purge nano -y 
sudo apt-get install vim
```

------------------------------------------------------------------------

# 1. TP1 - Disk

-   [x] Partition the disk with an EFI part (USE as : EFI sys Part;
    Bootable Flag : off)\
-   [x] Create an LV\
-   [x] Create a Volume Group (VG)\
-   [x] Create 4 partitions in ext4
    -   [x] `/var/tmp`\
    -   [x] `/var/log`\
    -   [x] `/tmp`\
    -   [x] `/`

------------------------------------------------------------------------

# 2. TP2 - Serveur DNS

## 2.1 Dup VM TP1

## 2.2 Set Static IP

### Show IP

``` bash
ip r
```

### Edit network interface

``` bash
sudo vim /etc/network/interfaces
```

    # The primary network interface
    allow-hotplug ens160
    iface ens160 inet static
     address 192.168.58.128
     netmask 255.255.255.0
     gateway 192.168.58.2
     dns-nameserver 192.168.58.131 1.1.1.1

``` bash
sudo systemctl restart networking
sudo systemctl status networking
```

------------------------------------------------------------------------

## 2.3 Bind9

### 2.3.1 Install Bind9

``` bash
sudo apt-get install bind9
```

### 2.3.2 Go to bind cache dir

``` bash
cd /var/cache/bind/
```
[Documentation Bind 9](https://bind9.readthedocs.io/en/v9.18.14/chapter3.html)


### 2.3.3 Create forward zone file

``` bash
sudo vim /var/cache/bind/oteria.lan
```

Contents:

    $TTL 7d
    @         IN      SOA   oteria.lan. admin.oteria.lan. (
                                    2025111001 ; serial number
                                    12h        ; refresh
                                    15m        ; update retry
                                    3w         ; expiry
                                    2h         ; minimum
                                    )

    @               IN      NS      dns1.oteria.lan.
    dns1            IN      A       192.168.58.131
    oteria.lan.     IN      A       192.168.58.131

To add an entry:

``` bash
your.entry. IN A xxx.xxx.xxx.xxx
```

### 2.3.4 Create reverse zone file

``` bash
cp oteria.lan oteria.lan.rev
sudo vim /var/cache/bind/oteria.lan.rev
```

    $TTL 7d
    @         IN      SOA   oteria.lan. admin.oteria.lan. (
                                    2025111001
                                    12h
                                    15m
                                    3w
                                    2h
                                    )

    @       IN      NS      dns1.oteria.lan.
    131     IN      PTR     dns1
    141     IN      PTR     oteria.lan.

### 2.3.5 Add zones to Bind config

``` bash
sudo vim /etc/bind/named.conf.local
```

    zone "oteria.lan" {
        type master;
        file "/var/cache/bind/oteria.lan";
    };

    zone "58.168.192.in-addr.arpa" {
        type master;
        file "/var/cache/bind/oteria.lan.rev";
    };

### 2.3.6 Set resolv.conf manually
In etc/resolv.conf change the nameserver xxx.xxx.xxx.xxx by your dns server ip (we don't have a dhcp server so you need to do this to everyone of your VM)

``` bash
sudo vim /etc/resolv.conf
```

------------------------------------------------------------------------

## 2.4 Restart service

``` bash
sudo systemctl restart named
sudo systemctl status named
```

## 2.5 Test DNS

``` bash
dig -x oteria.lan
nslookup oteria.lan
```

------------------------------------------------------------------------

# 3. TP3 --- Web

## 3.1 Install MariaDB

Guide :\
https://www.digitalocean.com/community/tutorials/how-to-allow-remote-access-to-mysql

### 3.1.1 Install

``` bash
sudo apt-get install mariadb-server && systemctl enable mariadb.service
```
``` bash
sudo mariadb-secure-installation
```

### 3.1.2 Allow external access

⚠️ **Never do this in a prod env** ⚠️

``` sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### 3.1.3 Edit bind-address

``` bash
sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf
```

Set:

    bind-address = 0.0.0.0

### 3.1.4 Create user

``` sql
CREATE USER 'elPatron'@'%' IDENTIFIED BY 'PWDofElPatron00!';
```
### 3.1.4 Grant privileges

``` sql
GRANT SELECT, INSERT, UPDATE, DELETE ON mydb.* TO 'elPatron'@'%';
FLUSH PRIVILEGES;
```

## 3.2 DNS entry

You can add a DNS entry for your db:

``` bash
db.oteria.lan. IN A 192.168.52.203
```

------------------------------------------------------------------------

## 3.2 Install Apache2 / Nginx

``` bash
sudo apt install apache2 php-cli
sudo apt install php-fpm php-mysql mariadb-server nginx unzip php-xml
```

------------------------------------------------------------------------

# 4. Install WordPress (NGINX)

## 4. Requirements
``` bash
sudo apt-get install php8.4 php8.4-cli php8.4-fpm php8.4-mysql php8.4-opcache php8.4-mbstring php8.4-xml php8.4-gd php8.4-curl
```

## 4.1 Create Wordpress DB

``` bash
mariadb -h ip.of.your.db.server -u user -p
CREATE USER 'wpuser'@'%' IDENTIFIED BY 'wppwd';
CREATE DATABASE IF NOT EXISTS wordpress_db;
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
```

------------------------------------------------------------------------

## 4.2 Nginx Config

``` bash
cd /etc/nginx/sites-available
```

Show php version:

``` bash
ls /var/run/php
```

Create config:

``` bash
sudo vim /etc/nginx/sites-available/wordpress.conf
```

``` nginx
server {
    listen 80;
    root /var/www/wordpress/;
    index index.php index.html;
    server_name oteria.lan;

    access_log /var/log/nginx/oteria.access.log;
    error_log /var/log/nginx/oteria.error.log;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht { deny all; }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
}
```

Enable:

``` bash
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/wordpress.conf .
sudo nginx -t
sudo systemctl reload nginx
```

------------------------------------------------------------------------

## 4.3 Install WordPress

``` bash
sudo mkdir -p /var/www/wordpress/
```
``` bash
cd /var/www/wordpress/
```
``` bash
sudo wget https://wordpress.org/latest.tar.gz
```
``` bash
sudo tar -zxvf latest.tar.gz
```
``` bash
sudo mv wordpress/* .
```
``` bash
sudo rm -rf wordpress
```
``` bash
cd /var/www/html/wordpress/
```
``` bash
sudo chown -R www-data:www-data *
sudo chmod -R 755 *
```

Configure:

``` bash
cd /var/www/wordpress/
sudo mv wp-config-sample.php wp-config.php
sudo vim wp-config.php
```

------------------------------------------------------------------------

## 4.4 Finish wordpress installation via web interface

Go to http://oteria.lan and follow the instructions.
------------------------------------------------------------------------
------------------------------------------------------------------------


# 5. Install NextCloud (Apache2)

Guide :\
https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html

## 5.1 Requirements

``` bash
sudo apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql \
php-curl php-mbstring php-intl php-gmp php-xml php-imagick php-zip
```

------------------------------------------------------------------------

## 5.2 Download Nextcloud

``` bash
cd /var/www
sudo mkdir nextTemp
cd nextTemp
```

### 5.2.1 Download

``` bash
sudo wget https://download.nextcloud.com/server/releases/latest.tar.bz
```

### 5.2.2 Extract

``` bash
sudo tar -xjvf latest.tar.bz2
```

### 5.2.3 Move folder and delete temp folder

``` bash
sudo cp -r nextcloud /var/www
cd /var/www
sudo rm -rf /var/nextTemp
```

------------------------------------------------------------------------

## 5.3 Permissions

``` bash
cd nextcloud/
sudo chown -R www-data: /var/www/nextcloud/
sudo chown -R user:user /var/www/nextcloud
```

## 5.4 Create data folder

``` bash
sudo mkdir /var/www/nextcloud/data
```

------------------------------------------------------------------------

## 5.5 Apache2 config

``` bash
sudo vim /etc/apache2/sites-available/nextcloud.conf
```

    <VirtualHost *:80>
      DocumentRoot /var/www/nextcloud/
      ServerName next.oteria.lan

      <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
          Dav off
        </IfModule>
      </Directory>
    </VirtualHost>

### 5.5.1 Enable your site and disable default site

``` bash
sudo a2ensite nextcloud.conf
sudo a2dissite 000-default.conf
```

### 5.5.2 Restart

``` bash
systemctl restart apache2
```

------------------------------------------------------------------------

## 5.6 DNS entry

``` bash
next.oteria.lan. IN A 192.168.52.234
```

------------------------------------------------------------------------

## 5.7 Create Database and User for NextCloud 

``` sql
CREATE USER 'nextuser'@'%' IDENTIFIED BY 'nextpwd';
```
``` sql
CREATE DATABASE IF NOT EXISTS nextcloud_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```
``` sql
GRANT ALL PRIVILEGES ON nextcloud_db.* TO 'nextuser'@'%';
```
``` sql
FLUSH PRIVILEGES;
```

------------------------------------------------------------------------

## 5.8 Finish NextCloud installation via web interface

Go to http://next.oteria.lan and follow the instructions.
------------------------------------------------------------------------
------------------------------------------------------------------------


# 6. Securize  Apache2 / NGINX with Hashicorp Vault







# 6. Database Users (Notes)

    mariaDB user
    root / root

    wpuser / wppwd

    nextuser / nextpwd

WordPress user:

    narvalo
    4nRJT)8WNBK8t*k9Wq

NextCloud user:

    userNextCloud
    berangere
    4nRJT)8WNBK8t*k9Wq

Test user:

    riz / riz
