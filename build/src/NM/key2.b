//  PUK SOURCE  6.87

/**
         NM.KEY2 - KEY DISPLAY FOR NATIONAL MAPPABLE
         -------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         MAPPROC

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         28.02.86 1        D.R.Freed   Initial version

         g.nm.display.key
         g.nm.display.box
         g.nm.display.link.key
**/

section "nmkey2"
get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/nmhd.h"

get "H/nmcphd.h"

// manifests local to this module

manifest
$(
m.nm.char.width   =  m.sd.mesw / m.sd.charsperline
m.nm.box0.size    =  m.nm.char.width * 2 + m.nm.x.pixels.to.graphics * 2
$)


/**
         G.NM.DISPLAY.KEY - DISPLAY KEY TO MAPPABLE DATA
         -----------------------------------------------

         Displays the key to the current mappable data display,
         in the message area, with or without outline box.

         INPUTS:

         Outline flag

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s!m.nm.box.position
         g.nm.s!m.nm.number.width

         SPECIAL NOTES FOR CALLERS:

         This routine should work for any sensible number of
         class intervals (m.nm.num.of.class.intervals), ie.
         2 - 5. Five is the maximum because it uses all the
         available colours.

         PROGRAM DESIGN LANGUAGE:

         g.nm.display.key [outline.flag]
         ----------------

         turn off mouse pointer

         display first box (NA - not available)

         IF current dataset type = incidence data THEN
            display special key
         ELSE
            calculate box positions and number width

            display all regular boxes, suppressing numbers in
                                       duplicate boxes
            display last box ( > - all values greater than last
                                   cut-point)
         ENDIF

         IF outline.flag is TRUE THEN
            IF class intervals are changed THEN
               select flashing white for border
            ELSE
               select select steady white for border
            ENDIF
            draw outline border
         ENDIF

         restore mouse pointer

         (displaying a box involves drawing the box in the
         interval's colour and then displaying the upper bound
         for the interval in the complementary colour, so that it
         is visible)
**/

let g.nm.display.key (outline.flag) be
$(
   let entry.state   =  ?

   entry.state := g.sc.pointer (m.sd.off)

   // first box always same - white NA on black background
   do.NA.box ()

   test (g.nm.s!m.nm.value.data.type = m.nm.incidence.type) then

      nm.display.incidence.words ()

   else
      $(
      nm.setup.key ()

      // regular boxes containing actual cut-points

      for i = 1 to (m.nm.num.of.class.intervals - 1) do

         // this box identical to previous one (number and physical colour) ?
         test (g.sc.complement.colour(g.nm.class.colour!i) =
                  g.sc.complement.colour(g.nm.class.colour!(i-1)) ) &
              (g.ut.cmp32 (g.nm.class.upb + (i * m.nm.max.data.size),
                           g.nm.class.upb + ((i-1) * m.nm.max.data.size) ) =
                                                                 m.eq) then

            g.nm.display.box (i, TRUE)  // suppress number display

         else

            g.nm.display.box (i, FALSE) // show number


      // last box - ">"
      g.nm.display.box (m.nm.num.of.class.intervals, FALSE)
      $)

   // draw outline box, if required, in appropriate colour
   if outline.flag then
      draw.border ()

   g.sc.pointer (entry.state)
$)


/**
         G.NM.DISPLAY.BOX - DISPLAY INDIVIDUAL BOX IN KEY
         ------------------------------------------------

         Displays the specified box in the key ; if the suppress
         flag is FALSE, then the number is displayed in the box.

         To be used for all boxes except the first ("NA"), which
         cannot be manipulated.

         INPUTS:

         Index into class and box position vectors
         Suppress flag

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none


         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.display.box [index, suppress]
         ----------------

         select background colour from colour vector
         move to box start position (in position vector)
         draw box of appropriate size

         assign complement physical colour of box to logical
            colour
         select the foreground colour

         IF suppress = TRUE THEN
            RETURN
         ENDIF

         move inside box for number/symbol display

         IF index = 1 (first cut-point) THEN
            display "<" in box
         ENDIF

         IF index = m.nm.num.of.class.intervals THEN
            display centred ">" in box

         ELSE IF dual data type THEN
            display number in box using secondary normalising
                                                   factor
         ELSE
            display number in box using primary normalising
                                                   factor
         ENDIF
**/

