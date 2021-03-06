//  AES SOURCE  6.87

/**
         NATINIT - dy.init and dy.free routines for National Essay
         ----------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.text

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         30.6.87  1        PAC     Adopted for AES
**/          

SECTION "natinit"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/gldyhd.h"
get "GH/glNEhd.h"
get "H/sdhd.h"
get "H/nehd.h"
get "H/iohd.h"

/**
         G.NE.DY.INIT - routine called on entry to National Essay
         -----------------------------------------------------

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.ne.buff
         g.ne.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         G.NE.DY.INIT :
                     
         get a vector for statics
         get a vector for g.sc.opage's use
         get a big vector (but not huge) for workspace
                                       
         restore cached statics
         
         store pointer to the opage vector in statics 

         calculate the maximum number of pages that we can
         store in our workspace vector
    
         open data1 and data2
**/

LET G.NE.dy.init() BE
$(
   Let room, page.buffer = ?,?

   g.ne.s      := GETVEC(m.ne.statics.size)
   page.buffer := GETVEC(m.sd.opage.buffsize)
   room        := MAXVEC()      

   room := (room > m.ne.max.worksize) -> m.ne.max.worksize,room 

   g.ne.buff   := GETVEC( room )

   g.ut.restore(g.ne.s,m.ne.statics.size,m.io.necache)
                                                       
   room := room - m.ne.photo.data.size/bytesperword // account for photo data

   g.ne.s!m.ne.max.pages := room/m.sd.opage.buffsize-1

   g.ne.s!m.ne.pagebuff  := page.buffer

   g.sc.pointer(m.sd.off) // added 5.9.86 PAC
               
   // open the data files for subsequent use
   //
   g.ne.s!m.ne.D1.handle := g.dh.open("DATA1")
   g.ne.s!m.ne.D2.handle := g.dh.open("DATA2")
$)

/**
         G.NE.DY.FREE - routine called on exit from National Essay
         ------------------------------------------------------

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.ne.buff
         g.ne.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:
                           
         close data1 and data2 files

         Cache context area
         
         Freevec data buffer
         Freevec page buffer
         Freevec context     

**/

AND G.NE.dy.free() BE
$(
   g.dh.close(g.ne.s!m.ne.D1.handle)
   g.dh.close(g.ne.s!m.ne.D2.handle)
   g.ut.cache(g.ne.s,m.ne.statics.size,m.io.necache)
   FREEVEC (g.ne.buff)
   FREEVEC (g.ne.s!m.ne.pagebuff)
   FREEVEC (g.ne.s)
$)
.
