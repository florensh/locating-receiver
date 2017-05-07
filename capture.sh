#!/usr/bin/env bash
#
# Boilerplate for creating a simple bash script with some basic strictness
# checks, help features, easy debug printing.
#
# Usage:
#   bash-simple-plus argument
#
# Depends on:
#  list
#  of
#  programs
#  expected
#  in
#  environment
#
# Bash Boilerplate: https://github.com/alphabetum/bash-boilerplate
#
# Copyright (c) 2015 William Melody • hi@williammelody.com

# Notes #######################################################################

# Extensive descriptions are included for easy reference.
#
# Explicitness and clarity are generally preferable, especially since bash can
# be difficult to read. This leads to noisier, longer code, but should be
# easier to maintain. As a result, some general design preferences:
#
# - Use leading underscores on internal variable and function names in order
#   to avoid name collisions. For unintentionally global variables defined
#   without `local`, such as those defined outside of a function or
#   automatically through a `for` loop, prefix with double underscores.
# - Always use braces when referencing variables, preferring `${NAME}` instead
#   of `$NAME`. Braces are only required for variable references in some cases,
#   but the cognitive overhead involved in keeping track of which cases require
#   braces can be reduced by simply always using them.
# - Prefer `printf` over `echo`. For more information, see:
#   http://unix.stackexchange.com/a/65819
# - Prefer `$_explicit_variable_name` over names like `$var`.
# - Use the `#!/usr/bin/env bash` shebang in order to run the preferred
#   Bash version rather than hard-coding a `bash` executable path.
# - Prefer splitting statements across multiple lines rather than writing
#   one-liners.
# - Group related code into sections with large, easily scannable headers.
# - Describe behavior in comments as much as possible, assuming the reader is
#   a programmer familiar with the shell, but not necessarily experienced
#   writing shell scripts.

###############################################################################
# Strict Mode
###############################################################################

# Treat unset variables and parameters other than the special parameters ‘@’ or
# ‘*’ as an error when performing parameter expansion. An 'unbound variable'
# error message will be written to the standard error, and a non-interactive
# shell will exit.
#
# This requires using parameter expansion to test for unset variables.
#
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
#
# The two approaches that are probably the most appropriate are:
#
# ${parameter:-word}
#   If parameter is unset or null, the expansion of word is substituted.
#   Otherwise, the value of parameter is substituted. In other words, "word"
#   acts as a default value when the value of "$parameter" is blank. If "word"
#   is not present, then the default is blank (essentially an empty string).
#
# ${parameter:?word}
#   If parameter is null or unset, the expansion of word (or a message to that
#   effect if word is not present) is written to the standard error and the
#   shell, if it is not interactive, exits. Otherwise, the value of parameter
#   is substituted.
#
# Examples
# ========
#
# Arrays:
#
#   ${some_array[@]:-}              # blank default value
#   ${some_array[*]:-}              # blank default value
#   ${some_array[0]:-}              # blank default value
#   ${some_array[0]:-default_value} # default value: the string 'default_value'
#
# Positional variables:
#
#   ${1:-alternative} # default value: the string 'alternative'
#   ${2:-}            # blank default value
#
# With an error message:
#
#   ${1:?'error message'}  # exit with 'error message' if variable is unbound
#
# Short form: set -u
set -o nounset

# Exit immediately if a pipeline returns non-zero.
#
# NOTE: this has issues. When using read -rd '' with a heredoc, the exit
# status is non-zero, even though there isn't an error, and this setting
# then causes the script to exit. read -rd '' is synonymous to read -d $'\0',
# which means read until it finds a NUL byte, but it reaches the EOF (end of
# heredoc) without finding one and exits with a 1 status. Therefore, when
# reading from heredocs with set -e, there are three potential solutions:
#
# Solution 1. set +e / set -e again:
#
# set +e
# read -rd '' variable <<EOF
# EOF
# set -e
#
# Solution 2. <<EOF || true:
#
# read -rd '' variable <<EOF || true
# EOF
#
# Solution 3. Don't use set -e or set -o errexit at all.
#
# More information:
#
# https://www.mail-archive.com/bug-bash@gnu.org/msg12170.html
#
# Short form: set -e
set -o errexit

# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail

# Set IFS to just newline and tab at the start
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
#
# $DEFAULT_IFS and $SAFER_IFS
#
# $DEFAULT_IFS contains the default $IFS value in case it's needed, such as
# when expanding an array and you want to separate elements by spaces.
# $SAFER_IFS contains the preferred settings for the program, and setting it
# separately makes it easier to switch between the two if needed.
#
# Supress ShellCheck unused variable warning:
# shellcheck disable=SC2034
DEFAULT_IFS="${IFS}"
SAFER_IFS=$'\n\t'
IFS="${SAFER_IFS}"

###############################################################################
# Environment
###############################################################################

# $_ME
#
# Set to the program's basename.
_ME=$(basename "${0}")

###############################################################################
# Debug
###############################################################################

# _debug()
#
# Usage:
#   _debug printf "Debug info. Variable: %s\n" "$0"
#
# A simple function for executing a specified command if the `$_USE_DEBUG`
# variable has been set. The command is expected to print a message and
# should typically be either `echo`, `printf`, or `cat`.
__DEBUG_COUNTER=0
_debug() {
  if [[ "${_USE_DEBUG:-"0"}" -eq 1 ]]
  then
    __DEBUG_COUNTER=$((__DEBUG_COUNTER+1))
    # Prefix debug message with "bug (U+1F41B)"
    printf "🐛  %s " "${__DEBUG_COUNTER}"
    "${@}"
    printf "――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――\n"
  fi
}
# debug()
#
# Usage:
#   debug "Debug info. Variable: $0"
#
# Print the specified message if the `$_USE_DEBUG` variable has been set.
#
# This is a shortcut for the _debug() function that simply echos the message.
debug() {
  _debug echo "${@}"
}

###############################################################################
# Die
###############################################################################

# _die()
#
# Usage:
#   _die printf "Error message. Variable: %s\n" "$0"
#
# A simple function for exiting with an error after executing the specified
# command. The command is expected to print a message and should typically
# be either `echo`, `printf`, or `cat`.
_die() {
  # Prefix die message with "cross mark (U+274C)", often displayed as a red x.
  printf "❌  "
  "${@}" 1>&2
  exit 1
}
# die()
#
# Usage:
#   die "Error message. Variable: $0"
#
# Exit with an error and print the specified message.
#
# This is a shortcut for the _die() function that simply echos the message.
die() {
  _die echo "${@}"
}

###############################################################################
# Help
###############################################################################

# _print_help()
#
# Usage:
#   _print_help
#
# Print the program help information.
_print_help() {
  cat <<HEREDOC
Receiver for sending wifi probe requests to a backend.

Usage:
  ${_ME} [--options] [<arguments>]
  ${_ME} -h | --help

Options:
  -h --help     Display this help information.
  -b --backend  Backend mode
HEREDOC
}

###############################################################################
# Options
###############################################################################

# Steps:
#
# 1. set expected short options in `optstring` at beginning of the "Normalize
#    Options" section,
# 2. parse options in while loop in the "Parse Options" section.

# Normalize Options ###########################################################

# Source:
#   https://github.com/e36freak/templates/blob/master/options

# The first loop, even though it uses 'optstring', will NOT check if an
# option that takes a required argument has the argument provided. That must
# be done within the second loop and case statement, yourself. Its purpose
# is solely to determine that -oARG is split into -o ARG, and not -o -A -R -G.

# Set short options -----------------------------------------------------------

# option string, for short options.
#
# Very much like getopts, expected short options should be appended to the
# string here. Any option followed by a ':' takes a required argument.
#
# In this example, `-x` and `-h` are regular short options, while `o` is
# assumed to have an argument and will be split if joined with the string,
# meaning `-oARG` would be split to `-o ARG`.
optstring=xo:h

# Normalize -------------------------------------------------------------------

