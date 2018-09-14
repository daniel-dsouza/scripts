#!/usr/bin/env bash

# check root status
if [ "$EUID" -e 0 ]
then
  echo "this script reads user variables, do not run as root"
  exit
fi

# install ROS packages
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/ros-latest.list 
wget -4 http://packages.ros.org/ros.key -O - | sudo apt-key add -

sudo apt update
sudo apt install -y ros-kinetic-desktop-full python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools python3-pip

# setup rosdep

sudo rosdep init
rosdep update
source /opt/ros/kinetic/setup.bash

# setup catkin

CATKIN_WS_PATH=${HOME}/catkin_ws
mkdir -p $CATKIN_WS_PATH/src
cd $CATKIN_WS_PATH
catkin init && catkin build
CATKIN_LIB=${CATKIN_WS_PATH}/devel/lib/python2.7/dist-packages
echo $CATKIN_LIB > catkin.pth

# Setup environment variables
cat >> ~/.bashrc << 'EOM'

# ROS variables
unset CMAKE_PREFIX_PATH
unset ROS_PACKAGE_PATH
source /opt/ros/kinetic/setup.bash

WORKSPACE=${HOME}/.bash_catkin.sh
if [ -f $WORKSPACE ]
then
  source $WORKSPACE
else
  echo "could not find $WORKSPACE, does devel exists?"
fi

unset PYTHONPATH  # move to user site packages
EOM

# setup rospy dependencies
# sudo apt install -y python3-pip
PYTHON2_USER_SITE=`python2 -m site --user-site`
PYTHON3_USER_SITE=`python3 -m site --user-site`
ROSPY_LIB="/opt/ros/kinetic/lib/python2.7/dist-packages"

mkdir -p $PYTHON2_USER_SITE  # sometimes the folder does not exist?
mkdir -p $PYTHON3_USER_SITE

echo $ROSPY_LIB > ${PYTHON2_USER_SITE}/ros.pth  # let python know about /opt/ros
echo $ROSPY_LIB > ${PYTHON3_USER_SITE}/ros.pth

ln -s ${CATKIN_WS_PATH}/catkin.pth ${PYTHON2_USER_SITE}/catkin.pth  # let python know about catkin pkgs
ln -s ${CATKIN_WS_PATH}/catkin.pth ${PYTHON3_USER_SITE}/catkin.pth

# setup workspace switching

mkdir -p ${HOME}/.local/bin
cat >> ${HOME}/.local/bin << 'EOM'
#!/usr/bin/env bash

WORKSPACE_PATH=$(find $HOME ! -path "*.local*" -type d -name ${1}_ws)

if [ -d "${WORKSPACE_PATH}" ]
then
  # links to workspace configuration
  if [ -f "${WORKSPACE_PATH}/devel/setup.bash" ]
  then
    echo "source ${WORKSPACE_PATH}/devel/setup.bash" > ${HOME}/.bash_catkin.sh
    source ${WORKSPACE_PATH}/devel/setup.bash
    
    # create python symlinks
    PYTHON_SITE=${WORKSPACE_PATH}/devel/lib/python2.7/dist-packages/
    echo $PYTHON_SITE > $(python2 -m site --user-site)/catkin.pth
    echo $PYTHON_SITE > $(python3 -m site --user-site)/catkin.pth
  else
    echo "Could not find ${WORKSPACE_PATH}/devel/setup.bash"
  fi
  
  echo "workspace set to ${WORKSPACE_PATH}"
else
  echo "Could not find ${WORKSPACE_PATH}"
fi
EOM

# setup systemd

sudo tee /usr/local/sbin/launch_roscore.sh &>/dev/null <<EOF
#!/bin/bash

if pgrep -x "roscore" > /dev/null
then
    echo "roscore is already running"
else
    source /opt/ros/kinetic/setup.bash
    /opt/ros/kinetic/bin/roscore
fi
EOF
sudo chmod +x /usr/local/sbin/launch_roscore.sh

sudo tee /etc/systemd/user/roscore.service &>/dev/null <<EOF
[Unit]
Description=Launch roscore

[Service]
ExecStart=/usr/local/sbin/launch_roscore.sh
Restart=on-abort
EOF

sudo loginctl enable-linger $USER
systemctl --user enable roscore.service
  
