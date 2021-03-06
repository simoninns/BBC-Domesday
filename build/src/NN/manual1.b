//  PUK SOURCE  6.87

/**
         NM.MANUAL1 - MANUAL CLASSING OPERATION FOR MAPPABLE DATA
         --------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmMANU

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         20.02.86 1        D.R.Freed   Initial version
         ********************************
         30.6.87  2        DNH         CHANGES FOR UNI
         21.08.87 3        SRY         Added toggle video mode

         g.nm.manual
         g.nm.man.to.man
         g.nm.disable.entry.mode
**/

section "nmmanual1"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/kdhd.h"
get "H/nmhd.h"
get "H/nmclhd.h"


/**
         G.NM.MANUAL - ACTION ROUTINE FOR MANUAL CLASS OPERATION
         -------------------------------------------------------

         Action routine for manual manipulation of the class
         interval colours and numbers.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.key

         g.nm.s
         g.nm.class.upb

         PROGRAM DESIGN LANGUAGE:

         g.nm.manual []
         -----------

         IF (key = Tab) AND (pointer over box) AND
                            (entry mode is disabled) THEN
            change box colour
            resave new palette so that colour changes are permanent
            key = no action (to prevent beep)

         ELSE IF (key = Return) THEN
                  IF (entry mode enabled) THEN
                     convert string to unscaled number
                     update class upper bound
                     set intervals changed static to TRUE
                     put Replot on menu bar
                     disable entry mode

                  ELSE IF (pointer over box) THEN
                     enable entry mode

                  ELSE (disabled and outside message area)
                        do nothing - let kernel beep
                  ENDIF

         ELSE IF (entry mode is enabled) AND
                 (key is a valid character for a number string)
                  THEN include number in string and echo
              ENDIF
         ENDIF
**/

let g.nm.manual () be
$(
   let number = vec m.nm.max.data.size
   let norm.factor  =  ?

   let box.now = nm.get.box ()

   switchon g.key into
   $( case m.kd.tab:
         test g.screen = m.sd.message
         then if box.now > 0 & (not g.nm.s!m.nm.entry.mode)
              $( nm.change.box.colour (box.now)

                 // read palette and resave physical colours for restoring on
                 // exit out of Class - this ensures that the colours are left
                 // as the user has set them
                 for i = 1 to m.nm.num.of.class.intervals do
                    g.nm.s!(m.plotted.palette + i - 1) :=
                       g.sc.physical.colour (g.nm.class.colour!i)

                 g.key := m.kd.noact
              $)
         else g.nm.toggle.video.mode()
      endcase
      case m.kd.return:
         test g.nm.s!m.nm.entry.mode
         then $( test g.nm.dual.data.type (g.nm.s!m.nm.value.data.type)
                 then norm.factor := g.nm.s!m.nm.secondary.norm.factor
                 else norm.factor := g.nm.s!m.nm.primary.norm.factor

                 test g.nm.string.to.num (g.nm.s + m.number.string,
                                          norm.factor, number)
                 then $( g.ut.mov32 (number, g.nm.class.upb +
                                     g.nm.s!m.box * m.nm.max.data.size)

                         g.nm.s!m.nm.intervals.changed := TRUE

                         // Replot is now possible
                         g.nm.s!(m.nm.menu + m.box4) := m.sd.act
                         g.sc.menu (g.nm.s + m.nm.menu)
                      $)
                 else g.sc.ermess ("Invalid number")
                 g.nm.disable.entry.mode ()
              $)

         else if (g.screen = m.sd.message) &
                 (0 < box.now < m.nm.num.of.class.intervals)
                 nm.enable.entry.mode (g.nm.s + m.number.string, box.now)
      endcase
      default:
         if g.nm.s!m.nm.entry.mode & nm.valid.char (g.key)
            g.sc.input (g.nm.s + m.number.string, g.nm.s!m.foreg.col,
                        g.nm.class.colour!(g.nm.s!m.box),
                        g.nm.s!m.nm.number.width)
   $)
$)


