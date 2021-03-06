//  $MSC
//  AES SOURCE  4.87

/**
         SC.ICON - ICON DISPLAY ROUTINES
         -------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.icon

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87 1        PAC         ADOPTED FOR AES SYSTEM
         27.07.87 2        PAC         Remove pointer calls
**/

SECTION "icon"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/sdhd.h"

/**
         G.SC.ICON - DISPLAY SPECIFIED ICON
         ----------------------------------

         This routine puts up the icon at the current graphics
         position.

         INPUTS:

         icon type ( a manifest from sdhdr )
         plot type ( m.sd.plot or m.sd.clear )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Icons available are:

         m.sd.cross1 - a blue cross
         m.sd.cross2 - a yellow cross
         m.sd.mag.glass - drop shadow magnifying glass

         PROGRAM DESIGN LANGUAGE:

         G.sc.icon ( icontype, plottype )
         ---------
         CASE OF icontype
          m.sd.cross1 : clear cross background
                        IF plottype <> clear
                          THEN draw blue cross

          m.sd.cross2 : clear cross background
                        IF plottype <> clear
                          THEN draw yellow cross


          m.sd.mag.glass : clear icon background
                           IF plottype <> clear
                           THEN draw magnifying glass


**/
LET G.sc.icon( icontype, plottype ) BE
$(
   LET lowX = 0            // define display area as window
   LET lowY = 0
   LET hiX  = m.sd.disW-1
   LET hiY  = m.sd.disH-1

   LET coords = VEC m.sd.coordsize
   // LET oldptr = G.sc.pointer( m.sd.off )

   G.sc.savcur( coords )               // save current cursor
   G.sc.setwin( lowX, lowY, hiX, hiY ) // restrict icons to display area

   SWITCHON icontype INTO
   $( CASE m.sd.cross1 :
      $(
         cross.icon( 8,32, m.sd.clear ) // always clear

         IF plottype ~= m.sd.clear
         THEN $( G.sc.XOR.selcol( m.sd.blue )
                 G.sc.mover( 0,4 )  // fix 5.8.86 PAC
                 cross.icon( 2,22, m.sd.plot ) // plot in colour
                 G.sc.mover( 0,-4 ) // fix 5.8.86 PAC
                 G.sc.selcol(m.sd.blue)
              $)
      $)
      ENDCASE

      CASE m.sd.cross2 :
      $(
         cross.icon( 8,32,m.sd.clear ) // always clear

         IF plottype ~= m.sd.clear
         THEN $( G.sc.selcol( m.sd.yellow )
                 cross.icon( 4,28, m.sd.plot ) // plot in colour
              $)
      $)
      ENDCASE

      CASE m.sd.mag.glass :
      $(
         clr.mag()
         IF plottype ~= m.sd.clear
         THEN $(
                 G.sc.selcol( m.sd.blue )  // first the shadow
                 magnifying()              // plot in colour
//               G.sc.mover(-4,-4)         // move for drop shadow Right, Up
                 G.sc.mover(4,4)         // move for drop shadow Left, Down
                 G.sc.selcol( m.sd.yellow )
                 magnifying()              // plot in colour
              $)
      $)
      ENDCASE
   $)

   G.sc.defwin()           // set default window
   G.sc.rescur( coords )   // restore coords
   // G.sc.pointer( oldptr )  // restore pointer

$)

AND cross.icon( arm.width, size, type ) BE
$( G.sc.mover( -arm.width, size )
   G.sc.rect ( type, (arm.width<<1), -(size<<1) )
   G.sc.mover( -(arm.width+size),arm.width+size )
   G.sc.rect ( type, (size<<1), -(arm.width<<1) )
   G.sc.mover( -size, arm.width )
$)

AND magnifying() BE
$(
   VDU ("25,153,24;-24;")
   G.sc.mover(-24,24)        // VDU ("25,0,-24;24;")
   VDU ("25,155,20;-20;")
   G.sc.mover(0,-4)          // VDU ("25,0,0;-4;")
   G.sc.mover(36,-36)        // VDU ("25,0,36;-36;")
   VDU ("25,113,4;4;")
   G.sc.mover(-60,56)        // VDU ("25,0,-60;56;")
$)

AND clr.mag() BE
$(
   VDU ("25,155,28;-28;")
   G.sc.mover(-4,-8)         // VDU ("25,0,-4;-8;")
   G.sc.mover(32,-32)        // VDU ("25,0,32;-32;")
   VDU ("25,115,12;12;")
   G.sc.mover(-68,56)        // VDU ("25,0,-68;56;")
$)
.

