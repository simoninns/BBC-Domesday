//  PUK SOURCE  6.87

/**
         NM.RETR2 - RETRIEVE SUB-OPERATION FOR MAPPABLE DATA
         ---------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmRETR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         14.04.86 1        D.R.Freed   Initial version
         11.08.87 2        SRY         Modified for DataMerge

         g.nm.gridref
         g.nm.unit
**/

section "nmretr2"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sihd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/nmhd.h"

get "H/nmrehd.h"


/*
      g.nm.gridref ()

            handles the grid ref state of the retrieve operation
*/

let g.nm.gridref () be
$(
   let easting, northing = ?, ?
   let grid.eight =  vec 10/BYTESPERWORD
   let grid.mixed =  vec 10/BYTESPERWORD

   switchon g.key into
   $( case m.kd.return:
         if (g.screen = m.sd.display) &
             g.nm.id.grid.pos (@easting, @northing, @easting, @northing) then

         $( let entry.state = g.sc.pointer (m.sd.off)
            g.ut.grid.eight.digits (easting, northing, grid.eight)
            g.ut.grid.mixed (easting, northing, grid.mixed)
            g.sc.mess (" %s  National Grid Ref  %s", grid.eight, grid.mixed)
            g.sc.pointer (entry.state)
         $)
      endcase

      case m.kd.fkey3:  // Sum or Values function
         g.nm.s!m.local.state := g.nm.s!(m.nm.menu+m.box3)
         g.nm.s!(m.nm.menu + m.box3) := m.wClear
         g.nm.s!(m.nm.menu + m.box5) := m.wGridref
         g.sc.menu (g.nm.s + m.nm.menu)
         g.nm.restore.message.area ()
      endcase

      case m.kd.fkey6:
         if g.nm.check.download() g.nm.to.write (m.sd.act, m.wgridref)
      endcase
   $)
$)


/*
      g.nm.unit ()

            handles the unit state of the retrieve operation;
            displays the name of the areal unit
*/

and g.nm.unit () be
$(
   let easting, northing = ?, ?
   let grid.str   =  vec 5

   switchon g.key into
   $( case m.kd.return:
         if (g.screen = m.sd.display) &
            g.nm.id.grid.pos (@easting, @northing, grid.str, grid.str) then
         $( let entry.state = g.sc.pointer (m.sd.off)
            g.nm.s!m.area.no := 0

            // retrieve area number of this grid square
            g.nm.retrieve.values (easting, northing, easting, northing)

            test 0 < g.nm.s!m.area.no <= g.nm.s!m.nm.nat.num.areas
            then $(   // get name string for this area number from gazetteer
                    let name = vec 40 / BYTESPERWORD
                    g.sc.mess (g.nm.get.area.name (g.nm.s!m.area.no, name))
                 $)
            else g.sc.ermess ("Unclassified area")

            g.nm.position.videodisc ()
            g.sc.pointer (entry.state)
         $)
      endcase

      case m.kd.fkey3:  // Values function
         g.nm.s!m.local.state := m.wValues
         g.nm.s!(m.nm.menu + m.box3) := m.wClear
         g.nm.s!(m.nm.menu + m.box5) := m.wUnit
         g.sc.menu (g.nm.s + m.nm.menu)
         g.nm.restore.message.area ()
      endcase

      case m.kd.fkey6:
         g.nm.to.write (m.sd.act, m.wunit)
      endcase
   $)
$)
.