/**
         G.NM.MAN.TO.MAN - MANUAL TO MANUAL TRANSITION
         ---------------------------------------------

         Initialisation routine for transition from manual
         to manual ; called when Replot is selected.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED:

         g.nm.s

         PROGRAM DESIGN LANGUAGE:

         g.nm.man.to.man []
         ---------------

         IF entry mode is enabled THEN
            disable entry mode
         ENDIF
         IF new class intervals are consistent THEN
            stop key border flashing
            replot variable
            suppress Replot on menu bar
            resave new class intervals
         ELSE
            error message
         ENDIF
**/

and g.nm.man.to.man () be
$(
   if g.nm.s!m.nm.entry.mode
      g.nm.disable.entry.mode ()

   test g.nm.check.class.intervals () then
      $(
         // stop key border flashing
         g.nm.s!m.nm.intervals.changed := FALSE
         g.nm.display.key (TRUE)

         // make box 4 blank to suppress Replot box
         g.nm.s!(m.nm.menu + m.box4) := m.wblank
         g.sc.menu (g.nm.s + m.nm.menu)

         g.nm.replot (FALSE, FALSE, FALSE)

         // resave new class intervals, since they have now
         // been made permanent
         MOVE (g.nm.class.upb, g.nm.s + m.plotted.upb,
               (m.nm.num.of.class.intervals + 1) * m.nm.max.data.size)
      $)

   else
         g.sc.ermess ("Inconsistent Class Intervals")
$)


/*
      nm.change.box.colour

         reassigns next physical colour to the box under the
         pointer and redraws the key to ensure suppressions are
         correct
*/

and nm.change.box.colour (box) be
$(
   g.sc.palette (g.nm.class.colour!box,
                 g.sc.next.colour (g.nm.class.colour!box) )

   g.nm.display.key (FALSE)
$)


/*
      nm.enable.entry.mode

         enables string entry mode, sets static box,
         sets up foreground colour and initialises the entry routine
*/

and nm.enable.entry.mode (string.ptr, box) be
$(
   g.nm.s!m.box := box

   g.nm.display.box (box, TRUE)   // wipe out old number by suppression

   // use the complement of the box colour, as in g.nm.display.box
   g.nm.s!m.foreg.col := m.nm.fg.col.base + box - 1

   g.sc.movea (m.sd.message,
               g.nm.s!(m.nm.box.position + box) + m.nm.x.pixels.to.graphics -1,
               m.sd.mesYtex)

   if box = 1 then    // restore "<" after suppression cleared it
      $(
         g.sc.selcol (g.nm.s!m.foreg.col)
         g.sc.oprop ("<")
      $)

   g.key := m.kd.noact
   string.ptr%0 := 0    // initialise string length

   g.sc.input (string.ptr, g.nm.s!m.foreg.col, g.nm.class.colour!box,
               g.nm.s!m.nm.number.width)

   g.nm.s!m.nm.entry.mode := TRUE
$)


/*
      g.nm.disable.entry.mode

         disables string entry mode, cleans up the input state and
         redisplays the key
*/

and g.nm.disable.entry.mode () be
$(
   g.nm.s!m.nm.entry.mode := FALSE

   // clean up text input state
   g.key := m.kd.return
   g.sc.input ("", g.nm.s!m.foreg.col, g.nm.class.colour!(g.nm.s!m.box), 0)

   g.nm.display.key (TRUE)
   g.key := m.kd.noact  // prevent the kernel beeping
$)


/*
      nm.get.box

         determines which box in the key the mouse pointer is
         over - assumes that the pointer is somewhere in the
         message screen area
*/

and nm.get.box () = valof
$(
   let box = 0

   for i = 1 to (m.nm.num.of.class.intervals - 1) do

      if (g.nm.s!(m.nm.box.position + i) < g.xpoint <
                     g.nm.s!(m.nm.box.position + i + 1) ) then
         box := i

   if (g.xpoint > g.nm.s!(m.nm.box.position + m.nm.num.of.class.intervals))
      then box := m.nm.num.of.class.intervals

   resultis box
$)

/*
      nm.valid.char

         determines if a character is a valid one for a
         scientific number notation literal OR a valid
         cursor editing key
*/

and nm.valid.char (char) = valof
$(
   if '0' <= char <= '9'  RESULTIS TRUE

   for i = 0 to 8 do
      if char = i!TABLE ' ', '.', '+',
                        '-', 'e', 'E',
                        m.kd.left, m.kd.right, m.kd.delete  RESULTIS TRUE
   RESULTIS FALSE
$)

.
