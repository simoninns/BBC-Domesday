//  AES SOURCE  4.87

section "nv2"

/**
         NV.NV2 - Utility Routines for National Video
         --------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.film

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
           1.1.86    1     DNH      Initial version
          22.7.86    2              Private Help text
         ****************************
         20.5.87     2     DNH      CHANGES FOR UNI
         5.6.87      3     DNH      pointer handling

         GLOBALS DEFINED:
            g.nv.show.help.page
            g.nv.start.chosen.film
            g.nv.show.film.list
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNVhd.h"
get "H/sdhd.h"
get "H/vhhd.h"

get "H/nvhd.h"

static
$(
s.i = ?    // counter for line. routine
$)

/**
         procedure 'line. (string)' outputs a string as a line of
         text for the private single-page Help function.
         Copied from routine of same name in Bookmark.
**/

let line. (string) be
$( g.sc.movea (m.sd.display, m.sd.propXtex, m.sd.disYtex-m.sd.linw*s.i)
   g.sc.oprop (string)
   s.i := s.i+1
$)


/**
         proc G.NV.SHOW.HELP.PAGE ()
              -------------------

         Show Private Help Page for NV

         INPUTS: No parameters.  Uses NV statics only

         PROGRAM DESIGN LANGUAGE:

         procedure g.nv.show.help.page []
                   ----------------------
            clear message and display areas
            unset 'film list on display' flag
            initialise line counter
            set colour to cyan and init. cursor position
            output hard-wired lines of text
         end
**/

and g.nv.show.help.page () be
$(
   g.sc.clear (m.sd.message)
   g.sc.clear (m.sd.display)
   g.nv.s!m.film.list.on.display := false       // Help text is on display now
   G.sc.selcol(m.sd.cyan)

   s.i := 0

   line.("      Help with Video Sequences")
   line.("")
   line.("")
   line.("You are now on the National Disc - side B.")
   line.("You can select another video sequence")
   line.("by using the pointer and pressing")
   line.("<ACTION>.  Alternatively you can return")
   line.("to the last selection operation on")
   line.("side A by pressing 'Main'.")
   line.("")
   line.("To interrupt any video sequence press")
   line.("<ESCAPE>.")
   line.("")
   line.("Don't forget that there is sound with the")
   line.("video sequences.  You may need to adjust")
   line.("the volume control.")
   line.("")
   line.("")
   line.("Fuller Help Text on video sequences is")
   line.("available on side A immediately after")
   line.("selecting any Film item.")
$)


/**
         function this.title (buff)
         function this.chapter ()
         function this.audio.mode () each unpack and returns a value from the
         Film data item, obtained from DATA1/DATA2.
**/

let this.title (buff) =      // align string from byte 2 of current entry
   g.ut.align (g.nv.s!m.recptr, g.nv.s!m.current.entry.offset + 2, buff)

let this.chapter () =        // unpack byte 0 of current entry
   (g.nv.s!m.recptr) % (g.nv.s!m.current.entry.offset)

let this.audio.mode () = valof         // byte 1 of current entry
   switchon (g.nv.s!m.recptr) % (g.nv.s!m.current.entry.offset + 1) into
   $( case 0: resultis m.vh.no.channel
      case 1: resultis m.vh.right.channel
      case 2: resultis m.vh.left.channel
      default: resultis m.vh.both.channels
   $)

let this.title (buff) =      // align string from byte 2 of current entry
   g.ut.align (g.nv.s!m.recptr, g.nv.s!m.current.entry.offset + 2,
                                                      buff, m.nv.entry.size)


