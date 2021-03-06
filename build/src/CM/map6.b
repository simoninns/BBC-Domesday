//  UNI SOURCE  4.87

section "map6"

/**
         CM.B.MAP6 - Central Routine for Showing Maps
         --------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.map

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         8.7.86   1        DNH         split from map3

         GLOBALS DEFINED:
         g.cm.showmap
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/sdhd.h"
get "H/cmhd.h"
get "H/cm2hd.h"

/**
         procedure g.cm.showmap (display flags, direction)
         handles display of the current map.  It is passed flags
         which control its operation.  These specify:
            m.cm.messages.bit <=> ignored
            m.cm.graphics.bit <=> show graphics for the map move
            m.cm.frame.bit    <=> show the video frame
            m.cm.icons.bit    <=> show icons and yellow border
         It is also passed a 'direction' manifest from cm2hdr,
         valid only if the graphics bit is set.

         IF graphics bit
         THEN
             IF down
             THEN
                 show video frame
                 IF level is 2, 3 or 4
                 THEN
                     clear the yellow border
                     select colour yellow
                     show expanding framework
                 ENDIF
             ELSE
                 IF up
                 THEN
                     show video frame
                     IF level = 1, 2 or 3
                     THEN
                         work out final box position
                         select colour yellow
                         show shrinking framework
                     ENDIF
                 ELSE
                     select colour blue
                     show first half of moving arrow
                     show video frame
                     show second half of moving arrow
                 ENDIF
             ENDIF
         ELSE
             IF frame bit
             THEN
                 show video frame
             ENDIF
         ENDIF

         IF icons bit
         THEN
             IF level 5
             THEN
                 clear yellow border
             ELSE
                 select colour yellow
                 show yellow border
             ENDIF

             IF icons exist
             THEN
                 FOR each submap
                     draw box or boxes
                     set 'clear pending' static
                 ENDFOR
             ENDIF
         ENDIF
         RETURN

         This routine is NEVER called to display a level 0 map
         since g.cm.showframe must be called directly to display
         the correct highlighted frame.
**/

let g.cm.showmap (dispflags, dir) be
$(
    test (dispflags & m.cm.graphics.bit) ~= 0 then    // show the graphics
    $(                                                // (frame bit assumed)
        test (dir = m.down) then
        $(  g.cm.showframe (g.cm.s!m.map)
            if 2 <= g.cm.s!m.cmlevel <= 4 do
            $(
                g.cm.clear.yellow.border ()
                g.sc.selcol (m.sd.yellow)
                g.cm.expand.frame.from (g.cm.s!m.old.a0,
                                        g.cm.s!m.old.b0,
                                        g.cm.s!m.old.a1,
                                        g.cm.s!m.old.b1)
            $)
        $)
        else
        test (dir = m.up) then
        $(  g.cm.showframe (g.cm.s!m.map)
            if 1 <= g.cm.s!m.cmlevel <= 3 do
            $(                     // work out offsets and show frames
                let a0 = g.cm.a.of (g.cm.s!m.old.x0 - g.cm.s!m.x0)
                let b0 = g.cm.b.of (g.cm.s!m.old.y0 - g.cm.s!m.y0)
                let a1 = g.cm.a.of (g.cm.s!m.old.x1 - g.cm.s!m.x0)
                let b1 = g.cm.b.of (g.cm.s!m.old.y1 - g.cm.s!m.y0)
                g.sc.selcol (m.sd.yellow)
                g.cm.shrink.frame.to (a0, b0, a1, b1)
            $)
        $)
        else        // other dirs are all 'move's
        $(          // show graphics before and after new frame
            let mask = m.n | m.s | m.e | m.w
            g.sc.selcol (m.sd.blue)
            g.cm.moving.arrow (dir & mask, false)
            g.cm.showframe (g.cm.s!m.map)
            g.cm.moving.arrow (dir & mask, true)
        $)
    $)
    else            // no graphics; just show the frame
        if (dispflags & m.cm.frame.bit) ~= 0 do
            g.cm.showframe (g.cm.s!m.map)

                    // show yellow border and icons if required
    if (dispflags & m.cm.icons.bit) ~= 0 do
    $(              // draw yellow border except at L5 where we clear it
        test g.cm.s!m.cmlevel = 5 then
            g.cm.clear.yellow.border ()
        else
        $(  g.sc.selcol (m.sd.yellow)               // show yellow border
            g.cm.box (true,0,0,m.sd.disw-1,m.sd.dish-1)  // abs. coords
        $)
                    // draw icons, if present. Set 'clear pending' flag
                    // if some drawn.
        if g.cm.s!m.istart ~= 0 do
        $(  let p = g.cm.s!m.recptr
            let d = g.cm.s!m.istart
            until d = g.cm.s!m.iend do
            $(  test (p%(d+1) & 4) ~= 0 then g.cm.drawboxes(p,d+2)
                else g.cm.drawbox(p%(d+2),p%(d+3),p%(d+4),p%(d+5))
                         // NB! for showframe next time it is called
                g.cm.s!m.clear.is.pending := true
                d := d+p%d
            $)
        $)
    $)
$)
.
