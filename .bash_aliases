#!/usr/bin/env bash

shopt -s expand_aliases

alias beep='echo -ne "\007"'
alias clipboard='xclip -sel clip'
alias cpufreq='watch -n.1 "grep \"^[c]pu MHz\" /proc/cpuinfo"'
alias prune-local='git branch -vv | grep "origin/.*: gone]" | awk "{print $1}" | xargs git branch -d'
alias get_pycharm_path='find /home/daniel/.local/share/JetBrains/Toolbox/apps -name "pycharm.sh" | sort -r | sed q'
alias godoc_server='godoc -http=":6060"'
alias reload_udev='sudo udevadm control --reload-rules && sudo udevadm trigger'
alias restart_synergy='kill -9 $(pidof synergyc) && /usr/bin/synergyc --daemon --name doraemon 192.168.1.100:24800'

# BEGIN kitty

alias darken='kitty +kitten themes "Dark Pastel"'
alias brighten='kitty +kitten themes "Solarized Light"'

# END kitty

verifysha256() {
  echo "${1} ${2}" | sha256sum --check
}

git() {
  if [[ $@ == "pull" ]]
  then
    command git pull --prune
  else
    command git "$@"
  fi
}

# quicktar tgz faster.
# Usage: quicktar output.tgz folder1 folder 2 ...
function quicktar () {
  TAR=$1
  shift
  tar -I pigz -cf "${TAR}" "$@"
}

function send_map () {
  # USAGE: send_map map_dir target_host
  BYTES=$(du -bs ${1} | cut -f 1)
  tar cf - ${1} ${3} | pv -s ${BYTES} | ssh ${2} "cd ~/.ranger && tar xf -"
}

# ROS aliases
alias con='rosrun swri_console swri_console &'
alias viz='rosrun mapviz mapviz &'
alias rcore='systemctl --user restart roscore.service'
alias rdepi='rosdep install . --from-paths -i --os=ubuntu:$(cat /etc/os-release | sed -En 's/UBUNTU_CODENAME=//p') -y -r'
alias rmsg='rosmsg'
alias rnode='rosnode'
alias rsrv='rosservice'
alias rtopic='rostopic'
alias sim_time='rosparam set use_sim_time true'
alias pull_workspace='wstool up -j$(nproc) --continue-on-error'
alias chws='source workspace'
alias purge_param="rosparam list | xargs -I % sh -c 'rosparam delete % -v'"

# CLion

clion_cmake_options () {
  xmlstarlet ed -L -a "/project/component[@name='CMakeSettings']/configurations/configuration[@PROFILE_NAME='Debug']" -t attr -n GENERATION_OPTIONS -v "-DCATKIN_DEVEL_PREFIX:PATH=${WORKSPACE_SETUP%'/setup.bash'}" workspace.xml
  xmlstarlet ed -L -a "/project/component[@name='CMakeSettings']/configurations/configuration[@PROFILE_NAME='Debug']" -t attr -n GENERATION_DIR -v "${WORKSPACE_SETUP%'/devel/setup.bash'}/build" workspace.xml 
}

alias get_clion_path='find /home/daniel/.local/share/JetBrains/Toolbox/apps -name "clion.sh" | sort -r | sed q'

ros_clion () {
  JETBRAINS_APP=clion.sh
  RUN_PATH=`find /home/daniel/.local/share/JetBrains/Toolbox/apps -name "$JETBRAINS_APP" | sort -r | sed q`

  #bash -i -c "${RUN_PATH}" %f
  nohup "${RUN_PATH}" &>/dev/null &
}

ros_pycharm() {
  JETBRAINS_APP=pycharm.sh
  RUN_PATH=`find /home/daniel/.local/share/JetBrains/Toolbox/apps -name "$JETBRAINS_APP" | sort -r | sed q`

  #bash -i -c "${RUN_PATH}" %f
  nohup "${RUN_PATH}" &>/dev/null &
}