and g.nm.display.box (i, suppress.flag) be
$(
   let offset, foreg.col, end.pos =  ?, ?, ?

   g.sc.selcol (g.nm.class.colour!i)
   g.sc.movea (m.sd.message, g.nm.s!(m.nm.box.position + i),
               m.nm.y.pixels.to.graphics)

   test (i = m.nm.num.of.class.intervals) then
      end.pos := m.sd.mesw - m.nm.x.pixels.to.graphics - 1
   else
      end.pos := g.nm.s!(m.nm.box.position + i + 1)

   g.sc.rect (m.sd.plot, end.pos - g.nm.s!(m.nm.box.position + i) - 1,
              m.sd.mesh - 2 * m.nm.y.pixels.to.graphics - 1)

   foreg.col := m.nm.fg.col.base + i - 1

   g.sc.palette (foreg.col, g.sc.complement.colour (g.nm.class.colour!i) )
   g.sc.selcol (foreg.col)

   if (suppress.flag = TRUE) then
      return

   test (i = m.nm.num.of.class.intervals) then
      // centre ">" character in available width
      offset := (end.pos - g.nm.s!(m.nm.box.position + i)) / 2 -
                                                   m.nm.x.pixels.to.graphics
   else
      offset := m.nm.x.pixels.to.graphics

   g.sc.movea (m.sd.message,
               g.nm.s!(m.nm.box.position + i) + offset - 1,
               m.sd.mesYtex)

   if (i = 1) then
      g.sc.oprop ("<")  // first box needs prefix

   test (i = m.nm.num.of.class.intervals) then
      g.sc.oprop (">")

   else test g.nm.dual.data.type (g.nm.s!m.nm.value.data.type) then

      g.sc.opnum (g.nm.class.upb + i * m.nm.max.data.size,
                  g.nm.s!m.nm.secondary.norm.factor,
                  g.nm.s!m.nm.number.width)

   else

      g.sc.opnum (g.nm.class.upb + i * m.nm.max.data.size,
                  g.nm.s!m.nm.primary.norm.factor,
                  g.nm.s!m.nm.number.width)
$)


/**
         G.NM.DISPLAY.LINK.KEY - DISPLAY KEY FOR LINK OPERATION
         ------------------------------------------------------

         Displays the special key for the link sub-operation
         in the message area, with outline box.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.display.link.key []
         ---------------------

         turn off mouse pointer

         display first box (NA - not available)
         display boxes with words using colours
            that are temporarily allocated for use
            in the Link sub-operation
         draw border

         restore mouse pointer
**/

and g.nm.display.link.key () be
$(
   let entry.state = ?

   entry.state := g.sc.pointer (m.sd.off)

   do.NA.box ()
   nm.incidence.box (1, "No data", m.fg.nodata, m.bg.nodata)
   nm.incidence.box (2, "Coincident data", m.fg.coinc, m.bg.coinc)
   draw.border ()

   g.sc.pointer (entry.state)
$)


/*
      do.NA.box

         draws the special "NA" box which is common to all keys

         also assigns the logical colours white and flashing white
*/

and do.NA.box () be
$(
   // set up logical colours reserved for whites
   g.sc.palette (m.nm.white, m.sd.white2)
   g.sc.palette (m.nm.flash.white, m.sd.flash.white2)

   // draw white NA on black background
   g.sc.selcol (g.nm.class.colour!0)
   g.sc.movea (m.sd.message,
               2 * m.nm.x.pixels.to.graphics - 1,
               m.nm.y.pixels.to.graphics)

   g.sc.rect (m.sd.plot, m.nm.box0.size - 1,
              m.sd.mesh - 2 * m.nm.y.pixels.to.graphics - 1)

   g.sc.selcol (m.nm.white)

   g.sc.movea (m.sd.message,
               2 * m.nm.x.pixels.to.graphics, m.sd.mesYtex)

   g.sc.ofstr ("%c", m.nm.NA.char)  // special mode 2 character - "NA"
$)


