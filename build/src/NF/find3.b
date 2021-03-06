/**
         NF.FIND3 - RUNS THE FREE TEXT QUERY
         -----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         13.5.86  1        M.F.Porter  Initial working version
         23.5.86  2        PAC         Fix TRAP bug
         19.6.86  3        MFP         "gl4hd", g.sc.pointer in
                                          g.nf.runquery
         22.6.86  4        MFP         'backmove.' for 'backmove'
         1.7.86   5        MFP         "finding titles, please wait"
         14.7.86  6        MFP         bug fix as marked
         18.7.86  7        MFP         $<debug removed
         26.9.86  8        MFP         "These items .. found:"
         *******************************************
         9.6.87   9        MFP         CHANGES FOR UNI
         22.6.87  10       DNH         fix process.. bug
         *******************************************
         24.7.87  11        MH         CHANGES FOR PUK
         04.8.87  12        MH         update to G.nf.extracttitle
         16.12.87 13        MH         G.dh.read.names.rec added
         18.12.87 14        MH         G.nf.extractfiles added 17.12.87
**/


section "find3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNFhd.h"
get "H/sdhd.h"
get "H/nfhd.h"

/**
         See CF.FIND3 for comments
**/

static $( p = 0; worstmatch = 0; bestmatch = 0; mask = 0 $)


let trap.(n,val,low,high) be g.ut.trap("NF",30+n,true,3,val,low,high)

let backmove.(p,q,n) be for i = n-1 to 0 by -1 do q!i := p!i

let read.(v,q,n,errornumber) be unless g.dh.read(p!c.index,v,q,n) = n do
$(  trap.(errornumber,2,1,0) // force fatal error
    finish
$)

let makebuffers.(b, bsize) = valof
$(  let z = p+p.z
    let termcount = p!c.termcount
    let zlim = z+(termcount-1)*m.h
    for q = z to zlim by m.h do q!c.p := 0
    until termcount = 0 do
    $(  let r = 0
        /* set r to the term slot of smallest frequency among the terms with
           as yet unallocated buffers. */
        for q = z to zlim by m.h if q!c.p = 0 & (r = 0 | r!c.f > q!c.f) do
           r := q
        $(  let sp1 = r!c.f // total slots for current term
            let sp2 = bsize/(termcount*m.iisize)
                              // equitable division of remaining space
            let sp = sp1 < sp2 -> sp1, sp2 // smaller of these
            sp := sp*m.iisize
            r!c.p := b+bsize-sp
            r!c.sp := sp
            bsize := bsize-sp
            $<trace g.sc.ermess("%N words for term %N buffer",sp,(r-z)/m.h)
            $>trace
        $)
        if termcount = 1 do p!c.maxterm := r
        termcount := termcount-1
    $)
    resultis b
$)

and readitem.(q) be
$(  let c,i,sp = q!c.c, q!c.i, q!c.sp
    if q = p!c.maxterm & (i & mask) = 0 do g.nf.writepc(MULDIV(i,100,q!c.f))
    if i = q!c.f do
    $(  q!c.c := p+c.max  // end of stream indication
        return
    $)
    c := c+m.iisize
    //  trap.(0,c-q!c.p,m.iisize,sp)  (comment out for speed)
    if c = q!c.p+sp do
    $(  let n = q!c.f-i       // items left to be read
        sp := sp/m.iisize     // items readable in one gulp
        if n > sp do n := sp  // items to read this time round
        $(  let v = vec 1
            let w = vec 1
            g.ut.set32(i,0,v)
            g.ut.set32(m.biisize,0,w)
            g.ut.mul32(w,v)
            g.ut.add32(q+c.o,v)
            read.(v, q!c.p, n*m.biisize, 1)
            c := q!c.p
        $)
    $)
    q!c.c := c
    q!c.i := i+1
$)
and read.enabled.item(q) be
   readitem.(q) repeatuntil q!c.c = p + c.max | type.included(q!c.c%3)

and type.included(type) = valof
$(
   switchon type into   
   $(
   case 1: resultis G.nf.p!(c.include+5)  //gmap
   case 3: resultis G.nf.p!(c.include+6)  //amap
   case 4: resultis G.nf.p!(c.include+4)  //data
   case 8: resultis G.nf.p!c.include      //picture
   case 6:
   case 7: resultis G.nf.p!(c.include+1)  //text
   case 9: resultis G.nf.p!(c.include+2)  //walk
   case 10:resultis G.nf.p!(c.include+3)  //film
   default: resultis false
   $)
$)

