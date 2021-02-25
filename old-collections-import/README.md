# Scripts for migrating old collections into the main clean collection

I have a couple of old photo collections which I wanted to merge with my main collection. The problem however was that these old collections use different directory layouts, naming schemes, etc. 
The scripts here are an attempt to have a pipeline for transforming, copying and manipulating the files *AND* keeping the possibility to
tweak things depending on peculiarities of old collections.
And yes, using this very flexible approach comes at a cost of higher load because the pipeline will be running a number of commands in parallel.

How it works:
- find files (the source files)
- from the sources files, prepare the target destinations and any missing files (not created in the original source directories but in a tmp directory)
- copy all files
- apply some post processing (e.g. fixing timestamps, writing missing metadata)

How it works in detail:
- to be able to e.g. take care of a weird filename scheme in an old collection, all actions are split up and are joined in a pipeline (see example in the script directory)
- after finding the files to be imported, the found source files are piped through a series of actions which build the target path. To accomplish this, these actions pass a string formatted as "<SOURCE_FILE>|<TARGET_FILE> to the next step in the pipeline. "<SOURCE_FILE>" is a full path whereas <TARGET_FILE> is a path relative to the root directory of the target collection.
- these target paths building actions will not only act on existing files to be imported but may also add new files (e.g. missing metadata files) to the pipeline stream. In that case, the source path will typically point to a location in a temp directory.
- import_files will do the actual copying. That action will not continue to pass on that source/target tuple but only echo the copied target paths (now as full paths, no longer relative to target collection root)
- afterwards post processing actions do whatever is necessary.



