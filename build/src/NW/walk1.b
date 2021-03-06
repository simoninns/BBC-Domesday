//  UNI SOURCE  6.87

/**
22.      WALK - NATIONAL WALK AND GALLERY
         --------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.WALK

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         (Notes on previous versions deleted 7.10.86 NRY to make room.)
         7.8.86   11       M.F.Porter  m.picwidth, m.picheight changed
         8.9.86   12           "       separate header; full comments;
                                       width of central area increased;
                                       bug fixes as marked
         9.9.86   13       PAC         Mod to heading text
         17.9.86  14       DNH         Menu bar redraw fix
                                       Video unmute fixes
                                       Gallery from VFS not ADFS
         ***************************************************
         8.6.87   15       MFP         CHANGES FOR UNI
         16.9.87  16       MH          G.nw.init2, g.nw.action and arrow.
                                       taken out and put in walk2.
                                       showframe. is now a global
                                       G.nw.showframe.
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNWhd.h"
get "GH/gldyhd.h"
get "H/iohd.h"
get "H/kdhd.h"
get "H/ovhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/vhhd.h"
get "H/nwhd.h"

let r(d) = g.ut.unpack16.signed(g.nw,d+d)
and ru(d) = g.ut.unpack16(g.nw,d+d)

/**
         clear.() clears the message and display areas if
         necessary
**/

let clear.() be
$(  if g.nw!wmess do $(  g.sc.clear(m.sd.message); g.nw!wmess := false $)
    if g.nw!wdisp do $(  g.sc.clear(m.sd.display); g.nw!wdisp := false $)
$)

/**
         G.nw.showframe.(n) shows the nth videodisc frame
**/

and G.nw.showframe.(n) be    // DON'T UNMUTE HERE  DNH 17.9
$(  g.vh.frame(n)
    //  g.vh.video(m.vh.video.on)
    //  g.nw!vrestore := false  // video does not need restoring now
$)

/**
         WALK behaves differently depending on whether we have
         entered the gallery at the top level, or have retrieved
         and are exploring a surrogate journey. ingallery.() is
         true in the first case, otherwise false. Note that if
         from the gallery we walk through into a connected
         surrogate journey, ingallery.() is still true. The cases
         can be differentiated by the possible values of
         g.context!m.state, except when in the 'detail' state. In
         this latter case WALK keeps its own state in
         g.nw!gallerydetail to resolve the ambiguity.
**/

and ingallery.() = valof // g.nw!m.syslev = 1 until 15.7.86
$(  let s = g.context!m.state
    if s = m.st.gallery | s = m.st.galmove |
       s = m.st.gplan1 | s = m.st.gplan2 |
       s = m.st.detail & g.nw!gallerydetail resultis true
    resultis false
$)

/**
         The WALK data structure is pointed to by g.nw. This data
         structure is described fully elsewhere. g.nw!ctable
         points to the control table, which contains information
         about the series of views, 1, 2, 3 ... The current view
         is in g.nw!view. For a view, v, the view 45deg. right is
         v+1 if v is not a multiple of 8, otherwise v-7. The view
         obtained by moving forward is given in
         r(g.nw!ctable+2*v), but if this is zero there is nothing
         ahead of v. Hence the next definition of deadend.(view).
**/

and deadend.(view) = r(g.nw!ctable+2*view) = 0

/**
         If r(g.nw!c.table+2*v) < 0 the 'next' view is to be found
         in a linked data structure given in the link table.
         nextview.(view) therefore provides the view got by just
         moving forward.
**/

and nextview.(view) = valof
$(  let next = r(g.nw!ctable+2*view)
    if next >= 0 resultis next   // '0' means a dead-end
    view := r(g.nw!ltable-next+2)  // if next < 0 this is the next view
                                   // of the linked data structure
    $(  let v = vec 1
        g.ut.unpack32(g.nw,(g.nw!ltable-next)*2,v) // to linked data
        readdataset.(v)
    $)
    G.nw!base.pos := (view - 1) / 8 * 2  //MH 21.9.87
    resultis view
$)

/**
         rightof.(view) is the view got by turning right 45deg.
         Similarly leftof.(view)
**/

