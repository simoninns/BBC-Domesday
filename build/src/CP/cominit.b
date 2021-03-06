//  AES SOURCE  4.87

/**
         COMINIT - CP/CT Init and Free
         -----------------------------

         This module contains DY.INIT and DY.FREE and some
         utilities.

         NAME OF FILE CONTAINING RUNNABLE CODE: r.phtx

         GLOBALS DEFINED:

         G.cp.dy.init
         G.cp.dy.free
         G.cp.find.data
         G.cp.init.globals


         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         28.07.86    12    PAC      Cache buffer A properly
         *******************************
         6.5.87      13    DNH      CHANGES FOR UNI
                     13a            cache param
         1.6.87      14    PAC      Fix diagnostics
**/

SECTION "cominit"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/gldyhd.h"
get "GH/glCPhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/cphd.h"
get "H/iohd.h"

$<DEBUG
get "H/dhhd.h"

STATIC
$( // ******** FOR TESTBED ONLY **************
s.entry.fs  =  ?
s.data.fs   =  ?
$)
$>DEBUG


/**
         G.CP.DY.INIT - OVERLAY INITIALISATION
         -------------------------------------

         General overlay initialisation routine
         This caters for both photo and text overlay
         initialisations.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         G.cp.buffA
         G.cp.buffB

         SPECIAL NOTES FOR CALLERS:

         The restore from I/O processor memory is not done at
         present.

         PROGRAM DESIGN LANGUAGE:

         Get heap space for first data buffer (G.cp.buffA)
         Restore buffer from I/O processor memory

**/

LET G.cp.dy.init() BE
$(
   LET restored = ?

   G.cp.context := GETVEC ( m.cp.consize )
   restored := G.ut.restore( G.cp.context, m.cp.consize, m.io.cpcache )

   G.cp.buffA   := GETVEC ( m.cp.framesize/BYTESPERWORD )
   IF restored THEN
      restored := G.ut.restore (G.cp.buffA, m.cp.framesize/BYTESPERWORD,
                                                              m.io.CPbuffer)
   G.cp.buffB   := GETVEC ( m.cp.framesize/BYTESPERWORD )
   G.cp.context!m.cp.pagebuff := GETVEC ( m.sd.opage.buffsize )

   // set the 'dirty' flags for the data frame buffers
   UNLESS restored DO
      G.cp.context!m.cp.frameA := m.cp.invalid  // restore is valid
                              // BUT data frame may not be correct !!
   G.cp.context!m.cp.frameB   := m.cp.invalid // buffer B is always stomped on
   G.cp.context!m.cp.turn.on  := TRUE        // turn on video when photo starts

   // change to schools text font unless we have just restored AA text
   UNLESS restored & G.cp.context!m.cp.type = 0 DO
      G.sc.setfont( m.sd.schools )

$<DEBUG
   // ******** REST IS FOR TESTBED ONLY  **********************

   IF G.ut.diag () THEN
   $(
   G.sc.movea ( m.sd.display, 0, m.sd.dish )
   G.sc.rect  ( m.sd.clear, m.sd.disw, -16*m.sd.linW )
   G.sc.selcol( m.sd.yellow )
   G.sc.movea ( m.sd.display,0,m.sd.disYtex )

   WRITEF("*nData frame number  <%n> :",G.context!m.itemaddress)
   WRITEF("*nInitial picture no <%n> :",G.context!m.picture.no)
   WRITEF("*nInitial page no    <%n> :",G.context!m.page.no)
   WRITEF("*nJustselected is : %s",G.context!m.justselected->"true","false")
  
   G.ut.wait( 300 )
  $)
$>DEBUG

$)


/**
         G.CP.DY.FREE - FREE OVERLAY
         ---------------------------

         Frees any vectors GETVECed by G.dy.init
         Caches the data buffer in I/O processor memory


         GLOBALS MODIFIED:

         none (frees vector pointed to by G.cp.buffA)

         SPECIAL NOTES FOR CALLERS:

         The call to cache does nothing at present.

         PROGRAM DESIGN LANGUAGE:

         Cache current context data in I/O processor
         Free the data buffer vectors
**/

LET G.cp.dy.free() BE
$(

   G.ut.cache( G.cp.context, m.cp.consize, m.io.cpcache )
   G.ut.cache( G.cp.buffA, m.cp.framesize/BYTESPERWORD, m.io.CPbuffer )

   FREEVEC ( G.cp.context!m.cp.pagebuff )
   FREEVEC ( G.cp.buffB )
   FREEVEC ( G.cp.buffA )
   FREEVEC ( G.cp.context )

   G.sc.setfont( m.sd.normal )     // reset to normal font on exit

$<DEBUG

   IF G.ut.diag () THEN
   $(
   G.sc.movea ( m.sd.display, 0, m.sd.dish )
   G.sc.rect  ( m.sd.clear, m.sd.disw, -16*m.sd.linW )
   G.sc.selcol( m.sd.yellow )
   G.sc.movea ( m.sd.display,0,m.sd.disYtex )
   WRITES("Exiting PHTX - Globals are:")
   WRITEF("*nleveltype : %n *nitemaddr. : %n",G.context!m.leveltype,G.context!m.itemaddress)
   WRITEF("*npicture.no: %n *npage.no   : %n",G.context!m.picture.no,G.context!m.page.no)
   WRITEF("*nframe no. : %x4",G.context!m.frame.no)
   WRITEF("*nmaprecord : %n",G.context!m.maprecord)
   WRITEF("*nGR east   : %n *nGR north  : %n",G.context!m.grbleast,G.context!m.grblnorth)

   G.ut.wait(300)

   $)
$>DEBUG

$)



//  if buffer not right, then load data frame buffer A

LET G.cp.find.data () BE
$(
   IF G.cp.context!m.cp.frameA ~= G.context!m.itemaddress THEN
   $(
      G.dh.readframes (G.context!m.itemaddress, G.cp.buffA, 1) // get data
      G.cp.context!m.cp.frameA := G.context!m.itemaddress    // this frame
      G.cp.context!m.cp.turn.on := TRUE       // video will need restoring
   $)
$)


/**
         G.cp.init.globals()
         set up globals for use by MAP (see above)
**/

LET G.cp.init.globals() BE
$(                         // (type is high byte of leveltype pair)
   G.context!m.leveltype := (G.cp.context!m.cp.type << 8) |
                                                   G.cp.context!m.cp.level
   G.context!m.grbleast  := G.cp.context!m.cp.grbleast
   G.context!m.grblnorth := G.cp.context!m.cp.grblnorth
   G.context!m.maprecord := G.cp.context!m.cp.maprec.no
   G.context!m.map.no    := G.cp.context!m.cp.map.no
$)
.
