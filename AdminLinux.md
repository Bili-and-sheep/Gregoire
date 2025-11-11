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
auto enp0s5
iface enp0s5 inet static
 address 192.168.2.236
 netmask 255.255.255.0
 gateway 192.168.2.254
 dns-nameservers 1.1.1.1 8.8.8.8
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



## TP3 - Install HTTPD / NGINX
```bash
sudo apt install apache2
```



