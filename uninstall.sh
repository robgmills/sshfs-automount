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

  CHECK_AUTOSSHFSCFG_RUNNING=$(launchctl list | grep "${SSHFSAM}" | wc -l)
  if [ $CHECK_AUTOSSHFSCFG_RUNNING -ge 1 ]; then 
    sudo launchctl unload "${LAUNCHDFULL}"
  fi

  if [ -d "${SSHFSAMDIR}" ]; then
    sudo rm -r "${SSHFSAMDIR}"
  fi

  if [ -L "${LAUNCHDFULL}" ]; then
    sudo rm "${LAUNCHDFULL}"
  fi

  AUTO_MASTER_CFG="/-                              auto_ssh          -nobrowse,nosuid"
  CHECK_AUTOSSHCFG_INSTALLED=$(grep "${AUTO_MASTER_CFG}" "/etc/auto_master" | wc -l)
  if [ $CHECK_AUTOSSHCFG_INSTALLED -ge 1 ]; then
    sudo sed -i '' '/\/-                              auto_ssh          -nobrowse,nosuid/d' /etc/auto_master
    sudo rm /etc/auto_ssh
  fi
  unset CHECK_AUTOSSHCFG_INSTALLED

  printf "${GREEN}"
  echo 'SSHFS Automount....is now uninstalled. Goodbye!'
  printf "${NORMAL}"
}

main 
