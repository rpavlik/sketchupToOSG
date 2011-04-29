require 'sketchup.rb'
require 'extensions.rb'

osg_exportviacollada_extension = SketchupExtension.new "Export to OpenSceneGraph (via COLLADA)", "osgconv/osgconv.rb"
osg_exportviacollada_extension.version = '1.2'
osg_exportviacollada_extension.description = "Export to OpenSceneGraph formats, by first exporting to COLLADA then converting. Accessible via a submenu of File, unfortunately not in Export due to SketchUp API limitations."
osg_exportviacollada_extension.copyright = "2011, Iowa State University VRAC"
osg_exportviacollada_extension.creator = "Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>"
Sketchup.register_extension osg_exportviacollada_extension, true