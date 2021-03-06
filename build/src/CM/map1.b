
//  UNI SOURCE  4.87

section "map1"

/**
         CM.B.MAP1 - Display and Cache Procedures for Map
         ------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.map (overlay)

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18.2.86  1        DNH         Initial version
          1.4.86  2                    filing system checking
          9.5.86  3                    $$vfs flag to cmhdr
         29.5.86  4                    m0 -> map.L0;
         10.6.86  5                    debugmess changes
         26.6.86  6                    fix showframe logic
          1.7.86  7                    abort code from uthdr
                                       bugfix showframe
********************************************
         30.4.87   15      DNH      UNI version
                                    use g.ut.diag in debugmess
                                    use g.ut.unpack16 instead of
                                       g.cm.intof
                                    update g.cm.wordsfor

         GLOBALS DEFINED:
         g.cm.clear.yellow.border
         g.cm.showframe
         (g.cm.debugmess)
         g.cm.collapse
         g.cm.drawbox
         g.cm.drawboxes
         g.cm.wordsfor
         g.cm.findmaprec
         g.cm.testbit
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCMhd.h"
get "H/dhhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/vhhd.h"
get "H/cmhd.h"


/**
         procedure clear.display.centre () clears the display
         area right up to but not including the yellow rectangle.
         This gets rid of icons etc.
**/

let clear.display.centre () be
$(
    g.sc.movea (m.sd.display, 4, 4)
    g.sc.rect (m.sd.clear, m.sd.disw-9, m.sd.dish-9)
$)


/**
         procedure g.cm.clear.yellow.border () does just that.
         This is useful to avoid the slow process of clearing the
         whole display area when no icons are there to be
         cleared.
**/

let g.cm.clear.yellow.border () be
    g.cm.box (false, 0, 0, m.sd.disw-1, m.sd.dish-1)

/**
         procedure g.cm.showframe (frame.number) displays the
         specified frame unless it is already on show.  It sets
         the static frame number for use by other modules,
         especially in L0 highlighting.  It also clears relevant
         micro display areas if a clear is pending and switches
         the video on if required.
**/

and g.cm.showframe (n) be
$(
    $<DEBUG                // for testing
    g.cm.sel.fs (m.dh.vfs)
    $>DEBUG
    if g.cm.s!m.frame ~= n | g.cm.s!m.data.accessed do
    $(  if g.cm.s!m.frame ~= n & g.cm.s!m.clear.is.pending do
        $(  clear.display.centre ()       // get rid of old icons
            g.cm.s!m.clear.is.pending := false
        $)
        g.vh.frame (n)                       // show the frame
        g.cm.s!m.frame := n                  // set static
    $)
    if g.cm.s!m.data.accessed do         // must unmute video
    $(  g.cm.s!m.data.accessed := false  // reset flag
        g.vh.video (m.vh.video.on)       // switch on video
    $)
$)


/*
         g.cm.debugmess (f,a,b,c) takes a writef string f and
         optional parameters a,b,c and outputs it to the screen.
         But only if diagnostics are enabled.
*/

and g.cm.debugmess (f,a,b,c) be
    if g.ut.diag () do
        g.sc.mess (f,a,b,c)


/**
         procedure g.cm.collapse (f,a,b,c) is called on fatal
         errors. It calls g.sc.mess and the two debug procedures
         above before calling the global abort and tidy up
         routine.
**/

and g.cm.collapse (f,a,b,c) be
$(  g.sc.mess (f,a,b,c)
    g.ut.abort (m.ut.map.abort)
$)


/**
         procedure g.cm.drawbox (x,y,x1,y1) takes bottom left and
         top right grid ref. residuals within the current map and
         converts them to screen coordinates (BBC graphic units)
         before calling g.cm.box to draw the box.  It is used for
         the yellow border at L1-L4 and for icon boxes at L3 and
         L4.
**/

and g.cm.drawbox(x,y,x1,y1) be
$(  g.sc.selcol (m.sd.yellow)
    g.cm.box ( true, g.cm.a.of(x),    g.cm.b.of(y),
                     g.cm.a.of(x+x1), g.cm.b.of(y+y1) )
$)


/**
         procedure g.cm.drawboxes (p,d) extracts grid ref.
         residuals from the type b) icon vector starting at p%d
         to form a partial 5 by 5 grid overlaying certain level 3
         maps.  It ensures that the pointer stays off during
         this.
**/

and g.cm.drawboxes (p,d) be
$(  let old.ptr = g.sc.pointer (m.sd.off)
    for j = 0 to 4
        for i = 0 to 4
            if g.cm.testbit (p,d,5*j+i) do
                g.cm.drawbox ( muldiv (g.cm.s!m.width,i,5),
                               muldiv (g.cm.s!m.height,j,5), 8, 6 )
    g.sc.pointer (old.ptr)
$)


/**
         function g.cm.wordsfor (bytes) returns the number of
         words required to store a given number of bytes.
         It is fully wordsize independent.
**/

