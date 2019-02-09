#!/bin/sh
BUILDSCRIPTS=$(cd $(dirname $0) && pwd)


for PLATFORM in win; do
    for SUVER in 2017; do
        "${BUILDSCRIPTS}/build-one.sh" ${SUVER} ${PLATFORM}
    done
done
