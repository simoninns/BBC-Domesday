//  AES SOURCE  6.87

/**                                                                                                                             /**
         PHOTO - NATIONAL PHOTO OVERLAY
         ------------------------------

         This module contains G.np.phoini

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.photo

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         11.3.86  1        SRY         National Photo initialisation
         24.6.86  2        SRY         Video mode and menu bar
**/


SECTION "Natpho2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNPhd.h"
get "H/sdhd.h"
get "H/dhhd.h"
get "H/vhhd.h"
get "H/nphd.h"



/**
         G.NP.PHOINI - INITIALISE FOR PHOTO
         ----------------------------------

         PROGRAM DESIGN LANGUAGE:

         Clear screen
         Initialise data buffer
         Set 'justselected' false
**/

let g.np.phoini () be
$(
   g.sc.clear (m.sd.display)
   g.sc.clear (m.sd.message)

   init.data.buffer ()

   g.vh.video (m.vh.superimpose)
   g.context!m.justselected := FALSE
$)


AND init.data.buffer () BE
$(
   g.np.s!m.np.lastpage := (g.np.s!m.np.npics-1)/m.sd.displines + 1
   g.np.s!m.np.local.state := m.np.photo

   g.np.s!m.np.box1 := m.sd.act
   MOVE (g.np.s + m.np.box1, g.np.s + m.np.box2, m.menubarsize)

   test g.context!m.picture.no = 1 then
      for j = m.np.box3 to m.np.box5 do
         g.np.s!j := m.sd.wBlank
   else
      g.np.s!m.np.box4 := m.sd.wClear

   if g.np.s!m.np.npics > 100 do
      g.np.s!m.np.box6 := m.sd.wBlank
$)
.

