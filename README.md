# E-Project
Networking development on PC - 
This poweshell script is to discover IPv4 addresses of end devices connected to same LAN

How to run:

. Download the file script ScanLAN.ps1. to any directory
. Open PowerShell as Administrator.
. Navigate to the directory where this file is downloaded
. Run cmdlet:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\ScanLAN.ps1


 And if it doesn't work or not running, 
 perhaps for your system security reason, or mistaken
 
 Please HELP, do not hesitate to suggest changes 
     ------------------------------------------------------

The upcoming project related to it will function same as nmap with additional features.

Aim:
To discover connected device on LAN, 
To detect if device is connected or disconnected, usefull for troubleshoot

The objective of the program is to build friendly GUI interface displaying all devices connected to corporate LAN,
easy to identify new conncction or lost connection of each end device.
Additionally, I would love to feature it as customizable naming entry (for example: Printer HR dept - User: Mr Xavier - Ip x.x.x.x - OS/firmware version - Status On/Off - last time ON)

