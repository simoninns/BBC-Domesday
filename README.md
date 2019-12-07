# BBC-Domesday
The original source code for the BBC Domesday system (Acorn AIV) taken from an Archimedes A500 development machine used at Logica in the 80s.  Note that the current BCPL source is the version for the Archimedes which is modified from the original BBC Acorn Master machine used in the AIV set-up.

All BCPL files have been renamed with .bcpl and batch files (containing star commands) have .obey extensions or .comm extentions (the original ARTHUR operating system used on the A500 did not use file extensions (files had 'types' instead).  The batch files contain the original commands for compiliing the software using the A500.  Any text files have been renamed with .txt

Note that the 'UT' directory contains .asm files that form the assembly language drivers for supporting things like VFS on the A500.

# Building the source
Right now the aim of the repo is to recreate the build environment found on the original A500 machine; this presents several issues.  Firstly the build environment is tied to the type of hard drive used in the machine and the position of the top-level directory.  To fix this issue there is a python script which rewrites tokens in the build source according to the required target.

For example, if you want to compile on in arculator (an Archimedes emulator) you will need to set up a machine image with at least 20Mb of hard drive.  The root of the hard drive will typically be "ADFS::4.$".  On a physical machine with IDE this could be "IDEFS::Dev1.$.Domesday" as another example.  The process should be similar for both real machines and emulators.

Clone the repo onto a Linux machine using a command such as:

    git clone https://github.com/simoninns/BBC-Domesday

Next move into the 'arthur' directory (note: this seems to compile ok in Arthur 1.20, RISC OS 2 and RISC OS 3):

    cd BBC-Domesday/arthur

Now run the generate-arthur python script using the correct target location for your build machine:

    python3 generate-arthur.py --target="ADFS::4.$.Domesday"

This will generate a set of source files under arthur/root.  The build scripts and source files will be written with the correct file paths according to the --target you set.  The python script will also replace the original file extensions with a hexadecimal number representing the RISC OS file type.

Move the contents of the root directory (without the top-level 'root') to the target environment.  You can either FTP the contents to the hostfs directory of arculator or use a RISC OS tool like !FTPc to transfer it to a real machine (don't forget to turn on the hexadecimal file extension stripping in !FTPc before transferring).  If using hostfs, transfer the files from hostfs to the virtual hard drive before using (according to the target directory you set earlier).

Next, from the Archimedes CLI perform the following (this is an example, change the values according to your set-up):

    *MOUNT 4
    *DIR ADFS::4.$.Domesday
    *!boot
    *DIR SRC.UTILS
    *BUILDSYS

That's it, the original A500 code should now compile and link as if it were the original machine.  Note that the build scripts spool the output of the build to the log folder (at the top of your build location) - you can review the final build state from those files.

Note: There is currently a bug in the original A500 build environment that causes linking to fail on the first run (the stinit executable fails to build in the linkmods step).  Right now you have to BUILDSYS twice before getting the required kernel image as this seems to be caused by an incorrect linking order.  This will be fixed shortly.

# Using the source
This is a work in progress (and there is no documentation for the environment) - so either experiment and report back your findings, or watch this space.

# Source code map
Various directories available under the src directory:

* System functions
    * DH - Data Handler
        * The Data Handler contains routines for accessing data files from the Domesday LaserDisc
    * GH - Global Headers
        * Contains the master system global definition files.  All modules 'get' these headers as they contain the definition of all global variables for the system (this prevents overlap of globals due to local definitions)
    * GHDRS - Global Headers
        * Same as GH (could be due to the Archimedes port of the code?)
    * H - Headers
        * Contains header definitions for all system, community and national modules
    * HDRS - Headers
        * Same as H (could be due to the Archimedes port of the code?)
    * HE - Help
        * Contains the help 'overlay' which sets up the help menu and contains the code for navigating the available help features
    * KE - Kernel
        * The kernel is the core of the Domesday system. It initialises the system and state tables. It contains the primary state processing loop for the system. 
    * SC - System Calls
        * Contains modules that communicate with physical hardware (such as the mouse driver)
    * SI - State table initialisation
        * Contains modules to generate the required state tables.  This is not part of the core retrieval software - it creates a executable called STINIT that is responsibile for creating the state tables required by the kernel.  STINIT is used during the build process to make the required tables (but is not executed as part of the normal runtime activity of the Domesday retrieval sytem)
    * UT - Utility functions
        * Contains various utilities used by the rest of the modules (such as debug, bookmark load/save, etc.)
    * UTILS - Utilities
        * This contains the overall build command scripts to assemble the runnable kernel image and Community/National specific code
    * VH - Video Handler
        * The video handler contains routines for accessing video content from the Domesday LaserDisc including FCode interaction and frame number polling
    * VIEW - Word list
* Community functions
    * CF - Community Find overlay
    * CM - Community Map
    * CO - Community Map Options
    * CP - Community PHTX overlay
    * CT - Community Text parts of PHTX overlay
* National functions
    * NA - National Area overlay
    * NC - National Chart overlay
    * NE - National Essay (text overlay)
    * NF - National Find
    * NM - National Mappable Analyse
    * NN - National Map (description not clear)
    * NP - National Photo overlay
    * NT - National Text overlay
    * NV - National Video
    * NW - National Walk


