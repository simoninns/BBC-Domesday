# Arthur 1.20 build environment
This directory contains the required scripts to create a Domesday build environment for the Acorn Arthur 1.20 OS.

# Instructions
Run the following command to create the build environment:

python3 generate-arthur.py 

This will create a directory of source and executables under the top-level directory 'root'.

The contents of the root directory should be transfered to the target Archimedes machine

The files will be given ',fff' style extensions to indicate the target RISC OS file extension.  Copy the resulting directory to the Archimedes using a utility like !FTPc; this will copy the files and automatically set the file-type on the target machine.  Note: You must middle-click in the !FTPc window in RISC OS, go to 'Options' and select the 'add/remove ,hex filetype' option for this to work correctly).

Note that the root paths in both .bcpl get commands and .obey star commands will be set to ":4.$" (to-do: make this a command line option)

# Compiling the source code
Copy the root directory over to the Archimedes using !FTPc and double-click on the 'root/!Boot file' to initialise the environment.
To be continued...