/*
      draw.border

         draws the outline border box in:
            flashing white if the class intervals have been
                           changed without a Replot
            white otherwise
*/

and draw.border () be
$(
   test g.nm.s!m.nm.intervals.changed then
      g.sc.selcol (m.nm.flash.white)
   else
      g.sc.selcol (m.nm.white)

   g.sc.movea (m.sd.message, 0, 0)
   g.sc.linea (m.sd.plot, m.sd.message, 0, m.sd.mesh - 1)
   g.sc.linea (m.sd.plot, m.sd.message, m.sd.mesw - 1, m.sd.mesh - 1)
   g.sc.linea (m.sd.plot, m.sd.message, m.sd.mesw - 1, 0)
   g.sc.linea (m.sd.plot, m.sd.message, 0, 0)
$)


/*
      nm.display.incidence.words

         displays the words in the special key for
         incidence type data
*/

and nm.display.incidence.words () be
$(
   // assign foreground colours and draw each box

   g.sc.palette (m.nm.fg.col.base,
                 g.sc.complement.colour (g.nm.class.colour!1) )
   g.sc.palette (m.nm.fg.col.base + 1,
                 g.sc.complement.colour (g.nm.class.colour!2) )

   nm.incidence.box (1, "Absent", m.nm.fg.col.base, g.nm.class.colour!1)
   nm.incidence.box (2, "Present", m.nm.fg.col.base + 1, g.nm.class.colour!2)
$)


/*
      nm.incidence.box

         draws a box containing a string in one of the special
         keys, using the given foreground and background logical
         colours
*/

and nm.incidence.box (pos, string.ptr, fg.col, bg.col) be
$(
   let width  =  ?

   g.sc.selcol (bg.col)

   width := m.sd.mesw - m.nm.box0.size // available width

   g.sc.movea (m.sd.message,
               (pos - 1) * (width / 2) + m.nm.box0.size,
               m.nm.y.pixels.to.graphics)

   g.sc.rect (m.sd.plot, width / 2,
              m.sd.mesh - 2 * m.nm.y.pixels.to.graphics - 1)

   g.sc.selcol (fg.col)

   g.sc.movea (m.sd.message,
               (pos - 1) * (width / 2) +  m.nm.box0.size +
                  (((m.sd.charsperline / 2) - string.ptr%0) / 2) *
                                                      m.nm.char.width,
               m.sd.mesYtex)

   g.sc.oprop (string.ptr)
$)


/*
      nm.setup.key

         calculates the starting position of each box in the key,
         in graphics coords, and the character width available
         for each number
*/

and nm.setup.key () be
$(
   // 6 character positions are lost to "NA ", "<", " > " plus
   // 2 pixels before "NA", 1 pixel at the end of each number box
   // and 2 pixels at end of last box

   g.nm.s!m.nm.number.width :=
      (m.sd.mesw - 6 * m.nm.char.width -
         (m.nm.num.of.class.intervals + 1) * m.nm.x.pixels.to.graphics
      ) / ( (m.nm.num.of.class.intervals - 1) * m.nm.char.width)

   g.nm.s!m.nm.box.position := 0

   g.nm.s!(m.nm.box.position + 1) := m.nm.box0.size

   // next box has to allow for the "<" character in the previous box
   g.nm.s!(m.nm.box.position + 2) :=
               g.nm.s!(m.nm.box.position + 1) +
                  (g.nm.s!m.nm.number.width + 1) * m.nm.char.width +
                     m.nm.x.pixels.to.graphics

   for i = 3 to m.nm.num.of.class.intervals do

      g.nm.s!(m.nm.box.position + i) :=
            g.nm.s!(m.nm.box.position + i-1) +
                  g.nm.s!m.nm.number.width * m.nm.char.width +
                     m.nm.x.pixels.to.graphics
$)

.

