if [[ -f .ash-init-successful ]]
then
  exit
fi

echo "Setting up your session ..."
sudo wifi.sh

for i in $(seq 1 10)
do
  ping -c 1 1.1.1.1 &> /dev/null
  if [[ $? -eq 0 ]]
  then
    break 
  fi
  sleep 1
done
  
tce-load -i /mnt/mmcblk0p2/tce/optional/FBTerm.tcz &> /dev/null
# tce-audit updatedeps
# tce-update

sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono/
sudo mv .SETUP/JetBrains*.ttf /usr/share/fonts/truetype/jetbrains-mono/
fc-cache -f

rm -rf ~/.SETUP

touch .ash-init-successful
fbterm
