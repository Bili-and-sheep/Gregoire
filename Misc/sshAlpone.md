# Enable SSH on Alpine Linux :


```bash
apk add openssh
rc-update add sshd
/etc/init.d/sshd start
```

```bash
vi /etc/ssh/sshd_config 
```

Remove the `#` at the beginning of the line to uncomment it.

Port 22 is the default SSH port. You can change it if needed.

Change the line `#PermitRootLogin prohibit-password` to `PermitRootLogin yes` to allow root login via SSH.

```bash
rc-service sshd restart # Restart the SSH service to apply the changes
```

## Connect to a remote server using SSH :
```bash
ssh root@<IP_ADDRESS>
```


### Useful Links : 
https://wiki.alpinelinux.org/wiki/Setting_up_a_SSH_server

https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user
