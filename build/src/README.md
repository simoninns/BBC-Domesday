# Source code
This folder contains the source code of the BCPL and ARM assembly code for the Domesday system

# File types
In order to preserve file-types within git the following extensions are used:

* .b - A BCPL source file
* .h - A BCPL header file
* .a - An ARM assembly file
* .obey - A RISC OS 'Obey' file (list of star commands)
* .comm - A RISC OS 'Command' file (list of commands)
* .txt - An ASCII text file

# RISC OS File type mapping
The following mappings should be used to convert file extensions to RISC OS file-types

* .b = &fff (ASCII text)
* .h = &fff
* .a = &fff
* .obey = &feb (Obey command file)
* .comm = &ffe (Command file)
* .txt = &fff

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
        * Contains modules to generate the required state tables.  This is not part of the core retrieval software - it creates a executable called STINIT that is responsible for creating the state tables required by the kernel.  STINIT is used during the build process to make the required tables (but is not executed as part of the normal runtime activity of the Domesday retrieval system)
    * UT - Utility functions
        * Contains various utilities used by the rest of the modules (such as debug, bookmark load/save, etc.)
    * UTILS - Utilities
        * This contains the overall build command scripts to assemble the runnable kernel image and Community/National specific code
    * VH - Video Handler
        * The video handler contains routines for accessing video content from the Domesday LaserDisc including FCode interaction and frame number polling
    * VIEW - Word list
* Community functions
    * CF - Community Find overlay
        * Find using "Map by Grid Reference", "Map by Place Name" and "Text and Photos by Topic"
    * CM - Community Map
        * Community map text overlay and Map Record Translation Tables (for locating file locations of maps)
    * CO - Community Map Options
        * Map overlay options handlers including sideways scrolling between maps
    * CP - Community Photograph and text captions (PHTX) overlay
        * Routines for displaying photographs with text overlays
    * CT - Community Text parts of PHTX overlay
        * Text handling for the photograph overlays.  Text content is divided int "AA" and "Schools text", 
* National functions
    * NA - National Area overlay
        * Routines for establishing an area of interest and then providing a text overlay of options for the area
    * NC - National Chart overlay
        * Routines for creating and displaying charts based on national statistics data
    * NE - National Essay (text overlay)
        * National essays are a collection of text articles included on the National disc.  Contains routines for displaying essays
    * NF - National Find
        * Routines for finding content on the National disc.  Code comments state this is a 'chopped-down' version of the Community Find Overlay (CF)
    * NM - National Mappable Analyse
        * Routines for handling National disc mappable data (i.e. statistics that are tied to mappable locations)
    * NN - National Map
        * Routines for handling National mapping data (and interacting with the gazetteer)
    * NP - National Photo overlay
        * Routines for displaying National photo sets
    * NT - National Text overlay
        * Routines for handling the National contents data
    * NV - National Video
        * Routines for handling the video content on the CLV (side B) of the National disc
    * NW - National Walk
        * Routines to provide the surrogate walks (including the top-level gallery itself)

# Build, join and linking order

## A500 version executable generation
The A500 version of the build process differs from the original BBC Master version in the way the resulting BCPL files are linked and joined; all executables are combined into a single 'kernel' image.  The following lists show the way the executable files are combined through the join and link stages of the build:

* l.kernel
    * DH.c.kernel
        * dh1
        * dh2
        * seldisc
        * userdata
    * SC.c.kernel
        * k1
            * graph1
            * graph2
            * text1
            * text2
            * text3
            * input
            * number
        * virtual
        * getact
        * menu
        * mouse
        * textlnk
        * icon
        * setfont
        * chart9
    * UT.c.kernel
        * k1
            * utils1
            * utils2
            * utils3
            * utils4
            * calc32b
            * errtext
        * print
        * write
        * grid1
        * grid2
        * bookmark
        * helplnk
        * download
    * VH.c.kernel
        * vh1
        * vh2
        * vh3
* l.community
    * l.mapoverlay
        * l.map
            * CM.c.map0
            * CM.c.map1
            * CM.c.map2
            * CM.c.map3
            * CM.c.map4
            * CM.c.map5
            * CM.c.map6
            * CM.c.cm0
            * CM.c.cm1
            * CM.c.cm2
            * CM.c.cm3
            * CM.c.cm4
        * l.mapopt
            * CO.c.mapopt1
            * CO.c.mapopt2
            * CO.c.mapopt3
            * CO.c.mapopt4
            * CO.c.mapopt5
            * CO.c.mapopt6
            * CO.c.mapopt7
            * CO.c.mapopt8
    * l.phtx
        * l.cphoto
            * CP.c.cominit
            * CP.c.compho1
            * CP.c.compho2
        * l.sctext
            * CT.c.gentext1
            * CT.c.gentext2
            * CT.c.ctext1
            * CT.c.ctext2
            * CT.c.ctext3
            * CT.c.ctext4
        * l.aatext
            * CT.c.aatext1
            * CT.c.aatext2
            * CT.c.aatext3
            * CT.c.aatext4
    * l.find
        * CF.c.find0
        * CF.c.find1
        * CF.c.find2
        * CF.c.find3
        * CF.c.find4
        * CF.c.find5
        * CF.c.find6
        * CF.c.find7
        * CF.c.find8
