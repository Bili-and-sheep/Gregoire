# Internal HTTPS with HashiCorp Vault PKI for `*.dewey.lan`

This document describes how to:

- Use HashiCorp Vault as an internal Certificate Authority (CA)
- Issue a wildcard TLS certificate for `*.dewey.lan`
- Configure **Nginx** and **Apache** with that certificate
- Redirect HTTP (port 80) to HTTPS (port 443)

Assumptions:

- Vault is reachable at: **http://dewey.lan**
- You have the `vault` CLI and `jq` installed and configured
- You want a wildcard certificate: **`*.dewey.lan`**
- Web root for WordPress instance at `https://dewey.lan` is `/var/www/wordpress`
- PHP-FPM socket: `/run/php/php8.4-fpm.sock` (adjust if different)
- Certs are stored on web servers under `/etc/ssl/deweySSL_Vault/`

---

Ensure permissions are restricted on the private key:

```bash
sudo chown root:root /etc/ssl/deweySSL_Vault/dewey-wildcard.key
sudo chmod 600 /etc/ssl/deweySSL_Vault/dewey-wildcard.key
```

---




## 11. Manual Certificate Renewal (No Auto-Renew)

When the wildcard certificate is close to expiry and you want to renew **manually**, repeat:

```bash
vault write -format=json pki/issue/dewey-lan     common_name="*.dewey.lan"     alt_names="dewey.lan"     ttl="720h" > dewey-wildcard-NEW.json

cat dewey-wildcard-NEW.json | jq -r '.data.certificate'  > dewey-wildcard.crt
cat dewey-wildcard-NEW.json | jq -r '.data.private_key'  > dewey-wildcard.key
cat dewey-wildcard-NEW.json | jq -r '.data.issuing_ca'   > dewey-issuing-ca.crt
cat dewey-wildcard.crt dewey-issuing-ca.crt > dewey-wildcard-fullchain.crt
```

Then copy the updated files to:

```text
/etc/ssl/deweySSL_Vault/dewey-wildcard-fullchain.crt
/etc/ssl/deweySSL_Vault/dewey-wildcard.key
```

(on each web server), and reload Nginx/Apache:

```bash
# Nginx
sudo nginx -t
sudo systemctl reload nginx

# Apache
sudo apachectl configtest
sudo systemctl reload apache2
```

You now have a fully working internal Vault PKI-backed HTTPS setup for `*.dewey.lan`, with Nginx and Apache configured and HTTP traffic redirected to HTTPS.
