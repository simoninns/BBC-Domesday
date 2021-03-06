//  AES SOURCE  4.87


/**
         CF.FIND6 - GAZETTEER HANDLER
         ----------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2             "      New 'get' directives
         2.5.86   3             "      trap.() for trap()
         3.5.86   4             "      overflow prevention in readblock.()
                                       traps 61 and 62 added
         19.6.86  5        NY          Add gl5hd
         18.7.86  6        MFP         $<debug removed
                                       pointer restored as marked
         18.7.86  7        MFP         Bug fix as marked
         17.10.86 8        PAC         Clear message bar in changepage
         20.10.86 9        PAC         Tidy up traps.
         *********************************************
         8.6.87   10       MFP         CHANGES FOR UNI
**/

section "find6"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/sdhd.h"
get "H/cfhd.h"

/**
         When a word, x, is looked up in the gazetteer, a
         continuous slab of the gazetteer is read into core
         starting at address b and ending at b+2*bsize. The entry
         for x is at b+bsize. Thus forward or backward paging
         does not involve further reads until q, the pointer into
         this area, goes below b or above b+2*bsize. If q does go
         outside these limits a new slab is read into the same
         area with the entry that was at the limit now in the
         middle of the area again.

         b, bsize, q and a few other variables are held as local
         statics.

         The structure of the gazetteer is described elsewhere.
**/

static $(

b = 0        // buffer area for gazetteer pages
bsize = 0    // half-size (in words) of this area
bbsize = 0   // ditto in bytes
w = 0        // 3 word slot for g.cf.lookup
q = 0        // byte offset into the gazetteer area
endstate = 0 // = -1, 0 or 1 according as q is in 1st, inner or last page
p = 0        // main FIND data structure pointer

$)

manifest $( maxgroupsize = 1000 $) //bytes

let trap.(n,val,low,high) be g.ut.trap("CF",60+n,true,3,val,low,high)

/**
         getvars.(..) and putvars.(..) copy the local statics
         from and to the area for caching statics in g.cf.p.
**/

let getvars.(h) be b,bsize,bbsize,w,q,endstate := h!0,h!1,h!2,h!3,h!4,h!5
and putvars.(h) be h!0,h!1,h!2,h!3,h!4,h!5 := b,bsize,bbsize,w,q,endstate

/**
         read.(size) reads 'size' bytes from the gazetteer to
         store address b at offset 'w' bytes (w a pointer to a
         double word quantity) down the gazetteer.
**/

and read.(size) be unless g.dh.read(p!c.gaz,w,b,size) = size do
$(  trap.(1,2,1,0)  // force fatal error
    finish
$)

/**
         readblock.(n)
            reads from 'w'-bsize to 'w'+bsize if n = -1
                  from 'w'+bsize to 'w'+3*bsize if n = +1
         'w' is adjusted to be the start position of this new
         slab. Thus readblock.(1) reads forward along the
         gazetteer and readblock.(-1) reads backward. An
         adjustment is made for the case when 'w' is close to the
         end of the file.
**/

and readblock.(n) be
$(  let v = vec 1
    let x = vec 1
    let size = 2*bbsize   // may go negative
                          // (actually it never does)
    test n > 0 then g.ut.set32(bbsize,0,v)
                 or g.ut.set32(-bbsize,-1,v)
    g.ut.add32(v,w)                   // readjust 'w'
    g.ut.mov32(p+c.gazsize,x)
    g.ut.sub32(w,x)   // x contains number of bytes between w & end of file
    g.ut.set32(size,0,v)  // bug fix of 18.7.86 here
    if g.ut.cmp32(x,v) < 0 do size := g.ut.get32(x,LV size)
    $<trace g.sc.ermess("reading %N bytes offset %X4 %X4 to %N",size,w!1,w!0,b)
    $>trace
    read.(size)
$)

/**
         prev.(q) moves q backward to point to the previous item.
         The length of the previous item is held in offset q-2 in
         bytes.
**/

and prev.(q) = valof
$(  let l = g.ut.unpack16(b,q-2)
    trap.(2,l,5,200) // had missing parameter - PAC 20.10.86
    q := q-l
    if q < 0 do $( readblock.(-1); q := q+bbsize $)
    resultis q
$)

/**
          next.(q) similarly.
**/

and next.(q) = valof
$(  let l = g.ut.unpack16(b,q)
    $<trace if g.ut.diag() do g.sc.ermess("At %N len %N",q,l) $>trace
    trap.(3,l,5,200)  // was g.ut.trap - mod 20.10.86 PAC
    q := q+l
    if q >= 2*bbsize do $( readblock.(1); q := q-bbsize $)
    resultis q
$)

/**
         Some gazetteer place names exceed the 35 character
         maximum for the screen. shorten.(q) cuts string at q
         down to this size. Result moved to b-20.
**/

and shorten.(q) = valof
$(  let l = b%q
    if l > 35 do l := 35
    g.ut.movebytes(b,q,b-20,0,l+1)
    (b-20)%0 := l
    resultis b-20
$)

/**
         changepage.(l,d,s) changes page in direction d (d = +1
         is forwards, d = -1 backwards), moving over l lines (= l
         gazetteer entries). s is the style. If s = 1 the new
         page is printed. If s = 0 there is no change on the
         screen.

         The result is the number of lines on the screen
         (excluding the last overlap line.)
**/