and setmaxval.(q) be g.ut.set32(0,true,q)  // fill with 1's

and cmp.(p,q) = p%2 ~= q%2 -> p%2-q%2,
                p%1 ~= q%1 -> p%1-q%1, p%0-q%0

and addtobestmatches.(d,w) be
$(
    /* if the item in p!c.h is <= [w,d] return */
    if p!c.h < w | p!c.h = w & cmp.(p+c.h+1,d) > 0 return
    $(  let m, mend = p+p.m, p!c.mend
        if mend = m.msize do mend := mend-m.misize
        $(  let i = mend
            let distance = 0
            while i > 0 do
            $(  let diff = m!(i-m.misize)-w
                if diff < 0 do $( i := i-m!(i-1); loop $)
                if diff = 0 do distance := m!(i-1)
                break
            $)
            backmove.(m+i, m+i+m.misize, mend-i)
            m!i := w; g.ut.mov32(d, m+i+1)
            m!(i+m.misize-1) := distance+m.misize
        $)
        mend := mend+m.misize
        if mend = m.msize do worstmatch := m!(m.msize-m.misize)
        p!c.mend := mend
        if w = bestmatch do
        $(  p!c.bestcount := p!c.bestcount+1
            g.nf.writepm(p!c.bestcount)
        $)
    $)
$)

and processquery.() be
$(  let z = p+p.z
    let termcount = p!c.termcount
    let zlim = z+(termcount-1)*m.h
    let w = 0
    let prev.D = vec m.iisize-1
    setmaxval.(prev.D)
    worstmatch := 0
    bestmatch := p!c.bestmatch
    $(  let maxfreq = p!c.maxterm!c.f
        mask := maxfreq / 100
        $(  let n = 1
            while n < mask do $( mask := mask | n; n := n << 1 $)
        $)
    $)
    /* force initialisation: */
    for q = z to zlim by m.h do
    $(  q!c.i := 0
        q!c.c := q!c.p+q!c.sp-m.iisize
        read.enabled.item(q)
        if cmp.(q!c.c,prev.D) < 0 do MOVE(q!c.c,prev.D,m.iisize)
    $)
    g.nf.writepm(0)
    setmaxval.(p+c.max)
    p!c.bestcount := 0
    $(  let q = z
        let qc = ?
        for p = q+m.h to zlim by m.h if cmp.(p!c.c,q!c.c) < 0 do q := p
        /* q now gives the smallest D-value in z */
        qc := q!c.c
        $(  let qweight = q!c.w
            test cmp.(qc,prev.D) = 0
            then w := w+qweight or
            $(  if w > worstmatch do
                $(  addtobestmatches.(prev.D,w)
                    if worstmatch = bestmatch return
                $)
                w := qweight
            $)
        $)
        if qc = p+c.max RETURN
        MOVE(qc, prev.D, m.iisize)
        $<trace2 WRITEF("%N/%X4/%X4 ",(q-z)/m.h,prev.D!1,prev.D!0) $>trace2
        read.enabled.item(q)
    $) repeat
$)

and g.nf.extracttitles(p) be
$(  let mbase, t = p+p.m+p!c.m, p+p.t
    let mtop = ?
    let items = m.titlespp+1
    let a = (p!c.mend-p!c.m)/m.misize
    g.sc.mess("Finding titles, please wait")
    if items > a do items := a
    mtop := mbase+(items-1)*m.misize
    for q = mbase to mtop by m.misize do !q := -!q
                                  // mark as uncollected
    for j = 1 to items do
    $(  let q = mbase
        while !q > 0 do q := q+m.misize
        trap.(2,q,mbase,mtop)
        for r = q+m.misize to mtop by m.misize
                    if !r < 0 & cmp.(r+1,q+1) < 0 do q := r
        $(  let v = vec 1
            let w = vec 1
            let o = (q-mbase)/m.misize*m.item.wrec.size  // 04.8.87 MH
            g.ut.movebytes(q+1,0,v,0,4); v%3 := 0
            g.ut.unpack32(v,0,w)
            unless g.dh.read.names.rec(p!c.names,w,t+o,
                           m.item.rec.size) = m.item.rec.size do // 16.12.87 MH 
            $(  trap.(3,2,1,0)
                finish  
            $)
        $)
        !q := -!q  // mark as collected
    $)
    p!c.titles := items
    g.sc.clear(m.sd.message)
$)

