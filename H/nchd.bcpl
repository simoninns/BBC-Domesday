// /**
//       NCHDR - HEADER FOR NATIONAL CHART
//       ---------------------------------
//
//       Manifest definitions for the national chart
//       operation.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//        2.10.86 6        SRY         Add Regroup CV, X, Y
//                                     Remove some coords
//        3.11.86 7        SRY         Scaling factor exp.
// *********************************************************************
//        2.06.87 8        SRY         Changes for UNI
//       13.08.87 9        SRY         Modified for DataMerge
//       19.08.87 10       MH          Modified for virtual keyboard
//       14.09.87 11       PAC         Fix m.nc.ts for ARM
//       21.09.87 12       SRY         Expanded for floating point
// **/

MANIFEST
$( m.nc.origx  = 160  // Pixels from bottom left of screen to bottom left
   m.nc.origy  = 260  // of bar chart area

   m.nc.tx = 156  // Bottom left hand corner in character coordinates
   m.nc.ty = 844  // from bottom left of screen
   m.nc.tw = 1126 // width and depth in graphics coordinates
   m.nc.td = 52

   m.nc.ckeyx = 960
   m.nc.ckeyy = 40
   m.nc.ckeyw = 316
   m.nc.ckeyd = 80

   m.nc.yay    = 248
   m.nc.yaw    = 156
   m.nc.yad    = 648

   m.nc.xay    = 40
   m.nc.xaw    = 952
   m.nc.xad    = 204

   m.nc.cx = 160
   m.nc.cy = 252
   m.nc.cw = 796
   m.nc.cd = 588

   m.nc.vkeyx  = 960
   m.nc.vkeyy  = 128
   m.nc.vkeyw  = 316
   m.nc.vkeyd  = 712

   m.nc.abkeyw = 1276
   m.nc.abkeyd = 32

   m.nc.centrex = 476
   m.nc.centrey = 546
   m.nc.radius  = 282

   // General constants

   m.nc.gnb = 20    // Bytes in a group name
   m.nc.lines = 20  // Lines in a page - regroup
   m.nc.tlY   = m.nc.lines * 40 // Y-coord of prompt line in page
   m.nc.nameX = 160 // Name text in a page
   m.nc.abX   = 96  // Abbreviation text


   // $MSC
   // The next two are machine specific - depends on speed of machine
   m.nc.ts = 6000    // Value for ten seconds - action routine calls
   m.nc.aw = 40     // Animation wait = .4 seconds
   // $MSC

   m.nc.maxnames = 20 // Maximum user group names
   m.nc.lsize.b  = 42 // Bytes in a label entry
   m.nc.olsize.b = m.nc.gnb + 2 // Bytes in a group label entry
   m.nc.nm = 10     // Total number of possible display methods

   m.nc.lhead   = 2500 // Bytes of data info in header (56) +
                       // category labels - max 2352 (56 labels)
   m.nc.gname   = m.nc.lhead/bytesperword // Start of area of group names
   m.nc.gcats   = m.nc.gname + (m.nc.maxnames*m.nc.olsize.b)/bytesperword
                                          // Start of area of group categories
   m.nc.gcat.words = 650                  // 26 * 25
   m.nc.values  = m.nc.gcats + m.nc.gcat.words // Table of values for chart
   m.nc.values.words = 72                      // fixed at 3 words per bar
   v            = m.nc.values + m.nc.values.words // Start of variables in G.nc.area
   f            = v + 53           // Free area
   m.nc.cache   = f - m.nc.gname // Words to cache: m.nc.gname
   m.nc.head    = 28     // Number of bytes in dataset header
   m.nc.all     = #X01FF // 'All' group word value (stet)
   m.nc.gpwords = 26     // Words in a groupcat line (stet)
   m.nc.incg    = 25     // Word offset for included groups (stet)

   // Values for box id

   ///////////////////////////////////////////////////////////////////////////
   //                                                                       //
   //             NB. Do not change these values                            //
   //                                                                       //
   ///////////////////////////////////////////////////////////////////////////

   m.nc.unknown  = -1
   m.nc.var1     =  1
   m.nc.var2     =  2
   m.nc.var3     =  3
   m.nc.var4     =  4
   m.nc.var5     =  5
   m.nc.var6     =  6
   m.nc.group1   =  7
   m.nc.group2   =  8
   m.nc.group3   =  9
   m.nc.group4   =  10
   m.nc.group5   =  11
   m.nc.group6   =  12
   m.nc.Yaxis    =  13
   m.nc.ckey     =  14
   m.nc.ab.key   =  15
   m.nc.colkey   =  16
   m.nc.more     =  17
   m.nc.chart    =  18

   // Values for local.state

   m.nc.main    = 1   // Chart/Regroup action routine
                      // Can also be m.nc.looping = 6; see below
   m.nc.split   = 3
   m.nc.s.v     = 4
   m.nc.inc     = 5
   m.nc.cat     = 2
   m.nc.dest    = 7
   m.nc.omit    = 8
   m.nc.wait    = 9
   m.nc.on      = 10
   m.nc.input   = 11
   m.nc.comp    = 12
   m.nc.regroup = 13
   m.nc.write   = 14
   m.nc.text    = 15
   m.nc.overwrite = 16
   m.nc.error   = 17
   m.nc.on1     = 18

   // Values for chart type (as in dataset header)

   m.nc.bar     = 1  // Simple bar chart
   m.nc.BtoB    = 2  // Back to back bar chart
   m.nc.stacked = 3  // Stacked bar chart - omitted
   m.nc.ABtoB   = 4  // Adjusted BtoB - omitted
   m.nc.Astack  = 5  // Adjusted stacked - omitted
   m.nc.looping = 6  // Looping SBC
   m.nc.pie     = 7  // Pie chart
   m.nc.STSLG   = 8  // Single line time series line graph
   m.nc.sg      = 9  // Scattergram - omitted
   m.nc.MTSLG   = 10 // Multi-line TSLG

   // Byte offsets into G.nc.area for variables in dataset header

   m.nc.vars   = 0   // Number of dimensions/variables
   m.nc.datoff = 26  // Byte offset to data area
   m.nc.dsize  = 30  // Data size (1,2 or 4)
   m.nc.add    = 31  // Flag
   m.nc.norm   = 32  // Normalising factor for values
   m.nc.s.f    = 36  // 'M' or 'D' - multiply or divide by norm. fact
   m.nc.sfe    = 37  // 'E' or ' ': exponent or value: scaling factor
   m.nc.dm     = 42  // 10 bytes: list of available display methods
   m.nc.defdis = 52  // Default display method
   m.nc.colset = 53  // 3 bytes: colour set for dataset: BBC colours
   m.nc.labels.b = 56 // Start of label region

   m.nc.aoff   = 41   // Byte offset of abbreviation in a label record
   m.nc.oaoff  = m.nc.gnb + 1 // Byte offset of abbreviation in a group record

   m.nc.sf       = v      // 2 words scaling - pixels
   m.nc.cv       = v + 2  // Current independent variable
   m.nc.cc       = v + 3  // Current display method
   m.nc.lc       = v + 4  // Display method of chart on screen
   m.nc.bv       = v + 5  // base var for variable key display
   m.nc.bw       = v + 6  // \ For width of bars in bar chart
   m.nc.x        = v + 6  // / Regroup X - shared with above
   m.nc.sampsiz  = v + 7  // \ FP.LEN words: Sample size - add. vars only
   m.nc.oldx     = v + 7  // / Old x for regroup - shared with above
   m.nc.abbrevs  = v + 10  // \ Are abbreviations shown in key ?
   m.nc.rcv      = v + 10  // / Regroup CV - shared with above
   m.nc.time     = v + 11 // For measuring looping barchart times
   m.nc.l.s      = v + 12 // Local state for ACTION routines
   m.nc.sv       = v + 13 // Secondary variable or unknown
   m.nc.ca       = v + 14 // Group of abbreviation shown
   m.nc.bn       = v + 15 // \ Bar number if on chart area
   m.nc.y        = v + 15 // / Regroup Y - shared with above
   m.nc.menu     = v + 16 // Six words for local menu bar
   m.nc.pg       = v + 22 // Current page no  (Regroup)
   m.nc.mp       = v + 23 // Max page no (Regroup)
   m.nc.gplines  = v + 24 // Vector of line numbers for group index - Regroup
   m.nc.groups   = v + 37 // Number of groups in var - Regroup
   m.nc.string   = v + 38 // Byte offset from G.nc.area to string - Regroup
   m.nc.handle   = v + 39 // File handle
   m.nc.h        = v + 40 // No. of text currently coloured yellow
   m.nc.catno    = v + 41 // Category no. - Regroup
   m.nc.nb       = v + 42 // No. of bars in current chart
   m.nc.soc      = v + 43 // FP.LEN-word socratic interval (1,2,5 scaled)
   m.nc.int      = v + 46 // No. socratic intervals (3, 4, 5)
   m.nc.dataptr  = v + 47 // 2-word byte offset from start of DATA1/2
   m.nc.itemsave = v + 49 // 2-word save area for itemaddress
   m.nc.sy       = v + 51 // Starty for barchart xaxis
   m.nc.name.buff = v + 52 // pointer to name buffer for vptr & gptr
$)
