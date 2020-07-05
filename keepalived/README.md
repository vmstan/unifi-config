# Load Balancing w/ Keepalived

## Background

What is better than a Pi-hole blocking ads via DNS on your network? That's right, Two Pi-hole! There are a couple of ways to accomplish this. You can setup two independant Pi-hole and link their databases together with Gravity Sync, and then hand out both DNS records in your DHCP settings.

The advantage here is there's no additional software or network configuration required (aside from Gravity Sync) -- the downside is you have two places where your clients are logging lookup requests to. One way to get around this is by using keepalived and present a single virtual IP address of the two Pi-hole to clients in an active/passive mode. The two nodes will check their own status, and each other, and hand the VIP around if there are issues.

## Installation

Requirements
- Pi-hole installed on two systems.
- Designate one Pi-hole as primary, and one as secondary.
- Install Gravity Sync on the secondary.
- New static IP address to use a VIP.
- DHCP server managed by your router or other device.

### Both Systems

On both Pi-hole, install Keepalive.

```
sudo apt install keepalived
```

On both Pi-hole, create a file called `/etc/scripts/chk_ftl` and mark it as executable. This script will monitor the status of the FTLDNS service, and Unbound, on the local instance. (If you're not using Unbound then comment everything in that section out.)

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

### Primary

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

### Secondary

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

## Testing

Restart keepalived on both systems to pickup the configuration changes.

```
sudo service keepalived restart
```

Check the output of `ip a` on both Pi-holes to verify that the primary system has the new VIP assigned to it. Test the transfer of the VIP between hosts by stopping the keepalived service on the primary. After a couple of seconds it should appear on the secondary. Restart the service to bring it back. Now stop the FTLDNS or Unbound service on the primary, again it should transfer after a few seconds. Restart the service to bring it back.

## Examples

Refer to `unipi-keepalived.conf` and `tripi-keepalived.conf` for examples of a production primary/secondary pair to compare your own configuration files to.

