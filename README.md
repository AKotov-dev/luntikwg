# LuntikWG - simple WireGuard connector
LuntikWG is a simplified version of the WireGuard-GUI. Loads any `*.conf` configuration and adapts it to VPN-Up/Down events to work correctly with VPN/DNS. There is an autostart on reboot.

The connection is raised immediately after downloading the `*.conf` file. The connection can be stopped or restarted at any time. VPN indication: yellow - waiting/lost, green - active. Tested and works with `network.service/net_applet` and `NetworkManager/nm-applet` in Mageia-8/9.

Note: Don't forget to open the iptables ports required for configurations. If you can't decide on the ports, temporarily disable iptables/iptables6 in the Mageia Control Center. Unlike OpenVPN, WireGuard is especially sensitive to IPv6. To use free WireGuard configurations, at least iproute2, resolv conf, iptables/iptables6, systemd, active ipv4/ipv6 forwarding and a kernel module are required.

Similar topic (Luntik - OpenVPN Connector): https://github.com/AKotov-dev/luntik 

![](https://github.com/AKotov-dev/luntikwg/blob/main/ScreenShot.png)
