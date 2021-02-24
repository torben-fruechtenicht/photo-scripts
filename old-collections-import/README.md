# Scripts for migrating old collections into the main clean collection

I have a couple of old photo collections which I wanted to merge with my main collection. The problem however was that these old collections use a different directory layout, naming scheme, etc. 
The scripts here are an attempt to have a pipeline for transforming, copying and manipulating the files *AND* keeping the possibility to
tweak things depending on peculiarities of old collections.

How it works:
- find files (the source files)
- from the sources files, prepare the target destinations and any missing files (not created in the original source directories but in a tmp directory)
- copy all files
- apply some post processing (e.g. fixing timestamps, writing missing metadata)



