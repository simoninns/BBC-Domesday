//  UNI SOURCE  4.87

section "mapopt6"

/**
         CO.MAPOPT6 - OPTIONS DISPLAY ROUTINES
         -------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         28.4.86  1        DNH         Initial version
         12.5.86  2        DNH         Globals to gl3hdr
         16.5.86  3        DNH         g.cm.unitsini in here
         22.7.86  4        DNH         unitsini bugfix

         g.cm.unitsini
         g.co.show.units
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/cmhd.h"
get "H/cm3hd.h"


/**
         G.CM.UNITSINI - Init routine for Units Operation
         ------------------------------------------------

         Toggle between Metric and Imperial units for display of
         Distance and Area values.  All done in this routine.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: toggles map static
         g.cm.s!m.measure!m.v.units

         SPECIAL NOTES FOR CALLERS: state global

         PROGRAM DESIGN LANGUAGE:
         g.cm.unitsini ()
            switch off pointer (about to use screen routines)
            toggle units static
            show new units and scale bar
            show current value (if any) in new units
         end procedure
**/

let g.cm.unitsini () be
$(
   let substate = g.cm.s!m.substate
   g.sc.pointer (m.sd.off)
   g.cm.s!m.measure!m.v.units := ~g.cm.s!m.measure!m.v.units
   g.co.show.units ()
   g.co.show.value ()
$)


/**
         G.CO.SHOW.UNITS - Show new units name and scale bar
         ---------------------------------------------------

         PROCEDURE g.co.show.units ()

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:
         g.co.show.units ()
            redraw cyan box in message area
            select blue
            if in distance operation
               output units string
               output scale bar
            else (area)
               output "square " units string
            endif
         end procedure
**/

let g.co.show.units () be
$(
   let u.str = ?                 // pointer to units string
   let cmlevel = g.cm.s!m.cmlevel
   let units   = g.cm.s!m.measure!m.v.units

   g.sc.selcol (m.sd.cyan)       // redraw message area
   g.sc.movea (m.sd.message, 0, 0)
   g.sc.rect (m.sd.plot, m.sd.mesw-1, m.sd.mesh-1)
   g.sc.selcol (m.sd.blue)       // select blue for text etc.

   test units = m.metric then
      u.str := cmlevel < 4 -> "kilometres", "metres"
   else
      u.str := cmlevel < 4 -> "miles", "yards"

   test (g.cm.s!m.substate & m.distance.substate.bit) ~= 0 then
   $( g.sc.movea (m.sd.message, m.distance.units.X.pos, m.sd.mesYtex)
      g.sc.ofstr (u.str)
      show.scale.bar (cmlevel, g.cm.s!m.map, units)
   $)
   else                                                  // Area operation
   $( g.sc.movea (m.sd.message, m.area.units.X.pos, m.sd.mesYtex)
      g.sc.ofstr ("square %S", u.str)
   $)
$)


/**
         g.co.show.scale.bar (map level, map number, current
                                                         units)
         Outputs the scale bar for the Distance operation,
         aligned with the map grid lines plotted on the screen.
         A width value string is also output:
         eg.  __________________________  200
             |                          |
**/


and show.scale.bar (cmlevel, map, units) be
$(
   let length.tab = table
// graphics units              Screenwidth (km)
              148,   // L0        1733
                0,
      m.sd.mesw/4,   //             40
      m.sd.mesw/4,   //              4
      m.sd.mesw/8    // L4           0.8

   let L1.length.tab = table
              200,   // South      640
              176,   // North      720
              176,   // Shet       360
              268,   // Ire        240
              212,   // Man         60
              256    // Chan       100


   let value.tab = table         // the number of units the bar represents
              200,   // L0 (km/miles)
                0,
               10,
                1,
              100    // L4 (metres/yards)

   let L1.value.tab = table
              100,   // South
              100,   // North
               50,   // Shet
               50,   // Ire
               10,   // Man
               20    // Chan


   let length, value = ?,?       // pointers into the tables
   let num.str = vec 3

   test cmlevel = 1 then
   $( let index = map - map.L1
      length := L1.length.tab!index
      value  := L1.value.tab!index
   $)
   else
   $( length := length.tab!cmlevel
      value  := value.tab!cmlevel
   $)

   if units = m.imperial do
      test cmlevel = 4 then
         length := muldiv (length, 1000, 1094)     // slightly shorter: yards
      else
         length := muldiv (length, 1609, 1000)     // much longer bar: miles

   g.sc.selcol (m.sd.blue)
   g.sc.movea (m.sd.message, m.sd.mesw/2, 0)    // start half way along
   g.sc.liner (m.sd.plot, 0, m.sd.mesh/2)       // to half way up...
   g.sc.liner (m.sd.plot, length, 0)            // along the length...
   g.sc.liner (m.sd.plot, 0, (-m.sd.mesh/2))    // and down to bottom edge
   g.sc.movea (m.sd.message, m.sd.mesw/2+length+m.sd.charwidth, m.sd.mesYtex)
      // now convert value to a string pointer
   value := valof switchon value into
   $( case   1: resultis "1"
      case  10: resultis "10"
      case  20: resultis "20"
      case  50: resultis "50"
      case 100: resultis "100"
      case 200: resultis "200"
      default: resultis "**!@~"
   $)
   g.sc.ofstr (value)                           // one char pos further on
$)
.
