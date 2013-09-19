# Copyright Iowa State University 2011, 2013
#
# Distributed under the Boost Software License, Version 1.0.
#
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

require "osgconv/fileutils.rb"

module RP_SketchUpToOSG
    # TODO de-duplication
    @osg_exportviacollada_extension_url = "https://github.com/rpavlik/sketchupToOSG#readme"

    def self.exportToOSG(selectionOnly, extension)
	    # Present an options dialog
	    prompts = ["Open in viewer after export?",
		    "Export edges?",
		    "Double-sided faces?",
		    "Rotate to Y-UP?",
		    "Convert to output units:"]
	    defaults = ["yes", "yes", "yes", "yes", "meters"]
	    list = ["yes|no", "yes|no", "yes|no", "yes|no", "inches (no scaling)|feet|meters"]
	    if extension == ".ive"
		    prompts << "Compress textures?"
		    defaults << "yes"
		    list << "yes|no"
	    end
	    input = UI.inputbox prompts, defaults, list, "OpenSceneGraph Export Options"

	    if input == nil
		    # If they cancelled the options dialog, don't export
		    return
	    end

	    # Interpret results of options dialog
	    view = (input[0] == "yes")
	    edges = (input[1] == "yes")
	    doublesided = (input[2] == "yes")
	    doRotate = (input[3] == "yes")
	    doScale = (input[4] != "inches (no scaling)")
	    doCompress = false
	    if extension == ".ive"
		    doCompress = (input[6] == "yes")
	    end

	    # Get model information
	    model = Sketchup.active_model
	    title = model.title

	    # Present "Save as" dialog
	    outputFn = UI.savepanel("Save to #{extension}...", nil, "#{title}#{extension}")
	    if outputFn == nil
		    # Don't export if they hit cancel
		    return
	    end
	    if File.extname(outputFn) == ""
		    # If specified filename had no extension, add the default.
		    outputFn = outputFn + extension
	    end

	    # Flag: don't delete the export texture dir if it already exists before export
	    skipDeleteDir = File.directory?(outputFn + "-export")

	    # Export to DAE
	    Sketchup.status_text = "Exporting to a temporary DAE file..."
	    tempFn = outputFn + "-export.dae"
	    options_hash = {:triangulated_faces   => true,
					    :doublesided_faces    => doublesided,
					    :edges                => edges,
					    :materials_by_layer   => false,
					    :author_attribution   => true,
					    :texture_maps         => true,
					    :selectionset_only    => selectionOnly,
					    :preserve_instancing  => true }
	    status = model.export tempFn, options_hash
	    if (not status)
		    UI.messagebox("Could not export to DAE")
		    return
	    end

	    # Set up command line arguments
	    convertArgs = [tempFn,
		    outputFn,
		    "--use-world-frame",
		    "-O", "OutputRelativeTextures"]
	    viewPseudoLoader = ""

	    if doScale
		    if input[4] == "meters"
			    scale = "0.02539999969303608" # inches to meters
		    elsif input[4] == "feet"
			    scale = "0.083333" # inches to feet
		    end
		    convertArgs << "-s"
		    convertArgs << "#{scale},#{scale},#{scale}"
	    end

	    if doRotate
		    convertArgs << '-o'
		    convertArgs << '0,0,1-0,1,0'
		    viewPseudoLoader = viewPseudoLoader + ".90,0,0.rot"
	    end

	    if doCompress
		    convertArgs << "--compressed"
	    end

	    # Tell OSG where it can find its plugins
	    if Object.RUBY_PLATFORM=~/darwin/
	    	ENV['OSG_LIBRARY_PATH'] = @osgbindir + '/vendor/lib/osgPlugins-3.0.1'
	    else
	    	ENV['OSG_LIBRARY_PATH'] = @osgbindir
	    end
	    	

	    # Change to output directory
	    outdir = File.dirname(outputFn)
	    Dir.chdir outdir do
		    # Run the converter
		    Sketchup.status_text = "Converting .dae temp file to OpenSceneGraph format..."
		    status = Kernel.system(@osgconvbin, *convertArgs)

		    if not status
			    UI.messagebox("Failed when converting #{tempFn} to #{outputFn}! Temporary file not deleted, for your inspection.")
			    return
		    end
	    end

	    # Delete temporary file(s)
	    File.delete(tempFn)
	    if not skipDeleteDir
		    FileUtils.rm_rf outputFn + "-export"
	    end

	    # View file if requested
	    extraMessage = ""
	    if view
		    Sketchup.status_text = "Launching viewer of exported model..."
		    Thread.new{ system(@osgviewerbin, "--window", "50", "50", "640", "480", outputFn + viewPseudoLoader) }
		    extraMessage = "Viewer launched - press Esc to close it."
	    end

	    Sketchup.status_text = "Export of #{outputFn} successful!  #{extraMessage}"
    end

    def self.selectionValidation()
	    if Sketchup.active_model.selection.empty?
		    return MF_GRAYED
	    else
		    return MF_ENABLED
	    end
    end

    if( not file_loaded? __FILE__ )

	    # Find helper applications
	    @osgbindir = File.dirname( __FILE__ )
	    @binext = (Object.RUBY_PLATFORM=~/mswin/)? ".exe" : ""
	    @osgconvbin = @osgbindir + "/osgconv" + @binext
	    @osgviewerbin = @osgbindir + "/osgviewer" + @binext
	    if @osgconvbin == nil or @osgviewerbin == nil
		    UI.messagebox("Failed to find conversion/viewing tools!\nosgconv: #{@osgconvbin}\nosgviewer: #{@osgviewerbin}")
		    return
	    end

        osg_menu = UI.menu("File").add_submenu("Export to OpenSceneGraph")

	    osg_menu.add_item("Export entire document to OSG...") { self.exportToOSG(false, ".osg") }

	    osg_menu.add_item("Export entire document to IVE...") { self.exportToOSG(false, ".ive") }

	    osg_menu.add_separator

	    selItem = osg_menu.add_item("Export selection to OSG...") { self.exportToOSG(true, ".osg") }
	    osg_menu.set_validation_proc(selItem) {self.selectionValidation()}

	    selItem = osg_menu.add_item("Export selection to IVE...") { self.exportToOSG(true, ".ive") }
	    osg_menu.set_validation_proc(selItem) {self.selectionValidation()}

	    osg_menu.add_separator

	    osg_menu.add_item("Visit SketchupToOSG homepage") { UI.openURL(@osg_exportviacollada_extension_url) }

        file_loaded __FILE__
    end

end #module
