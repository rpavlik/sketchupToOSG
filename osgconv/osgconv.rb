# Copyright Iowa State University 2011, 2013, 2014
#
# Distributed under the Boost Software License, Version 1.0.
#
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

if Sketchup.version_number < 14000000
	require "osgconv/fileutils.rb"
else
	require 'fileutils'
end

module RP_SketchUpToOSG
    # TODO de-duplication
    @osg_exportviacollada_extension_url = "https://github.com/aroth-fastprotect/sketchupToOSG#readme"

    def self.exportToOSG(selectionOnly, extension)
	    # Present an options dialog
	    prompts = [
            "Open in viewer after export?",
            "Export format:",
		    "Export edges?",
		    "Double-sided faces?",
            "Tessellation:",
            "Preserve Instancing?",
		    "Rotate to Y-UP?",
		    "Convert to output units:",
            "Use STATIC transform?",
            "Optimize material usage?",
            "Keep temporary files?",
            ]
	    defaults = [
            "no",       # viewer
            "DAE",      # format
            "no",       # edges
            "no",       # double-sided
            "Sketchup", # Tessellation
            "no",       # preserve instancing
            "no",       # rotate
            "meter",    # units
            "yes",      # static transform
            "yes",      # optimize material usage
            "no",       # temp files
        ]
	    list = [
            "yes|no",              # viewer
            "DAE",                 # format
            "yes|no",              # edges
            "yes|no",              # double-sided
            "Sketchup|None|Polygons|Polygons as Triangle Fan",        # Tessellation
            "yes|no",              # preserve instancing
            "yes|no",              # rotate
            "inch|feet|meter",     # units
            "yes|no",              # static transform
            "yes|no",              # optimize material usage
            "yes|no",              # temp files
        ]
        if extension == ".ive" or extension == ".osgb"
            prompts << "Compress textures?"
            defaults << "yes"
            list << "yes|no"
        end
        if extension == ".osgb" or extension == ".osgx" or extension == ".osgt"
            prompts << "Target OSG version:"
            defaults << "latest"
            list << @osg_versions.keys.join('|')
        end
	    input = UI.inputbox prompts, defaults, list, "OpenSceneGraph Export Options"

	    if input == nil
		    # If they cancelled the options dialog, don't export
		    return
	    end

	    # Interpret results of options dialog
        input_index = 0
	    view = (input[input_index] == "yes")
        input_index+=1
        exportFormat = input[input_index].downcase
        input_index+=1
        exportFormatDAE = (exportFormat == "dae")
        exportFormatOBJ = (exportFormat == "obj")
	    edges = (input[input_index] == "yes")
        input_index+=1
	    doublesided = (input[input_index] == "yes")
        input_index+=1
        tessellation = input[input_index]
        input_index+=1
        doTriangulate = (tessellation == "Sketchup")
        doPreserveInstancing = (input[input_index] == "yes")
        input_index+=1
	    doRotate = (input[input_index] == "yes")
        input_index+=1
        scale_units = input[input_index]
        input_index+=1
	    doScale = (scale_units != "inch")
	    doCompress = false
        targetOSGVersion = ""
        useStaticTransform = (input[input_index] == "yes")
        input_index+=1
        optimizeMaterialUsage = (input[input_index] == "yes")
        input_index+=1
        keepTemporaryFiles = (input[input_index] == "yes")
        input_index+=1
	    if extension == ".ive" or extension == ".osgb"
		    doCompress = (input[input_index] == "yes")
            input_index+=1
	    end
        if extension == ".osgb" or extension == ".osgx" or extension == ".osgt"
            targetOSGVersion = input[input_index]
            input_index+=1
        end

        targetOSGVersion_so = @osg_versions.fetch(targetOSGVersion, 0)

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

        Sketchup.status_text = "Exporting to a temporary ." + exportFormat + " file..."
        tempFn = outputFn + "-export." + exportFormat
        logfile = File.open(outputFn + ".log", "w")

        options_hash = {}
	    # Export to DAE
        if exportFormatDAE
            options_hash = {:triangulated_faces   => doTriangulate,
                            :doublesided_faces    => doublesided,
                            :edges                => edges,
                            :materials_by_layer   => false,
                            :author_attribution   => true,
                            :texture_maps         => true,
                            :selectionset_only    => selectionOnly,
                            :preserve_instancing  => doPreserveInstancing,
                            :camera_lookat        => false}
        elsif exportFormatOBJ
            options_hash = {:triangulated_faces   => doTriangulate,
                            :units                => scale_units,
                            :doublesided_faces    => doublesided,
                            :edges                => edges,
                            :texture_maps         => true,
                            :selectionset_only    => selectionOnly
                           }
        else
            status = 0
        end
        logfile.puts "Export model options: " + options_hash.to_s
        status = model.export tempFn, options_hash
        if (not status)
            UI.messagebox("Could not export to " + exportFormat)
            logfile.close
            return
        end

	    # Set up command line arguments
	    convertArgs = [tempFn,
		    outputFn,
		    "--use-world-frame",
		    "-O", "OutputRelativeTextures"]
        if exportFormatDAE
			convertArgs << "-O"
			convertArgs << "daeUseSequencedTextureUnits"
            if not doTriangulate
                convertArgs << "-O"
                if tessellation == "None"
                    convertArgs << "daeTessellateNone"
                elsif tessellation == "Polygons"
                    convertArgs << "daeTessellatePolygons"
                else # if tessellation == "Polygons as Triangle Fan"
                    convertArgs << "daeTessellatePolygonsAsTriFans"
                end
            end
        elsif exportFormatOBJ
            if not doTriangulate
                convertArgs << "-O"
                if tessellation == "None"
                    convertArgs << "noTriStripPolygons"
                else
                    convertArgs << "noTesselateLargePolygons"
                end
            end
        end

        if extension == ".ive" or extension == ".osgb"
			convertArgs << "-O"
			convertArgs << "WriteImageHint=IncludeData"
        end
        if targetOSGVersion_so != 0
            # pass OSG SO version number to make sure the file is readable by an earlier version
			convertArgs << "-O"
			convertArgs << "TargetFileVersion=#{targetOSGVersion_so}"
		end
	    viewPseudoLoader = ""

	    if doScale
            scale = "1.0"
		    if scale_units == "meter"
			    scale = "0.02539999969303608" # inches to meters
		    elsif scale_units == "feet"
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
        if extension == ".osgb"
            convertArgs << "-O"
            convertArgs << "Compressor=zlib"
        end


	    # Tell OSG where it can find its plugins
	    ENV['OSG_LIBRARY_PATH'] = @osglibpath
		ENV['OSG_OPTIMIZER'] = 'DEFAULT,FLATTEN_STATIC_TRANSFORMS,FLATTEN_STATIC_TRANSFORMS_DUPLICATING_SHARED_SUBGRAPHS,MERGE_GEODES,VERTEX_POSTTRANSFORM,VERTEX_PRETRANSFORM,BUFFER_OBJECT_SETTINGS,TEXTURE_ATLAS_BUILDER'
        if useStaticTransform
            ENV['OSG_OPTIMIZER'] = ENV['OSG_OPTIMIZER'] + ',PATCH_UNSPECIFIED_TRANSFORMS'
        end
        if optimizeMaterialUsage
            ENV['OSG_OPTIMIZER'] = ENV['OSG_OPTIMIZER'] + ',COMBINE_GEOMETRIES_BY_STATESET'
        end

        logfile.puts "OSG binary dir: " + @osgbindir
        logfile.puts "Environment: "
        logfile.puts "OSG_LIBRARY_PATH=" + ENV['OSG_LIBRARY_PATH'].to_s
        logfile.puts "OSG_OPTIMIZER=" + ENV['OSG_OPTIMIZER'].to_s
        
	    # Change to output directory
	    outdir = File.dirname(outputFn)
	    Dir.chdir outdir do
		    # Run the converter
		    Sketchup.status_text = "Converting .#{exportFormat} temp file to OpenSceneGraph format..."
            logfile.puts "Converting .#{exportFormat} temp file to OpenSceneGraph format..."
            logfile.puts @osgconvbin + " \"" + convertArgs.join("\" \"") + "\""
            status = -1
            begin
                #status = Kernel.system(@osgconvbin, *convertArgs)
                require 'open3'
                Open3.popen3(@osgconvbin, *convertArgs) do |osgconv_stdin, osgconv_stdout, osgconv_stderr, wait_thr|
                    status = wait_thr.value
                    logfile.puts @osgconvbin + " status " + status.to_s
                    logfile.puts osgconv_stdout.read
                    logfile.puts osgconv_stderr.read
                end
            rescue StandardError => msg
                logfile.puts msg
            end

            if status != 0
                logfile.puts "Failed when converting #{tempFn} to #{outputFn}! Temporary file not deleted, for your inspection."
			    UI.messagebox("Failed when converting #{tempFn} to #{outputFn}! Temporary file not deleted, for your inspection.")
                logfile.close
			    return
		    end
	    end

        if keepTemporaryFiles
            logfile.puts "Keep temporary file #{tempFn}"
        else
            # Delete temporary file(s)
            logfile.puts "Delete temporary file #{tempFn}"
            File.delete(tempFn)
            if not skipDeleteDir
                FileUtils.rm_rf outputFn + "-export"
            end
        end

	    # View file if requested
	    extraMessage = ""
	    if view
		    Sketchup.status_text = "Launching viewer of exported model..."
            logfile.puts "Launching viewer of exported model..."
            viewerArgs = ["--window", "50", "50", "640", "480"]
            viewerArgs << outputFn + viewPseudoLoader
            logfile.puts "Start viewer " + @osgviewerbin + " \"" + viewerArgs.join("\" \"") + "\""
		    Thread.new{ system(@osgviewerbin, *viewerArgs) }
		    extraMessage = "Viewer launched - press Esc to close it."
	    end
        logfile.puts "Export of #{outputFn} successful!"
        logfile.close

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

	    # Find helper applications and directories
	    @plugindir = File.dirname( __FILE__ )
	    @osgbindir = (Object::RUBY_PLATFORM=~/mswin|x64-mingw32/)? @plugindir : @plugindir + '/vendor/bin'
	    @osglibpath = (Object::RUBY_PLATFORM=~/mswin|x64-mingw32/)?  @plugindir : @plugindir + '/vendor/lib/osgPlugins-3.5.6'
	    @binext = (Object::RUBY_PLATFORM=~/mswin|x64-mingw32/)? ".exe" : ""
        @osg_debug_version = false
        @osg_ini = @plugindir + '/osg.ini'
        if File.file?(@osg_ini)
            File.open(@osg_ini, "r") do |f|
                f.each_line do |line|
                    if line.start_with?('OSG=')
                        @osgbindir = line[4..-1].rstrip
                    elsif line.start_with?('debug=')
                        @osg_debug_version = line[6..-1].rstrip.to_i != 0
                    end
                end
            end
        end
        if @osg_debug_version
            @binext = "d" + @binext
        end
        @osgversionbin = @osgbindir + "/osgversion" + @binext
	    @osgconvbin = @osgbindir + "/osgconv" + @binext
	    @osgviewerbin = @osgbindir + "/osgviewer" + @binext

	    if not File.exists?(@osgconvbin) or not File.exists?(@osgviewerbin)
		    UI.messagebox("Failed to find conversion/viewing tools!\nosgconv: #{@osgconvbin}\nosgviewer: #{@osgviewerbin}")
		    return
	    end

        @osg_versions = {
            "latest" => 158,
            "3.6" => 158,
            "3.5" => 148,
            "3.4" => 131
            }

        osg_menu = UI.menu("File").add_submenu("Export to OpenSceneGraph")

	    osg_menu.add_item("Export entire document to IVE...") { self.exportToOSG(false, ".ive") }
		osg_menu.add_item("Export entire document to OSG binary...") { self.exportToOSG(false, ".osgb") }
        osg_menu.add_item("Export entire document to OSG XML...") { self.exportToOSG(false, ".osgx") }
	    osg_menu.add_item("Export entire document to OSG text...") { self.exportToOSG(false, ".osgt") }

	    osg_menu.add_separator

	    selItem = osg_menu.add_item("Export selection to IVE...") { self.exportToOSG(true, ".ive") }
	    osg_menu.set_validation_proc(selItem) {self.selectionValidation()}
		
	    selItem = osg_menu.add_item("Export selection to OSG binary...") { self.exportToOSG(true, ".osgb") }
	    osg_menu.set_validation_proc(selItem) {self.selectionValidation()}

	    selItem = osg_menu.add_item("Export selection to OSG XML...") { self.exportToOSG(true, ".osgx") }
	    osg_menu.set_validation_proc(selItem) {self.selectionValidation()}

	    selItem = osg_menu.add_item("Export selection to OSG text...") { self.exportToOSG(true, ".osgt") }
	    osg_menu.set_validation_proc(selItem) {self.selectionValidation()}

	    osg_menu.add_separator

	    osg_menu.add_item("Visit SketchupToOSG homepage") { UI.openURL(@osg_exportviacollada_extension_url) }

        file_loaded __FILE__
    end

end #module
