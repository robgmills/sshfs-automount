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

  ERRORS=0

  if ! [ -f /Library/Application\ Support/SSHFSAutomount/com.rgm.sshfs-automount.plist ]; then
    printf "${RED}Missing com.rgm.sshfs-automount.plist!${NORMAL}\n"
    ERRORS=$((ERRORS + 1))    
  fi

  if ! [ -f /Library/Application\ Support/SSHFSAutomount/com.rgm.sshfs-automount.sh ]; then
    printf "${RED}Missing com.rgm.sshfs-automount.sh!${NORMAL}\n"
    ERRORS=$((ERRORS + 1))
  fi

  if ! [ -L /Library/LaunchDaemons/com.rgm.sshfs-automount.plist ]; then
    printf "${RED}Missing com.rgm.sshfs-automount.plist symlink!${NORMAL}\n"
    ERRORS=$((ERRORS + 1))
  fi

  if ! [ -L /sbin/mount_sshfs ]; then
    printf "${RED}Missing mount_sshfs symlink!${NORMAL}\n"
    ERRORS=$((ERRORS + 1))
  fi

  AUTO_MASTER_CFG="/-                              auto_ssh          -nobrowse,nosuid"
  CHECK_AUTOSSHCFG_INSTALLED=$(grep "${AUTO_MASTER_CFG}" "/etc/auto_master" | wc -l)
  if ! [ $CHECK_AUTOSSHCFG_INSTALLED -ge 1 ]; then
    printf "${RED}Missing auto_ssh configuration in auto_master!${NORMAL}\n"
    ERRORS=$((ERRORS + 1))
  fi
  unset CHECK_AUTOSSHCFG_INSTALLED

  if ! [ -f /etc/auto_ssh ]; then
    printf "${RED}Missing auto_ssh file!${NORMAL}\n"
    ERRORS=$((ERRORS + 1))
  fi

  if [ $ERRORS -ge 1 ]; then
    printf "\n\n"
    printf "${RED}There were ${ERRORS} errors!${NORMAL}\n"
  else
    printf "${GREEN}Success!!${NORMAL}\n"
  fi
}

main 
