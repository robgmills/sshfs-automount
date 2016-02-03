main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  CHECK_OSXFUSE_INSTALLED=$(which sshfs | wc -l)
  if [ ! $CHECK_OSXFUSE_INSTALLED -ge 1 ]; then
    printf "${YELLOW}OSXFUSE is not installed!${NORMAL} Please install OSXFUSE first!\n"
    exit
  fi
  unset CHECK_OSXFUSE_INSTALLED

  CHECK_SSHFS_INSTALLED=$(which sshfs | wc -l)
  if [ ! $CHECK_SSHFS_INSTALLED -ge 1 ]; then
    printf "${YELLOW}SSHFS is not installed!${NORMAL} Please install SSHFS first!\n"
    exit
  fi
  unset CHECK_SSHFS_INSTALLED

#  printf "${BLUE}Looking for an existing sshfs-automount config...${NORMAL}\n"
#  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
#    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n";
#    mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh;
#  fi

  SSHFSAMDIR="/Library/Application Support/SSHFSAutomount"
  LAUNCHDDIR="/Library/LaunchDaemons"
  SSHFSAMGIT="https://raw.githubusercontent.com/robgmills/sshfs-automount/master"
  SSHFSAM="com.rgm.sshfs-automount"
  SSHFSAMPLIST="${SSHFSAM}.plist"
  SSHFSAMSCRIPT="${SSHFSAM}.sh"
  SSHFSPLISTURL="${SSHFSAMGIT}/${SSHFSAMPLIST}"
  SSHFSSCRIPTURL="${SSHFSAMGIT}/${SSHFSAMSCRIPT}"
  SSHFSAMPLISTFULL="${SSHFSAMDIR}/${SSHFSAMPLIST}"
  SSHFSAMSCRIPTFULL="${SSHFSAMDIR}/${SSHFSAMSCRIPT}"
  LAUNCHDFULL="${LAUNCHDDIR}/${SSHFSAMPLIST}"

  CHECK_SSHFSAM_INSTALLED=$(sudo launchctl list | grep -i com.rgm.sshfs-automount | wc -l)
  if [ $CHECK_SSHFSAM_INSTALLED -ge 1 ]; then
    printf "${BLUE}sshfs-automount is already installed and running...unloading${NORMAL}\n"
    sudo launchctl unload "${LAUNCHDFULL}"
  fi
  unset CHECK_SSHFSAM_INSTALLED

  printf "${BLUE}Using the SSH Automount launchd config${NORMAL}\n"
  
  sudo mkdir -p "${SSHFSAMDIR}"
  sudo curl -s -o "${SSHFSAMPLISTFULL}" "${SSHFSPLISTURL}"
  sudo curl -s -o "${SSHFSAMSCRIPTFULL}" "${SSHFSSCRIPTURL}"
  sudo chmod +x "${SSHFSAMSCRIPTFULL}"
  sudo rm "${LAUNCHDFULL}"
  sudo ln -s "${SSHFSAMPLISTFULL}" "${LAUNCHDFULL}" 
  sudo launchctl load "${LAUNCHDFULL}"

  AUTO_MASTER_CFG="/-                              auto_ssh          -nobrowse,nosuid"
  CHECK_AUTOSSHCFG_INSTALLED=$(grep "${AUTO_MASTER_CFG}" "/etc/auto_master" | wc -l)
  if [ $CHECK_AUTOSSHCFG_INSTALLED -ge 1 ]; then
    printf "${BLUE}"
    printf "auto_ssh was already configured in auto_master by previous install.\n"
    printf "Backing up /etc/auto_master -> /etc/auto_master.bak to update.\n"
    printf "${NORMAL}"
    sudo sed -i.bak '/\/-                              auto_ssh          -nobrowse,nosuid/d' /etc/auto_master
  fi
  unset CHECK_AUTOSSHCFG_INSTALLED

  echo "${AUTO_MASTER_CFG}" | sudo tee -a /etc/auto_master > /dev/null
  sudo touch /etc/auto_ssh

  printf "${GREEN}"
  echo 'SSHFS Automount....is now installed!'
  printf "${NORMAL}"
}

main 
