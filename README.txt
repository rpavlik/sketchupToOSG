SketchUp to OSG Plugin
======================

<https://github.com/rpavlik/sketchupToOSG>

Original Author: Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
<http://academic.cleardefinition.com>

Iowa State University HCI Graduate Program/VRAC

Introduction
------------

Google SketchUp is a pretty slick application, and OpenSceneGraph (OSG) is a
great 3D rendering system. SketchUp can export its models to COLLADA (.dae),
and OpenSceneGraph conveniently has a plugin to load COLLADA models, though
it (and/or its dependencies) can be tough to build. You could create native
.osg/.ive models by exporting to COLLADA, then using `osgconv` to convert
them. Since SketchUp has support for plugins written in Ruby, why not combine
the steps and make a plugin that bundles a COLLADA-capable OSG build and
can set up the COLLADA export and conversion processes for the best results?

Well, that's what this is - a plugin for combining those steps. It's been
useful to us - hopefully it's useful to you as well!

If you have modifications or improvements, they're gratefully appreciated.
Just use GitHub to fork/edit the scripts, then send a pull request if you'd
like your improvements integrated upstream.

Getting Started
---------------
A simple installer is now available.  If you would prefer to do it the
hard way:

Unzip this somewhere, and drop the osgconv folder and the
"openscenegraph_exportviacollada.rb" file into your Google Sketchup
Plugins folder, something like:

> C:\Program Files (x86)\Google\Google SketchUp 8\Plugins

No matter how you install, the results are the same. SketchUp should
have an Export to OpenSceneGraph menu under File next time you start it.
(see the screenshot named `sketchup-to-osg.jpg`)

We have only used this with the free version of Google SketchUp 8 on Windows -
compatibility with other versions is unknown.

Licenses
--------

This plugin is free and open-source software.

The Ruby scripts serving as the SketchUp plugin may be distributed under
the following license:

> Copyright Iowa State University 2011
>
> Distributed under the Boost Software License, Version 1.0.
>
> (See accompanying file `osgconv/LICENSE_1_0.txt` or copy at
> <http://www.boost.org/LICENSE_1_0.txt>)

A local copy of fileutils.rb from the upstream Ruby project is bundled.

An actual in-use instance of this plugin makes use of the OpenSceneGraph
package and its dependencies, including but not limited to COLLADA-DOM,
which have their own licenses.

Acknowledgement
---------------

If you find this useful, we would appreciate hearing from you. If you
use this for academic work, we would also appreciate a copy of the
publication and a citation: this helps make a case for our work. You may
contact the main developer, Ryan Pavlik (Iowa State University), by
email at <rpavlik@iastate.edu> or <abiryan@ryand.net>.

Paper materials and copies of publications may be mailed to:

> Ryan Pavlik
> Virtual Reality Applications Center
> 1620 Howe Hall
> Ames, Iowa 50011-2274
> USA

Of course, this plugin would not be possible without the work of the
OpenSceneGraph and COLLADA-DOM teams. Thanks to them and the others in
the open-source ecosystem supporting them.