and rightof.(view) = (view & 7) = 0 -> view-7, view+1
and leftof.(view) = (view & 7) = 1 -> view+7, view-1

/**
         opposite.(view) is the view got by turning 180deg. This
         is implemented as four 'leftof.' turns.
**/

and opposite.(view) = leftof.(leftof.(leftof.(leftof.(view))))

/**
         moveto.(nextview) does the work of placing the user at
         nextview. If we have a gallery type data structure,
         g.nw!m.syslev = 1, and then no icons should be drawn to
         indicate details, otherwise magnifying glasses are drawn
         as necessary.
**/

and moveto.(nextview) be
$(  g.nw!view := nextview   // remember the new current position
    g.nw!fiddlemenu := true // following a move, the menu bar may need
                            // readjusting
    clear.()                // clear the screen if necessary
    G.nw.showframe.(g.nw!m.baseview+nextview) // show the picture for nextview
    unless g.nw!m.syslev = 1 do
    $(  let o = r(g.nw!ctable+2*nextview+1)// pick up offset into detail table
        if o < 0 return                   // no details if o < 0
        o := g.nw!dtable+o                // convert to offset down dtable
        // additions of 15.7.86 follow:
        g.sc.pointer(m.sd.off)            // turn mouse pointer off for speed
        // the next line sets a cautious window for writing to the screen
        g.sc.setwin(0, 0, m.sd.disw-1, m.sd.dish-1)
        // now draw the list of magnifying glasses:
        $(  g.sc.movea(m.sd.display, abs(r(o)), r(o+1))  // adjustment 14.7.86
            g.sc.icon(m.sd.mag.glass, m.sd.plot)
            g.nw!wdisp := true // something written in display area
            if r(o) < 0 break
            o := o+3
        $) repeat
        g.sc.defwin()          // go back to the default window
        g.sc.pointer(m.sd.on)  // mouse pointer back on
    $)
$)

/**
         readdataset.(o) reads into core the WALK dataset given
         by the double word item at adresses o,o+1. This is
         interpreted as a byte offset down a file F, where:

         F = "GALLERY" if in gallery mode (ingallery.()=true)
         F = "DATA1" if not, and if the offset top bit is unset
         F = "DATA2" if not, and if the offset top bit is set.

         The reading must be done in two parts. First 30 bytes
         are read. The offset to, and length of, the detail
         table are then found. Data is then read to the end of
         the detail table (which ends the data structure).

         Finally there is some fiddling of byte to word offsets.
**/

