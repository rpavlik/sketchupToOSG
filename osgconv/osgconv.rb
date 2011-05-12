# Copyright Iowa State University 2011
#
# Distributed under the Boost Software License, Version 1.0.
#
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

require "osgconv/fileutils.rb"

def exportToOSG(selectionOnly, extension)
	prompts = ["Open in viewer after export?",
		"Export edges?",
		"Double-sided faces?",
		"Rotate to Y-UP?",
		"Scale from inches to meters?"]
	defaults = ["yes", "yes", "yes", "no", "no"]
	list = ["yes|no", "yes|no", "yes|no", "yes|no", "yes|no"]
	if extension == ".ive"
		prompts << "Compress textures?"
		defaults << "yes"
		list << "yes|no"
	end
	input = UI.inputbox prompts, defaults, list, "OpenSceneGraph Export Options"
	
	if input == nil
		return
	end

	view = (input[0] == "yes")
	edges = (input[1] == "yes")
	doublesided = (input[2] == "yes")
	doRotate = (input[3] == "yes")
	doScale = (input[4] == "yes")
	doCompress = false
	if extension == ".ive"
		doCompress = (input[5] == "yes")
	end
	
	model = Sketchup.active_model
	options_hash = {:triangulated_faces   => true,
					:doublesided_faces    => doublesided,
					:edges                => edges,
					:materials_by_layer   => false,
					:author_attribution   => true,
					:texture_maps         => true,
					:selectionset_only    => selectionOnly,
					:preserve_instancing  => true }
	title = model.title
	
	outputFn = UI.savepanel("Save to #{extension}...", nil, "#{title}#{extension}")
	if outputFn == nil
		return
	end
	skipDeleteDir = File.directory?(outputFn + "-export")
	tempFn = outputFn + "-export.dae"
	Sketchup.status_text = "Exporting to a temporary DAE file..."
	status = model.export tempFn , options_hash
	if (not status)
		UI.messagebox("Could not export to DAE")
		return
	end
	flags = " "
	viewPseudoLoader = ""
	if doScale
		scale = "0.02539999969303608" # inches to meters
		flags = flags + "-s \"#{scale},#{scale},#{scale}\" -t \"0,0,0\" "
	end
	if doRotate
		flags = flags + '-o "0,0,1-0,1,0" '
		viewPseudoLoader = viewPseudoLoader + ".90,0,0.rot"
	end
	if doCompress
		flags = flags + "--compressed "
	end
	
	osgconv = Sketchup.find_support_file "osgconv.cmd", "Plugins/osgconv/"
	osgviewer = Sketchup.find_support_file "osgviewer.cmd", "Plugins/osgconv/"
	
	# TODO make sure we find our commands
	
	Sketchup.status_text = "Converting .dae temp file to OpenSceneGraph format..."
	cmdline = "\"#{osgconv}\" \"#{tempFn}\" \"#{outputFn}\" " + flags
	status = system(cmdline)
	if not status
		UI.messagebox("Failed when converting #{tempFn} to #{outputFn}! Temporary file not deleted, for your inspection.")
		return
	end
	
	File.delete(tempFn)
	if not skipDeleteDir
		FileUtils.rm_rf outputFn + "-export"
	end
	if view
		Sketchup.status_text = "Launching viewer of exported model..."
		Thread.new{ system("\"#{osgviewer}\" \"#{outputFn}#{viewPseudoLoader}\"") }
	end
	
	Sketchup.status_text = "Export of #{outputFn} successful!"
end

if( not file_loaded? __FILE__ )
    osg_menu = UI.menu("File").add_submenu("OpenSceneGraph Exporter")
	osg_menu.add_item("Export entire document to OSG...") { exportToOSG(false, ".osg") }
	osg_menu.add_item("Export entire document to IVE...") { exportToOSG(false, ".ive") }
	osg_menu.add_separator
	osg_menu.add_item("Export selection to OSG...") { exportToOSG(true, ".osg") }
	osg_menu.add_item("Export selection to IVE...") { exportToOSG(true, ".ive") }
    file_loaded __FILE__
end
