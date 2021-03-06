//  $MSC
//  AES SOURCE  4.87

/**
         SC.GRAPH2 - GRAPHICS PACKAGE SECOND PART
         ----------------------------------------

         This is the continuation of the graphics package, made
         necessary because of file size.

         This file contains the procedures:

         G.sc.dtob         - convert Domesday to BBC co-ords
         G.sc.btod         - convert BBC to Domesday co-ords
         G.sc.savcur       - save graphics cursor
         G.sc.rescur       - restore graphics cursor
         G.sc.setwin       - set a graphics window
         G.sc.defwin       - restore default graphics window
         G.sc.clear        - clear selected screen area
         G.sc.selcol       - select a logical colour,plot normal
         G.sc.XOR.selcol   - select a logical colour,plot XOR
         G.sc.setpal       - set up a predefined palette
         G.sc.palette      - set individual palette entries
                             (MODE 2 only)
         G.sc.pixcol       - inquire pixel colour
         G.sc.mode         - change screen mode
         G.sc.physical.colour - map logical to physical colour
         G.sc.next.colour  - return next colour in sequence
         G.sc.complement.colour   - complement physical colour
         G.sc.findmode     - return current screen mode

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87 1        PAC         ADOPTED FOR AES SYSTEM
         24.07.87 2        PAC         Remove mouse pointer calls
         25.7.87  3        PAC         Hacks to G.sc.mode, etc
         26.7.87  4        PAC         New version of mode
**/

SECTION "sc.graph2" // graphics package

get "H/libhdr.h"
get "H/syshdr.h"
get "GH/glHD.h"   // globals
get "H/SDHD.h"   // manifests header
get "H/SDPHD.h"  // private manifests

/**
         G.SC.DTOB - CONVERT DOMESDAY TO BBC CO-ORDINATES
         ------------------------------------------------

         Converts the given domesday co-ordinate to the absolute
         value required by the BBC.

         INPUTS:

         co-ordinate system -
         range <m.sd.menu, m.sd.display, m.sd.message>

         domesday Y co-ordinate

         OUTPUTS:

         bbc Y co-ordinate

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         This routine, and its companion g.sc.btod, assume that
         the X co-ordinates are the same between the two systems,
         and hence do not need conversion.

         PROGRAM DESIGN LANGUAGE:

         g.sc.dtob [ co-ord system, domesday Y -> bbc Y ]

         CASE OF co-ord system
            m.sd.menu    : bbc Y = domesday Y
            m.sd.display : bbc Y = domesday Y + m.sd.disY0
            m.sd.message : bbc Y = domesday Y + m.sd.mesY0

            default      : bbc Y = -1 (invalid)
         ENDCASE

         RETURN ( bbc Y )
**/

let G.sc.dtob ( coords, newY ) = valof

$( // this write can be used for debugging
   // writef("Call to dtob :%n %n*n",coords,newY)
   switchon coords into

   $( case m.sd.menu: // the menu bar area
         resultis ( newY + m.sd.menY0 )
      case m.sd.display :   // the display area
         resultis ( newY + m.sd.disY0 )
      case m.sd.message :   // the message area
         resultis ( newY + m.sd.mesY0 )
   $)

   // otherwise, no co-ordinate system
   resultis ( -1 )
$)


/**
         G.SC.BTOD - CONVERT BBC TO DOMESDAY CO-ORDINATES
         ------------------------------------------------

         Convert bbc co-ordinate to domesday co-ordinate

         INPUTS:

         bbc Y co-ordinate

         OUTPUTS:

         domesday Y co-ordinate

         domesday co-ordinate system
         ( see g.sc.dtob for range )

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         This routine, and its companion g.sc.dtob, assume that
         the X co-ordinates are the same between the two systems,
         and hence do not need conversion.

         PROGRAM DESIGN LANGUAGE:

         g.sc.btod [ bbc Y -> co-ord system, domesday Y ]

         IF bbc Y is within menu bar
            THEN  system = m.sd.menu
                  domesday Y = bbc Y
            ENDIF
         ELSE IF bbc Y is within display area
            THEN  system = m.sd.display
                  domesday Y = bbc Y - m.sd.disY0
            ENDIF
         ELSE IF bbc Y is within message area
            THEN  system = m.sd.message
                  domesday Y = bbc Y - m.sd.mesY0
            ENDIF
         ELSE  system = m.sd.none
               domesday Y = bbcY (invalid)
            ENDIF

         RETURN

**/

