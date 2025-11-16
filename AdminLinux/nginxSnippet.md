# 1 Nginx Configuration for WordPress with Vault TLS Certs

Below is a complete Nginx config for a WordPress site at `oteria.lan`:

- HTTP (80) → redirects to HTTPS
- HTTPS (443) serves WordPress via PHP-FPM
- Uses the Vault-generated wildcard certificate

Make sure `php-fpm` (or a versioned service like `php8.4-fpm`) is installed and running.

------------------------------------------------------------------------

## 1.1 Nginx Site Config: `/etc/nginx/sites-available/oteria.lan`

```nginx
# HTTP: redirect all traffic to HTTPS
server {
    listen 80;
    server_name oteria.lan;

    return 301 https://$host$request_uri;
}

# HTTPS: WordPress + PHP-FPM
server {
    listen 443 ssl;
    server_name oteria.lan;

    root /var/www/wordpress;
    index index.php index.html;

    access_log /var/log/nginx/oteria.access.log;
    error_log  /var/log/nginx/oteria.error.log;

    ssl_certificate           /etc/ssl/oteriaSSL_Vault/oteria.certificate.crt;
    ssl_certificate_key       /etc/ssl/oteriaSSL_Vault/oteria.key;
    ssl_trusted_certificate   /etc/ssl/oteriaSSL_Vault/oteria.trusted_certificate.crt;

    # WordPress front controller
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # PHP handling via PHP-FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        # Adjust to your PHP-FPM socket if different, e.g.:
        # fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }

    # Deny access to .ht* files
    location ~ /\.ht {
        deny all;
    }

    # Favicon
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    # robots.txt
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
}
```

------------------------------------------------------------------------

## 1.2 Enable the Site and Reload Nginx

```bash
sudo ln -s /etc/nginx/sites-available/oteria.lan /etc/nginx/sites-enabled/oteria.lan
sudo nginx -t
sudo systemctl reload nginx
```

------------------------------------------------------------------------