function rosnetwork () {
  # usage: rosnetwork INTERFACE [ROS_MASTER_SUFFIX [ROS_MASTER_PORT]]
  INTERFACE=$1
  MASTER_SUFFIX=${2:-100}
  MASTER_PORT=${3:-11311}

  # figure out the ROS_IP
  IP_REGEX="([0-9]{1,3}.){3}[0-9]{1,3}"
  INTERFACE_IP=`ip addr show $INTERFACE | egrep -o "inet $IP_REGEX" | cut -c 6-`

  if [[ $INTERFACE_IP = "" ]]
  then
    echo "could not find interface ${INTERFACE}"
  fi

  MASTER_IP="`echo ${INTERFACE_IP} | cut -f 1-3 -d '.'`.${MASTER_SUFFIX}"

  # attempt to resolve hostname (TODO)

  # figure out the ROS_MASTER_URI
  if [[ $INTERFACE_IP != "" ]] && $(nc -z -w1 ${MASTER_IP} ${MASTER_PORT})
  then
    # set to rosmaster
    export ROS_IP="${INTERFACE_IP}"
    export ROS_MASTER_URI="http://${MASTER_IP}:${MASTER_PORT}"
  else
    # could not ping ROS master, set localhost instead
    export ROS_IP="127.0.0.1"
    export ROS_MASTER_URI="http://localhost:${MASTER_PORT}"
    return 1
  fi
}

complete -W "$(ls /sys/class/net)" rosnetwork

# function ros_network () {
#   IP_REGEX="([0-9]{1,3}.){3}[0-9]{1,3}"
#   WIRED_IP=`ip addr show eno1 | egrep -o "inet $IP_REGEX" | cut -c 6-`
#   TUN_IP=`ip addr show tun0 2>/dev/null | egrep -o "inet $IP_REGEX" | cut -c 6-`
#   
#   if [[ $WIRED_IP != "" ]]
#   then
#     INTERFACE_IP=$WIRED_IP
#     MASTER_IP="`echo ${INTERFACE_IP} | cut -f 1-3 -d '.'`.100"
#   elif [[ $TUN_IP != "" ]]
#   then
#     INTERFACE_IP=$TUN_IP
#     MASTER_IP="`echo ${INTERFACE_IP} | cut -f 1-3 -d '.'`.1"
#   fi
# 
#   if [[ $INTERFACE_IP != "" ]] && nc -z -w1 $MASTER_IP 11311
#   then
#     export ROS_IP="${INTERFACE_IP}"
#     export ROS_MASTER_URI="http://${MASTER_IP}:11311"
#   else
#     export ROS_IP="127.0.0.1"
#     export ROS_MASTER_URI="http://127.0.0.1:11311"
#   fi
# }

function workspace () {
  FOLDER="${1}_ws"
  
  if [[ ${1} == "none" ]]
  then
    WORKSPACE_PATH="/opt/ros/${ROS_DISTRO}"
    FOLDER=""
  else
    # look for packages in devel or install space
    [[ -z "${2}" ]] && PACKAGES="devel" || PACKAGES="${2}"
  
    # search for the root folder of the catkin workspace
    # WORKSPACE_PATH="$(find $HOME -maxdepth 2 ! -path "*.local*" ! -name "*.dbus*" -type d -name ${FOLDER})/${PACKAGES}"
    WORKSPACE_PATH="$(find $HOME/ros -maxdepth 2 -type d -name .dbus -prune -o -name .gvfs -prune -o -name .local -prune -o -name ${FOLDER} -print)/${PACKAGES}"
    FOLDER="${FOLDER}/${PACKAGES}"
  
    # go to source directory
    [ -d "${WORKSPACE_PATH}" ] && cd "${WORKSPACE_PATH}/../src"
  fi
  
  
  if [ -d "${WORKSPACE_PATH}" ]
  then
    # links to workspace configuration
    if [ -f "${WORKSPACE_PATH}/setup.bash" ]
    then
      if [ ! -f "${HOME}/.bash_catkin" ]
      then
        # create blank ~/.bash_catkin file

        cat > ${HOME}/.bash_catkin << 'EOM'
#!/usr/bin/env bash

WORKSPACE_SETUP=/home/daniel/ros/network_attack_ws/devel/setup.bash
export ROS_WORKSPACE=network_attack_ws/devel
export ROS_WORKSPACE_INCLUDE_PATH=/home/daniel/ros/network_attack_ws/devel/include

unset CMAKE_PREFIX_PATH
unset ROS_PACKAGE_PATH

# source /opt/ros/kinetic/setup.bash
source $WORKSPACE_SETUP
source $WORKSPACE_SETUP

unset PYTHONPATH
EOM
      fi

      sed -i 's|^WORKSPACE_SETUP.*|WORKSPACE_SETUP='${WORKSPACE_PATH}'/setup.bash|g' ${HOME}/.bash_catkin
      sed -i 's|ROS_WORKSPACE=.*|ROS_WORKSPACE='${FOLDER}'|g' ${HOME}/.bash_catkin
      sed -i 's|ROS_WORKSPACE_INCLUDE_PATH=.*|ROS_WORKSPACE_INCLUDE_PATH='${WORKSPACE_PATH}'/include|g' ${HOME}/.bash_catkin
      source ${HOME}/.bash_catkin
   
      PY2_USER_SITE="$(python2 -m site --user-site)"
      PY3_USER_SITE="$(python3 -m site --user-site)"

      # create user site if it doesn't exist.
      if [ ! -d $PY2_USER_SITE ]
      then
        mkdir -p $PY2_USER_SITE
        echo /opt/ros/${ROS_DISTRO}/lib/python2.7/dist-packages/ > ${PY2_USER_SITE}/ros.pth
      fi

      if [ ! -d $PY3_USER_SITE ]
      then
        mkdir -p $PY3_USER_SITE
        echo /opt/ros/${ROS_DISTRO}/lib/python2.7/dist-packages/ > ${PY3_USER_SITE}/ros.pth
      fi

      # create python symlinks
      PYTHON_SITE=${WORKSPACE_PATH}/lib/python2.7/dist-packages/
      echo $PYTHON_SITE > $(python2 -m site --user-site)/catkin.pth
      echo $PYTHON_SITE > $(python3 -m site --user-site)/catkin.pth
    else  
      echo "Could not find ${WORKSPACE_PATH}/devel/setup.bash"
    fi    
    
    echo "workspace set to ${WORKSPACE_PATH}"
    echo "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
  else  
    echo "Could not find workspace ${FOLDER} under ${HOME}"
  fi
}

