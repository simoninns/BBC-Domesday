//  AES SOURCE  4.87

section "Stinit"

/**
         SI.STINIT - Main Routine to Create State Tables
         -----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         Contains routine START to create the state tables
         as a file 'states' in the 'SI.R' directory.

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         15.5.87     2     PAC      Adopted for AES system
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/sthd.h"
get "H/stphd.h"
get "H/st2hd.h"       // offset defin's for state tables

/**
         START is not part of the retrieval software but defines
         the start of a program called "STINIT" held in SI.r
         used to create the state tables.  This used to be done
         at boot time by the two overlays "STINIT1" and "STINIT2"
         but these are now redundant. This saves considerable
         time in booting and space on the system floppy.

         It would be possible to split the state tables in two
         (com. and nat.)
         If they are split care will be needed to
         duplicate HE states in both, giving HE the lowest state
         numbers in SIHDR.
**/


LET start () be
$(         
   let pb = VEC 3
   let p  = ? 
   let st = ? 

   WRITES ("*NCreating AES State Tables*N*N")
   RUNPROG ("**TIME*c")

// allocate a big vector for the whole state tables and point the globals
// to the correct offsets within it

   p := GETVEC (m.st.total.size)
   p!1 := (m.st.total.size - 2) * bytesperword // size - 2 for header (bytes) 

   Writef("*nState table size : %n (%x4) bytes*n", p!1,p!1 )

   g.stover := p + m.st.over.offset
   g.stactr := p + m.st.actr.offset
   g.sttran := p + m.st.tran.offset
   g.stinit := p + m.st.init.offset
   g.stmenu := p + m.st.menu.offset

   g.st.rcom ()
   g.st.rexam ()
   g.st.rgalwal ()
   g.st.rhe ()
   g.st.rnm ()
   g.st.rsear ()

   g.st.scom ()
   g.st.sexam ()
   g.st.sgalwal ()
   g.st.she ()
   g.st.snm ()
   g.st.ssear ()

//   VECTOFILE (p, "/f.<$SRCDIR>.R.states")    
              
   st := (p+2) * bytesperword  // hardware address of start of data
                                // start, end addresses
   pb!0, pb!1, pb!2, pb!3 := 0, 0, st, st+p!1 

   Osfile( 0, "<$SRCDIR>.R.states", pb )

   STOP (0)
$)
.
