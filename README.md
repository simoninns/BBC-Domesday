# BBC-Domesday
The original source code for the BBC Domesday system (Acorn AIV) taken from an Archimedes A500 development machine used at Logica in the 80s.  Note that the current BCPL source is the version for the Archimedes which is modified from the original BBC Acorn Master machine used in the AIV set-up.

All BCPL files have been renamed with .bcpl and batch files (containing star commands) have .obey extensions or .comm extensions (the original ARTHUR operating system used on the A500 did not use file extensions (files had 'types' instead).  The batch files contain the original commands for compiling the software using the A500.  Any text files have been renamed with .txt

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

# Domesday LaserDisc Contents
Note: These content lists are taken from the CAMiLEON Project backup of the disc data (using the ADFS *EX command).

The following fields are shown by the *EX command in the listings below:

* Object name
* Attributes
* Sequence
* Load address
* Execution address
* Length in bytes
* Start sector

## National
    National            (41)
    Drive:2             Option 02 (Run )
    Dir. $              Lib. "Unset"   

    !BOOT      LR (01)  00000E00  00000E00  00004050  000018  (16,464 bytes)
    AREA       LR (02)  00000000  00000000  00001750  0A77C0  (5,968 bytes)
    CHART      LR (03)  00000000  00000000  000049E6  0A78E0  (‭18,918‬ bytes)
    CNMAUTO    LR (04)  00000000  00000000  000016B4  0A7808  
    CNMCORR    LR (05)  00000000  00000000  00001744  0A7820  
    CNMDETL    LR (06)  00000000  00000000  0000080A  0A7838  
    CNMDISP    LR (07)  00000000  00000000  00000CB4  0A7850  
    CNMLINK    LR (08)  00000000  00000000  00000482  0A7868  
    CNMMANU    LR (09)  00000000  00000000  00000CDC  0A7880  
    CNMRETR    LR (0A)  00000000  00000000  000017B8  0A7898  
    CNMWIND    LR (0B)  00000000  00000000  00000740  0A78B0  
    CNMWRIT    LR (0C)  00000000  00000000  00000DBE  0A78C8  
    CONTENTS   LR (0D)  00000000  00000000  00000D0A  0A4FB8  
    DATA1      LR (0E)  00000000  00000000  099D0800  00B298  (‭161,286,144‬ bytes)
    DATA2      LR (0F)  00000000  00000000  03A9C800  0A9DB8  (‭61,458,432‬ bytes)
    FILM       LR (10)  00000000  00000000  00000A88  0A7988  
    FIND       LR (11)  00000000  00000000  00002BF0  0A7A30  
    FONT2      LR (12)  FFFF2800  FFFF2800  00000744  000090  
    GALLERY    LR (13)  00000000  00000000  0000D5BC  004BC0  
    GAZETTEER  LR (14)  00000000  00000000  00127000  0A6548  (‭1,208,320‬ bytes)
    HELP       LR (15)  00000000  00000000  000045AA  0A79A0  
    HELPTEXT   LR (16)  00000000  00000000  00043000  0A7AA8  
    HIERARCHY  LR (17)  00000000  00000000  00042000  0A60F8  
    INDEX      LR (18)  00000000  00000000  000A2000  0A5000  
    INIT       LR (19)  00000000  00000000  000001EC  000078  
    MAP        LR (1A)  00000000  00000000  00003F70  0A79E8  
    MAPDATA    LR (1B)  00000000  00000000  00003000  0A6518  
    MAPPROC    LR (1C)  00000000  00000000  000023C2  0A77D8  
    NAMES      LR (1D)  00000000  00000000  0006C798  0A5A20  
    NATFIND    LR (1E)  00000000  00000000  00001E92  0A4FD0  
    PHOTO      LR (1F)  00000000  00000000  00000C36  0A7940  
    PHTX       LR (20)  00000000  00000000  00003310  0A7A60  
    RMLHELPT   LR (21)  00000000  00000000  00043800  0A7EE0  
    ROOT       LR (22)  00000000  00000000  0000048C  000060  
    STINIT1    LR (23)  00000000  00000000  000015C0  0000A8  
    STINIT2    LR (24)  00000000  00000000  00000CF8  0000C0  
    TEXT       LR (25)  00000000  00000000  00002222  0A7958  
    USERKERN   LR (26)  00000E00  00000E00  00004096  0A8318  
    WALK       LR (27)  00000000  00000000  00000AAA  0000F0  
    WORDS      LR (28)  00000000  00000000  00000290  0000D8  

## Community North
    Community N         (4E)
    Drive:0             Option 02 (Run )
    Dir. "Unset"        Lib. "Unset"   

    !BOOT      LR (01)  00000E00  00000E00  00004050  000018  
    AREA       LR (02)  00000000  00000000  000016FE  095160  
    CHART      LR (03)  00000000  00000000  00004782  095280  
    CNMAUTO    LR (04)  00000000  00000000  000016A0  0951A8  
    CNMCORR    LR (05)  00000000  00000000  0000154A  0951C0  
    CNMDETL    LR (06)  00000000  00000000  00000544  0951D8  
    CNMDISP    LR (07)  00000000  00000000  00000A84  0951F0  
    CNMLINK    LR (08)  00000000  00000000  0000047A  095208  
    CNMMANU    LR (09)  00000000  00000000  00000CDC  095220  
    CNMRETR    LR (0A)  00000000  00000000  000017A2  095238  
    CNMWIND    LR (0B)  00000000  00000000  0000055E  095250  
    CNMWRIT    LR (0C)  00000000  00000000  00000CE0  095268  
    CONTENTS   LR (0D)  00000000  00000000  00000D0A  092328  
    DATA1      LR (0E)  00000000  00000000  06414000  00E940  
    DATA2      LR (0F)  00000000  00000000  0272A000  0A7820  
    FILM       LR (10)  00000000  00000000  00000976  095310  
    FIND       LR (11)  00000000  00000000  00002BF0  075FA8  
    FONT2      LR (12)  FFFF2800  FFFF2800  00000744  000090  
    GAZETTEER  LR (13)  00000000  00000000  00809800  0768D8  
    HELP       LR (14)  00000000  00000000  0000456E  076020  
    HELPTEXT   LR (15)  00000000  00000000  00042800  076068  
    INDEX      LR (16)  00000000  00000000  0017E800  073260  
    INIT       LR (17)  00000000  00000000  000001EC  000078  
    MAP        LR (18)  00000000  00000000  00003F70  072C90  
    MAPDATA1   LR (19)  00000000  00000000  00058000  072CD8  
    MAPPROC    LR (1A)  00000000  00000000  000022F0  095178  
    NAMES      LR (1B)  00000000  00000000  00154C2C  074A48  
    NATFIND    LR (1C)  00000000  00000000  00001E92  092340  
    PHOTO      LR (1D)  00000000  00000000  00000C36  0952C8  
    PHTX       LR (1E)  00000000  00000000  00003310  075FD8  
    RMLHELPT   LR (1F)  00000000  00000000  00042800  0764A0  
    ROOT       LR (20)  00000000  00000000  0000048C  000060  
    STINIT1    LR (21)  00000000  00000000  000015C0  0000A8  
    STINIT2    LR (22)  00000000  00000000  00000CF8  0000C0  
    TEXT       LR (23)  00000000  00000000  00002210  0952E0  
    USERKERN   LR (24)  00000E00  00000E00  00004096  095610  
    WALK       LR (25)  00000000  00000000  00000AAA  092310  
    WORDS      LR (26)  00000000  00000000  00000290  0000D8  

## Community South
    Community S         (53)
    Drive:1             Option 02 (Run )
    Dir. $              Lib. "Unset"   

    !BOOT      LR (01)  00000E00  00000E00  00004050  000018  
    AREA       LR (02)  00000000  00000000  000016FE  095160  
    CHART      LR (03)  00000000  00000000  00004782  095280  
    CNMAUTO    LR (04)  00000000  00000000  000016A0  0951A8  
    CNMCORR    LR (05)  00000000  00000000  0000154A  0951C0  
    CNMDETL    LR (06)  00000000  00000000  00000544  0951D8  
    CNMDISP    LR (07)  00000000  00000000  00000A84  0951F0  
    CNMLINK    LR (08)  00000000  00000000  0000047A  095208  
    CNMMANU    LR (09)  00000000  00000000  00000CDC  095220  
    CNMRETR    LR (0A)  00000000  00000000  000017A2  095238  
    CNMWIND    LR (0B)  00000000  00000000  0000055E  095250  
    CNMWRIT    LR (0C)  00000000  00000000  00000CE0  095268  
    CONTENTS   LR (0D)  00000000  00000000  00000D0A  092328  
    DATA1      LR (0E)  00000000  00000000  06414000  00E940  
    DATA2      LR (0F)  00000000  00000000  04C86000  0A7820  
    FILM       LR (10)  00000000  00000000  00000976  095310  
    FIND       LR (11)  00000000  00000000  00002BF0  07BFD8  
    FONT2      LR (12)  FFFF2800  FFFF2800  00000744  000090  
    GAZETTEER  LR (13)  00000000  00000000  00809800  07C908  
    HELP       LR (14)  00000000  00000000  0000456E  07C050  
    HELPTEXT   LR (15)  00000000  00000000  00042800  07C098  
    INDEX      LR (16)  00000000  00000000  004B3000  073380  
    INIT       LR (17)  00000000  00000000  000001EC  000078  
    MAP        LR (18)  00000000  00000000  00003F70  072C90  
    MAPDATA1   LR (19)  00000000  00000000  0006A800  072CD8  
    MAPPROC    LR (1A)  00000000  00000000  000022F0  095178  
    NAMES      LR (1B)  00000000  00000000  00411D8C  077EB0  
    NATFIND    LR (1C)  00000000  00000000  00001E92  092340  
    PHOTO      LR (1D)  00000000  00000000  00000C36  0952C8  
    PHTX       LR (1E)  00000000  00000000  00003310  07C008  
    RMLHELPT   LR (1F)  00000000  00000000  00042800  07C4D0  
    ROOT       LR (20)  00000000  00000000  0000048C  000060  
    STINIT1    LR (21)  00000000  00000000  000015C0  0000A8  
    STINIT2    LR (22)  00000000  00000000  00000CF8  0000C0  
    TEXT       LR (23)  00000000  00000000  00002210  0952E0  
    USERKERN   LR (24)  00000E00  00000E00  00004096  095610  
    WALK       LR (25)  00000000  00000000  00000AAA  092310  
    WORDS      LR (26)  00000000  00000000  00000290  0000D8  
    
## Source file generation modules
The following section of the source should create the required executable in the 'r' directory:

    NA - AREA
    NC - CHART
    NN - CNMAUTO
    NN - CNMCORR
    NN - CNMDETL
    NN - CNMDISP
    NN - CNMLINK
    NN - CNMMANU
    NN - CNMRETR
    NN - CNMWIND
    NN - CNMWRIT
    NT - CONTENTS
    NV - FILM
    CF - FIND (Community)
    NF - FIND (National)
    HE - HELP
    CO - MAP
    CM - MAP
    NP - PHOTO
    CT - PHTX
    SI - STINIT1
    SI - STINIT2
    NE - TEXT
    NW - WALK

## Generated files available on the original A500 image
The following generated files are present on the original A500 build image:

    $.ARC.R/
    DOM001
    DOM002
    fast
    HTRECS
    kernel
    mapdata1
    names
    pagetest
    slow
    states
    stinit
    words

    $.t/
    cnmauto
    cnmcorr
    cnmdetl
    cnmdisp
    cnmlink
    cnmmanu
    cnmrank
    cnmretr
    cnmwind
    cnmwrit
    mapproc

    $.ARC.l/
    aatext
    area
    chart
    community
    contents
    cphoto
    film
    find
    help
    kernel
    map
    mapopt
    mapoverlay
    mapproc
    natfind
    national
    nm
    nn
    photo
    phtx
    sctext
    text
    walk
