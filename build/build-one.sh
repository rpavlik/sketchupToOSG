#!/bin/sh

set -x

# Package version.
VER=1.6.7

# SketchUp version: 2013 means 2013 and earlier (don't go much earlier
# than 8.0 M1 for best results), while 2014 means 2014, and
# theoretically later.
SUVER=$1

# Either mac or win.
PLATFORM=$2

SRC=$(cd $(dirname $0) && cd .. && pwd)
BUILDSCRIPTS=$(cd $(dirname $0) && pwd)

# Where everything should be copied
SCRATCH=$(mktemp -d -t tmp.packagebuild.XXXXXXXXXX)
finish() {
  rm -rf "${SCRATCH}"
}
trap finish EXIT

#SCRATCH="${SRC}/Temp"
#mkdir -p "$SCRATCH"
DESTDIR="${SRC}/Output"
mkdir -p "$DESTDIR"

DESTSTEM="sketchupToOpenSceneGraph-v${VER}-su${SUVER}-${PLATFORM}"
DESTBASE="${DESTDIR}/${DESTSTEM}"

echo "Currently building:"
echo " - ${DESTSTEM}"
echo " - from ${SRC}"
echo " - using scratch ${SCRATCH}"
echo

(
    cd "$SRC"

    ### Clean up refuse.
    find ./binaries/ -name '*.DS_Store' -type f -delete
    find ./osgconv/ -name '*.DS_Store' -type f -delete

    ###
    echo "Copy platform-independent files..."
    cp -v "openscenegraph_exportviacollada.rb" "${SCRATCH}"

    mkdir -p "${SCRATCH}/osgconv"
    cp -v "osgconv/osgconv.rb" "osgconv/LICENSE_1_0.txt" "${SCRATCH}/osgconv/"
    cp -v README.mkd "${SCRATCH}/README_openscenegraph_exportviacollada.txt"
    
    if [ $SUVER -lt 2014 ]; then
        cp -v "osgconv/fileutils.rb" "${SCRATCH}/osgconv/"
    fi

    ###
    echo "Copy platform-dependent files..."
    # the -d is to keep symlinks intact for Mac.
    cp -v --recursive -d  binaries/${PLATFORM}/* "${SCRATCH}/osgconv"
    
    echo "Build archive..."
    # Compress to ZIP/RBZ
    rm -fv "${DESTBASE}.rbz"
    7za a -tzip -r "${DESTBASE}.rbz" "${SCRATCH}"/*
    
    # Rename to RBZ
    #mv "${DESTBASE}.zip" "${DESTBASE}.rbz"
    echo " - Generated ${DESTBASE}.rbz"
)

echo "Done with ${DESTSTEM}"
echo
