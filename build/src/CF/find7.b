//  AES SOURCE  4.87

/**
         CF.FIND7 - OUTPUTS FIND'S RUNNING COUNTS ON THE SCREEN
         ------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2             "      New 'get' directives
         22.05.86 3        PAC         Include g.cf.highlight,
                                       g.cf.einit, g.cf.eaction,
                                       g.dy.init, g.dy.free
         19.6.86  4        NY          Add gl5hd
         1.7.86   5        MFP         Remove g.sc.pointer calls
         28.7.86  6        MFP         'c.vrestore' setting added
         17.9.86  7        MFP         adjustments as marked
        15.10.86  8        PAC         diagnostics in g.cf.eaction
        16.10.86  9        PAC         Remove diags., fix posn. of numbers
        **********************************************
         8.6.87   10       MFP         CHANGES FOR UNI
         17.6.87  11       PAC         Fix max wsize
**/


section "find7"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "GH/gldyhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/cfhd.h"
get "H/iohd.h"

/**
         There are two special count boxes in  find, the
         'percentage through search' box and the 'perfect
         matches' box. These will be called the %-box and the
         m-box repectively.

         (x1,y1) are the coordinates of the %-box, and (x2,y2) of
         the m-box. The boxes have height h, full with 4c, where
         c is the width of one character.
**/

manifest $( c = m.sd.charwidth; h = m.sd.linw
            c2 = c*2; c3 = c*3; c4 = c*4
            x1 = m.sd.disXtex+24*c
            y1 = m.sd.disYtex-17*h
            x2 = m.sd.disXtex+24*c
            y2 = m.sd.disYtex-19*h
         $)

/**
         wrn.(n, x, y, xi, eta, s) outputs the number n in a
         small cyan box on the screen with top right hand corner
         at (x,y) (strictly: (x,y+4)) and dimensions xi by eta. s
         gives a WRITEF style string format for writing.
**/

let wrn.(n, x, y, xi, eta, s) be
$(  // g.sc.pointer(m.sd.off)      - removed 1.7.86
    g.sc.movea(m.sd.display, x, y+4)
    g.sc.selcol(m.sd.cyan); g.sc.rect(m.sd.plot, xi, -eta)
    g.sc.movea(m.sd.display, x, y-4) // y-4 mod. 16.10.86 PAC
    g.sc.selcol(m.sd.blue); g.sc.ofstr(s, n)
    // g.sc.pointer(m.sd.on)
$)

/**
         g.cf.writepc(n) outputs 'n%' in the 'percentage through
         search' box. If the previous number on the screen,
         'oldn', only differs from n in the final digit, then
         this digit alone is written.
**/

let g.cf.writepc(n) be
$(
    static $( oldn = 0 $)
    test n > 0 & n/10 = oldn/10 then wrn.(n rem 10, x1+c2, y1, c, h, "%N")
                                  or wrn.(n, x1, y1, c4, h, "%I3%%")
    oldn := n
$)

/**
         Similarly g.cf.writepm(n) writes into the 'perfect
         matches' box.
**/

let g.cf.writepm(n) be
$(
    static $( oldn = 0 $)
    if n = 101 do n := 100
    test n > 0 & n/10 = oldn/10 then wrn.(n rem 10, x2+c2, y2, c, h, "%N")
                                  or wrn.(n, x2, y2, c4, h, "%I3")
    oldn := n
$)

/**
         g.cf.highlight() highlights the keywords in the main
         query box.
**/

let g.cf.highlight() be
    for z = g.cf.p+p.z to g.cf.p+p.z+(g.cf.p!c.termcount-1)*m.h by m.h do
        g.cf.boxinput('h', z!c.hl1, z!c.hl2, m.sd.yellow, m.sd.blue)

/**
         FIND has two main states: 'main' and 'review'. 'Main'
         corresponds to the inputting of a new query. 'Review'
         corresponds to the inspection of a batch of retrieved
         query items. In entering FIND an 'extra' or E-state is
         used to choose between them.

         The init routine for the E-state is null.

         The action routine for the E-state chooses the 'review'
         state so long as (a) FIND was last exited from a
         non-null hit list, and (b) the current map has not
         changed. Otherwise 'main' is chosen.
**/