# iterate over options, breaking -ab into -a -b and --foo=bar into --foo bar
# also turns -- into --endopts to avoid issues with things like '-o-', the '-'
# should not indicate the end of options, but be an invalid option (or the
# argument to the option, such as wget -qO-)
unset options
# while the number of arguments is greater than 0
while ((${#}))
do
  case ${1} in
    # if option is of type -ab
    -[!-]?*)
      # loop over each character starting with the second
      for ((i=1; i<${#1}; i++))
      do
        # extract 1 character from position 'i'
        c=${1:i:1}
        # add current char to options
        options+=("-${c}")

        # if option takes a required argument, and it's not the last char
        # make the rest of the string its argument
        if [[ ${optstring} = *"${c}:"* && ${1:i+1} ]]
        then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;
    # if option is of type --foo=bar, split on first '='
    --?*=*)
      options+=("${1%%=*}" "${1#*=}")
      ;;
    # end of options, stop breaking them up
    --)
      options+=(--endopts)
      shift
      options+=("${@}")
      break
      ;;
    # otherwise, nothing special
    *)
      options+=("${1}")
      ;;
  esac

  shift
done
# set new positional parameters to altered options. Set default to blank.
set -- "${options[@]:-}"
unset options

# Parse Options ###############################################################

# Initialize program option variables.
_PRINT_HELP=0
_USE_DEBUG=0
_BACKEND_URL="https://young-beach-90165.herokuapp.com"
_RECEIVER_UUID="unknown"
_POST_URI="/signals"
_MONI="mon0"
_INTERFACE="wlan1"
_WIFI_INTERFACE_MODE="monitor"

# Initialize additional expected option variables.
_BACKEND=0
_OPTION_X=0
_SHORT_OPTION_WITH_PARAMETER=""
_LONG_OPTION_WITH_PARAMETER=""

# _require_argument()
#
# Usage:
#   _require_argument <option> <argument>
#
# If <argument> is blank or another option, print an error message and  exit
# with status 1.
_require_argument() {
  # Set local variables from arguments.
  #
  # NOTE: 'local' is a non-POSIX bash feature and keeps the variable local to
  # the block of code, as defined by curly braces. It's easiest to just think
  # of them as local to a function.
  local _option="${1:-}"
  local _argument="${2:-}"

  if [[ -z "${_argument}" ]] || [[ "${_argument}" =~ ^- ]]
  then
    _die printf "Option requires an argument: %s\n" "${_option}"
  fi
}
# getopts and getopts have inconsistent behavior, so using a simple home-brewed
# while loop. This isn't perfectly compliant with POSIX, but it's close enough
# and this appears to be a widely used approach.
#
# More info:
#   http://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html
#   http://stackoverflow.com/a/14203146
#   http://stackoverflow.com/a/7948533
while [ ${#} -gt 0 ]
do
  __option="${1:-}"
  __maybe_param="${2:-}"
  case "${__option}" in
    -h|--help)
      _PRINT_HELP=1
      ;;
    --debug)
      _USE_DEBUG=1
      ;;
    -x|--option-x)
      _OPTION_X=1
      ;;
    -o)
      _require_argument "${__option}" "${__maybe_param}"
      _SHORT_OPTION_WITH_PARAMETER="${__maybe_param}"
       shift
      ;;
    -b|--backend)
      _BACKEND=1
      ;;
    --long-option-with-argument)
      _require_argument "${__option}" "${__maybe_param}"
      _LONG_OPTION_WITH_PARAMETER="${__maybe_param}"
      shift
      ;;
    --endopts)
      # Terminate option parsing.
      break
      ;;
    -*)
      _die printf "Unexpected option: %s\n" "${__option}"
      ;;
  esac
  shift
done

###############################################################################
# Program Functions
###############################################################################

