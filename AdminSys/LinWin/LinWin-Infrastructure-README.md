# LinWin Lab Infrastructure README (AD + DNS + Debian Join + HTTPS Apache + Logs + Security)

## 1. Lab Topology

-   **Domain:** LinWin.local\
-   **DC:** LinWin-WS2022-DC01 --- 192.168.122.10\
-   **Debian Client:** LinWin-Debian13-Client --- 192.168.122.20\
-   **Network:** 192.168.122.0/24\
-   **DNS for all hosts:** 192.168.122.10

------------------------------------------------------------------------

## 2. AD Deployment (Windows Server 2022)

### Install roles

    Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools

### Create new forest

    Install-ADDSForest -DomainName "LinWin.local" -DomainNetbiosName "LINWIN" -InstallDNS:$true

------------------------------------------------------------------------

## 3. Tiering Model OUs + Users

### OU structure

-   Tier0\
-   Tier1\
-   Tier2\
-   LinuxHosts\
-   ServiceAccounts

### Groups

-   Tier0-Admins\
-   Tier1-Admins\
-   Tier2-Admins

### Users

-   linwin-dcadmin (Tier0)\
-   linwin-srvadmin (Tier1)\
-   linwin-user1 (Tier2)

------------------------------------------------------------------------

## 4. DNS Forward + Reverse

### Forward zone required records

-   A: LinWin.local → 192.168.122.10\
-   A: LinWin-WS2022-DC01 → 192.168.122.10\
-   SRV: \_ldap.\_tcp\
-   SRV: \_kerberos.\_tcp

------------------------------------------------------------------------

## 5. Reverse Zone FIX (Final)

    Remove-DnsServerZone -Name "0.122.168.192.in-addr.arpa" -Force
    Add-DnsServerPrimaryZone -NetworkId "192.168.122.0" -ReplicationScope Domain
    Add-DnsServerResourceRecordPtr -Name "10" -ZoneName "0.122.168.192.in-addr.arpa" -PtrDomainName "LinWin-WS2022-DC01.LinWin.local."
    Resolve-DnsName 192.168.122.10 -Type PTR -Server 192.168.122.10

PTR must resolve correctly before Linux can join domain.

------------------------------------------------------------------------

## 6. Debian 13 -- Static IP + DNS Config

    auto enp1s0
    iface enp1s0 inet static
        address 192.168.122.20
        netmask 255.255.255.0
        gateway 192.168.122.1
        dns-nameservers 192.168.122.10
        dns-search LinWin.local

### /etc/resolv.conf

    nameserver 192.168.122.10
    search LinWin.local

### Test DNS

    ping LinWin.local
    dig LinWin.local
    dig -x 192.168.122.10
    dig _kerberos._tcp.LinWin.local SRV

### Install join tools

    apt install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin krb5-user

### Kerberos test

    kinit Administrator
    klist

### Join AD

    realm join LinWin.local --user=Administrator --computer-ou="OU=LinuxHosts,DC=LinWin,DC=local"

------------------------------------------------------------------------

## 7. Apache HTTPS Hardened Server

### Install Apache

    apt install apache2

### Enable HTTPS modules

    a2enmod ssl headers rewrite

### Generate certificate

    openssl req -x509 -nodes -days 365 -newkey rsa:4096   -keyout /etc/ssl/private/apache.key   -out /etc/ssl/certs/apache.crt

### Hardened HTTPS VHost

    <VirtualHost *:443>
        ServerName linwin-web.linwin.local

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache.crt
        SSLCertificateKeyFile /etc/ssl/private/apache.key

        Header always set X-Frame-Options "DENY"
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-XSS-Protection "1; mode=block"

        SSLProtocol all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
        SSLCipherSuite HIGH:!aNULL:!MD5
        SSLHonorCipherOrder on

        DocumentRoot /var/www/html
    </VirtualHost>

Enable:

    a2ensite secure.conf
    systemctl reload apache2

------------------------------------------------------------------------

## 8. Log Collector Stack (rsyslog + NXLog)

### On collector (Debian)

    /etc/rsyslog.d/collector.conf:

    module(load="imtcp")
    input(type="imtcp" port="514")

    module(load="imudp")
    input(type="imudp" port="514")

    template(name="RemoteLogs" type="string" string="/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log")
    *.* ?RemoteLogs

    systemctl restart rsyslog

### Windows NXLog sample

    <Input in>
      Module im_msvistalog
      Query <QueryList><Query Id="0"><Select Path="Security">*</Select></Query></QueryList>
    </Input>

    <Output out>
      Module om_udp
      Host 192.168.122.30
      Port 514
    </Output>

    <Route r>
      Path in => out
    </Route>

------------------------------------------------------------------------

## 9. Security Baselines

### AD

-   Enforce SMB signing\
-   Disable NTLMv1\
-   Implement LAPS\
-   Tiered admin model

### Windows

-   Credential Guard\
-   Full audit policies\
-   Firewall enabled

### Linux

-   Disable root SSH\
-   Enforce SSH keys\
-   Enable auditd\
-   Fail2ban

### Apache

-   TLS 1.2+ only\
-   Strong ciphers\
-   Security headers

------------------------------------------------------------------------

## 10. Troubleshooting Commands

### Windows

    Resolve-DnsName 192.168.122.10 -Type PTR
    dcdiag /v
    repadmin /replsummary

### Linux

    dig -x 192.168.122.10
    realm list
    systemctl status sssd
    journalctl -u sssd
