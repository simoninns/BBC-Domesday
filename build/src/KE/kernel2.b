//  AES SOURCE  4.87

/**
         B.KERNEL2 - OVERLAY HANDLING CODE FOR KERNEL
         --------------------------------------------

         NOTE: This version is for a standalone BCPL environment.
         When testing in a non-standalone environment, the version
         in b.kerneln should be used.

         This module contains the BCPL procedure G.ov.load which
         is the machine specific overlay handling routine for the
         software. This routine load a CINTCODE file into a vector
         and re-assigns the globals defined by that CINTCODE
         using the inbuilt procedure GLOBIN.

         LOCATION OF RUNNABLE CODE:

         s.kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR    DETAILS OF CHANGE
         27.04.87 1        PAC       ADOPTED FOR AES SYSTEM
         18.5.87  2        PAC       Only does diagnostics now
          2.6.87  3        PAC       Diagnostics under debug
         21.12.87 4        MH        G.vh.send.fcode("E0") changed to
                                     G.vh.video(m.vh.video.off)
**/

SECTION "b.Kernel2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/gldyhd.h"
get "H/sihd.h"
get "H/sdhd.h"
get "H/vhhd.h"

/**
         G.ov.load - LOAD OVERLAY ROUTINE
         --------------------------------

         INPUTS:

         Filename as string, Pointer to start of vector to
         receive CINTCODE file

         OUTPUTS:

         Vector into which the overlay was loaded.

         GLOBALS MODIFIED:

         G.dy.init & G.dy.free

         - new overlays always include these routines
           which are dynamically assigned

         Any Globals present in the newly loaded overlay are
         initialised.

         SPECIAL NOTES FOR CALLERS:

         Any failure to load an overlay is treated as a 'FATAL'
         error and a message is output, indicating the error, and
         the program forced to terminate.
         WARNING
         This routine relies on the fact that if heap is never
         fragmented then GETVECs will consistently GET the same
         area of memory.

         This routine is used for loading all parent overlays,
         and the NM children. An NM child overlay filename MUST
         begin with the letters "cnm", plus 4 other characters;
         e.g. "cnmretr", "cnmauto".

         PROGRAM DESIGN LANGUAGE:

         G.ov.load [string pointer, old overlay] -> address
         ---------

         FREE old overlay

         The memory from memory pointer onwards is loaded with
         the CINTCODE from the file named by string pointer.
         The CINTCODE in memory is initialised by the inbuilt
         proceedure GLOBIN, re defining any relevant GLOBALs

         RETURN address of current overlay vector

**/

LET G.ov.load (overlay, oldvec) = VALOF
$(                 
$<debug
    IF G.ut.diag() G.sc.mess("ov.load : new overlay is '%s'",overlay)
$>debug
    
    set.up.dys()

$<floppy
    G.vh.video(m.vh.video.off)  // emulate the videodisc mute on data access
//above updated from G.vh.send.fcode("E0") to above 21.12.87 MH
$<debug
    IF g.ut.diag() THEN
    $( LET oldframe = G.context!m.frame.no 
       G.vh.frame(16243)      // send to known frame for debugging
       G.context!m.frame.no := oldframe
    $)
$>debug
$>floppy
   RESULTIS oldvec
$)                


AND set.up.dys() BE
$(  
   LET initroutine, freeroutine = ?,?
   LET overlay.name.pointer     = G.stover!(G.context!m.state)

   SWITCHON overlay.name.pointer INTO
   $(
      CASE m.wMap      : $( initroutine := G.CM.dy.init
                            freeroutine := G.CM.dy.free 
                         $) ENDCASE

      CASE m.wPhtx     : $( initroutine := G.CP.dy.init
                            freeroutine := G.CP.dy.free 
                         $) ENDCASE

      CASE m.wFind     : $( initroutine := G.CF.dy.init
                            freeroutine := G.CF.dy.free 
                         $) ENDCASE

      CASE m.wWalk     : $( initroutine := G.NW.dy.init
                            freeroutine := G.NW.dy.free 
                         $) ENDCASE

      CASE m.wPhoto    : $( initroutine := G.NP.dy.init
                            freeroutine := G.NP.dy.free 
                         $) ENDCASE

      CASE m.wText     : $( initroutine := G.NE.dy.init
                            freeroutine := G.NE.dy.free 
                         $) ENDCASE

      CASE m.wChart    : $( initroutine := G.NC.dy.init
                            freeroutine := G.NC.dy.free 
                         $) ENDCASE

      CASE m.wFilm     : $( initroutine := G.NV.dy.init
                            freeroutine := G.NV.dy.free 
                         $) ENDCASE

      CASE m.wMapproc  : $( initroutine := G.NM.dy.init
                            freeroutine := G.NM.dy.free 
                         $) ENDCASE

      CASE m.wContents : $( initroutine := G.NT.dy.init
                            freeroutine := G.NT.dy.free 
                         $) ENDCASE

      CASE m.wNatFind  : $( initroutine := G.NF.dy.init
                            freeroutine := G.NF.dy.free 
                         $) ENDCASE

      CASE m.wArea     : $( initroutine := G.NA.dy.init
                            freeroutine := G.NA.dy.free 
                         $) ENDCASE

      CASE m.wHelp     : $( initroutine := G.HE.dy.init
                            freeroutine := G.HE.dy.free 
                         $) ENDCASE         

      DEFAULT          : $( initroutine := G.dy.init  // for safety
                            freeroutine := G.dy.free           
                         $)
   $)                                                   

   G.dy.init := initroutine   // set up the routines
   G.dy.free := freeroutine  

$<debug
   IF (initroutine>>16 = #xAE95) |    
      (freeroutine>>16 = #xAE95) |   
      (initroutine = Undefined.global) |     
      (freeroutine = Undefined.global)
   THEN 
   $( G.sc.mess("DY INIT/FREE routine not found")
      G.ut.abort(999)
   $)
$>debug
  
$)
.
