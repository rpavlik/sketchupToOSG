#!/bin/sh
VERSION=1.6.2
(
cd $(dirname $0)
rm -f sketchup-to-openscenegraph-mac-${VERSION}.rbz
find osgconv -type f -print0 |xargs -0 zip sketchup-to-openscenegraph-mac-${VERSION}.rbz openscenegraph_exportviacollada.rb

)