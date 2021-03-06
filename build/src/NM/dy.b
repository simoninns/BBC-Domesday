//  PUK SOURCE  6.87

/**
         NM.DY - DYNAMIC ROUTINES FOR NATIONAL MAPPABLE
         ----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         12/02/86  1       D.R.Freed   Initial version
         13/02/86  2       DRF         Error handling for test bed
         26/02/86  3       DRF         Vector sizes adjusted
                                       get & cache g.nm.areal.map
                                       g.nm.child.ovly allocated
                                       position videodisc
                                       load current child overlay
                                       calls to CNMDISP removed
                                       testbed question sequence
                                          reduced & conditional
                                          on just selected flag
                                          runprog's eliminated
                                          allow fuller dir spec
                                       open & close gazetteer file
                                       g.dy.free only sets mode 1
                                          if not going to Help
                                       g.nm.debug.set.data.fs,
                                       g.nm.debug.restore.fs
                                          added for development
                                       coarse index reorganised
                                       areal vector may need
                                          reloading from disc
                                          to restore it
         ********************************
         23.6.87     3     DNH      CHANGES FOR UNI
                                    Debug stuff gone
                                    Rename to g.nm.dy...
                                    Use g.ut.movebytes
         26.8.87     4     SRY      Close moved above freevec!
         ********************************
         06.06.88    5     SA       CHANGES FOR COUNTRYSIDE
                                    total function

         g.nm.dy.init
         g.nm.dy.free
**/

section "nmdy"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/gldyhd.h"
get "GH/glNMhd.h"
get "H/iohd.h"
get "H/kdhd.h"
get "H/nmhd.h"


/**
         G.NM.DY.INIT - OVERLAY INITIALISATION FOR NM
         --------------------------------------------

         Initialises the NM overlay. Called by the root, whenever
         the overlay is loaded.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.frame
         g.nm.child.ovly
         g.nm.areal
         g.nm.coarse.index.record
         g.nm.coarse.index.offset
         g.nm.s
         g.nm.areal.map
         g.nm.values
         g.nm.class.upb
         g.nm.class.colour


         PROGRAM DESIGN LANGUAGE:

         g.dy.init []
         ---------

         allocate global vectors for this overlay
         restore context variables from IO processor
         restore areal vector
         open gazetteer file
         initialise frame buffer
         initialise values buffer
         IF NOT just selected THEN
            reload coarse index
            load any child overlay that was resident
            IF NOT returning from Text THEN
               position videodisc for underlay map
            ENDIF
         ENDIF
**/

let g.nm.dy.init () be
$(
   let   last.child = vec m.nm.file.name.length/BYTESPERWORD

   g.nm.areal := getvec (m.nm.areal.vector.size)
   g.nm.frame := getvec (m.nm.frame.size - 1)
   g.nm.child.ovly := getvec (m.nm.child.ovly.size)
   g.nm.coarse.index.record := getvec (m.nm.coarse.index.size - 1)
   g.nm.coarse.index.offset := getvec (m.nm.coarse.index.size - 1)
   g.nm.s := getvec (m.nm.global.statics.size)
   g.nm.values := getvec ( (m.nm.fine.blocksize * m.nm.fine.blocksize + 1) *
                                                            m.nm.max.data.size)
   g.nm.areal.map := getvec (m.nm.areal.map.size)
   g.nm.class.upb := getvec ((m.nm.num.of.class.intervals + 1) *
                                                            m.nm.max.data.size)
   g.nm.class.colour := getvec (m.nm.num.of.class.intervals)


   g.ut.restore (g.nm.areal.map,
                 m.nm.areal.map.size,
                 m.io.wa.nm.areal.map)

   g.ut.restore (g.nm.class.upb,
                 (m.nm.num.of.class.intervals + 1) * m.nm.max.data.size,
                 m.io.wa.nm.class.upb)

   g.ut.restore (g.nm.class.colour,
                 m.nm.num.of.class.intervals,
                 m.io.wa.nm.class.colour)

   g.ut.restore (g.nm.s,
                 m.nm.global.statics.size,
                 m.io.wa.nm.statics)

// TESTBED CODE removed from here ******************

   g.nm.restore.areal.vector ()

   g.nm.s!m.nm.gaz.handle := g.dh.open ("GAZETTEER")

   g.nm.init.frame.buffer ()
   g.nm.init.values.buffer ()

   if (NOT g.context!m.justselected) then

      $(
         // reload coarse block index from sub-dataset
         g.nm.load.coarse.index ()

         if (g.nm.s!m.nm.curr.child ~= 0) then
            $( // reload last child overlay
               g.ut.movebytes (g.nm.s + m.nm.curr.child, 0,
                               last.child, 0,
                               m.nm.file.name.length)
               g.nm.s!m.nm.curr.child := 0
               g.nm.load.child (last.child)
            $)

         // if there is an underlay map, ensure that it is displayed,
         // provided we are not returning from Text (where it would
         // probably be muted almost immediately)

         if NOT g.nm.s!m.nm.gone.to.text then
            g.nm.position.videodisc ()
      $)

   //clear 'total displayed' flag  SA 06.06.88
   g.nm.s!m.nm.total.displayed := FALSE
$)


/**
         G.NM.DY.FREE - OVERLAY CLOSEDOWN FOR NM
         ---------------------------------------

         Closes down the NM overlay. Called by the root, whenever
         the overlay is unloaded.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.frame
         g.nm.child.ovly
         g.nm.areal
         g.nm.coarse.index.record
         g.nm.coarse.index.offset
         g.nm.s
         g.nm.areal.map
         g.nm.values
         g.nm.class.upb
         g.nm.class.colour

         PROGRAM DESIGN LANGUAGE:

         g.dy.free []
         ---------

         save context variables to IO processor
         free global vectors for this overlay
         close gazetteer file
         IF not going to Help overlay THEN
            restore screen to mode 1
         ENDIF
**/

and g.nm.dy.free () be
$(
   g.ut.cache (g.nm.areal,             // cache as much as possible;
               m.nm.areal.cache.size,  // if all of the vector won't
               m.io.wa.nm.areal)       // fit, then it will be reloaded
                                       // from disc when it is restored
   g.ut.cache (g.nm.areal.map,
               m.nm.areal.map.size,
               m.io.wa.nm.areal.map)

   g.ut.cache (g.nm.class.upb,
               (m.nm.num.of.class.intervals + 1) * m.nm.max.data.size,
               m.io.wa.nm.class.upb)

   g.ut.cache (g.nm.class.colour,
               m.nm.num.of.class.intervals,
               m.io.wa.nm.class.colour)

   g.ut.cache (g.nm.s,
               m.nm.global.statics.size,
               m.io.wa.nm.statics)

   g.dh.close (g.nm.s!m.nm.gaz.handle)

   freevec (g.nm.areal)
   freevec (g.nm.frame)
   freevec (g.nm.child.ovly)
   freevec (g.nm.coarse.index.record)
   freevec (g.nm.coarse.index.offset)
   freevec (g.nm.s)
   freevec (g.nm.values)
   freevec (g.nm.areal.map)
   freevec (g.nm.class.upb)
   freevec (g.nm.class.colour)

   if (g.key ~= m.kd.fkey1) then
      g.sc.mode (1)

// ******** TESTBED CODE REMOVED FROM HERE
$)

.
