echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/ros-latest.list 
wget -4 http://packages.ros.org/ros.key -O - | sudo apt-key add -

sudo apt update
sudo apt install -y ros-kinetic-desktop-full

sudo rosdep init
rosdep update

source /opt/ros/kinetic/setup.bash

# setup catkin
CATKIN_WS_PATH=${HOME}/catkin_ws
sudo apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools

mkdir -p $CATKIN_WS_PATH/src
cd $CATKIN_WS_PATH
catkin init && catkin build
CATKIN_LIB=${CATKIN_WS_PATH}/devel/lib/python2.7/dist-packages
echo $CATKIN_LIB > catkin.pth

# Setup environment variables
cat >> ~/.bashrc << EOM
# ROS variables
source /opt/ros/kinetic/setup.bash
source ${CATKIN_WS_PATH}/devel/setup.bash
PYTHONPATH="" # move to user site packages
EOM

# setup rospy dependencies
sudo apt install -y python3-pip
PYTHON2_USER_SITE=`python2 -m site --user-site`
PYTHON3_USER_SITE=`python3 -m site --user-site`
ROSPY_LIB="/opt/ros/kinetic/lib/python2.7/dist-packages"

mkdir -p $PYTHON2_USER_SITE  # sometimes the folder does not exist?
mkdir -p $PYTHON3_USER_SITE

echo $ROSPY_LIB > ${PYTHON2_USER_SITE}/ros.pth  # let python know about /opt/ros
echo $ROSPY_LIB > ${PYTHON3_USER_SITE}/ros.pth

ln -s ${CATKIN_WS_PATH}/catkin.pth ${PYTHON2_USER_SITE}/catkin.pth  # let python know about catkin pkgs
ln -s ${CATKIN_WS_PATH}/catkin.pth ${PYTHON3_USER_SITE}/catkin.pth
