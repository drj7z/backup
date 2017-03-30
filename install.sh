#!/bin/bash


##
## Install the program
##


##
## ChangeLog
##
## @author Dr. John X Zoidberg <drjxzoidberg@gmail.com>
## @version 1.1.0
## @date 2017-02-05
##  - made generic from grive.sh
##
##
## @author Dr. John X Zoidberg <drjxzoidberg@gmail.com>
## @version 1.0.0
## @date 2016-07-21
##  - first release
##


WD="$(dirname "$0")"


if [ ! -r "${WD}/install.settings" ] ; then
  echo "[EE] cannot read install.settings"
  exit 1
fi

. "${WD}/install.settings"

expand ()
{
  local s
  s="$1"
  while grep -q '\${' <<<"${s}" ; do
    eval s="${s}"
  done
  printf '%s' "${s}" 
}

removeQuotes ()
{
  sed -e 's/"//g' -e 's/\([[:space:]]\)/\\\(\1\)/g' <<<"$1"
}

##
## Install: user must be sudoer.
##
install ()
{
  cat "${WD}/message_install.txt"
  
  read -p 'Continue [y/N]?' a
  if [ "${a}" != "y" ] ; then
    return 1
  fi

  rm -fr "${WD}/build"
  mkdir -p "${WD}/build"

  for t in "${WD}"/*.template ; do 
    cp "${t}" "${WD}/build/${EXEC_PREFIX}$(basename "${t}" .template)"
  done

  IFS=$'\n'
  for p in $(grep -v ^# "${WD}/install.settings") ; do
    name="${p%%=*}"
    eval value=\"\$${name}\"
    exp_value="$(removeQuotes "$(expand "${value}")")"

    sed -i \
      -e 's:@@'"${name}"'@@:'"${value}"':g' \
      -e 's:@@exp\:'"${name}"'@@:'"${exp_value}"':g' \
      "${WD}/build"/*
  done

  sudo install -D "${WD}/build/${EXEC_PREFIX}backup.sh" ${PREFIX_BIN}/${EXEC_PREFIX}backup.sh || return 1
  sudo install -D -m 0644 "${WD}/build/${EXEC_PREFIX}backup.desktop" ${PREFIX_SHARE}/${GROUP}/${PRG_NAME}/${EXEC_PREFIX}backup.desktop || return 1
  sudo install -D -m 0644 "${WD}/build/${EXEC_PREFIX}conf" ${PREFIX_SHARE}/${GROUP}/${PRG_NAME}/${EXEC_PREFIX}conf || return 1
  sudo install -D -m 0644 "${WD}/build/${EXEC_PREFIX}logrotate.conf" ${PREFIX_SHARE}/${GROUP}/${PRG_NAME}/${EXEC_PREFIX}logrotate.conf || return 1
  sudo install -D -m 0644 "${WD}/backup.png" ${PREFIX_SHARE}/${GROUP}/${PRG_NAME}/${EXEC_PREFIX}backup.png || return 1
  sudo install -D "${WD}/unity-launcher.py" ${PREFIX_SHARE}/${GROUP}/${PRG_NAME}/${EXEC_PREFIX}unity-launcher.py || return 1
}


##
## MAIN
##

cmd="$1"

case $cmd in
  install)
    install
  ;;

  *)
     echo "usage: $(basename "$0") install"
  ;;
esac


