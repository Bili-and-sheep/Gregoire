# Admin Linux
## TP1 - Disk

## TP2 - Serveur DNS

### Dup VM TP1
### Set Static IP

***SHOW IP***
```bash
ip r
```

**VIM NETWORK INTERFACE**

```
sudo vim /etc/network/interfaces
```

```
# The primary network interface
allow-hotplug ens160
iface ens160 inet static
 address 192.168.58.128
 netmask 255.255.255.0
 gateway 192.168.58.2
 dns-nameserver 192.168.58.131 1.1.1.1
 ``` 

 ```bash
 sudo systemctl restart networking
 sudo systemctl status networking
```


#### Bind9
```bash
apt install debian bind9
```

```bash
cd /var/cache/bind/
```
https://bind9.readthedocs.io/en/v9.18.14/chapter3.html

```bash
sudo vim /var/cache/bind/oteria.lan
```

```bash
$TTL 7d
@         IN      SOA   oteria.lan. admin.oteria.lan. (
                                2025111001 ; serial number
                                12h        ; refresh
                                15m        ; update retry
                                3w         ; expiry
                                2h         ; minimum
                                )

@			IN      NS 	dns1.oteria.lan.
dns1		IN      A 	192.168.58.131
oteria.lan.	IN 		A 	192.168.58.131
```

To add an entry (we will see wordpress later) at the end of your bind config write
```bash
your.entry. IN      A   xxx.xxx.xxx.xxx
```

cp oteria.lan oteria.lan.rev
sudo vim /var/cache/bind/oteria.lan.rev
```bash
$TTL 7d
@         IN      SOA   oteria.lan. admin.oteria.lan. (
                                2025111001 ; serial number
                                12h        ; refresh
                                15m        ; update retry
                                3w         ; expiry
                                2h         ; minimum
                                )

@		IN      NS 	dns1.oteria.lan.
131		IN      PTR dns1
141		IN 		PTR oteria.lan.
```

sudo vim /etc/bind/named.conf.local
```bash
zone "oteria.lan" {
	type master;
	file "/var/cache/bind/oteria.lan";
};

zone "58.168.192.in-addr.arpa" {
	type master;
	file "/var/cache/bind/oteria.lan.rev";
};
```

In etc/resolv.conf change the nameserver xxx.xxx.xxx.xxx by your dns server ip
```bash
sudo vim /etc/resolv.conf
```

#### Restart named service
```
sudo systemctl restart named
sudo systemctl status named
```

#### Test your DNS
```bash
dig -x oteria.lan
```
```bash
nslookup oteria.lan
```



## TP3 - Web

### Install MariaDB
https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04
```bash
sudo apt-get install mariadb-server
```
```bash
sudo systemctl enable mariadb.service
```
```bash
sudo mariadb-secure-installation
```



After You setup your account please change the acces with % (meaning that you can connect from everywere and not only localost)
⚠️ DON'T DO IT ON A PROD SERVER ⚠️
```bash
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
```

To allow access to mariadb from everywhere edit

```bash
sudo cat /etc/mysql/mariadb.conf.d/50-server.cnf
```

and at 
bind-address
change the = value to 0.0.0.0



### Install Apache2 / NGINX

```bash
sudo apt install apache2 php-cli
sudo apt install php-fpm php-mysql mariadb-server nginx unzip php-xml
```


### Install Wordpress (NGINX)

#### First Create your Data1base for wordpress
***Connect to your db***
```bash
mariadb -h ip.of.your.db.server -u user -p
```
```bash
CREATE DATABASE wordpress_db
```

***The best pratice is to create a user how is only responsible of the wordpress db***

```bash
GRANT ALL ON wordpress_db.* TO 'wpuser'@'localhost' IDENTIFIED BY 'Passw0rd!' WITH GRANT OPTION;
```

```bash
FLUSH PRIVILEGES;
```

#### Nginx Config


```bash
cd /etc/nginx/sites-available
```

***Show php path***

```bash
ls /var/run/php
```

```bash
vim wordpress.conf
```
***fastcgi_pass unix:/run/php/php8.4-fpm.sock; replace php8.4 by your actuall php version***

```bash
server {
            listen 80;
            root /var/www/wordpress/public_html;
            index index.php index.html;
            server_name SUBDOMAIN.DOMAIN.TLD;

        access_log /var/log/nginx/SUBDOMAIN.access.log;
            error_log /var/log/nginx/SUBDOMAIN.error.log;

            location / {
                         try_files $uri $uri/ =404;
            }

            location ~ \.php$ {
                         include snippets/fastcgi-php.conf;
                         fastcgi_pass unix:/run/php/php8.4-fpm.sock;
            }
            
            location ~ /\.ht {
                         deny all;
            }

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

```bash
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/wordpress.conf .
```
***Chek your conf nginx***
```bash
sudo nginx -t
```
```bash
systemctl reload nginx
```

#### Install Wordpress

```bash
cd /var/www/wordpress/public_html
```
```bash
sudo wget https://wordpress.org/latest.tar.gz
```
```bash
sudo tar -zxvf latest.tar.gz
```
```bash
sudo mv wordpress/* .
```
```bash
sudo rm -rf wordpress
```
```bash
cd /var/www/html/wordpress/public_html
```
```bash
chown -R www-data:www-data *
```
```bash
chmod -R 755 *
```

***You can already setup the db connection before starting the Wordpress intal***
```bash
cd /var/www//wordpress/public_html
```
```bash
sudo mv wp-config-sample.php wp-config.php
```
```bash
sudo vim wp-config.php
```


### Install NextCloud (Apache2/Httpd)











```bash
mariaDB user
root
root

wpuser
wppwd

nextuser
nextpwd

userWordPress

narvalo
4nRJT)8WNBK8t*k9Wq


userNextCloud
berangere
4nRJT)8WNBK8t*k9Wq
```









