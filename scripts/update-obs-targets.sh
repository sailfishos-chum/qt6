# Update Qt or KF packages at OBS

set -e

ARGS_PROCESSED=$(getopt -o a:d:rt --long add:,delete:,release,testing,reset -- "$@")

ADD=
DEL=
KF6=
QT6=
KDE=
OBS_PROJECT=
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
OBSMOD=${SCRIPT_DIR}/obsbuildmod.py

eval set -- "$ARGS_PROCESSED"
while [ : ]; do
  case "$1" in
    -a | --add) OPT="--add $2"; shift 2; ;;
    -d | --delete) OPT="--delete $2"; shift 2; ;;
    --reset) OPT="--reset"; shift; ;;
    -r | --release) OBS_PROJECT=sailfishos:chum; shift; ;;
    -t | --testing) OBS_PROJECT=sailfishos:chum:testing; shift; ;;
    --) shift; break; ;;
  esac
done

# check options
[ -z "$OPT" ] && echo "Specify whether you want to add or delete SFOS version build target or reset all targets" && exit 1
[ -z "$OBS_PROJECT" ] && echo "Specify whether you want to update release (sailfishos:chum) or testing (sailfishos:chum:testing) OBS project" && exit 1

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
