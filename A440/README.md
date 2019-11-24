# Archimedes A440 build environment
This directory contains the required scripts to create a Domesday build environment for the Acorn Archimedes A440/1.

# Instructions
Run the following command to create the build environment:

python3 generate-a440.py 

This will create a directory of source under the top-level directory 'ARC'.

The files will be given ',fff' style extensions to indicate the target RISC OS file extension.  Copy the resulting directory to the Archimedes using a utility like !FTPc; this will copy the files and automatically set the file-type on the target machine.

Note that the root paths in both .bcpl get commands and .obey star commands will be set to "IDEFS::Development.$.Domesday.ARC" (to-do: make this a command line option)

# Compiling the source code
To be added