and changepage.(lines,direction,style) = valof
$(  let f = direction = 1 -> next., prev.
    let g = direction = 1 -> prev., next.
    if style ~= 0 do              // tidy up the screen
    $(  g.sc.pointer(m.sd.off)
        g.sc.clear(m.sd.message)  // added 17.10.86 PAC
        g.sc.clear(m.sd.display)
        g.sc.high(0,0,false,100)  // to force initial highlighting
        g.sc.selcol(m.sd.cyan)
        g.sc.movea(m.sd.display, m.sd.disXtex, m.sd.disYtex-m.sd.linw)
    $)
    for i = 1 to lines do
    $(  q := f(q)                 // go to next item
        if style ~= 0 do g.sc.oplist(i, shorten.(g(q)+2))
        if b%(q+3) = #XFF do          // if at terminal point in gazetteer,
        $(  q := g(q)              // go to previous item
            endstate := direction  // record type of end condition
            g.sc.pointer(m.sd.on)  // added 18.7.86
            resultis i-1           // return number of lines on screen
        $)
    $)
    if style ~= 0 do
    $(  g.sc.oplist(lines+1,shorten.(q+2)) // output the overlap line
        g.sc.pointer(m.sd.on)
    $)
    resultis lines   // return number of lines on screen
$)

/**
         begins.(s,q) gives true if the entry at q is equal to or
         begins with the word(s) in string s, false otherwise. If
         s is shorter than q the result will be false if s
         matches the beginning of q exactly, but if the last word
         of s is only a part word in q. For example:

            s = "beacon"
            q = "Beaconsfield" would give false.

         The comparison ignores case. **/

and begins.(s,q) = valof
$(  let l = s%0
    for i = 1 to l if CAPCH(s%i) ~= CAPCH(b%(q+i)) resultis false
    if b%q = l resultis true
    $(  let ch = b%(q+l+1)
        if ch = ' ' | ch = ',' | ch = '.' resultis true
    $)
    resultis false
$)

/**
         g.cf.lookupgaz(p0,s,v) looks up string s in the
         gazetteer.
         p0 is just g.cf.p
         The result is true if s is found uniquely, and then
         vector v contains the grid ref of the place. Otherwise
         the result is false, and the gazetteer page containing
         the nearest matching name is put on the screen.
**/

and g.cf.lookupgaz(p0, s, v) = valof
$(  p := p0              // p is just g.cf.p
    w := p!c.ws          // find a slot for w in the workspace area
    b := w+40            // b is well beyond w
    bsize := (p!c.wssize-40)/2  // b+2*bsize is the end of the workspace area
    bbsize := bsize*BYTESPERWORD
    // remove unnecessary spacing from s. (e.g. "  Little  Gidding" becomes
    // "Little Gidding"
    $(  let j = 0
        let lastspace = true
        for i = 1 to s%0 do
        $(  let ch = s%i
            let space = ch = ' '
            unless lastspace & space do $( j := j+1; s%j := ch $)
            lastspace := space
        $)
        s%0 := j  // reset the length
    $)
    // the next 5 lines is the standard mechanism for index look up in
    // FIND. See FIND2 for details
    g.ut.set32(0,0,w); w!o.wsize := maxgroupsize
    for i = 1 to m.cf.gazlevels-1 do
    $(  read.(w!o.wsize)
        g.cf.lookup(s,b,w)
    $)
    // The nearest entry to s is now given by offset 'w'.
    readblock.(-1)     // read a slab into store
    q := bbsize        // q is at the nearest entry
    while g.cf.compstring(s,0,b,q+2) > 0 do q := next.(q)
    // q is now at the first entry >= s.
    if begins.(s,q+2) do
    $(  q := next.(q)            // look at the following item
        unless begins.(s,q+2) do
        // the next block is obeyed if s uniquely identifies an entry
        $(  let easting, northing = g.ut.unpack16(b,q-6), g.ut.unpack16(b,q-4)
            test not g.cf.checkgr(easting,northing) then
               g.sc.ermess("Bad gridref")  // should never happen
            or
            $(  v!0, v!1 := easting, northing
                putvars.(p+p.s); resultis true
            $)
        $)
        q := prev.(q)            // otherwise back to previous item
    $)
    // the first gaz. item displayed should be the last one which
    // precedes s, so go back one:
    q := prev.(q)
    if b%(q+3) = #XFF do q := next.(q)// but go forward again if at
                                      // beginning
    endstate := 0                     // indicates not at beginning or end
    $(  let n = changepage.(m.titlespp, 1, 1)     // print the page
        p!c.gaztitles :=  changepage.(n, -1, 0)+1 // reset to head of page
    $)
    putvars.(p+p.s); resultis false
$)

/**
         g.cf.changegazpage(p0,d) changes page in direction d (d
         = 1 is forward, d = -1 backward). p0 is just g.cf.p.
**/

and g.cf.changegazpage(p0, direction) be
$(  p := p0
    getvars.(p+p.s)
    test direction = endstate then g.sc.beep() or
    $(  endstate := 0
        test changepage.(m.titlespp, direction, 0) = 0 &
          direction = endstate // only happens here if direction=-1
        then g.sc.beep() or
        $(  let n = changepage.(m.titlespp, 1, 1)    // print page
            p!c.gaztitles := changepage.(n, -1, 0)+1 // reset to head of page
        $)
    $)
    putvars.(p+p.s)
$)

/**
         g.cf.selectgazitem(n,v) selects the nth item on the
         current page by transferring its gridref to vector v.
**/

and g.cf.selectgazitem(n, v) = valof
$(  getvars.(g.cf.p+p.s)
    for i = 1 to n do q := next.(q)    // set q to end of nth item
    $(  let easting, northing = g.ut.unpack16(b,q-6), g.ut.unpack16(b,q-4)
        unless g.cf.checkgr(easting,northing) do
        $(  g.sc.ermess("Bad gridref") // this should never happen
            resultis false
        $)
        v!0, v!1 := easting, northing
    $)
    resultis true
$)
.
