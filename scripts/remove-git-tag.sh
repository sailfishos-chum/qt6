#!/usr/bin/env bash

# Remove a tag from Qt, KF, or KDE Git repositories

set -e

ARGS_PROCESSED=$(getopt -o kqKt: --long kf6,qt6,kde,tag: -- "$@")

INPUT=
KF6=
QT6=
KDE=
TAG=
GIT_BASE=https://github.com/sailfishos-chum

eval set -- "$ARGS_PROCESSED"
while true; do
  case "$1" in
    -k | --kf6) KF6=1; INPUT=packages.kf6; shift; ;;
    -q | --qt6) QT6=1; INPUT=packages.qt6; shift; ;;
    -K | --kde) KDE=1; INPUT=packages.kde; shift; ;;
    -t | --tag) TAG=$2; shift 2; ;;
    --) shift; break; ;;
    *) echo "Unexpected option: $1"; exit 1; ;;
  esac
done

# check options
[ -z "$INPUT" ] && echo "Input file missing" && exit 1
[ -z "$TAG" ] && echo "Git tag missing" && exit 1

MODE_COUNT=0
[ -n "$KF6" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ -n "$QT6" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ -n "$KDE" ] && MODE_COUNT=$((MODE_COUNT + 1))
[ "$MODE_COUNT" -ne 1 ] && echo "Specify either KDE, KF6, or QT6 to update" && exit 1

# process packages
while read -r line; do
    [ -z "$line" ] && continue
    package_arr=($line)
    package=${package_arr[0]}
    repo=${GIT_BASE}/${package}

    echo
    echo "Update: ${package}; Tag: ${TAG}"
    echo

    if git ls-remote --exit-code --tags ${repo} "refs/tags/${TAG}" > /dev/null; then
        git push ${repo} ":refs/tags/${TAG}"
    else
        echo "Git tag does not exist - skipping"
    fi
done < <(grep -v NOAUTO $INPUT | grep -v NOGIT)
