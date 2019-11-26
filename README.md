# BBC-Domesday
The original source code for the BBC Domesday system (Acorn AIV) taken from an Archimedes A500 development machine used at Logica in the 80s.  Note that the current BCPL source is the version for the Archimedes which is modified from the original BBC Acorn Master machine used in the AIV set-up.

All BCPL files have been renamed with .bcpl and batch files (containing star commands) have .obey extensions or .comm extentions (the original ARTHUR operating system used on the A500 did not use file extensions (files had 'types' instead).  The batch files contain the original commands for compiliing the software using the A500.  Any text files have been renamed with .txt

Note that the 'UT' directory contains .asm files that form the assembly language drivers for supporting things like VFS on the A500.

# Source code map
Various directories available under the src directory:

* CF - Community Find overlay
* CM - Community Map
* CO - Community Map Options
* CP - Community PHTX overlay
* CT - Community Text parts of PHTX overlay
* DH - Data Handler
* GH - Global Headers
* GHDRS - Global Headers
* H - Headers
* HDRS - Headers
* HE - Help
* KE - Kernel
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
* SC - System Calls (description not clear)
* SI - State table initialisation
* UT - Utilities package
* UTILS - Utilities
* VH - Video Handler
* VIEW - Word list


