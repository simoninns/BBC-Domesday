# Archimedes A500 build environment
This folder will eventually contain the scripts for assembling the BCPL source into an Archimedes build environment.

This will require setting the RISC OS filetype according to the file extension and then removing the file extension.  Probably best to move the files from src/ to a temporary directory under the A500 directory (so that any source changes are common to all build environments).

Right now there are 3 files here:

* settypes - A text file noting all the required filetypes by original filename
* !boot,ffe - The orignal A500 !boot file with aliases for the compilation tools
* assemble,ccc - A simple script for assembling ARM code



