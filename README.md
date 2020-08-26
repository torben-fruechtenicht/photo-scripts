# Photo scripts

A couple of Bash scripts I use in my photo post-processing and curating workflow. Although "workflow" is probably a bit far-fetched here. Let's call it "usecases" like copying files around my photo directories, adding metadata, archiving after postprocessing, etc. And most importantly, providing sidecar files for use with RawTherapee.

If anybody wants to use these scripts for their own purposes, please be advised that these work fine in my environment but I won't give any guarantees that they'll run everywhere. Everything is pretty much tied to my directory layout and similar constraints. And I wouldn't vouch for an absence of bugs so handle with care. And nothing is portable, modern Bash only.

Some more details:
- There's a couple of commands at the top level. These cover specific usecases (e.g. removing keywords or moving a file to a different album). 
- Then there is the apps directory. The scripts in there offer graphical UIs (with some help from yad) but they are delegating the actual work to the commands from the top level directory
- The rawtherapee directory has scripts for handling the more RawTherapee-related stuff
- lib directories exist in several places, they contain Bash includes (to be sourced from scripts) with functions for various smaller or larger tasks

All scripts very much rely on my directory layout:
- At the top level there are an _incoming_ and an _archive_ directory
- Below these the directory structure is identical: _YYYY/ALBUM/YYYY-MM-DD/_
- All photo files (incl. sidecars and output files) follow the same naming convention: _TITLE_YYYY_HHMM_CAMERA_NUMBER.EXT_
- Output files are located in _converted_ directories next to the photo files.