function path_add () {
  # append a path to $PATH, without creating duplicate entries.
  if [[ ${PATH} != *"${1}"* ]]
  then
    export PATH=${PATH}:${1}
  fi
}


function color () {
  # sets text foreground color
  # usage color color_no bold
  if [[ "${2}" == "bold" ]]
  then
    BOLD="$(tput bold)"
  fi

  echo "$(tput sgr0)"${BOLD}"$(tput setaf $1 $2)"
}

function parse_cmake_path {
  # pretty print catkin's current CMAKE_PREFIX_PATH, as defined in ~/.bash_catkin, or print none
  # ROS_WORKSPACE=$(echo $CMAKE_PREFIX_PATH | sed -n 's|.*\/\(.*.\)\/devel.*|\1|p')
  if [[ -z "${ROS_WORKSPACE// }" ]]
  then
    echo "none"
  else
    echo "${ROS_WORKSPACE}"
  fi
}

function parse_git_branch() {
  # generate a blurb about the current git status
  # USAGE parse_git_branch

  function parse_git_dirty () {
    # generate characters depending on branch status
    status=`git status 2>&1 | tee`
    dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
    ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    if [ "${renamed}" == "0" ]; then
      bits=">${bits}"
    fi
    if [ "${ahead}" == "0" ]; then
      bits="*${bits}"
    fi
    if [ "${newfile}" == "0" ]; then
      bits="+${bits}"
    fi
    if [ "${untracked}" == "0" ]; then
      bits="?${bits}"
    fi
    if [ "${deleted}" == "0" ]; then
      bits="x${bits}"
    fi
    if [ "${dirty}" == "0" ]; then
      bits="!${bits}"
    fi
    if [ ! "${bits}" == "" ]; then
      echo " ${bits}"
    else
      echo ""
    fi
  }

  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    echo "[${BRANCH}${STAT}]"
  else
    echo ""
  fi
}

function export_ps1 () {
  # export the PS1 variable, called from ~/.bashrc
  # USAGE export_ps1
  export PS1="\$(color 3)\A \$(color 6 bold)\$(echo \$ROS_IP):\$(parse_cmake_path) \$(color 2 bold)\u \$(color 7)at \$(color 2 bold)\h\$(color 7 ) in \$(color 6 bold)\w \$(color 1)\$(parse_git_branch)\$(color 7 9)\n \\$ \[\$(tput sgr0)\]" 
}

alias play_mp3='vlc --intf dummy'

function bringup_vcan () {
  sudo modprobe vcan
  sudo ip link add dev vcan0 type vcan && sudo ip link set up vcan0
}

