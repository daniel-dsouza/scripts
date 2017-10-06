sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
wget -4 http://packages.ros.org/ros.key -O - | sudo apt-key add -

sudo apt update
sudo apt install -y ros-kinetic-desktop-full

sudo rosdep init
rosdep update

echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source /opt/ros/kinetic/setup.bash

sudo apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools
