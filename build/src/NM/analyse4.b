//  PUK SOURCE  6.87


/**
         NM.ANALYSE4 - NATIONAL MAPPABLE ANALYSE OPERATION
         -------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         14.04.86 1        D.R.Freed   Initial version
         11.08.87 2        SRY         Modified for DataMerge
         30.09.87 3        SRY         ut.open -> ud.open

         g.nm.to.write
         g.nm.write
**/

section "nmanalyse4"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/nmhd.h"

get "H/nmrehd.h"

/*
      g.nm.to.write

         changes the state of the local state machine for
         the Retrieve operation to the Write state and
         performs the associated housekeeping

         the Write handler is in child overlay cnmWRIT due to lack
         of room in cnmRETR; control for swapping overlays is
         in the parent overlay MAPPROC
*/

static $( f=? temp=? l.st=? $)

let g.nm.to.write (box3, box5) be
$(
   let prompt = "File:"

   if g.nm.s!m.restore then
      $(
         g.nm.restore.screen (NOT g.nm.s!m.saved)
         g.nm.s!m.restore := FALSE
      $)

   g.nm.s!m.local.state := m.wwrite
   if box3 ~= m.sd.act then
      g.nm.s!(m.nm.menu + m.box3) := box3
   if box5 ~= m.sd.act then
      g.nm.s!(m.nm.menu + m.box5) := box5
   g.nm.s!(m.nm.menu + m.box6) := m.wblank
   g.sc.menu (g.nm.s + m.nm.menu)

   // issue warning message since Write is not interruptable and can take
   // about an hour for maximum number of data points with a non-empty disc;
   // number of areas includes missing values since these get written out as
   // well
   g.nm.s!m.sum.total :=
      (g.nm.s!m.nm.dataset.type = m.nm.grid.mappable.data) ->
          ((g.nm.s!m.nm.grid.sq.top.e - g.nm.s!m.nm.grid.sq.low.e) *
           (g.nm.s!m.nm.grid.sq.top.n - g.nm.s!m.nm.grid.sq.low.n)),
          g.nm.s!m.nm.num.areas

   g.sc.ermess ("%n values; download could be slow", g.nm.s!m.sum.total)

   f := "*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S"
      // compiler bug
   f%0 := 0
   temp := table 0, 0
   temp%0 := 0
   l.st := 0

   g.sc.mess (prompt)
   g.sc.movea (m.sd.message, g.sc.width (prompt) + m.sd.mesXtex, m.sd.mesYtex)
   g.key := m.kd.noact
   G.sc.input(f, m.sd.blue, m.sd.cyan, 32)
   if G.screen = m.sd.menu G.sc.moveptr(G.xpoint, G.sc.dtob(m.sd.display,4))
$)


/**
         G.NM.WRITE - WRITE FUNCTION IN RETRIEVE
         ---------------------------------------

         Handler for the Write local state within Retrieve;
         included here due to lack of room in the child
         overlay, cnmRETR.

         Performs the writing of data to floppy in the Retrieve
         operation.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         No kernel state change is involved, only a
         local state change within the retrieve handler.

         When the routine is entered, it is waiting for the
         answer to a prompt issued by the main retrieve handler.

         PROGRAM DESIGN LANGUAGE:

         g.nm.write []
         ----------

         IF a key has been pressed THEN
            echo 'R' or 'Q'
            wait a while so echo can be seen
            IF 'R' or 'r' pressed THEN
               turn off mouse pointer
               load child overlay "cnmWRIT"
               write data on screen out to floppy
               restore child overlay "cnmRETR"
               reposition videodisc for underlay
               restore mouse pointer
            ENDIF
            change state to Retrieve (top level)
            IF key is function key 3 THEN
               change state to Sum or Values
            ENDIF
            IF key is function key 5 THEN
               change state to Unit or GridRef
            ENDIF
            IF key is not Main THEN
               restore message area
               put write back on menu bar
            ENDIF
            flush keyboard buffer
         ENDIF
**/

and g.nm.write () be
$(
   if g.key = m.kd.noact return

   test l.st = 0 // write
   then g.sc.input(f, m.sd.blue, m.sd.cyan, 32)
   else g.sc.input(temp, m.sd.blue, m.sd.cyan, 1)

   switchon g.key into
   $( case m.kd.return:
         g.key := m.kd.noact
         test l.st = 0 // write
         then unless f%0 = 0 // quit immediately
                 unless do.write() 
                 $( G.nm.position.videodisc()
                    return
                 $)
         else if capch(temp%1) = 'Y'
                 if G.dh.delete.file(f)
                    unless do.write() 
                    $( G.nm.position.videodisc()
                       return
                    $)
      case m.kd.Fkey1:
         g.nm.s!m.local.state := m.wretrieve
      endcase
      case m.kd.fkey3:
         g.nm.s!m.local.state := g.nm.s!(m.nm.menu + m.box3)
         g.nm.s!(m.nm.menu + m.box3) := m.wclear
      endcase
      case m.kd.fkey5:
         g.nm.s!m.local.state := g.nm.s!(m.nm.menu + m.box5)
         g.nm.s!(m.nm.menu + m.box5) := m.wclear
      endcase
      default: return
   $)

   g.sc.pointer(m.sd.off)
   g.nm.position.videodisc()
   g.sc.keyboard.flush()
   g.nm.s!(m.nm.menu + m.box6) := m.sd.act

   // restore message area and draw new menu bar unless leaving
   // the current kernel state, in which case both will happen anyway
   unless g.key = m.kd.fkey2
   $( g.nm.restore.message.area ()
      g.sc.menu (g.nm.s + m.nm.menu)
   $)
   G.nm.position.videodisc()
   g.sc.pointer(m.sd.on)
$)

and do.write() = valof
$( let h = ?
   let result = false
   g.sc.pointer(m.sd.off)
   g.nm.load.child ("cnmWRIT")
   h := G.ud.open.file(f)
   if h = 0 // strictly m.ut.success but no room!
   $( g.nm.write.data()
      g.ud.close.file()
      result := true
      goto exit
   $)
   test 0 < h < #x80 // strictly m.ut.min.error but no room!
   then $( l.st := 1   // check overwrite
           temp%0 := 0
           G.sc.input(temp, m.sd.blue, m.sd.cyan, 1)
        $)
   else g.sc.input(0, m.sd.blue, m.sd.cyan, 32)

exit:
   g.nm.load.child ("cnmRETR")
   g.sc.pointer(m.sd.on)
   resultis result
$)

.