AND g.sc.btod ( bbcY,domY ) = VALOF
$( LET system = ?

   TEST (bbcY >= m.sd.menY0) & (bbcY <= m.sd.mentop)

      THEN $( system := m.sd.menu; !domY := bbcY-m.sd.menY0 $)
      ELSE
         TEST (bbcY >= m.sd.disY0 ) & (bbcY <= m.sd.distop)

            THEN $( system := m.sd.display; !domY := bbcY-m.sd.disY0 $)
            ELSE
               TEST (bbcY >= m.sd.mesY0) & (bbcY <= m.sd.mestop)

                  THEN $( system := m.sd.message; !domY := bbcY-m.sd.mesY0 $)
                  ELSE
                     $( system := m.sd.none; !domY := bbcY $) // default - invalid

   RESULTIS system
$)
// end of btod

/**
         G.SC.SAVCUR - SAVE    GRAPHICS CURSOR
         G.SC.RESCUR - RESTORE GRAPHICS CURSOR
         -------------------------------------

         These routines allow 'transparent' use of graphics
         facilities by routines such as menu bar draw, message
         o/p, etc. The common argument is the address of a four
         word vector, which is used to save the positions. This
         routine uses OSWORD call with A= #x0D.

         INPUTS:

         pointer to vector, in which the last 2 cursor positions
         are stored

         OUTPUTS:

         The vector is as follows:

            pointer!0 = previous X position
            pointer!1 = previous Y position
            pointer!2 = current  X position
            pointer!3 = current  Y position

         All these are in BBC screen co-ords

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Declare the vector as <name> VEC m.sd.coordsize in the
         calling routine, then call G.sc.savcur ( <name> ), or
         G.sc.rescur ( <name> ). The co-ords in the vector are
         available if you want them, but no manipulation of them
         should be attempted if the routine is to be transparent.

         PROGRAM DESIGN LANGUAGE:

         G.sc.savcur  [ pointer to vector ]
         -----------
         Save current cursor positions in given vector, using
         operating system call.

         G.sc.rescur  [ pointer to vector ]
         -----------
         Restore cursor positions using the information in the
         vector to move to last two positions visited.
**/