let g.nf.runquery(p0) = valof
$(  g.sc.mess("Processing the query, please wait")
    p := p0
    makebuffers.(p!c.ws, p!c.wssize)
    p!c.mend := 0
    g.sc.pointer(m.sd.off)  // added 19.6.86
    if p!c.termcount > 0 do
    $(
        p!c.mend := 0
        processquery.()
        if p!c.mend = 0 then
        $(
            G.sc.clear(m.sd.message)
            G.sc.ermess("No relevant items found")
            resultis false
         $)
    $)
    g.sc.pointer(m.sd.on)   // added 19.6.86
    p!c.m := 0
    $<trace g.sc.ermess("p!c.mend = %N",p!c.mend) $>trace
    $<trace2 for q = p+p.m to p+p.m+p!c.mend-m.misize by m.misize do
           WRITEF("[%N]%X4/%X4 ",q!0,q!2,q!1)
    $>trace2
    g.nf.extracttitles(p)
    g.sc.mess(p!c.termcount = 0 -> "No relevant items found",
                                   "These items have been found:")
    MOVE(p+p.m+p!c.mend-m.misize, p+c.h, m.misize) // save worst item
    resultis true
$)


/**
        G.nf.extractfiles(p)
        --------------------
   This routine gets the next page of titles to display 
**/

and g.nf.extractfiles(p) be
$(  let t = p+p.t
    let items = 0
    let c = vec 1
    let rec.len = vec 1
    let n.recs = vec 1
    let dummy = vec 1
    let dummy1 = vec 1
    let one = vec 1
    let zero = vec 1
    let neg = vec 1
    let sign = p!c.file.rec < 0 -> -1, 0

   G.ut.set32(1, 0, one)
   G.ut.set32(0, 0, zero)
   G.ut.set32(-1, -1, neg)
   G.ut.set32(p!c.file.rec, sign, c)
   // record length in bytes
   g.ut.set32(m.item.rec.size-4,0,rec.len)  //28.7.87 MH
   // determine file length in records to set up bounds for log chopping
   g.dh.length(g.nf.p!c.names, n.recs)   // in bytes
   g.ut.div32(rec.len, n.recs, dummy)   // in records
   if G.ut.cmp32(c, zero) = m.lt 
      G.ut.mov32(zero, c)
   G.ut.mov32(n.recs, dummy)
   G.ut.sub32(one, dummy)
   unless G.ut.cmp32(c, dummy) = m.lt then
     G.ut.mov32(dummy, c)

    g.sc.mess("Finding titles, please wait")
    while items < m.titlespp+1 & (g.ut.cmp32(c, n.recs) = m.lt) do
    $(  if type.included(g.dh.read.type(c)) then
        $( unless g.dh.read.names.rec(p!c.names,c,t+(items*m.item.wrec.size),
                           m.item.rec.size) = m.item.rec.size do // 16.12.87 MH 
           $(  trap.(3,2,1,0)
               finish  
           $)
          items := items + 1
          if items = 1 p!c.file.rec := !c
        $)
        G.ut.add32(one, c)
    $)
    p!c.last.rec := !c
    if g.ut.cmp32(c, n.recs) = m.eq g.ut.sub32(one, c)
    if items < m.titlespp+1 then
    $( let i = 0
       let c1 = vec 1
       let last.rec = vec 1
       
       G.ut.mov32(c, c1)
       while i < m.titlespp+1 & (g.ut.cmp32(c1, neg) = m.gt) do
       $(
          if type.included(g.dh.read.type(c1)) then
          $( i := i + 1
             G.ut.mov32(c1, last.rec)
          $)
          G.ut.sub32(one, c1)
       $)
       G.ut.mov32(last.rec, c)
       p!c.file.rec := !c   
       items := 0
       while items < m.titlespp+1 & (g.ut.cmp32(c, n.recs) = m.lt) do
       $(  if type.included(g.dh.read.type(c)) then
           $( unless g.dh.read.names.rec(p!c.names,c,t+(items*m.item.wrec.size),
                           m.item.rec.size) = m.item.rec.size do // 16.12.87 MH 
              $(  trap.(3,2,1,0)
                  finish  
              $)
             items := items + 1
             if items = 1 p!c.file.rec := !c
           $)
           G.ut.add32(one, c)
       $)
    $)   
    p!c.titles := items
    g.sc.clear(m.sd.message)
$)
.