* l.national
    * l.walk
        * NW.c.nv0
        * NW.c.nv1
        * NW.c.nv2
    * l.contents
        * NT.c.nt0
        * NT.c.nt1
        * NT.c.nt2
        * NT.c.nt3
    * l.natfind
        * NF.c.find0
        * NF.c.find1
        * NF.c.find2
        * NF.c.find3
        * NF.c.find5
        * NF.c.find7
        * NF.c.find9
    * l.area
        * NA.c.area0
        * NA.c.area
        * NA.c.area2
        * NA.c.area3
        * NA.c.area4
    * l.chart
        * NC.c.chart0
        * NC.c.chart1
        * NC.c.chart2
        * NC.c.chart3
        * NC.c.chart4
        * NC.c.chart5
        * NC.c.chart6
        * NC.c.chart7
        * NC.c.chart8
    * l.text
        * NE.c.natinit
        * NE.c.ntext1
        * NE.c.ntext2
        * NE.c.ntext3
        * NE.c.ntext4
        * NE.c.ntext5
        * NE.c.ntext6
    * l.photo
        * NP.c.natinit
        * NP.c.natpho1
        * NP.c.natpho2
        * NP.c.natpho3
    * l.mapproc
        * l.nm
            * t1
                * NM.c.dy
                * NM.c.map1
                * NM.c.map2
                * NM.c.map3
                * NM.c.analyse1
                * NM.c.analyse2
                * NM.c.analyse3
                * NM.c.analyse4
            * t2
                * NM.c.compare1
                * NM.c.compare2
                * NM.c.process
                * NM.c.unpack
                * NM.c.load1
                * NM.c.load
            * t3
                * NM.c.subsets
                * NM.c.frame
                * NM.c.key1
                * NM.c.key2
                * NM.c.utils
                * NM.c.utils2
        * l.nn
            * X1
                * NN.c.area
                * NN.c.auto1
                * NN.c.auto2
                * NN.c.auto3
                * NN.c.auto4
                * NN.c.class32
                * NN.c.context
                * NN.c.correl1
                * NN.c.correl2
            * X2
                * NN.c.detail1
                * NN.c.detail2
                * NN.c.display1
                * NN.c.display2
                * NN.c.fpwrite
                * NN.c.link
                * NN.c.manual1
                * NN.c.manual2
            * X3
                * NN.c.mpadd
                * NN.c.mpconv
                * NN.c.mpdisp
                * NN.c.mpdiv
                * NN.c.name
                * NN.c.plot
                * NN.c.rank
                * NN.c.write
            * X4
                * NN.c.retr1
                * NN.c.retr2
                * NN.c.retr3
                * NN.c.retr4
                * NN.c.sortrank
                * NN.c.tiefactor
                * NN.c.treesort
                * NN.c.valid
                * NN.c.window
            * X5
                * NN.c.rankop1
                * NN.c.rankop2
                * NN.c.rankop4

The final (single) executable is generated by joining:
* r.kernel
    * $.alib.lib
    * KE.c.kernel
        * KE.c.init
        * KE.c.root
        * KE.c.general
        * KE.c.sram
        * KE.c.kernel1
        * KE.c.kernel2
    * l.kernel
    * l.community
    * l.national
    * l.help

Note: l.film is orphaned by the build process (i.e. not linked into the final kernel image):
* l.film
    * NV.c.nv0
    * NV.c.nv1
    * NV.c.nv2

## A500 version state table generation
In the A500 version the state tables are generated separately from the kernel:

* r.stinit
    * $.Alib.Lib
    * t1
        * SI.c.stinit
        * SI.c.rcom
        * SI.c.rexam
        * SI.c.rgalwal
        * SI.c.rhe
        * SI.c.rnm
        * SI.c.rsear
    * SI.c.scom
    * SI.c.sexam
    * SI.c.sgalwal
    * SI.c.she
    * SI.c.snm
    * SI.c.ssear

## A500 version help generation
The help files (which must be linked before generating the kernel) are combined in the state-table generation link stage:

* l.help
    * HE.c.helpinit
    * HE.c.help0
    * HE.c.help1
    * HE.c.helpA
    * HE.c.helpB
    * HE.c.helpC
    * HE.c.helpD
    * HE.c.htext1
    * HE.c.htext2
    * HE.c.htext4
    * HE.c.htext5
    * HE.c.htext6
    * HE.c.htext7

## Words list
There is a words.txt file located in the VIEW directory.  They are loaded into a vector called G.menuwords in the kernel; see file KE/root.b.
