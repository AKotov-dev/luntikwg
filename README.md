# LuntikWG - simple WireGuard connector
LuntikWG is a simplified version of the WireGuard-GUI. Loads any `*.conf` configuration and adapts it to VPN-Up/Down events to work correctly with VPN/DNS. There is an autostart on reboot.

The connection is raised immediately after downloading the `*.conf` file. The connection can be stopped or restarted at any time. VPN indication: yellow - waiting/lost, green - active. Tested and works with `network.service/net_applet` and `NetworkManager/nm-applet` in Mageia-8/9.

Note-1: Don't forget to open the iptables ports required for configurations. If you can't decide on the ports, temporarily disable `iptables/ip6tables` in the Mageia Control Center. Unlike OpenVPN, WireGuard is especially sensitive to IPv6. To use free WireGuard configurations, at least iproute2, resolvconf, iptables/ip6tables, systemd, active ipv4/ipv6 forwarding and a kernel module are required.  
Note-2: For tests, you need to clear all the rules to allow the main chains of iptables/ip6tables:
```
iptables -F; iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT
ip6tables -F; ip6tables -P INPUT ACCEPT; ip6tables -P FORWARD ACCEPT; ip6tables -P OUTPUT ACCEPT
```
  
Similar topic (Luntik - OpenVPN Connector): https://github.com/AKotov-dev/luntik 

![](https://github.com/AKotov-dev/luntikwg/blob/main/ScreenShot.png)