// get last two graphics cursor positions
and g.sc.savcur ( resptr ) be       
$(
   LET myvec = VEC 8/BYTESPERWORD
   Osword( #x0D, myvec ) 
                     
   FOR i = 0 TO 3 DO
   resptr!i := myvec%(2*i) + (myvec%(2*i+1) << 8)
$)

// restore last two graphics cursor positions
and g.sc.rescur ( pptr ) be
$( VDU ("25,4,%;%;25,4,%;%;", pptr!0, pptr!1, pptr!2, pptr!3 ) $)

/**
         G.SC.SETWIN - SET A GRAPHICS WINDOW
         -----------------------------------

         Allows setting of a graphics window, by providing a
         call to VDU 24. See BBC USER guide for details.

         INPUTS:

         Bottom left X,Y co-ordinates
         Top right   X,Y co-ordinates

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         The co-ordinates are assumed to have their origin at the
         bottom left hand corner of the display area, NOT the
         bottom LH of the whole screen.

         PROGRAM DESIGN LANGUAGE:

         G.sc.setwin [ Bottom Left X , Bottom Left Y,
         -----------   Top Right X, Top Right Y ]

         Define a graphics window using supplied co-ords
         RETURN
**/
AND G.sc.setwin ( Xmin,Ymin,Xmax,Ymax ) BE
$( $<debug
      G.ut.trap ("SC",27,false,3,Xmax,Xmin,1280)
      G.ut.trap ("SC",28,false,3,Ymax,Ymin,1024)
   $>debug

   VDU("24,%;%;%;%;",
        Xmin + m.sd.disX0,
        Ymin + m.sd.disY0,
        Xmax + m.sd.disX0,
        Ymax + m.sd.disY0 )
$)

/**
         G.SC.DEFWIN - SET DEFAULT GRAPHICS WINDOW
         -----------------------------------------

         Resets the graphics window to its default value
         (covering the whole of the micro display)

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         This is only needed for the mappable data overlay, to
         enable the screen window to be reset to normal. It
         resets the graphics cursor to the bottom LH corner of
         the micro display.

         PROGRAM DESIGN LANGUAGE:

         G.sc.defwin []
         -----------
         Reset default graphics window
**/
AND G.sc.defwin() BE
$( VDU("26") $)

/**
         G.SC.CLEAR - CLEAR SELECTED AREA
         --------------------------------

         Clear selected micro display area to graphics background
         colour.

         INPUTS:

         Co-ordinate system (m.sd.menu,m.sd.display,m.sd.message)

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         The whole area is cleared. If only a portion of a
         particular area needs to be cleared, then use G.sc.rect
         with a plot in background (m.sd.clrR) as plot type. As
         above, this routine assumes that the screen is the whole
         width of the display area. The cursor is left at the top
         right hand side of the area.

         There is an undefined area between the message area and
         the display area.  When clearing the message area this
         is cleared too.   DNH 8.10.86

         PROGRAM DESIGN LANGUAGE:

         G.sc.clear [ co-ordinate system ]
         ----------
         top right X co-ordinate = display width-1
         CASE OF co-ordinate system
            m.sd.menu    : top right Y = menu bar height-1
                           move to bottom left of menu area
            m.sd.display : top right Y = display height-1
                           move to bottom left of display area
            m.sd.message : top right Y = message height-1
                           move above top of display area
         ENDCASE
         draw rectangle relative in current graphics b/g
            to top right X, top right Y
         RETURN
**/
and G.sc.clear ( system ) be
$( LET topx,topy = ?,?
   $<debug G.ut.trap ("SC",29,false,3,system,m.sd.menu,m.sd.message)
   $>debug

   topx := m.sd.disw-1
   SWITCHON system INTO
   $( CASE m.sd.menu:         // the menu bar area
         g.sc.movea ( system, 0, 0 )
         topy := m.sd.menh-1
         ENDCASE
      CASE m.sd.display :     // the display area
         g.sc.movea ( system, 0, 0 )
         topy := m.sd.dish-1
         ENDCASE
      CASE m.sd.message :     // the message area
                  // modified by DNH 8.10.86
         g.sc.movea ( m.sd.display, 0, m.sd.disH )
         topy := m.sd.mesY0 - m.sd.menH - m.sd.disH + m.sd.mesH - 1
         ENDCASE
      DEFAULT : RETURN
   $)
   g.sc.rect ( m.sd.clrR,topx,topy )    // clear the area
$)

/**
         G.SC.SELCOL - SELECT A LOGICAL COLOUR
         G.SC.SETPAL - SET UP PALETTE TO PRESET MIX
         ------------------------------------------

         g.sc.selcol     : select colour
         g.sc.XOR.selcol : select colour in XOR mode

         g.sc.setpal   : set up palette to predefined colours

         INPUTS:

         g.sc.selcol    ( colour )  equivalent to GCOL 0, COLOUR
         g.sc.XOR.selcol( colour )  equivalent to GCOL 3, COLOUR

         g.sc.setpal ( choice )  choice is 1->30

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         The parameter to SETPAL gives the selection from the
         range of predefined palettes. The default palette for
         most operations is palette 15, which has a manifest in
         sdhdr - m.sd.defpal.
         It may be assumed that the palette has been set up by
         the system initialise, so that palette changes are not
         normally done by overlays, the exception being the
         graph plotting code. If you change the palette, then
         RESTORE IT when you've finished !!

**/

and g.sc.selcol ( colour ) be
$( vdu ("18,0,%",colour) $) // equivalent to GCOL 0, COLOUR

and g.sc.XOR.selcol( colour ) be
$( vdu ("18,3,%",colour) $) // equivalent to GCOL 3, COLOUR

//
// N.B. this routine is highly word-size specific
// and is probably only used with parameter 15 (m.sd.defpal)
// To be sorted out in due course
//
and g.sc.setpal ( choice ) be
$( let coltab = table   #x123, #x127, #x137, #x163, #x167, #x172,
                        #x214, #x251, #x254, #x314, #x351, #x354,
                        #x426, #x432, #x346, #x437, #x467, #x472,
                        #x523, #x526, #x527, #x537, #x563, #x567,
                        #x614, #x651, #x654, #x741, #x751, #x754
// that's a 30 word table: 1 entry for each colour
   let ptr = ? // colour table pointer

   $<debug G.ut.trap ("SC",30,false,3,choice,1,30)
   $>debug

   ptr := choice-1 // table starts at 0
   vdu ("19,1,%;0;",(coltab!ptr & #x0F00) >>8 )
   vdu ("19,2,%;0;",(coltab!ptr & #x00F0) >>4 )
   vdu ("19,3,%;0;",(coltab!ptr & #x000F) )
$)                   

/**
         G.SC.PALETTE - ASSIGN LOCICAL COLOUR TO ACTUAL COLOUR
         -----------------------------------------------------

         INPUTS:

         Logical colour
         Actual  colour

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         This routine is provided for the mappable data overlay.
         It should not normally be used elsewhere: G.sc.setpal is
         provided to alter the complete mode 1 palette to a
         default configuration.
         It is expected that the mappable data overlay will use
         logical colours 8 - 15, to minimise interaction with
         other routines, but the code makes no assumptions about
         the number of the colour being modified.

         PROGRAM DESIGN LANGUAGE:

         G.sc.palette [ logical colour, actual colour ]
         ------------
         Assign the logical entry in the machine's palette to the
         actual colour given.
         Example:
         G.sc.palette (1, m.sd.blue ) - make colour 1 blue
**/
and G.sc.palette ( logcol,actcol ) be
$( VDU("19,%,%;0;",logcol,actcol ) $)

/**
         G.SC.PIXCOL - INQUIRE PIXEL COLOUR
         ----------------------------------

         Finds out the logical colour at the current graphics
         point.

         INPUTS:

         none

         OUTPUTS:

         logical colour of pixel at current point, or #xFF if the
         point is off the screen.

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Move to the required point BEFORE calling this routine

         PROGRAM DESIGN LANGUAGE:

         G.sc.pixcol []
         -----------
         Find out current graphics position using OSWORD command
         Find out colour at point using OSWORD command
         RETURN
**/

// This routine is M/C specific AND wordsize specific

AND G.sc.pixcol() = VALOF
$( // LET oldstate = G.sc.pointer( m.sd.off )   // turn off pointer
   LET coords = VEC 8/bytesperword           // parameter block for OSWORD
  
   Osword( #x0D, coords )                    // get coordinates
   coords!0 := coords!1                      // adjust pointer to last point
   Osword( 9, coords )                       // get colour
  
   // G.sc.pointer( oldstate )                  // restore pointer
   RESULTIS ( coords%4 )                     // return colour
$)
/**
         G.SC.MODE - SET SCREEN MODE
         ---------------------------

         Set up the required screen mode, join cursors and select
         default palette.

         INPUTS:

         number of mode

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         This routine is ONLY to be used by the mappable data
         overlay, which is required to reset the mode to mode 1
         on exit.

         PROGRAM DESIGN LANGUAGE:

         G.sc.mode [ mode.number ]
         ---------
         Set screen mode to number
         Join text and graphics cursors
         Set up default palette
**/

AND G.sc.mode ( number ) BE
$( // LET oldstate = G.sc.pointer (m.sd.off)

   $<debug
     G.ut.trap("SC",31,true,3,(number & #x7F),0,20)
   $>debug

   TEST number > 127
   THEN
   $(
      OsByte(112,0)
      OsByte(113,0)
      OsByte(114,0)
      number := 137 // shadow mode 1
   $)
   ELSE 
   $( VDU("12") 
      number := ((number = 2) | (number = 9)) -> 9,1 
   $)

   VDU("22,%,5",number)       // set the mode

   IF number < 127 THEN
   $(
      OsByte(112,1) // select main memory for VDU access
      OsByte(113,1) // page back main memory for screen
      OsByte(114,1) // select main memory on next mode change
   $)

   G.sc.setpal (m.sd.defpal)  // select default palette
   // G.sc.pointer (oldstate)
$)

/**
         G.SC.FINDMODE - INQUIRE SCREEN MODE
         -----------------------------------

         INPUTS:

         none

         OUTPUTS:

         current screen mode number (0-20)

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         Use OPSYS #x87 to read current screen mode
         mask top bit of mode number
**/
AND G.sc.findmode() = VALOF
$( 
   Osbyte(#x87)

   RESULTIS (Result2 & #x7F) // mask top bit
$)
/**
         G.SC.PHYSICAL.COLOUR - MAP LOGICAL TO PHYSICAL COLOUR
         -----------------------------------------------------

         returns the physical colour corresponding to the
         the given logical colour.

         PROGRAM DESIGN LANGUAGE

         G.sc.physical.colour [ logical.colour ]
         --------------------
         read palette to map logical.colour -> physical.colour
         = physical.colour
**/
AND G.sc.physical.colour ( logical.colour ) = VALOF
$( LET block = VEC 2                         // parameter block for OSWORD call
   block%0 := logical.colour ; block!1 := 0  // set up required colour
   Osword( #x0B, block )                     // get physical colour
   RESULTIS ( block%1 )                      // return colour
$)

/**
         G.SC.COMPLEMENT.COLOUR - COMPLEMENT PHYSICAL COLOUR
         ---------------------------------------------------
         returns the physical colour corresponding to the
         complement of the physical colour assigned to
         the given logical colour.

         PROGRAM DESIGN LANGUAGE

         G.sc.complement.colour [ logical.colour ]
         ----------------------
         = m.sd.white2 - g.sc.physical.colour [ logical.colour ]
**/
AND G.sc.complement.colour ( logical.colour ) =
                     m.sd.white2 - g.sc.physical.colour (logical.colour)

/**
         G.SC.NEXT.COLOUR - RETURN NEXT COLOUR IN SEQUENCE
         -------------------------------------------------

         PROGRAM DESIGN LANGUAGE

         G.sc.next.colour [ logical.colour ]
         ----------------
         = ( g.sc.physical.colour [ logical.colour ] + 1 ) REM
                                          ( m.sd.white2 + 1 )
**/

AND G.sc.next.colour ( logical.colour ) =
         (g.sc.physical.colour (logical.colour) + 1 ) REM (m.sd.white2+1)
// end of graphics driver
.
