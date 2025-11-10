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


### Bind9
```bash
apt install debian bind9
```