_print_ascii_art(){
  cat <<"EOT"


                        _,)
                _..._.-;-'
             .-'     `(
            /      ;   \
           ;.' ;`  ,;  ;
          .'' ``. (  \ ;
         / f_ _L \ ;  )\
         \/|` '|\/;; <;/
        ((; \_/  (()
             "
              SNIFF
                SNIFF


EOT
}



_simple() {
  _debug printf ">> Performing operation...\n"

  if ((_OPTION_X))
  then
    printf "Perform a simple operation with --option-x.\n"
  else
    printf "Perform a simple operation.\n"
  fi
  if [[ -n "${_SHORT_OPTION_WITH_PARAMETER}" ]]
  then
    printf "Short option parameter: %s\n" "${_SHORT_OPTION_WITH_PARAMETER}"
  fi
  if [[ -n "${_LONG_OPTION_WITH_PARAMETER}" ]]
  then
    printf "Long option parameter: %s\n" "${_LONG_OPTION_WITH_PARAMETER}"
  fi
}


###############################################################################
# Initialize
###############################################################################
_initialize(){

  # delete tmp folder
  rm -r /tmp
  mkdir /tmp

  # check if in backend mode
  if((_BACKEND))
  then
    printf "Running in backend mode!\n"
    # print error if backendUrl is not present as env variable. Define env
    # variables via resin.io application or device configuration
    if [ -z "${backendUrl+1}" ]; then
      _die printf "Running in backend mode but backendUrl is not defined as environment variable!\n"
    fi
    if [ -z "${RESIN_DEVICE_UUID+1}" ]; then
      _die printf "Running in backend mode but RESIN_DEVICE_UUID is not defined as environment variable!\n"
    fi
    _RECEIVER_UUID="${RESIN_DEVICE_UUID}"
    _BACKEND_URL="${backendUrl}"
    printf "Using backend url: %s\n" "${_BACKEND_URL}"
  fi

  # checking if wifi interface already in monitor mode.
  if [[ !  -z  $(iwconfig 2>&1 | grep $_MONI)  ]]; then
    printf "Found wifi interface in monitor mode\n"
  else
    printf "No wifi interface in monitor mode, searching for devices...\n"
    for line in $(iw dev | grep phy); do
      # check if device supports monitor mode
      if [[ !  -z  $(iw phy ${line/\#/''} info | grep $_WIFI_INTERFACE_MODE) ]]; then
        printf "putting ${line/\#/''} into monitor mode...\n"
        sudo iw phy ${line/\#/''} interface add $_MONI type monitor
        sudo ifconfig mon0 up
        break
      fi
    done
    # checking again if wifi interface in monitor mode.
    if [[ !  -z  $(iwconfig 2>&1 | grep $_MONI)  ]]; then
      printf "Wifi interface in monitor mode now available!\n"
    else
      _die printf "Could not start wifi interface in monitor mode!\n"
    fi
  fi
}


###############################################################################
# Capture
###############################################################################
_capture(){

  _print_ascii_art

  printf "******************* Sniff dog up and running! *******************\n\n"
  stdbuf -oL tshark -i mon0 -I \
      -f 'broadcast' \
      -Y 'wlan.fc.type == 0 && wlan.fc.subtype == 4 && wlan_mgt.ssid != "" && radiotap.dbm_antsignal != ""' \
      -T fields \
        -e frame.time_epoch \
        -e wlan.sa \
        -e radiotap.dbm_antsignal \
        -e wlan.sa_resolved \
        -e wlan_mgt.ssid \
  | while read epoch sa antsignal sa_resolved ssid; do
    rssi=$(echo $antsignal | cut -f1 -d,)
    if((_BACKEND))
    then
      # sending data to backend
      curl --silent -i -H "Content-Type:application/json" \
      -d "{  \"timestamp\" : \"$(date -d @$epoch -u +"%Y-%m-%dT%H:%M:%SZ")\",  \"mac\" : \"$sa\", \"ssid\" : \"$ssid\", \"receiverUuid\" : \"$_RECEIVER_UUID\", \"rssi\" : \"$rssi\" }" "$_BACKEND_URL$_POST_URI" > /dev/null ;
    fi
      printf "mac: %s, rssi: %s, ssid: %s\n" $sa $rssi $ssid
  done

}

###############################################################################
# Main
###############################################################################

# _main()
#
# Usage:
#   _main [<options>] [<arguments>]
#
# Description:
#   Entry point for the program, handling basic option parsing and dispatching.
_main() {

  if ((_PRINT_HELP))
  then
    _print_help
  else
    _initialize "${@}"
    _capture "${@}"
#    _simple "${@}"
  fi
}

# Call `_main` after everything has been defined.
_main "${@:-}"
