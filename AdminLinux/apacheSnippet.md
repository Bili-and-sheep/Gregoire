# 1 Apache Configuration Example

## 1.1. Enable Required Apache Modules

```bash
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enmod rewrite
```

------------------------------------------------------------------------

## 1.2 Apache VHost for `next.oteria.lan` (HTTP → HTTPS Redirect)

```apache
# HTTP: redirect to HTTPS
<VirtualHost *:80>
    ServerName next.oteria.lan
    Redirect permanent / https://next.oteria.lan/
</VirtualHost>

# HTTPS: main site
<VirtualHost *:443>
    ServerName next.oteria.lan

    DocumentRoot /var/www/next

    SSLEngine on

    SSLCertificateFile      /etc/ssl/oteriaSSL_Vault/oteria-wildcard-fullchain.crt
    SSLCertificateKeyFile   /etc/ssl/oteriaSSL_Vault/oteria-wildcard.key
    SSLCACertificateFile    /etc/ssl/oteriaSSL_Vault/oteria-root-ca.crt

    <Directory /var/www/next>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog  ${APACHE_LOG_DIR}/next-error.log
    CustomLog ${APACHE_LOG_DIR}/next-access.log combined
</VirtualHost>
```

------------------------------------------------------------------------

### 1.3 Enable Site and Reload Apache

```bash
sudo a2ensite nextcloud.conf
sudo apachectl configtest
sudo systemctl reload apache2
```

------------------------------------------------------------------------