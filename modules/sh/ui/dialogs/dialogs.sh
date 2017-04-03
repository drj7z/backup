##
## @module sh/ui/dialogs
## @version 1.0.0
## @date 2017-03-31
##


## 
## ChangeLog
##
## @author Dr. John X. Zoidberg <drjxzoidberg@gmail.com>
## @version 0.1.0
## @date 2017-03-31
##  - first release.
##
## 



uiDialogsInit ()
{
  if [ -z "$DISPLAY" ] ; then
    return 1
  fi
  ## else
  if ! which zenity &>/dev/null ; then
    return 1
  fi

  local res

  local title
  title="$1"


  exec 7> >(zenity --notification --title="${title}" --listen)
  res=$?
  UI_DIALOGS_PID=$!
  if [ ${res} -ne 0 ] ; then
    UI_DIALOGS_PID=
    return 1
  else
    return 0
  fi
}


uiDialogsClose ()
{
  if [ -n "${UI_DIALOGS_PID}" ] ; then
    exec 7>&-
    kill ${UI_DIALOGS_PID}
  fi
}


uiNotify ()
{
  local icon
  icon="${2:-info}"
  if [ -n "${UI_DIALOGS_PID}" ] ; then
    echo "icon:${icon}" >&7
    echo "message:$1" >&7
  else
    printf "%s\n" "$1"
  fi
}


uiMessage ()
{
  if [ -n "$DISPLAY" ] ; then
    zenity "--$1" "$2" "$3" "$4" "$5"
  else
    printf "%s: %s :: %s\n" "$3" "$1" "$5"
  fi
}

uiQuestion ()
{
  local title
  title="$1"
  shift

  if [ -n "$DISPLAY" ] ; then
    zenity --question --title="${title}" --text="$1"
  else
    local ans
    while [ -z "${ans}" ] ; do
      read -p "${title}: $1 [Y/n]" ans
      if [ -z "${ans}" ] ; then
        return 0
      elif [ "${ans}" = "Y" -o "${ans}" = "y" ] ; then
        return 0
      elif [ "${ans}" = "N" -o "${ans}" = "n" ] ; then
        return 1
      else
        ans=""
      fi
    done
  fi
}