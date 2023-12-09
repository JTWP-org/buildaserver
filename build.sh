#!/bin/bash

# Ensure necessary directories exist
mkdir -p "/home/steam/pavlovserver${1}/Pavlov/Saved/Config"
mkdir -p "/home/steam/cfg"

# Install required packages
sudo apt update && sudo apt install -y gdb curl lib32gcc-s1 libc++-dev unzip

# SteamCMD update
/home/steam/Steam/steamcmd.sh +login anonymous +force_install_dir "/home/steam/pavlovserver${1}" +app_update 622970 -beta default +exit

# Create empty files with content
echo -n > "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/mods.txt"
echo -n > "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/whitelist.txt"
echo -n > "/home/steam/cfg/${1}.ini"


timeout 5s /home/steam/pavlovserver${1}/PavlovServer.sh
rm "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/LinuxServer/Game.ini"

sleep 3s

echo "[Script/Pavlov.DedicatedServer]
bEnabled=true
ServerName=\"JTWP.org ${1}\"
MaxPlayers=24
bSecured=true
bCustomServer=true 
bVerboseLogging=true
bCompetitive=false #This only works for SND
bWhitelist=false 
RefreshListTime=120 
LimitedAmmoType=0 
TickRate=90
TimeLimit=60
#Password=0000 
#BalanceTableURL=\"vankruptgames/BalancingTable/main\"
MapRotation=(MapId=\"UGC1758245796\", GameMode=\"GUN\")
MapRotation=(MapId=\"datacenter\", GameMode=\"SND\")
MapRotation=(MapId=\"sand\", GameMode=\"DM\")" > "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/LinuxServer/Game.ini"


# Firewall rules
sudo ufw allow "9${1}00"
sudo ufw allow 1${1}000
sudo ufw allow 1${1}400



# Generate password and update RconSettings.txt
password=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9!@#$%^&*()-_+=' | head -c 48)
final_password="${password}${1}"
echo -e "password=${final_password}\nPort=9${1}00" > "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/RconSettings.txt"

# Create systemd service file


echo "[Unit]
Description=Pavlov VR dedicated server ${1}

[Service]
Type=simple
WorkingDirectory=/home/steam/pavlovserver${1}
ExecStart=/home/steam/pavlovserver${1}/PavlovServer.sh -PORT=9${1}00

RestartSec=1
Restart=always
User=steam
Group=steam

[Install]
WantedBy=multi-user.target" > "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/${1}.service" 
sudo mv "/home/steam/pavlovserver${1}/Pavlov/Saved/Config/${1}.service" "/etc/systemd/system/pavlovserver${1}.service"

# Start and enable the systemd service
sudo systemctl start pavlovserver${1}
sudo systemctl enable pavlovserver${1}

# Create log directories and commands
mkdir -p "/home/steam/logs/pavlovserver${1}/Pavlov/Saved/Logs/"
echo "cp /home/steam/pavlovserver${1}/Pavlov/Saved/Logs/*.log /home/steam/logs/pavlovserver${1}/Pavlov/Saved/Logs/" > "/home/steam/cfg/logcmd.txt"
mkdir -p "/home/steam/logs/pavlovserver${1}/Pavlov/Saved/Stats/"
echo "cp /home/steam/pavlovserver${1}/Pavlov/Saved/Stats/*.log /home/steam/logs/pavlovserver${1}/Pavlov/Saved/Stats/" > "/home/steam/cfg/logcmd.txt"
