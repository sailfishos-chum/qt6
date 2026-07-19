#!/usr/bin/env bash

# Update Qt or KF packages at OBS

set -e

ARGS_PROCESSED=$(getopt -o kqKrt --long kf6,qt6,kde,release,testing -- "$@")

INPUT=
KF6=
QT6=
KDE=
GITHUB_BASE=https://github.com/sailfishos-chum
OBS_PROJECT=
PROJECT_COUNT=0

eval set -- "$ARGS_PROCESSED"
while true; do
  case "$1" in
    -k | --kf6) KF6=1; INPUT=packages.kf6; shift; ;;
    -q | --qt6) QT6=1; INPUT=packages.qt6; shift; ;;
    -K | --kde) KDE=1; INPUT=packages.kde; shift; ;;
    -r | --release) OBS_PROJECT=sailfishos:chum; PROJECT_COUNT=$((PROJECT_COUNT + 1)); shift; ;;
    -t | --testing) OBS_PROJECT=sailfishos:chum:testing; PROJECT_COUNT=$((PROJECT_COUNT + 1)); shift; ;;
    --) shift; break; ;;
    *) echo "Unexpected option: $1"; exit 1; ;;
  esac
done

# check options
MODE_COUNT=0
[ -n "$KF6" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ -n "$QT6" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ -n "$KDE" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ "$MODE_COUNT" -ne 1 ] && echo "Specify either KDE, KF6, or QT6 to update" && exit 1

[ "$PROJECT_COUNT" -ne 1 ] && echo "Specify either release or testing OBS project" && exit 1
[ -z "$INPUT" ] && echo "Input file missing" && exit 1

[ -d tmp ] && echo "Directory tmp exists. Please remove before starting." && exit 1

echo "Starting updates in ${OBS_PROJECT}"

# process packages
mkdir -p tmp
while read -r line; do
    [ -z "$line" ] && continue
    package_arr=($line)
    package_git=${package_arr[0]}
    package_obs=$package_git
    (( ${#package_arr[@]} > 1 )) && [ ${package_arr[1]} != "NOGIT" ] && package_obs=${package_arr[1]}

    # get the tag with the largest version
    VERSION=$(git -c 'versionsort.suffix=-' ls-remote --exit-code \
		  --refs --sort='version:refname' --tags \
		  ${GITHUB_BASE}/${package_git} '*.*.*' | tail --lines=1 | cut --delimiter='/' --fields=3)

    echo
    echo "Update: ${package_git} -> ${package_obs}; Version: ${VERSION}"
    echo

    pushd tmp

    echo "Checking out: ${OBS_PROJECT} ${package_obs}"
    osc co -o ${package_obs} ${OBS_PROJECT} ${package_obs}
    pushd ${package_obs}
    sed -i \
	"s|<param name=\"revision\">.*</param>|<param name=\"revision\">${VERSION}</param>|g" _service
    osc commit -m "Update to ${VERSION}"
    osc service remoterun
    popd
    popd
    echo
done < <(grep -v NOAUTO $INPUT | grep -v NOOBS)
