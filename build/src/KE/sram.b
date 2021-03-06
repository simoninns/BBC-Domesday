//  AES SOURCE  4.87

/**
         SRAM - SIDEWAYS RAM SETUP FOR CACHE
         -----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         s.kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         5.5.87      1     DNH      CREATED FROM ROOT1
                                    setup.sram -> g.ov.set...
                                    -515 pattern under debug
                     2     PAC      Modified for AES caches
**/

SECTION "sram"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/dhhd.h"
get "H/iohd.h"
get "H/iophd.h"
get "H/uthd.h"


/**
         G.OV.SETUP.SRAM
         ---------------

         Reset cache flags to indicate an invalid cache.
         If $$DEBUG is set a test pattern is written to the
         entire cache area - useful for debugging. This routine
         is not really machine specific but it is unlikely that
         an identical caching mechanism would be used for a port.
         Only invoked from root, on cold or warm boot.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: None, but sets up the IO cache flags.
**/

LET G.ov.setup.sram() BE
$(                   
   LET buff     = VEC m.io.flag.size     
   LET restype  = ? // 'type' of cache flag to be reset (National or Community)
   LET offset   = ?
   LET pattern  = (-515 << 16) | -515  // test pattern. (wordsize indep.)

   TEST G.context!m.discid = m.dh.natA
   THEN $( offset := m.io.NatStart/bytesperword ; restype := m.io.ComtoNat $)
   ELSE $( offset := m.io.ComStart/bytesperword ; restype := m.io.NattoCom $)

   // initialise cache    

$<debug // N.B. - the release version does not set up the test pattern
   Fillwords( G.cachevec+offset, m.io.halfram/bytesperword, pattern ) 
$>debug

   // reset cache flags    
   
   FOR i = 0 TO m.io.flag.size DO
       buff!i := FALSE
   G.ut.restore( buff, m.io.flag.size, restype )   
$)
.
