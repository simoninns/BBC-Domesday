//  AES SOURCE  4.87

/**
         GENTEXT2 - community text Utilities
         -----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.phtx

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         *********************************
         12.5.87      1    DNH      CREATED FOR UNI
         18.5.87      2    DNH      split from gentext1

         GLOBALS DEFINED:

         g.ct.prompt.for.write
         g.ct.set.up.for.write
         g.ct.check.for.write.abort
         g.ct.warn.user
**/

SECTION "gentext"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCPhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/cphd.h"


/**
         proc g.ct.prompt.for.write ()
              ---------------------

         Cache message area
         Prompt user with "Insert floppy disc; type R...etc"
         Set write.pending flag
**/

let g.ct.prompt.for.write () be
$(
   g.sc.cachemess(m.sd.save)
   g.sc.mess("Insert floppy disc; type R (ready) or Q (quit): ")
   g.cp.context!m.cp.write.pending := TRUE
$)


/**
         function g.ct.set.up.for.write ()
                  ---------------------
         Returns a boolean success status according to whether it
         has successfully opened for output a filing system file.

         Should only be called when a positive keypress to the
         question posed by g.ct.prompt.for.write has been made,
         and the key (R or r) is still in g.key.

         PDL:

         move to end of prompt message
         output reply key
         restore message area (cached by prompt.for.write)
         unset write.pending flag
         call function g.ut.open.file
         result is open success
**/

let g.ct.set.up.for.write () = valof
$(
   g.sc.movea(m.sd.message,m.cp.EOS,m.sd.mesYtex)
   g.sc.ofstr("%C", g.key)
   g.sc.cachemess (m.sd.restore)
   g.cp.context!m.cp.write.pending := FALSE
   RESULTIS (g.ut.open.file () = m.ut.success)
$)


/**
         procedure g.ct.check.for.write.abort ()
                   --------------------------
         Tests g.key for a character to be taken as a negative
         response by the user to the prompt.for.write question.
         If a negative response has been made the write is
         aborted.

         PDL:
         if g.key is neither 'space' nor 'R' nor 'r' do
            move to end of prompt message
            output reply key, or 'Q' if reply key not printable
            wait 1 second (give the user time to see response)
            restore message area
            unset write.pending flag
         endif
**/

let g.ct.check.for.write.abort () be
$(
   unless g.key = m.kd.noact | CAPCH(g.key) = 'R' do
   $(
      let ch = g.ut.printingchar (g.key) -> g.key,'Q'
      g.sc.movea(m.sd.message,m.cp.EOS,m.sd.mesYtex)
      g.sc.ofstr("%C",ch)
      g.ut.wait(100)
      g.sc.cachemess(m.sd.restore)
      g.cp.context!m.cp.write.pending := FALSE
   $)
$)


/**
         proc g.ct.warn.user ()
              --------------
         puts up and clears an error message to warn the user
         that items cannot be selected from the Options index
         page but only after Main has been selected.
**/

let g.ct.warn.user () be
   g.sc.ermess("Select 'Main' to choose page from Index")
.
