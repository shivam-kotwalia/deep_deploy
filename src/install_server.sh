#!/bin/bash
sudo -l >> /tmp/deep_deploy.logs
set -e
#Purpose: - Automate the Deployment Process for Deep Learning 
#Creation Date: - 12th March 2017
#Version:- 1.0

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

printf "${RED} ********************************************* ${NC}\n"
printf "     ${GREEN}Starting the Deep Deploy By SHiVAM${NC} "
echo "                                             "
echo "1. Start Script with Non Super User          "
echo "2. Script requires you to have root password "
echo "3. Python 2.x/3.x are supported              "
echo "4. Currently supports Linux esp Ubuntu 16.04  "
printf "${RED} ********************************************* ${NC}\n"

USER=$USER
SUDO='sudo'
OS=$(lsb_release -si)
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
VER=$(lsb_release -sr)
PYTHON=$(which python)
PIP=$(which pip)
LOCATION='$HOME/deep_deploy'
#homedir=$( getent passwd "$USER" | cut -d: -f6 )

echo "[INFO] Your Current OS is " $OS " and Version " $VER "and with" $ARCH " bit architecture.";
printf "\n";
echo ""

if (( $(bc <<< "$VER != 16.04") == 1)); then
    printf "${RED}[ERROR] Currently Deep Deploy supports Ubuntu 16.04 and greater. Kindly update your OS${NC}\n";
	exit 0
fi

if (( $EUID == 0 )); then
    printf "${RED}[ERROR] Please dont run the Script with Super User{NC}\n"
    exit 0
fi

if (( $(bc <<< "${#PYTHON} == 0") ==1)); then
    printf "${RED}[ERROR] Python not found !!. Please install python from https://python.org${NC}\n"
    exit 0
fi
 
printf "${GREEN}[INFO] Checking Dependencies - PIP, Virtualenv, Setuptools${NC}\n"

if (( $(bc <<< "${#PIP} == 0") ==1)); then
printf "${RED}[ERROR] PIP not found. Installing PIP${NC}\n"
$SUDO apt-get install -y python-pip >> /tmp/deep_deploy.logs
$SUDO pip install --upgrade pip >> /tmp/deep_deploy.logs
$SUDO pip install --upgrade setuptools >> /tmp/deep_deploy.logs
fi

$SUDO pip install --upgrade pip >> /tmp/deep_deploy.logs
$SUDO pip install --upgrade virtualenv >> /tmp/deep_deploy.logs

printf "${GREEN}[INFO] Creating Project ${NC}\n"
cd /home/$USER
mkdir deep_deploy
#$SUDO chmod 755 deep_deploy
#$SUDO chown -R $USER:$USER deep_deploy
cd deep_deploy

printf "${GREEN}[INFO] Creating Virtual Environment for Server${NC}\n"
mkdir venvs
virtualenv --system-site-packages venvs/main >> /tmp/deep_deploy.logs
source venvs/main/bin/activate
pip install --upgrade pip >> /tmp/deep_deploy.logs
pip install --upgrade setuptools >> /tmp/deep_deploy.logs
pip install --upgrade virtualenv >> /tmp/deep_deploy.logs
pip install --upgrade flask >> /tmp/deep_deploy.logs

printf "${GREEN}[INFO] Creating Skeleton ${NC}\n"
#mkdir -p deep_deploy/logs
#mkdir -p deep_deploy/static/js
#mkdir -p deep_deploy/static/css
#mkdir -p deep_deploy/template
#mkdir -p deep_deploy/view
#mkdir -p deep_deploy/task
mkdir -p ext_projects

printf "${GREEN}[INFO] Cloning the project from https://github.com/shivam-kotwalia/deep_deploy${NC}\n"
$SUDO apt-get install -y git >> /tmp/deep_deploy.logs
git clone https://github.com/shivam-kotwalia/deep_deploy >> /tmp/deep_deploy.logs
printf "${GREEN}[INFO] Installing Python Dependencies ${NC}\n";
pip install -r deep_deploy/requirements.txt >> /tmp/deep_deploy.logs

printf "${GREEN}[INFO] Installing Rabbit-mq Server ${NC}\n";
$SUDO apt-get install -y rabbitmq-server >> /tmp/deep_deploy.logs

printf "${GREEN}[INFO] Creating Symlink of the Project in VEnv ${NC}\n";
ln -s $HOME/deep_deploy/deep_deploy $HOME/deep_deploy/venvs/main/lib/python2.7
printf "${GREEN}[INFO] Creating Server Start Script ${NC}\n";
touch start_deep_deploy.sh
echo "#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
LOCATION='$HOME/deep_deploy'
source $LOCATION/venvs/main/bin/activate
cd $LOCATION/deep_deploy
printf "${GREEN}[INFO] Starting Deep Deploy Server ${NC}\n";
python -m webbrowser -t "http://127.0.0.1:5001" &
gunicorn -b 127.0.0.1:5001 wsgi:app >> $LOCATION/deep_deploy/logs/gunicorn.log
printf "${GREEN}[INFO] Running Deep Deploy at http://127.0.0.1:5001 ${NC}\n";
printf "${RED}[INFO] To Stop press Ctrl + C${NC}\n";
exit 0
" > start_deep_deploy.sh
printf "${GREEN}[INFO] Created a Start Script for Deep Deploy start_deep_deploy.py ${NC}\n";
chmod a+x start_deep_deploy.sh

printf "${GREEN}[INFO] Gathering all the logs and storing ${NC}"
mv "/tmp/deep_deploy.logs" "$LOCATION/deep_deploy/logs/deep_deploy_install.log"

./start_deep_deploy.sh

exit 0
