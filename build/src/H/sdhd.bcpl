// /**
//       SD.HDR - SCREEN DEFINITIONS
//       ---------------------------
//
//       This file contains manifest definitions for the Domesday
//       co-ordinate systems (i.e. the sizes of the menu, display
//       and message areas, in BBC graphics units )
//
//       The manifests m.wBlank & m.wClear are copied from SIHDR.
//       Any change to SIHDR MUST be reflected here.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       06.11.85 1        P.Cunnell   Initial version
//       30.04.87 1        PAC         ADOPTED FOR UNI SYSTEM
// **/
//
MANIFEST
$(
// error message delay in centiseconds
m.sd.errdelay = 300

// types of co-ordinate systems
m.sd.none    = 0  // not in any of the others
m.sd.menu    = 1
m.sd.display = 2
m.sd.message = 3

// area origins
m.sd.menX0 = 0    // menu bar x origin
m.sd.menY0 = 0    // menu bar Y origin
m.sd.barY0 = 4    // bottom of displayed menu bar
m.sd.disX0 = 0    // display area x origin
m.sd.disY0 = 76   // display area Y origin
m.sd.mesX0 = 0    // message area x origin
m.sd.mesY0 = 976  // message area Y origin

// text origins
// preliminary values only
m.sd.mesXtex = 4   // text start in message area (X co-ord)
m.sd.mesYtex = 36  // text start in message area (Y co-ord)
m.sd.disXtex = 4   // text start in display area (X co-ord)
m.sd.disYtex = 876 // text start in display area (Y co-ord)
m.sd.menXtex = 80  // text start in menu bar
m.sd.menYtex = 40  // text start in menu bar
m.sd.seeX    = 4   // position of "See:" in a list - X
m.sd.seeY    = 36  // position of "See:" in a list - Y

// area sizes (width and height)
m.sd.menw = 1280  // menu bar width
m.sd.menh = 76    // menu bar overall height
m.sd.barh = 48    // menu bar text height
m.sd.disw = 1280  // display width
m.sd.dish = 888   // display height
m.sd.mesw = 1280  // message area width
m.sd.mesh = 48    // message area height

// tops of the various areas
m.sd.mentop = m.sd.menY0 + m.sd.menh - 1
m.sd.distop = m.sd.disY0 + m.sd.dish - 1
m.sd.mestop = m.sd.mesY0 + m.sd.mesh - 1

m.sd.charwidth = 32 // width of a character in graphics units
m.sd.charheight= 32 // height of a character in graphics units
m.sd.linw = 40      // y offset to move for each new line
m.sd.charsperline = 40  // number of characters in a line
m.sd.displines = 22     // number of text lines in display

// manifests for G.sc.opage
m.sd.propXtex = 3*m.sd.charwidth // start X pos for PS page
m.sd.histart  = '{'             // start highlighting
m.sd.histop   = '}'            // stop highlighting
m.sd.screen.page = 1           // output page to screen
m.sd.print.page  = 2           // output page to printer
m.sd.write.page  = 3           // output page to floppy disc
m.sd.invalid     = -1          // invalid data frame number
m.sd.linelength  = 39          // characters in a line
m.sd.pagelength  = 858         // chars in page (= 22 * linelength)
// a complete page in words
m.sd.opage.buffsize = (m.sd.pagelength/BYTESPERWORD)+1

// PLOT types for use by application routines
// in calls to the GRAPH primitives
m.sd.plot   = 1   // plot object in foreground colour
m.sd.clear  = 3   // clear object to background colour
m.sd.invert = 2   // plot object in logical inverse colour

/* comment out for now
// copy / move block plot types
m.sd.rec.mover = 1 // move rectangle relative
m.sd.rec.copyr = 2 // copy rectangle relative
m.sd.rec.movea = 5 // move rectangle absolute
m.sd.rec.copya = 6 // copy rectangle absolute
*/

// constants for calling g.sc.menu
//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// DANGER: m.sd.wBlank & m.sd.wClear are only copied from SIHDR
// IF SIHDR CHANGES, THEN THESE MANIFESTS MUST BE UPDATED
//
// m.sd.act is duplicated in NMCLHDR to avoid blowing the BCPL
// compiler's symbol table in some NM/NN sources; any changes
// must be made to both files
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//
m.sd.act = 1        // box active
m.sd.wBlank = #x1FF // box blank
m.sd.wClear = 25    // box has 'Clear'

// constants for calling POINTER
m.sd.on  = true  // turn mouse pointer on
m.sd.off = false // turn mouse pointer off

// constant for use with G.sc.savcur/rescur
// this is the size of the buffer required IN WORDS !!
m.sd.coordsize = 4

// constants for list output primitive
m.sd.seenumber = -1   // "See:"  selected
m.sd.hinvalid  = -999 // no item selected

// constants for calling G.sc.cachemess
m.sd.restore = 0
m.sd.save   = -1

// constants for G.sc.setfont
m.sd.schools = 1
m.sd.normal = -1

// manifests for colours
// n.b. the colours are only valid after
// the default palette has been set
m.sd.defpal = 15 // default palette

m.sd.black  = 0  // background colour
m.sd.yellow = 1
m.sd.blue   = 2
m.sd.cyan   = 3

// constants for G.sc.icon
m.sd.cross1 = 1 // blue cross
m.sd.cross2 = 2 // yellow cross
m.sd.mag.glass = 3 // magnifying glass

// logical colours for use in mode 2
m.sd.ff.col2  = 4    // first free colour in mode 2
m.sd.max.col2 = 15   // last free colour in mode 2

// physical colours for use in mode 2
// these are the actual colours,
// NOT the logical colours.
m.sd.black2   = 0    // this one ONLY is also a logical colour number
m.sd.red2     = 1
m.sd.green2   = 2
m.sd.yellow2  = 3
m.sd.blue2    = 4
m.sd.magenta2 = 5
m.sd.cyan2    = 6
m.sd.white2   = 7
m.sd.flash.white2 = 15

$)




