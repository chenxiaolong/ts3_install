TS3 Install Script
==================
A small, simple, and lightweight script that will install a [TeamSpeak 3](https://www.teamspeak.com/teamspeak3) Server on any Debian-based Linux distribution. This process is entirely automated and requires very little user input.

**Do not use this script if you've already installed a TeamSpeak 3 Server!**  
This script is only for **new** installations.

####Process
1. Download the latest TS3 Server tar.gz.
2. Calcuate the MD5 and verify the integrity of the download.
3. Create `/usr/local/teamspeak3` and extract the files to that directory.
4. Install the server as a service through init.d.
5. Create a new `teamspeak` user and update permissions.
6. Update `iptables` to allow connections through TS.
7. Clean up any temporary files.

Website: http://k.yle.sh/  
Author: Kyle Colantonio <kyle10468@gmail.com>  
TeamSpeak: https://www.teamspeak.com/
