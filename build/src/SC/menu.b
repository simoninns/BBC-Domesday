//  $MSC
//  AES SOURCE  4.87

/**
         G.SC.MENU - MENU BAR DRAWING ROUTINE
         ------------------------------------

         This module contains g.sc.menu

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE      VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87  1        PAC         ADOPTED FOR AES SYSTEM
         27.07.87  2        PAC         Remove pointer calls
**/

Section "menu"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/sdhd.h"
get "H/sthd.h"

/**
         G.SC.MENU - DRAW MENU BAR
         -------------------------

         This routine draws the menu bar, using the information
         given in its parameters and in the state table.

         INPUTS:

         pointer to a six word vector consisting of one manifest
         for each menu bar box.
         each word contains either m.sd.act ( box active) ,or a
         manifest from SIHDR for the word ( eg. m.wGridRef,
         m.wBlank, m.wOld ).

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.redraw (set false at end of routine)
         Updates private status table for use by GETACT,
         which is a vector pointed to be G.menubar

         SPECIAL NOTES FOR CALLERS:

         'Active' boxes always contain the appropriate word,
         obtained from the state table.

         The vector can be initialised using TABLE : e.g.

         LET menu.boxes = TABLE m.sd.act, m.sd.act, m.wBlank,
                                m.sd.act, m.wAreal, m.sd.act

         G.sc.menu ( menu.boxes )

         Note that TABLEs start at 0, so the manifest for box
         number 1 on the menu bar is at menu.boxes!0. There are
         manifests defined for the boxes in GLHDR: m.box1 etc.
         When using G.key to find a function key, the key number
         is G.key - m.kd.keybase, and the menu bar box
         corresponding to it will be at:

            menu.boxes!(G.key-m.kd.keybase-1)

         It is VERY IMPORTANT to use the manifests provided,
         otherwise the routine will quite happily ouput garbage
         to the screen.

         SDHDR contains copies of m.wBlank and m.wClear, called
         m.sd.wBlank and m.sd.wClear respectively. If these are
         the only manifests used, then there is no need to GET
         SIHDR.

         PROGRAM DESIGN LANGUAGE:

         G.sc.menu [ boxvec ]
         ---------
         { Clear menu bar area } - not done now 31.1.86 PAC
         IF bar is on
            THEN Draw boxes using sizes from state table
                 Draw lefthand triangle
         Move to start of first box

         FOR boxnumber = 0 to 5 DO
            Update status store
            IF bar is on
            THEN IF boxvec!boxnumber = 'active'
                 THEN write menu bar word in box
                 ELSE IF boxvec!boxnumber = 'blank'
                      THEN do nothing
                      ELSE write appropriate word in box
                      ENDIF
                 ENDIF
            ENDIF
         move to start of box (boxnumber+1)
         NEXT boxnumber

         Set redraw flag off
         RETURN
**/

LET G.sc.menu ( boxvec ) BE
$( // LET oldstate = G.sc.pointer (m.sd.off)
   LET stateptr = (G.context!m.state-1)*m.st.barlen
   LET coords   = VEC m.sd.coordsize

   G.sc.savcur( coords )

   IF G.menuon
   THEN boxes ( stateptr )  // draw the boxes

   // move to start position for text
   G.sc.movea ( m.sd.menu, m.sd.menXtex, m.sd.menYtex )
   // G.sc.selcol( m.sd.blue ) is not needed because boxes
   // leaves the current colour at blue ( the triangle )

   FOR i=1 TO m.st.barlen
      $( LET wordptr = ( G.stmenu!(stateptr+i) )
         LET word = wordptr & #x1ff
         LET width = ( wordptr & #xFE00 ) >> 7 // n.b. converts pels to GU !!
         LET arg = boxvec!(i-1)

         G.menubar!(i-1) := arg // update status store

         IF G.menuon
         THEN $( TEST (word = m.sd.wBlank)|(arg = m.sd.wBlank)
                 THEN G.sc.mover( width,0 )   // test for m.sd.wBlank
                 ELSE TEST (arg = m.sd.act)  // box is active
                      THEN doword ( @G.menuwords!word, width )
                      ELSE doword ( @G.menuwords!arg, width )
              $)
      $)
   G.redraw := FALSE  // redraw set OFF

   G.sc.rescur( coords )

   // G.sc.pointer( oldstate )
$)

// draw the menu bar boxes
// 'index' is index into state table
AND boxes( index ) BE
$( LET col, vert = m.sd.cyan,?    // first box is in cyan
   vert := m.sd.barh-1           // all boxes same height
   // G.sc.clear ( m.sd.menu )  31.1.86 PAC
   G.sc.movea ( m.sd.menu,0,4 )
   G.sc.selcol( col )            // set colour
   G.sc.rect  ( m.sd.plot ,80 , vert )   // first box - fixed width

   FOR i = 1 TO m.st.barlen DO
      $( LET boxlen = ( (G.stmenu!(index+i) & #xFE00) >>7 )
         vert := -vert              // switch up/down plotting of rectangle
         col  := (col=m.sd.cyan -> m.sd.yellow,m.sd.cyan) // switch colour
         G.sc.selcol ( col )
         G.sc.rect ( m.sd.plot, boxlen, vert )
      $)
   // that does the boxes, now the triangle
   G.sc.selcol ( m.sd.blue )
   G.sc.movea ( m.sd.menu, 56, 8 )
   G.sc.triangle ( m.sd.plot,0,32, -32,-16 ) // draw triangle
$)

// write the word in the given box size
// assume we are at the L H edge of box
AND doword ( stringptr, boxsiz ) BE
$(
   LET len, space = ?,?

   IF stringptr%0 > 20 then stringptr%0 := 20 // check for reasonable string

   len := G.sc.width ( stringptr )
   space := ( boxsiz-len )/2  // leftover space at both ends of word

   G.sc.mover ( space,0 )     // move relative for start
   G.sc.oprop ( stringptr )   // write the word
   G.sc.mover ( space,0 )     // move relative to end
$)
.

