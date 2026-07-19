#!/usr/bin/env bash

# Update Qt or KF package sources

set -e

ARGS_PROCESSED=$(getopt -o kqKv:t: --long kf6,qt6,kde,version:,tag: -- "$@")

INPUT=
KF6=
QT6=
KDE=
VERSION=
TAG=
GITHUB_BASE=https://github.com/sailfishos-chum

eval set -- "$ARGS_PROCESSED"
while true; do
  case "$1" in
    -k | --kf6) KF6=1; INPUT=packages.kf6; shift; ;;
    -q | --qt6) QT6=1; INPUT=packages.qt6; shift; ;;
    -K | --kde) KDE=1; INPUT=packages.kde; shift; ;;
    -v | --version) VERSION=$2; shift 2; ;;
    -t | --tag) TAG=$2; shift 2; ;;
    --) shift; break; ;;
    *) echo "Unexpected option: $1"; exit 1; ;;
  esac
done

# check options
[ -z "$INPUT" ] && echo "Input file missing" && exit 1
[ -z "$VERSION" ] && echo "Target version missing" && exit 1
[ -z "$TAG" ] && TAG=v$VERSION

MODE_COUNT=0
[ -n "$KF6" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ -n "$QT6" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ -n "$KDE" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ "$MODE_COUNT" -ne 1 ] && echo "Specify either KDE, KF6, or QT6 to update" && exit 1

[ -d tmp ] && echo "Directory tmp exists. Please remove before starting." && exit 1

# process packages
mkdir -p tmp
while read -r line; do
    [ -z "$line" ] && continue
    package_arr=($line)
    package=${package_arr[0]}

    pushd tmp
    git clone --recursive $GITHUB_BASE/$package
    pushd $package
    # update upstream
    pushd upstream
	git checkout $TAG
	REAL_VERSION=$VERSION
    popd
    echo "Setting version to ${REAL_VERSION}"
    git add upstream

    sed -i "s/^Version:.*/Version: ${REAL_VERSION}/g" rpm/*.spec
    if [ -n "$KF6" ]; then
	sed -i -E "s/^%global[[:space:]]+kf6_version[[:space:]]+.*/%global kf6_version ${VERSION}/g" rpm/*.spec
    elif [ -n "$QT6" ]; then
	sed -i -E "s/^%global[[:space:]]+qt_version[[:space:]]+.*/%global qt_version ${VERSION}/g" rpm/*.spec
    elif [ -n "$KDE" ]; then
	sed -i -E "s/^%global[[:space:]]+kde_version[[:space:]]+.*/%global kde_version ${VERSION}/g" rpm/*.spec
    fi
    git add rpm/*.spec
    git status
    
    if git diff-index --quiet HEAD; then
	echo "Sources are already updated in the repository, skipping commit"
    else
	git commit -m "Update to version ${REAL_VERSION}"
    fi
    
    if [ -n "$(git tag -l "${REAL_VERSION}")" ]; then
	echo "Git tag already set - skipping"
    else
	git tag ${REAL_VERSION}
    fi

    git push origin main --tags
    popd
    popd
    echo
done < <(grep -v NOAUTO $INPUT | grep -v NOGIT)
