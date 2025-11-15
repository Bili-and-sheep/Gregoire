#Hostname Modification

```bash
sudo hostnamectl set-hostname NameOfMachine
```

```bash
vim /etc/hosts
```

Vim will say “readonly“ to force the write
```
w !sudo tee %
```

```bash
hostnamectl
```