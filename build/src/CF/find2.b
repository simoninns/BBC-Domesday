//  AES SOURCE  4.87

/**
         CF.FIND2 - CONSTRUCTS QUERY CONTOL VECTOR FROM TEXT QUERY
         ---------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2             "      New 'get' directives
         2.6.86   3             "      trap.() for trap()
         19.6.86  4        NY          Add gl5hd
         20.6.86  5        MFP         'maxgroupsize' fix
         18.7.86  6        MFP         $<debug removed
         23.7.86  7        NRY         Code for 'bad' GAZETTEER removed
         3.8.86   8        MFP         p!c.lev:=0 fudge removed
         17.9.86  9        MFP         'c.qforthisside' used
         *********************************************
         8.5.87  10        MFP         CHANGES FOR UNI
**/


section "find2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/cfhd.h"

let trap.(n,val,low,high) be g.ut.trap("CF",20+n,true,3,val,low,high)

/**
         small.(ch) is the converse of CAPCH(ch).
         worsizeofstring.(s) is the number of words required to
         hold string s
**/

let small.(ch) = 'A' <= ch <= 'Z' -> ch-'A'+'a', ch
let wordsizeofstring(s) = (s%0+bytesperword)/bytesperword

/**
         changecolour.(p) changes the colour of the query box
         from cyan to blue, and the colour of the query from blue
         to cyan. (p is g.cf.p).
**/

let changecolour.(p) be
$(  g.cf.boxinput('f',(table 0,m.sd.disYtex-8*m.sd.linw,40,3),m.sd.blue)
    g.cf.boxinput('h',1,(p+p.q)%0,m.sd.cyan,m.sd.blue)
$)

/**
         extractwords.(p) extracts the words in string s to an
         area v (the workspace area, allowing m.vsize words) for
         index lookup. The result is the number of words extracted.
**/

let extractwords.(p) = valof
$(  let s = p+p.q  // the current text query
    let v = p!c.ws  // the workspace area

    let w = v+2  // pointer into v-area
    let slen = s%0
    let i = 1  // offset in s
    let k = m.vsize  // v!k ... v!(m.vsize-1) address the words in v
    let ch = ?
    $(
        $(  if i > slen resultis m.vsize-k  // term count
            ch := small.(s%i); if 'a' <= ch <= 'z' break
            i := i+1
        $) repeat
        /* now at a letter */
        $(  let j = 0
            w!-2 := i  // 1st limit for highlighting
            $(  j := j+1; w%j := ch; i := i+1
                if i > slen break
                ch := small.(s%i)
            $) repeatwhile 'a' <= ch <= 'z'
            if j < 3 loop  // ignore 1 and 2 letter words
            w%0 := j
            w!-1 := i-1  // 2nd limit for highlighting
            g.cf.stem(w)
            if w%0 > 20 do w%0 := 20
        $)
        /* the new word is now a string at w */
        $<trace WRITEF("/%S/*N",w) $>trace
        $(  let l = k
            $(  let compare = l = m.vsize -> 1, COMPSTRING(v!l, w)
                if compare = 0 break // duplicate word
                if compare > 0 do
                $(  MOVE(v+k, v+k-1, l-k)  // leave a hole
                     v!(l-1) := w   // slot in w
                    k := k-1; w := w+2+wordsizeofstring(w)
                    trap.(1,w-v,2,k)
                    break
                $)
                l := l+1
            $) repeat
        $)
    $) repeat
$)

$<trace
let MONITOR.(s,p) be
$(  WRITEF("/%S/:  ",s)
    WRITEF("/%S/ ",p+1)
    p := nextind.(p)-4
    WRITEF("(%N) [%N:%N]*N",p!(-1),p!2,p!1)
$) $>trace

/**
         g.cf.lookup(s,p,r) searches for string s down the
         sequence of index entries starting at p. The address of
         the offset (O) part for the next level in the index goes
         into r, together with the size in bytes of the entries
         at the next level.
**/

let g.cf.lookup(s, p, r) be
$(  manifest $( maxgroupsize = 2000 $) // bytes
    let firstentry = true
    let v = vec o.wsize-1
    let d = 0
    let dbase = 0  // for trapping
    $(  $<trace MONITOR.(s,p) $>trace
        if g.cf.compstring(s,0,p,d+2) < 0 do
        $(  if firstentry do d := d+g.ut.unpack16(p,d) // a rare event
            g.ut.unpack32(p,d-6,r)
            // the next line should not be necessary (removed 23.7.86)
        //  test p%(d+3) = #XFF then r!o.wsize := maxgroupsize or
            $(  g.ut.unpack32(p,d+g.ut.unpack16(p,d)-6,v)
                g.ut.sub32(r,v)
                $(  let low, high = ?,?
                    low := g.ut.get32(v, LV high)
                    trap.(2,high,0,0)
                    trap.(3,low,10,2000)
                    r!o.wsize := low+g.ut.unpack16(p,d)
                $)
            $)
            $<trace WRITEF("Next grouping size:%N*N",r!o.wsize) $>trace
            return
        $)
        firstentry := false; d := d+g.ut.unpack16(p,d)
              trap.(4,d-dbase,10,r!o.wsize)
    $) repeat
$)

/**
         find0.(s, p) is similar, working at the lowest index
         level. The result is 0 if the string p is not found,
         otherwise the address of the offset.
**/

let find0.(s, p) = valof
$(  let d = 0
    $(  let compare = g.cf.compstring(s,0,p,d+2)
        $<trace MONITOR.(s,p) $>trace
        d := d + g.ut.unpack16(p,d)
        if compare < 0 resultis 0
        if compare = 0 resultis d-6
    $) repeat
$)