and g.cm.wordsfor (bytes) = (bytes+BYTESPERWORD-1)/BYTESPERWORD


/**
         FREESPACE MANAGEMENT
         Operations for the freespace management system follow
         this.  The vector must be obtained in g.dy.init.  Map
         records are read into store using the minimum number of
         bytes.  They are only cleared out when a record is
         required to be read and there is inadequate free store.
         Free store is always contiguous.

         function find (identifier, map number) tries to find the
         given map record in the freestore.  0 is returned for
         failure. The usage count for the record is incremented
         if it is found.
**/


and find(w0,w1) = valof
$(  let q = g.cm.s!m.base
    until q = g.cm.s!m.uptr do
    $(  if q!id0 = w0 & q!id1 = w1 do
        $(  q!lastused := g.cm.s!m.now
            q!usage := q!usage+1
            g.cm.s!m.now := g.cm.s!m.now+1
            resultis q
        $)
        q := q+size!q
    $)
    resultis 0
$)


/**
         procedure prunespace() makes room for another map record
         to be read in by shuffling up the freespace, deleting
         the least used record(s) until enough space has been
         freed.
**/

and prunespace() be
$(  let q = g.cm.s!m.base
    let q0 = g.cm.s!m.base
    until q = g.cm.s!m.uptr do
    $(  if q0!lastused >= q!lastused do q0 := q
        q := q+size!q
    $)
    /* q0 points to the item in the freespace which has not been used
       for the longest time, and this is removed. A more sophisticated
       removal rule could be tried, taking q!usage into account. */

    $(  let len = size!q0
        q := q0 + len
        for i = 0 to g.cm.s!m.uptr-q+1 do q0!(-headsize+i) := q!(-headsize+i)
        g.cm.s!m.uptr := g.cm.s!m.uptr - len
    $)
$)


/**
         function readtospace (ident, map number) reads the
         record whose map number is given into the cache.  First
         it reads the length and then it prunes the cache to free
         up some room if required.  Finally it reads the whole
         record, without the padding, into the cache.
**/

and readtospace(w0,w1) = valof
$(  let v = vec 1
    let u = ?
    let blen, wlen = ?,?
    let p32 = vec 1
    let t32 = vec 1
         // calculate file pointer as record size * map record offset
    g.ut.set32 (m.cm.map.rec.size, 0, p32)
    g.ut.set32 (g.cm.transmapno (w1) - map.L0, 0, t32)
    if g.ut.mul32 (t32, p32) = 0 do g.cm.collapse ("Overflow in readtospace")

         // read the length; make some space; read the record
    g.dh.read (g.cm.s!m.fhandle, p32, v, 2)
    blen := g.ut.unpack16.signed (v,0)
    if blen < 0 do g.cm.collapse("Negative length")
    wlen := headsize + g.cm.wordsfor(blen)
    if wlen < 0 do g.cm.collapse("Negative word length")
    if wlen > g.cm.s!m.top - g.cm.s!m.base do
        g.cm.collapse("Item too large - %N",wlen)
    while wlen > g.cm.s!m.top - g.cm.s!m.uptr do prunespace()
    u := g.cm.s!m.uptr     // local copy of cache pointer to space for record
    size!u := wlen
    u!lastused := g.cm.s!m.now
    u!usage := 1
    u!id0 := w0
    u!id1 := w1
    g.cm.s!m.now := g.cm.s!m.now + 1
    g.dh.read (g.cm.s!m.fhandle, p32, u, blen)

         // update flags and pointers
    g.cm.s!m.data.accessed := true     // (video has been muted)
    g.cm.s!m.uptr := u + wlen   // update uptr beyond current record
    resultis u                  // return pointer to new record
$)


/**
         function g.cm.findmaprec(map number) returns a pointer
         to the record whose map number is given.  It collapses
         if the record cannot be found.
**/

and g.cm.findmaprec(n) = valof
$(  let q = find('M',n)
    if q ~= 0 resultis q
    if g.cm.transmapno (n) = -1 do g.cm.collapse ("Map %N has no record", n)

    $<DEBUG
    g.cm.sel.fs (m.dh.adfs)
    $>DEBUG
    q := readtospace('M',n)
    $(  let map = g.ut.unpack16 (q,2)
        unless map = n do
            g.cm.collapse("Can't find map %N (%N)", n, map)
    $)
    resultis q
$)


/**
         function g.cm.testbit (p,i,j) returns a boolean value
         according to whether the jth bit, counting from bit zero
         of byte p%i, is set.
**/

and g.cm.testbit(p,i,j) = valof
$(  let q = j >> 3               // calc. byte offset
    let r = j & #X07             // calc. bit number within byte
    let byte = p%(i+q)           // get byte
    let bit = (byte >> r) & #X01 // move bit to LSbit
    resultis bit ~= 0            // return boolean for bit value
$)
.
