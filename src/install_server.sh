#!/bin/bash
#Purpose: - Automate the Deployment Process for Deep Learning 
#Creation Date: - 12th March 2017
#Version:- 1.0

RED='\033[0;31m'
NC='\033[0m'

echo "*********************************************"
printf "     ${RED}Starting the Deep Deploy By SHiVAM ${NC}      "
echo "                                             "
echo "1. Start Script with Non Super User          "
echo "2. Script requires you to have root password "
echo "3. Python 2.x/3.x are supported              "
echo "4. Currently supports Unix esp Ubuntu 16.04  "
echo "*********************************************"
echo ""


USER=$USER
SUDO='sudo'
OS=$(lsb_release -si)
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
VER=$(lsb_release -sr)
PYTHON=$(which python)
PIP=$(which pip)
LOCATION=$(/opt/deep_deploy)

echo "Your Current OS is "$OS" and Version " $VER "and with" $ARCH "bit architecture."; 

if (( $(bc <<< "$VER != 16.04") == 1)); then
echo "Currently Deep Deploy supports Ubuntu 16.04 and greater. Kindly update your OS";
	exit 0
fi

if (( $EUID == 0 )); then
    echo "Please dont run the Script with Super User"
    exit 0
fi

if (( $(bc <<< "${#PYTHON} == 0") ==1)); then
echo "Python not found !!. Please install python from https://python.org"
exit 0
fi
 
echo "Checking Dependencies - PIP |  Virtualenv"
if (( $(bc <<< "${#PIP} == 0") ==1)); then
echo "PIP not found. Installing PIP"
$SUDO apt-get install python-pip
$SUDO pip install --upgrade setuptools
fi
pip install --upgrade pip
pip install --upgrade virtualenv

echo "Creating Project"
cd /opt
$SUDO mkdir deep_deploy
$SUDO chmod 755 deep_deploy
$SUDO chown -R $USER:$USER deep_deploy
cd deep_deploy

echo "Creating Virtual Environment for Server"
mkdir venvs
virtualenv --system-site-packages venvs/main
source venvs/main/bin/activate
#pip install --upgrade pip
#pip install --upgrade setuptools
#pip install --upgrade virtualenv
#pip install --upgrade flask

echo "Creating Skeleton"
#mkdir -p deep_deploy/logs
#mkdir -p deep_deploy/static/js
#mkdir -p deep_deploy/static/css
#mkdir -p deep_deploy/template
#mkdir -p deep_deploy/view
#mkdir -p deep_deploy/task
mkdir -p ext_projects

echo "Cloning the project"
$SUDO apt-get install git
git clone https://github.com/shivam-kotwalia/deep_deploy
echo "Installing Pyhton Dependencies"
pip install -r deep_deploy/requirements.txt

echo "Rabbit-mq Server"
$SUDO apt-get install rabbitmq-server

echo "Creating Server Start Script"
touch start_deep_deploy.sh
echo "#!/bin/bash
source /opt/deep_deploy/venvs/main/bin/activate
ln -s /opt/deep_deploy/deep_deploy /opt/deep_deploy/venvs/main/lib/python2.7
cd /opt/deep_deploy/deep_deploy
gunicorn -b 127.0.0.1:5001 wsgi:app > /opt/deep_deploy/deep_deploy/logs/gunicorn.log &
" > start_deep_deploy.sh
echo "Created a Start Script for Deep Deploy start_deep_deploy.py"
chmod a+x start_deep_deploy.sh
./start_deep_deploy.sh

echo "Running Deep Deploy at http://127.0.0.1:5001"
echo "To Stop press Ctrl + C"
python -m webbrowser -t "http://127.0.0.1:5001"

exit 0
