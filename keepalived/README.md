# Load Balancing w/ Keepalived

## Both Systems

On both Pi-hole, create a file called `/etc/scripts/chk_ftl` and mark it as executable.

```
sudo mkdir /etc/scripts
sudo vim /etc/scripts/chk_ftl
sudo chmod +x /etc/scripts/chk_ftl
```

When you edit the chk_ftl file, paste in the following:

```bash
#!/bin/sh

STATUS='0'

# check for pihole service status
FTLCHECK=$(ps ax | grep -v grep | grep 'pihole-FTL')
if [ "$FTLCHECK" != "" ]
then
	STATUS=$((STATUS+0))
else
	STATUS=$((STATUS+1))
fi

# check for unbound service status
UNBCHECK=$(ps ax | grep -v grep | grep 'unbound -d')
if [ "$UNBCHECK" != "" ]
then
	STATUS=$((STATUS+0))
else
	STATUS=$((STATUS+1))
fi

# compare results
if [ "$STATUS" = "0" ]
then
    exit 0
else
    exit 1
fi
```

## Primary

On the primary Pi-hole, create a file called `/etc/keepalived/keepalived.conf` with the following contents. Anything inside `**` (including the astericks themselves) needs to be replaced with your values.

```
global_defs {
router_id **PRIMARYHOSTNAME**
script_user root
enable_script_security
}

vrrp_script chk_ftl {
script "/etc/scripts/chk_ftl"
interval 1
weight -150
}

vrrp_instance PIHOLE {
state MASTER
interface eth0
virtual_router_id 55
priority 200
advert_int 1
vrrp_unicast_bind **PRIMARYHOSTIP**
vrrp_unicast_peer **SECONDARYHOSTIP**

authentication {
auth_type PASS
auth_pass **SHAREDPASSWORD**
}

virtual_ipaddress {
**SHAREDVIP**/24 dev **INTERFACENAME**
}

track_script {
chk_ftl
}

}
```

## Secondary

On the secondary Pi-hole, create a file called `/etc/keepalived/keepalived.conf` with the following contents. Anything inside `**` (including the astericks themselves) needs to be replaced with your values.

```
global_defs {
router_id **SECONDARYHOSTNAME**
script_user root
enable_script_security
}

vrrp_script chk_ftl {
script "/etc/scripts/chk_ftl"
interval 1
weight -150
}

vrrp_instance PIHOLE {
state BACKUP
interface eth0
virtual_router_id 55
priority 100
advert_int 1
vrrp_unicast_bind **SECONDARYHOSTIP**
vrrp_unicast_peer **PRIMARYHOSTIP**

authentication {
auth_type PASS
auth_pass **SHAREDPASSWORD**
}

virtual_ipaddress {
**SHAREDVIP**/24 dev **INTERFACENAME**
}

track_script {
chk_ftl
}

}
```