and readdataset.(o) be
$(  let v = vec 1   // to take a double word quantity
    let low, high, p = ?,?,?
    low := g.ut.get32(o,LV high)
    // next line much simplified 15.7.86
    p := g.dh.open(ingallery.() -> "GALLERY",
                   (high & #X8000) ~= 0 -> "DATA2", "DATA1")
    g.ut.set32(low,high & #X7FFF,v)  // 'v' is 'o' without top bit
    g.ut.set32(low,high,g.nw+addr0)  // keep current data structure
                                     // position. (Placed here 18.7.86)
    g.dh.read(p,v,g.nw,60)  // read headers
    $(  let len = r(20)+r(25)*2-60 // len bytes remain to be read
        let sixty = vec 1
        g.ut.set32(60,0,sixty)
        g.ut.add32(sixty,v)  // move v along by 30 BCPL words

        /* The next line gives the only trap in WALK, and is a test that
           the data structure to be read is not greater than the manifest
           m.datasize. There are no traps on WALK to check for the validity
           of the various WALK data structures. */

        g.ut.trap("NW",1,true,3,len,0,m.datasize*bytesperword-60)
        g.dh.read(p, v, g.nw+60/BYTESPERWORD, len)  // read rest
    $)
    g.dh.close(p)
    // pull out main info:
    g.nw!ltable := r(14)/2
    g.nw!ctable := r(16)/2
    g.nw!ptable := r(18)/2
    g.nw!dtable := r(20)/2
    g.nw!m.baseview := r(27)-1
    g.nw!m.baseplan := r(28)
    g.nw!m.syslev := r(29)
    g.nw!vrestore := true      // video needs restoring after data access
$)

/**
         With the menu bar:

         < Plan/Help   Main   <Move   Forward   Back   >Move

         g.nw.goright is the initialisation routine for '>Move',
         and similarly goleft, goforward and goback for '<Move',
         'Forward' and 'Back'.
**/

/**
         'Going right' means a step to the right without a change
         of direction. This is implemented as a right turn of
         90deg. ('rightof.' twice), followed by on step forward
         ('nextview.'), followed by a left turn of 90deg.
         ('leftof.' twice).
**/

and g.nw.goright() be
$(  let next = nextview.(rightof.(rightof.(g.nw!view)))
    test next = 0 then error.() or moveto.(leftof.(leftof.(next)))
$)

/**
         'Going left' is similar
**/

and g.nw.goleft() be
$(  let next = nextview.(leftof.(leftof.(g.nw!view)))
    test next = 0 then error.() or moveto.(rightof.(rightof.(next)))
$)

/**
         error.() delivers the standard error message for an
         inability to move in a particular direction
**/

and error.() be g.sc.ermess("No move possible in this direction")

/**
         'Going forward' is easy.
**/

and g.nw.goforward() be
$(  let next = nextview.(g.nw!view)
    test next = 0 then error.() or moveto.(next)
$)

/**
         'Going backward' involves turning right round
         ('opposite.'), followed by one step forward
         ('nextview.'), followed by turning right round again
         ('opposite.').
**/

and g.nw.goback() be
$(  let next = nextview.(opposite.(g.nw!view))
    test next = 0 then error.() or moveto.(opposite.(next))
$)

/**
         g.nw.init0() is the initialisation routine for the first
         entry to WALK. There are two main cases: if
         g.context!m.itemselected = true, we have just returned
         to the gallery after leaving it to inspect an item. In
         that case g.nw!view hold the current view, and we move
         to it. Otherwise we are at the front of a surrogate
         journey, and the initial view is in r(g.nw!ctable). In
         this second case we may be at the front of the gallery,
         in which case the lead-in film is played unless the last
         state was m.st.startstop, in which case the user will
         already have seen it.
**/

and g.nw.init0() be
$(
    g.nw!cu := 0  // indicates not just out of 'detail'

    g.nw!wdisp := true  // to force clearing of the display area
    test g.context!m.itemselected & ingallery.() then // adjusted 8.9.86
    $(  g.context!m.itemselected := false
        g.vh.video(m.vh.superimpose)  // addition 14.7.86
        g.nw!wmess := true  // to force clearing of the message area
        moveto.(g.nw!view)  // show picture of current view
    $)
    or
    $(  g.nw!view := r(g.nw!ctable)  // current view := initial view
        G.nw!base.pos := (G.nw!view-1)/8*2  //MH 21.9.87
        test g.context!m.state = m.st.gallery &
             g.context!m.laststate ~= m.st.startstop then
        $(  clear.()         // added 15.7.86
            g.sc.clear(m.sd.menu)  // added 15.7.86

            /* now play the bit of film using the standard method of
               calling the kernel primities: */
            g.vh.frame(film.start)
            g.vh.video(m.vh.micro.only)
            g.vh.play(film.start, m.ov.nfilme)
            g.vh.video(m.vh.superimpose)
            $(  let v = vec m.vh.poll.buf.words
                until g.vh.poll(m.vh.read.reply, v) = m.vh.finished loop
            $)
            /* the film is now over */
        $)
        or g.vh.video(m.vh.superimpose)  // addition 8.9.86
        moveto.(g.nw!view)

        /* Now put a the initial 'key' in the message area */

        g.sc.pointer(m.sd.off) // addition 8.9.86 + message fix 9.9.86 PAC
        g.sc.mess("  Turn left           Forward         Turn right")
        g.sc.selcol(m.sd.blue)
        for i = 1 to 2 do
        $(  g.sc.movea(m.sd.message, lmarg, 0)
            g.sc.liner(m.sd.plot, 0, m.sd.mesh)
            g.sc.movea(m.sd.message, rmarg, 0)
            g.sc.liner(m.sd.plot, 0, m.sd.mesh)
        $)
        g.sc.pointer(m.sd.on) // addition 8.9.86
        g.nw!wmess := true  // something in message area
    $)
$)

/**
         The initialisation for WALK when coming back from the
         detail and plan subtates is given by g.nw.init.(), which
         has an obvious definition:
**/

and g.nw.init() be moveto.(g.nw!view)

/**
         aticon.(x,y) test to see if the mouse pointer is at the
         icon with screen coordinates (x,y). For a gallery
         picture (x,y) is the bottom left point of a small
         rectangle with dimensions m.picwidth by m.picheight. For
         a magnifying glass detail, (x,y) is the centre of a
         small square with half-width m.lens.size
**/

and aticon.(x,y) = g.nw!m.syslev = 1 -> x <= g.xpoint <= x+m.picwidth &
                                        y <= g.ypoint <= y+m.picheight,
                                           // adjustment 14.7.86
                                        abs (x-g.xpoint) <= m.lens.size &
                                        abs (y-g.ypoint) <= m.lens.size

/**
         getitem.(q,d) selects the item at q,d+d out of NAMES
         prior to a pending state change to that item. The code
         here is fairly standard and occurs in nearly this form
         in FIND etc.
**/

and getitem.(q,d) be
$(  let p = g.dh.open("NAMES")
    let v = vec 1                        // space for a double word
    let a = vec 1
    let t = vec m.titlesize/bytesperword // space for a title entry
    g.ut.unpack32(q,d+d,a)
    g.ut.set32(m.titlesize,0,v)
    g.ut.mul32(a,v)    // 'v' is 'a'*m.titlesize
    g.dh.read(p,v,t,m.titlesize)      // read the title line into t
    g.dh.close(p)

    $(  let type = t%31                  //pick up its type

        // copy the whole title line into the g.context area:
        g.ut.movebytes(t,0,g.context+m.itemrecord,0,m.titlesize-4)
        g.ut.unpack32(t,32,g.context+m.itemaddress)

        // give g.key the correct value for the pending state change:
        g.key := -(type!table 0, m.st.datmap, m.st.datmap, m.st.datmap,
                                 m.st.chart, 0, m.st.ntext, m.st.ntext,
                                 m.st.nphoto, m.st.walk, m.st.film)

        // g.key = 0 should never happen. If it does the following gives
        // a recovery which will keep the system alive:
        if g.key = 0 do
        $(  g.sc.ermess("This picture isn't yet working")
            moveto.(g.nw!view)  // to restore picture etc.
            return
        $)
        g.context!m.itemselected := true

        // a bit more delicate fiddling in the g.context area:
        if g.key = -m.st.nphoto do g.context!m.picture.no := 1
        if g.key = -m.st.ntext do
        $(  g.ut.set32(-1,-1,g.context+m.itemadd2)
            g.ut.set32(-1,-1,g.context+m.itemadd3)
        $)
    $)
$)

/**
         The various action routines now follow.
**/

and g.nw.action() be
$(
    if g.context!m.justselected |  // 'init0' must be called explicitly if
                                   // entry was via pending state change
       g.context!m.itemselected & ingallery.() do
            // or if back from selected item - adjusted 8.9.86
    $(  g.nw.init0()
        g.context!m.justselected := false
    $)

    if g.nw!cu > 0 do  // if just back from 'detail':
    $(  g.nw.init()    // call the init routine to show the current view
        g.nw!cu := 0   // this indicates not-just-back-from-detail
    $)
    if g.nw!vrestore do           // if the video needs restoring:
    $(  g.vh.video(m.vh.video.on) // restore it
        g.nw!vrestore := false    // mark as not needing restoring
    $)

    /* if we are in the main 'move' states and a move has taken place
       to another view, the menu bar will usually need redrawing
       as the move opportunities will usually have changed.
       g.nw!fiddlemenu is set to true when this happens */

    test (g.context!m.state = m.st.walmove |
          g.context!m.state = m.st.galmove) then if g.nw!fiddlemenu do
    $(  let v = vec 5          // for the new menu
        let p = g.nw!view      // p is the current view
        for i = 0 to 5 do v!i := m.sd.act    // make all slots active

        // now blank out slots 2,3,4,5 as necessary:
        if deadend.(p) do v!3 := m.sd.wblank
        if deadend.(opposite.(p)) do v!4 := m.sd.wblank
        if deadend.(leftof.(leftof.(p))) do v!2 := m.sd.wblank
        if deadend.(rightof.(rightof.(p))) do v!5 := m.sd.wblank
        // test to avoid redrawing an unchanged menu bar  DNH  17.9.86
        for i = 0 to 5 if v!i ~= g.menubar!i do $( g.sc.menu(v); break $)
        g.nw!fiddlemenu := false // menu bar does not now need redrawing
    $)
    or g.nw!fiddlemenu := true /* if not in the move states we will need
                                  to fiddle the menu bar as soon as a move
                                  state is entered  */

    /* The mouse pointer in the left, middle or right third of the display area
       together with the TAB key is equivalent to the left, up, or right cursor
       keys respectively: */

    if g.key = m.kd.tab & g.screen = m.sd.display do
        g.key := g.xpoint <= lmarg -> m.kd.s.left,
                 g.xpoint >= rmarg -> m.kd.s.right,
                 m.kd.s.up
    switchon g.key into
    $(
        /* left, right, up and down cursor keys correspond to left turn,
           right turn, forward and back moves respectively: */

        case m.kd.s.left:  moveto.(leftof.(g.nw!view)); endcase
        case m.kd.s.right: moveto.(rightof.(g.nw!view)); endcase
        case m.kd.s.up:    g.nw.goforward(); endcase
        case m.kd.s.down:  g.nw.goback(); endcase

        /* RETURN corresponds to detail selection */
        case m.kd.return:
        $(  let o = r(g.nw!ctable+2*g.nw!view+1)  // o is an offset into
                                                 // the detail table
            if o < 0 endcase
            o := g.nw!dtable+o
            $(  if aticon.(abs(r(o)), r(o+1)) do // adjustment 14.7.86

                $(  test g.nw!m.syslev = 1
                    then getitem.(g.nw,g.nw!dtable+r(o+2))
                    or
                    $(  g.nw!cubase := g.nw!dtable+r(o+2); g.nw!cu := 1
                        clear.()
                        G.nw.showframe.(g.nw!m.baseview+r(g.nw!cubase+g.nw!cu))
                        g.key := -m.st.detail // walking down a chain
                        g.nw!gallerydetail := ingallery.()
                    $)
                    break
                $)
                if r(o) < 0 break
                o := o+3
            $) repeat
        $)
    $)
$)

and g.nw.action1() be  // action routine for close-ups
$(  g.context!m.justselected := false  // added 18.7.86
    if g.nw!vrestore do
    $(  g.vh.video(m.vh.video.on)
        g.nw!vrestore := false
    $)
    if g.key = m.kd.tab & g.screen = m.sd.display
        test g.xpoint <= thirdwidth then g.key := m.kd.fkey7 or
        test g.xpoint >= 2*thirdwidth then g.key := m.kd.fkey8 or
        g.sc.beep()
    if g.key = m.kd.fkey7 test g.nw!cu = 1 then g.sc.beep() or
    $(  g.nw!cu := g.nw!cu-1
        G.nw.showframe.(g.nw!m.baseview+r(g.nw!cubase+g.nw!cu))
    $)
    if g.key = m.kd.fkey8 test g.nw!cu = r(g.nw!cubase) then g.sc.beep() or
    $(  g.nw!cu := g.nw!cu+1
        G.nw.showframe.(g.nw!m.baseview+r(g.nw!cubase+g.nw!cu))
    $)
$)
and g.nw.dy.init() be
$(  g.nw := GETVEC(m.h+m.datasize)
    g.ut.restore(g.nw, m.h, m.io.nwcache) // no need to check result
    g.nw := g.nw+m.h
    // now read the right dataset - all added 15/7/86
    test ingallery.() then
    $(  let s = g.context!m.laststate
        if s = m.st.conten | s = m.st.nfindm | s = m.st.uarea |
           s = m.st.area | s = m.st.startstop do g.ut.set32(0,0,g.nw+addr0)
    $)
    or unless g.context!m.state = g.context!m.laststate do
        g.ut.mov32(g.context+m.itemaddress,g.nw+addr0)
    readdataset.(g.nw+addr0)  // reads and sets vrestore flag
$)

and g.nw.dy.free() be
$(
    g.nw := g.nw-m.h
    g.ut.cache(g.nw, m.h, m.io.nwcache)
    FREEVEC(g.nw)
$)
