Azure Virtual WAN - POC
-----------------------

This **part 1** of a 5 part series of templates to deploy a glorified 3 tier
Azure network

Details
-------

This is a POC to demonstrate how to use Azure Virtual WAN, a Azure Virtual HUB
within region and P2S (Point to Site) from on-prem into Azure and other
**Spoke** virtual networks.

This POC leverages on Always On VPN with Windows 10 in order to connect securely
and remotely into Azure.

![A picture containing object, clock, drawing, meter Description automatically generated](media/28c6f1cb4e96fb1629e13f531bd8de50.png)

Always On VPN
-------------

**Always On VPN** is a Windows 10 feature that enables the active VPN profile to
connect automatically and remain connected.

**Always On VPN** connections include either of two types of tunnels:

**Device tunnel**: Connects to specified VPN servers before users sign in to the
device. Pre-sign-in connectivity scenarios and device management use a device
tunnel.

**User tunnel**: Connects only after users sign in to the device. By using user
tunnels, you can access organization resources through VPN servers

Test connectivity end-to-end from Windows 10 in the spoke vNet to on-prem.