let g.cf.einit() be return

let g.cf.eaction() be
$(
   /* diagnostics added PAC 15.10.86
    g.sc.ermess( "state: %n mend: %n",g.cf.p!c.state, g.cf.p!c.mend)

    g.sc.ermess( "CX:bl %n : %n, %n : %n",
         g.context!m.grbleast , g.cf.p!c.x0,
         g.context!m.grblnorth , g.cf.p!c.y0 )

    g.sc.ermess( "CX:tr %n : %n, %n : %n",
         g.context!m.grtreast , g.cf.p!c.x1 ,
         g.context!m.grtrnorth , g.cf.p!c.y1 )
   // diagnostics added PAC 15.10.86
   REMOVED 16.10.86 PAC */

    test g.cf.p!c.state = s.review &   // last exit was from review state
         g.cf.p!c.mend > 0 &         // hit list exists - 17.9.86
         g.context!m.grbleast = g.cf.p!c.x0 &
         g.context!m.grblnorth = g.cf.p!c.y0 &
         g.context!m.grtreast = g.cf.p!c.x1 &
         g.context!m.grtrnorth = g.cf.p!c.y1  // same map
    then g.key := -m.st.cfindr or g.key := -m.st.cfindm
    g.redraw := false  // the menu bar will be drawn in 'review' or 'main'
$)

/**
         g.cf.dy.init() sets up the FIND environment on first
         entry. There are two work areas: a vector of size
         m.cf.datasize pointed to by g.cf.p which is cached and
         restored over successive entries, and a general
         workspace area for which the largest contiguous area of
         free store is taken.
**/

let g.cf.dy.init() be
$(
    g.cf.p := GETVEC(m.cf.datasize)
    // (if we can't 'restore' this area it must be initialised)
    unless g.ut.restore(g.cf.p,m.cf.datasize,m.io.cfcache) do
    $(  g.cf.p!c.state := s.unset   // FIND state for first entry
        (g.cf.p+p.oldq)%0 := 0      // null prvious query
        g.cf.p!c.termcount := 0     // with zero terms
        // remember which side of the disc we're on
        g.cf.p!c.side := g.context!m.discid // added 17.9.86
        g.cf.p!c.mend := 0 // no hit list - added 17.9.86
    $)
    // now open the three files used by FIND
    g.cf.p!c.index := g.dh.open("INDEX")
    g.cf.p!c.names := g.dh.open("NAMES")
    g.cf.p!c.gaz   := g.dh.open("GAZETTEER")
    g.dh.length(g.cf.p!c.gaz, g.cf.p+c.gazsize)
    $(  let wsize = MAXVEC()
        if wsize > m.cf.max.wsize wsize := m.cf.max.wsize // not too large !
        g.cf.p!c.ws := GETVEC(wsize) // establish workspace area
        g.cf.p!c.wssize := wsize+1    // exact number of words in this area
    $)
    g.cf.p!c.vrestore := true // added 28.7.86

    // Now test to see if the disc has been turned over

    if g.cf.p!c.side ~= g.context!m.discid do  // added 17.9.86
    $(  g.cf.p!c.side := g.context!m.discid // if so, note new side
        g.cf.p!c.mend := 0      // cancel any existing hit list
        g.cf.p!c.qforthisside := false // prev. query does not relate to
                                       // this side
    $)
$)

/**
         g.cf.dy.free() closes all files, discard the workspace
         and caches the g.cf.p vector.
**/

let g.cf.dy.free() be
$(
    g.dh.close(g.cf.p!c.index)
    g.dh.close(g.cf.p!c.names)
    g.dh.close(g.cf.p!c.gaz)
    FREEVEC(g.cf.p!c.ws)
    g.ut.cache(g.cf.p,m.cf.datasize,m.io.cfcache)
    FREEVEC(g.cf.p)
$)