/**
         weight.(n) returns the integer part of 10*log(N/n) where
         N is the total number of indexable items. We can assume
         N = 50000, and return a crude estimate for the log (to
         base 2) without deleteriously affecting retrieval
         performance.
**/

let weight.(n) = valof
$( let x = 10000 / n  /* see above */
   let log2x = 25  // 10 log2 5
   while x >= 8 do $( x := x/2; log2x := log2x+10 $)
   resultis log2x + x!table 0, 0, 10, 16, 20, 23, 26, 28
$)

/**
         read.(h,v,q,n,e) reads n bytes from the file with handle h
         at offset v bytes (v a vector giving a double word
         quantity) to store address q. fatal trap e is forced if
         the read doesn't work.
**/

let read.(h,v,q,n,errornumber) be unless g.dh.read(h,v,q,n) = n do
$(  trap.(errornumber,2,1,0)  // force fatal error
    finish
$)

/**
         lookupwords.(p,termcount,levels) looks up the words in v
         = p!c.ws, putting the offsets into w using r as
         temporary work space. w and r are beyond v in the
         workspace area. The query control vector is then formed
         in z = p+p.z The result is the new termcount.
**/

let lookupwords.(p, termcount, levels) = valof
$(  let v = p!c.ws  // workspace area
    let w = v+m.vsize //2nd workspace area - requires 30*(o.wsize+1) words max
    let r = w+termcount*(o.wsize+1) // 3rd workspace area for index entries
    let z = p+p.z  // query control vector
    let notermasyet = true

    let oldo = vec o.wsize-1
    g.ut.set32(-1,-1,oldo) // anything different from 0

    /* initialise the index offsets to the front of the index: */
    for i = 0 to (o.wsize+1)*(termcount-1) by o.wsize+1 do
    $(  g.ut.set32(0,0,w+i)
        w!(i+o.wsize) := 200
    $)

    /* trace through the index levels up to the lowest: */
    for j = 1 to levels-1 for i = termcount-1 to 0 by -1 do
    $(  /* read a new index level if required: */
        let k = i*(o.wsize+1)
        $<trace WRITEF("Level %N*N",j) $>trace
        unless g.ut.cmp32(oldo,w+k) = 0 do
        $(  trap.(5,w!(k+o.wsize),0,(p!c.wssize-(r-v))*2)
            read.(p!c.index, w+k, r, w!(k+o.wsize), 6)
            g.ut.mov32(w+k,oldo)
        $)
        /* esablish the offset to the next index level: */
        g.cf.lookup(v!(m.vsize-1-i), r, w+k)
    $)
    /* trace through the lowest index levels */
    $<trace WRITEF("Level %N*N",levels) $>trace
    $(  let bestmatch = 0
        for i = termcount-1 to 0 by -1 do
        $(  let k = i*(o.wsize+1)
            read.(p!c.index, w+k, r, w!(k+o.wsize), 2)
            $(  let t = v!(m.vsize-1-i)
                let d = find0.(t, r)
                test d = 0 then termcount := termcount-1 or
                $(  let f = g.ut.unpack16(r,d-2) // pick up frequency
                    trap.(7,f,1,32767)
                    g.ut.unpack32(r,d,z+c.o) // copy offset
                    z!c.f := f
                    z!c.w := weight.(f); bestmatch := bestmatch+z!c.w
                    z!c.hl1 := t!-2
                    z!c.hl2 := t!-1
                    $<trace
                       WRITEF("term %N freq %N weight %N offset [%N:%N]*N",
                              i,f,z!c.w,z!(c.o+1),z!c.o)
                    $>trace
                    if notermasyet do changecolour.(p)
                    notermasyet := false
                    g.cf.boxinput('h',z!c.hl1,z!c.hl2,m.sd.yellow,m.sd.blue)
                                                 // highlight
                    z := z+m.h
                $)
            $)
        $)
        if termcount > 0 do
        $(  p!c.bestmatch := bestmatch
            p!c.bestcount := 0
            p!c.termcount := termcount
        $)
        resultis termcount
    $)
$)

/**
         g.cf.makequery(p) forms the query control table from the
         current query, giving result true if at least one proper
         index term is found, false otherwise.
**/

let g.cf.makequery(p) = valof
$(
    /* if the current query = previous query and the previous query is
       non-null and relates to this side of the disc, the formation of
       the query control vector can be bypassed */

    test COMPSTRING(p+p.oldq, p+p.q) = 0 &
         p!c.qforthisside &
         (p+p.q)%0 > 0 then $( changecolour.(p); g.cf.highlight() $) or
    $(
        $(  let termcount = extractwords.(p)
            if termcount = 0 do
            $(  g.sc.ermess("No proper words in this query")
                resultis false
            $)
            g.sc.mess("Searching for keywords")
            termcount := lookupwords.(p,termcount,m.cf.indexlevels)
            if termcount = 0 do
            $(  g.sc.clear(m.sd.message)
                g.sc.ermess("None of these words are in the index")
                resultis false
            $)
        $)
    $)
    p!c.qforthisside := true
    MOVE(p+p.q, p+p.oldq, wordsizeofstring(p+p.q))
    p!c.h := 10000
    MOVE(g.context+m.grbleast, p+c.x0, 4)
    p!c.lev := g.context!m.leveltype
//  p!c.x0 := -32767; p!c.y0 := -32767; p!c.x1 := 32767; p!c.y1 := 32767
//  p!c.lev := 0
    resultis true
$)


