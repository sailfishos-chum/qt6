#!/usr/bin/env bash

# Update Qt or KF packages at OBS

set -e

ARGS_PROCESSED=$(getopt -o a:d:rt --long add:,delete:,release,testing,reset -- "$@")

ADD=
DEL=
OBS_PROJECT=
ACTION_COUNT=0
PROJECT_COUNT=0
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
OBSMOD=${SCRIPT_DIR}/obsbuildmod.py

eval set -- "$ARGS_PROCESSED"
while true; do
  case "$1" in
    -a | --add) OPT="--add $2"; ACTION_COUNT=$((ACTION_COUNT + 1)); shift 2; ;;
    -d | --delete) OPT="--delete $2"; ACTION_COUNT=$((ACTION_COUNT + 1)); shift 2; ;;
    --reset) OPT="--reset"; ACTION_COUNT=$((ACTION_COUNT + 1)); shift; ;;
    -r | --release) OBS_PROJECT=sailfishos:chum; PROJECT_COUNT=$((PROJECT_COUNT + 1)); shift; ;;
    -t | --testing) OBS_PROJECT=sailfishos:chum:testing; PROJECT_COUNT=$((PROJECT_COUNT + 1)); shift; ;;
    --) shift; break; ;;
    *) echo "Unexpected option: $1"; exit 1; ;;
  esac
done

# check options
[ "$ACTION_COUNT" -ne 1 ] && echo "Specify either add, delete, or reset target action" && exit 1
[ "$PROJECT_COUNT" -ne 1 ] && echo "Specify either release or testing OBS project" && exit 1

echo -e "\nChanging targets in ${OBS_PROJECT}\n"

# process packages
PACKAGES=""
while read -r line; do
    [ -z "$line" ] && continue
    package_arr=($line)
    package_git=${package_arr[0]}
    package_obs=$package_git
    (( ${#package_arr[@]} > 1 )) && [ ${package_arr[1]} != "NOGIT" ] && [ ${package_arr[1]} != "NOAUTO" ] && package_obs=${package_arr[1]}
    PACKAGES="$PACKAGES $package_obs"
done < <(cat packages.qt6 packages.kf6 packages.kde | grep -v NOOBS)
PACKAGES="$PACKAGES `cat applications.obs`"

echo $PACKAGES

for package in $PACKAGES; do
    echo
    echo "Update: ${package}"
    echo

    osc meta pkg ${OBS_PROJECT} ${package} | \
       ${OBSMOD} ${OPT} | \
       osc meta pkg ${OBS_PROJECT} ${package} -F -
done
