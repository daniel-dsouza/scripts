sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
wget -4 http://packages.ros.org/ros.key -O - | sudo apt-key add -

sudo apt update
sudo apt install -y ros-kinetic-desktop-full

sudo rosdep init
rosdep update

# Setup environment variables
USER_SITE=$(python -m site --user-site)
echo -e "\n# ROS Variables" >> ~/.bashrc
echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
echo 'PYTHONPATH="" #move to user site packages' >> ~/.bashrc
mkdir -p $USER_SITE
echo /opt/ros/kinetic/lib/python2.7/dist-packages > ${USER_SITE}/ros.pth


source /opt/ros/kinetic/setup.bash

# install better catkin
sudo apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools
