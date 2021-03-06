//  PUK SOURCE  6.87

/**
         NM.FRAME - VIDEO FRAME PRIMITIVES FOR NATIONAL MAPPABLE
         -------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         13.01.86 1        D.R.Freed   Initial version
         16.04.86 2        DRF         Trap call removed from
                                       g.nm.read.frame since
                                       dh primitive does it
         ********************************
         18.6.87  3        DNH         CHANGES FOR UNI
         11.08.87 4        SRY         Modified for DataMerge


         g.nm.init.frame.buffer
         g.nm.current.frame.number
         g.nm.inc.frame.ptr
         g.nm.read.frame
**/

section "nmframe"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/dhhd.h"
get "H/nmhd.h"

   // Manifests used by this module

   manifest $( m.nm.clean = 0
               m.nm.dirty = 1
            $)

   // Statics used globally by this module

   static   $( s.buffer.flag = ?    // integrity of frame buffer
               s.current.frame.number = ?    // frame in buffer
               s.frame.type = ?     // VFS or ADFS
            $)

/**
         G.NM.INIT.FRAME.BUFFER - INITIALISE FRAME BUFFER
         ------------------------------------------------

         Sets buffer flag to dirty to indicate that a physical
         read is required on the next call to g.nm.read.frame.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: none


         SPECIAL NOTES FOR CALLERS:

         This routine must be called before any of the other
         routines in this module are called whenever :
            a) the calling overlay has been loaded
            b) the frame buffer memory is used as workspace.

         PROGRAM DESIGN LANGUAGE:

         g.nm.init.frame.buffer []
         ----------------------

         static buffer flag = dirty
**/

let g.nm.init.frame.buffer() be
$(
   s.buffer.flag := m.nm.dirty

   g.dummy () 
$)


/**
         G.NM.CURRENT.FRAME.NUMBER - GET CURRENT FRAME NUMBER
         ----------------------------------------------------

         Returns the absolute number of the frame which is in the
         buffer.

         INPUTS: none

         OUTPUTS:

         Returns absolute frame number

         GLOBALS MODIFIED: none

         PROGRAM DESIGN LANGUAGE:

         g.nm.current.frame.number []
         -------------------------

         RETURN (s.current.frame.number)
**/

and g.nm.current.frame.number() = valof
$(

   let a = 4  
   g.dummy ()
   resultis s.current.frame.number
 $)


/**
         G.NM.INC.FRAME.PTR - INCREMENT FRAME BUFFER POINTER
         ---------------------------------------------------

         Increments frame buffer pointer, reading in a new frame
         if necessary (and resetting pointer). The pointer is a
         byte offset.  It is safe to increment the pointer by 2
         before testing for end of frame because a frame has an
         even number of bytes in it.

         INPUTS:

         Address of pointer variable

         OUTPUTS:

         New value of pointer put at given address

         GLOBALS MODIFIED:

         Contents of g.nm.frame if new frame has to be read


         PROGRAM DESIGN LANGUAGE:

         g.nm.inc.frame.ptr [-> ptr]
         ------------------

         ptr = ptr + 2

         IF ptr >= frame size THEN

               read next frame
               ptr = 0
         ENDIF
**/

and g.nm.inc.frame.ptr (ptr) = valof
$( let result = true
   !ptr := !ptr + 2

   if !ptr >= m.dh.bytes.per.frame then
   $( let save = g.nm.s!m.nm.file.system
      g.nm.s!m.nm.file.system := s.frame.type
      result := g.nm.read.frame (s.current.frame.number + 1)
      !ptr := 0
      g.nm.s!m.nm.file.system := save
   $)
   resultis result
$)


/**
         G.NM.READ.FRAME - READ VIDEO FRAME
         ----------------------------------

         Reads specified frame into buffer, if it isn't there
         already.

         INPUTS: Absolute frame number.

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.frame

         PROGRAM DESIGN LANGUAGE:

         g.nm.read.frame [frame.number]
         ---------------

         IF buffer is clean AND frame.number = current frame THEN
               RETURN
         ENDIF

         read frame
         buffer flag = clean
         current frame = frame.number
**/

and g.nm.read.frame (frame.number) = valof
$( let ftype = g.nm.s!m.nm.file.system
   let adfsread = ftype = m.dh.adfs
   if (s.buffer.flag = m.nm.clean) & (frame.number = s.current.frame.number) &
      (s.frame.type = ftype) resultis true

   test adfsread
   then unless g.ud.readframes(frame.number, g.nm.frame) resultis false
   else g.dh.readframes (frame.number, g.nm.frame, 1)

   s.frame.type := ftype
   s.buffer.flag := m.nm.clean
   s.current.frame.number := frame.number
   resultis true
$)
.
