# Source code
This folder contains the top-level of the BCPL and ARM assembly code for the Domesday system

# File types
In order to preserve file-types within git the following extensions are used:

* .bcpl - A BCPL source file
* .asm - An ARM assembly file
* .obey - A RISC OS 'Obey' file (list of star commands)
* .comm - A RISC OS 'Command' file (list of commands)
* .txt - An ASCII text file

# RISC OS File type mapping
The following mappings should be used to convert file extensions to RISC OS file-types

* .bcpl = &fff (ASCII text)
* .asm = &fff
* .obey = &feb (Obey command file)
* .comm = &ffe (Command file)
* .txt = &fff

# Build order
The compilation scripts use the following build order:

* buildsys
	* compsys (compile everything)
		* compker (system kernel and Help)
			* KE.comp
			* DH.comp
			* SC.comp
			* VH.comp
			* UT.comp
			* SI.comp
			* HE.comp
		* compcom (community disc overlays)
			* CO.comp
			* CM.comp
			* CP.comp
			* CT.comp
			* CF.comp
		* compnat (national disc overlays)
			* NA.comp
			* NC.comp
			* NE.comp
			* NF.comp
			* NM.comp
			* NN.comp
			* NP.comp
			* NT.comp
			* NV.comp
			* NW.comp 
	* linksys (link everything)
		* linkmods (link the system kernel modules and make l.kernel)
			* KE.linc
			* UT.linc
			* SC.linc
			* DH.linc
			* VH.linc
			* SI.linc
			* HE.linc
			* Join DH.c.kernel SC.c.kernel UT.c.kernel VH.c.kernel -to l.kernel
		* linkcom (link the community disc modules)
			* CM.linc
			* CO.linc
			* CP.linc
			* CT.linc
			* CF.linc
		* linknat (link the national disc overlays)
			* NA.linc
			* NC.linc
			* NE.linc
			* NF.linc
			* NM.linc
			* NN.linc
			* NP.linc
			* NT.linc
			* NV.linc
			* NW.linc
		* linkernel (make the kernel(s), using the bits in the l directory)
			* Join DH.c.kernel SC.c.kernel UT.c.kernel VH.c.kernel -to l.kernel
			* Join l.mapoverlay l.phtx l.find -to l.community
			* Join l.walk l.contents l.natfind l.area l.chart l.text l.photo l.mapproc -to l.national
			* Join $.alib.lib l.kernel KE.c.kernel l.community l.national l.help -to r.kernel