/**
         proc G.NV.START.CHOSEN.FILM ()
              ----------------------

         Play Chapter Specified

         The chapter specified in the data structure for the
         current item is started in LV only video mode with audio
         set as specified.

         INPUTS: No parameters.  g.cm.s!m.current.entry.offset
         must have been set up to point to the details of the
         film to be shown.

         SPECIAL NOTES FOR CALLERS:

         Current filing system MUST be VFS; current disc must be
         Nat B.
         Does NOT clear the screen: this allows the film menu to
         remain, but invisible, during the film.
         Changes video and audio modes and uses fcode "QxxS" to
         start the chapter play.  fcode "X" must be issued if the
         chapter is interrupted.  This prevents spurious reply
         codes from being sent by the player.

         PROGRAM DESIGN LANGUAGE:

         procedure g.nv.start.chosen.film []
                   -------------------------
            get chapter from data structure
            construct fcode string
            select 'LV only' video mode
            clear out fcode reply buffer
            command player to play chapter
            get audio mode from data structure
            command player to set audio mode
            command player to switch LV video output on
         end
**/

and g.nv.start.chosen.film () be
$(
   let reply.buf = vec m.vh.poll.buf.words
   let chapter.str = "QxxS"
   let num.str = vec 6/BYTESPERWORD

   g.vh.word.asc ( this.chapter (), num.str )
   chapter.str%3 := num.str%5          // copy bottom two digits
   chapter.str%2 := num.str%4
   g.vh.video (m.vh.LV.only)           // set first to avoid genlock glitch
   g.vh.poll (m.vh.read.reply, reply.buf) // clear out any reply code
   g.vh.send.fcode (chapter.str)
   g.vh.audio ( this.audio.mode () )
   g.vh.video (m.vh.video.on)
   // assumes that the return code remains in the buffer since neither of the
   // last 2 calls have a return code.  Poll for reply in action routine.
$)


/**
         G.NV.SHOW.FILM.LIST - Display Film Menu
         ---------------------------------------

         INPUTS: No parameters.  Uses NV statics.

         OUTPUTS: None

         GLOBALS MODIFIED: None.  Sets NV static flag 'film list
         on display' to avoid unnecessary redisplay of menu.

         SPECIAL NOTES FOR CALLERS:
         Explicitly sets audio and video modes.

         PROGRAM DESIGN LANGUAGE:

         procedure g.nv.show.film.list []
                   ----------------------
            turn off pointer
            set audio off
            set video 'micro only'
            set LV video output off
            if film list not on show then
               clear display area
               output heading in drop shaddow
               output film titles in cyan
               make a dummy call to g.sc.high to initialise it
            endif
         end
**/

and g.nv.show.film.list () be
$(
   let tbuff = vec m.nv.entry.size/BYTESPERWORD    // to align title, if nec.

   g.sc.pointer (m.sd.off)    // prevent flicker; pointer will be on if
                              // film has reached end - g.key = m.kd.noact
   g.vh.audio (m.vh.no.channel)
   g.vh.video (m.vh.micro.only)
   g.vh.video (m.vh.video.off)

   unless g.nv.s!m.film.list.on.display do   // only show if not there already
   $(
      let heading = "Video Sequences Available"
      g.sc.clear (m.sd.display)

      //  output heading, drop shadow
      g.sc.movea ( m.sd.display,
                   (m.sd.disw - g.sc.width (heading)) / 2,
                     m.sd.disYtex - m.nv.screen.heading.offset * m.sd.linw )
      g.sc.odrop (heading)

      //  output film titles as list items in cyan
      g.sc.selcol (m.sd.cyan)
      g.sc.movea ( m.sd.display,
                    m.sd.disXtex,
                     m.sd.disYtex - m.nv.screen.list.offset * m.sd.linw )
      g.nv.s!m.current.entry.offset := m.nv.list.offset
      for j = 1 to g.nv.s!m.num.entries do
      $(
         g.sc.oplist ( j, this.title (tbuff) )
         g.nv.s!m.current.entry.offset := g.nv.s!m.current.entry.offset +
                                                               m.nv.entry.size
      $)
      g.nv.s!m.film.list.on.display := true
      g.sc.high (0, 0, false, 100)     // dummy call to initialise
   $)
$)
.
