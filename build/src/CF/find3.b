//  AES SOURCE  4.87

/**
         CF.FIND3 - RUNS THE FREE TEXT QUERY
         -----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2             "      New 'get' directives
         20.5.86  3             "      "No items found" message
         3.6.86   4             "      trap.() for trap(), backmove.()
                                       for backmove()
         19.6.86  5        NY          Add gl5hd
         1.7.86   6        MFP         Add g.sc.pointer in g.cf.runquery
                                       "Finding titles, please wait"
                                       'clear' before 'ermess' in 'runquery'
         14.7.86  7        MFP         bug fix as marked
         18.7.86  8        MFP         $<debug removed
         20.7.86  9        MFP         'g.cf.p!c.keepmess := true' added
                                       as marked
         23.7.86  10       NRY         Code to use 'short' NAMES recs. removed
         28.7.86  11       MFP         'd%0' changed to 'd%3' as marked
         28.7.86  12       MFP         "No items found in this area"
         28.7.86  13       MFP         MOVE(...) introduced as marked
         31.7.86  14       MFP         avoid grid-ref test at lev.0
                                       (as marked)
         25.9.86  15       MFP         ":" after "These items .. found"
        15.10.86  16       PAC         Speculative change to extracttitles
        16.10.86  17       PAC         Confirm change, fix states bug
        21.10.86  18       PAC         Reverse change, leave in bugfix
        **************************************************
         8.6.87   19       MFP         CHANGES FOR UNI
**/

section "find3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/sdhd.h"
get "H/cfhd.h"

static $( p = 0; worstmatch = 0; bestmatch = 0; mask = 0 $)

/**
         To process the query, we have a batch of terms, t1, t2
         ... tn and for each term t, a list D1, D2 ... of
         'D-values' which are the items indexed by t. To get the
         (next) 100 best matches, we have to do an n-way merge
         down this list of D-values.
**/

let trap.(n,val,low,high) be g.ut.trap("CF",30+n,true,3,val,low,high)

/**
         backmove.(p,q,n) moves n words down store from address p
         to q. setd.(v,n) sets v to be a double length integer
         equal to n
**/

let backmove.(p,q,n) be for i = n-1 to 0 by -1 do q!i := p!i

/**
         read.(v,q,n,e) reads n bytes from the index file to
         store address q starting at offset v down the file (v a
         vector holding a double word quantity. If the read fails
         a fatal trap is forced.
**/

let read.(v,q,n,errornumber) be unless g.dh.read(p!c.index,v,q,n) = n do
$(  trap.(errornumber,2,1,0)  // force fatal error
    finish
$)

/**
         makebuffers.(b,bsize) divides the vector at b (of size
         bsize) into a set of input buffers, one for each term.
         The terms are taken in increasing order of frequency.
         Suppose that when T terms are left requiring buffers the
         space left is H. The next term requires W words (say) to
         buffer all its D-values. If W <= H/T, W is allocated,
         otherwise H/T. This provides a good breakdown of the
         available space.
**/

let makebuffers.(b, bsize) = valof
$(  let z = p+p.z                            // query control area
    let termcount = p!c.termcount            // number of terms
    let zlim = z+(termcount-1)*m.h           // limit for z
    for q = z to zlim by m.h do q!c.p := 0   // mark as having no buffer
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
            r!c.p := b+bsize-sp        // pointer to front of buffer space
            r!c.sp := sp               // size of buffer space
            bsize := bsize-sp          // new value of remaining buffer area
            $<trace g.sc.ermess("%N words for term %N buffer",sp,(r-z)/m.h)
            $>trace
        $)
        if termcount = 1 do p!c.maxterm := r
                        // last allocation is for max. term
        termcount := termcount-1
    $)
    resultis b
$)

/**
         readitem.(q) moves the pointer for the buffer of 'q' to
         the next D-value in the list.
**/

and readitem.(q) be
$(  let c,i,sp = q!c.c, q!c.i, q!c.sp

    /* c is the address of the current D-value in the buffer.
       i is the number of the D-value (counting D1, D2 ... ).
       sp is the space in the current buffer.
       q!c.p is the address of the front of the buffer
    */
    // the progress of i in the max. term is used to decide whether
    // to update the %-box:

    if q = p!c.maxterm & (i & mask) = 0 do g.cf.writepc(MULDIV(i,100,q!c.f))
    if i = q!c.f do
    $(  q!c.c := p+c.max  // end of stream indication
        return
    $)
    c := c+m.iisize       // move c to next D-value
    //  trap.(0,c-q!c.p,m.iisize,sp)  (comment out for speed)
    if c = q!c.p+sp do    // test to see if at end of buffer
    $(  let n = q!c.f-i       // items left to be read
        sp := sp/m.iisize     // items readable in one gulp
        if n > sp do n := sp  // items to read this time round
        $(  let v = vec 1
            let w = vec 1
            g.ut.set32(i,0,v)
            g.ut.set32(m.biisize,0,w)
            g.ut.mul32(w,v)
            g.ut.add32(q+c.o,v)
            read.(v, q!c.p, n*m.biisize, 1)// read the next batch of D-values
            c := q!c.p        // set c back to the beginning of buffer
        $)
    $)
    q!c.c := c        // save new c
    q!c.i := i+1      // save new i
$)

and setmaxval.(q) be g.ut.set32(0,true,q)

/**
         cmp.(p,q) is the comparison routine for the two D-values
         at p and q
**/

and cmp.(p,q) = p%2 ~= q%2 -> p%2-q%2,
                p%1 ~= q%1 -> p%1-q%1, p%0-q%0

/**
         addtobestmatches.(d,w) adds the D-value d, weight w, to
         the vector of 100 best matches (the m-vec). This code
         will not be entered if the m-vec is full and w is <= the
         last weight in the m-vec.
**/

and addtobestmatches.(d,w) be
$(
    /* if the item in p!c.h is <= [w,d] return */
    if p!c.h < w | p!c.h = w & cmp.(p+c.h+1,d) > 0 return
    /* if d is outside the current map background return */
    $(  let lev, x, y = d%3, g.ut.unpack16(d,4), g.ut.unpack16(d,6)
                                       // fix of 28.7.86
        if p!c.lev > 0 do              // this line added 31.7.86
        $(  if lev < p!c.lev return
            unless p!c.x0 <= x < p!c.x1 &
                   p!c.y0 <= y < p!c.y1 return
        $)
    $)
    /* in the next part of the code, i is used to mark the
       offset down m (the m-vec) at which d is to be added in. The
       'distance' pointer is a refinement (unnecessary perhaps)
       used to point across items in the m-vec with the same weight.
    */
    $(  let m, mend = p+p.m, p!c.mend
        if mend = m.msize do mend := mend-m.misize  // if at end move back 1
        $(  let i = mend
            let distance = 0
            while i > 0 do
            $(  let diff = m!(i-m.misize)-w         // compares weight in
                                                    // m-vec with w
                if diff < 0 do $( i := i-m!(i-1); loop $)
                              // we've now found the point for adding d in
                if diff = 0 do distance := m!(i-1)
                break
            $)
            backmove.(m+i, m+i+m.misize, mend-i)   // make a hole
            m!i := w; g.ut.mov32(d,m+i+1)          // add w,d into hole
            m!(i+m.misize-1) := distance+m.misize  // readjust 'distance'
        $)
        mend := mend+m.misize                      // readjust mend

        /* if the m-vec is full pick up 'worstmatch' from the last weight
           in the m-vec : */

        if mend = m.msize do worstmatch := m!(m.msize-m.misize)
        p!c.mend := mend     // store mend
        if w = bestmatch do  // test to see if w = best possible value
        $(  p!c.bestcount := p!c.bestcount+1 // increase perfect matches count
            g.cf.writepm(p!c.bestcount)      // write it to the m-box
        $)
    $)
$)

/**
         processquery.() initialises the term buffers and then
         drives the n-way merge of the n lists of D-values.
**/

and processquery.() be
$(  let z = p+p.z                     // query control vec
    let termcount = p!c.termcount     // number of terms
    let zlim = z+(termcount-1)*m.h    // end of query control vec
    let w = 0                         // to hold sum of weights
    let prev.D = vec m.iisize-1       // previous D in the merge
    setmaxval.(prev.D)
    worstmatch := 0
    bestmatch := p!c.bestmatch        // max. possible val. of w (a
                                      // perfect match)
    /* 'mask' has the form '00...0011...11' in binary, and is set so
       that as i increments 1,2,3 ... maxfreq, (i & mask) will be
       zero about 100 times. This is used to determine when to update
       the %-box */

    $(  let maxfreq = p!c.maxterm!c.f
        mask := maxfreq / 100
        $(  let n = 1
            while n < mask do $( mask := mask | n; n := n << 1 $)
        $)
    $)
    /* force initialisation of the term buffers: */
    for q = z to zlim by m.h do
    $(  q!c.i := 0
        q!c.c := q!c.p+q!c.sp-m.iisize  // position at end of buffer
        readitem.(q)                 // read a D-value, thereby filling buffer
                    // collect the smallest of these in prev.D

        if cmp.(q!c.c,prev.D) < 0 do MOVE(q!c.c,prev.D,m.iisize)
    $)
    g.cf.writepm(0)             // initialise m-box
    setmaxval.(p+c.max)         // 'infinite' D-val - used as terminator
    p!c.bestcount := 0          // perfect match count to zero
    $(  let q = z               // q is pointer along the query control vec
        let qc = ?              // qc is used to hold q!c.c

        for p = q+m.h to zlim by m.h if cmp.(p!c.c,q!c.c) < 0 do q := p
        /* q now gives the smallest D-value in z */
        qc := q!c.c
        $(  let qweight = q!c.w                    // pick up the weight
            test cmp.(qc,prev.D) = 0
            then w := w+qweight or             // same as prev.D, so increase w
            $(  if w > worstmatch do           // add in if an impovement on
                                               // the worst match so far
                $(  addtobestmatches.(prev.D,w)

                    /* the next line causes the process to be discontinued
                       if it is found that the m-vec is full of best
                       matches */

                    if worstmatch = bestmatch return
                $)
                w := qweight
            $)
        $)
        if qc = p+c.max return
        /* bug fix: 'prev.D!0 := qc!0; prev.D!1 := qc!1' removed, and replaced
           by the following line (28.7.86) */
        MOVE(qc, prev.D, m.iisize)
        $<trace2 WRITEF("%N/%X4/%X4 ",(q-z)/m.h,prev.D!1,prev.D!0) $>trace2
        readitem.(q)
    $) repeat
$)

/**
         g.cf.extracttitles(..) puts into the t-vec (titles) the
         next pageful of titles derived from offsets into the
         NAMES file from the m-vec.
**/

and g.cf.extracttitles(p) be
$(  let mbase, t = p+p.m+p!c.m, p+p.t // mbase = position in m-vec of next
                                     // batch of titles; t = t-vec
    let mtop = ?                    // to hold end point corresponding to mbase
    let items = m.titlespp+1
    let a = (p!c.mend-p!c.m)/m.misize

    g.sc.mess("Finding titles, please wait") // this line original, rest added

    if items > a do items := a     // items is the number of titles to extract
    mtop := mbase+(items-1)*m.misize
    for q = mbase to mtop by m.misize do !q := -!q
                                  // mark as uncollected
    for j = 1 to items do
    $(  let q = mbase
        while !q > 0 do q := q+m.misize
        trap.(2,q,mbase,mtop)
        for r = q+m.misize to mtop by m.misize
                    if !r < 0 & cmp.(r+1,q+1) < 0 do q := r
        /* titles are extracted from NAMES in order along the file, which
           is different from their order in m-vec */
        $(  let v = vec 1
            let w = vec 1
            let o = (q-mbase)/m.misize*m.tsize
            g.ut.movebytes(q+1,0,v,0,4); v%3 := 0
            g.ut.unpack32(v,0,w)
            g.ut.set32(m.tbsize,0,v); g.ut.mul32(v,w) // unfixed 23.7.86
            unless g.dh.read(p!c.names,w,t+o,m.tbsize) = m.tbsize do
            $(  trap.(3,2,1,0)
                finish  $)
        $)
        !q := -!q  // mark as collected
    $)
    p!c.titles := items
    g.sc.clear(m.sd.message)
$)

/**
         g.cf.runquery(p0) runs the query forming the 100 best
         matches in m-vec. p0 is just g.cf.p
**/

let g.cf.runquery(p0) = valof
$(  g.sc.mess("Processing the query, please wait")
    p := p0
    makebuffers.(p!c.ws, p!c.wssize)
    p!c.mend := 0
    g.sc.pointer(m.sd.off)  // added 1.7.86
    processquery.()
    g.sc.pointer(m.sd.on)   // added 1.7.86
    if p!c.mend = 0 do
    $(  g.sc.clear(m.sd.message)
        g.sc.ermess("No items found in this area") //last 3 words added 28.7.86
        resultis false
    $)
    p!c.m := 0
    $<trace g.sc.ermess("p!c.mend = %N",p!c.mend) $>trace
    $<trace2 for q = p+p.m to p+p.m+p!c.mend-m.misize by m.misize do
           WRITEF("[%N]%X4/%X4 ",q!0,q!2,q!1)
    $>trace2
    g.cf.extracttitles(p)
    g.sc.mess(/* p!c.termcount = 0 -> "No relevant items found",
                 - commented out 20.7.86  */
              "These items have been found:")
    // g.cf.p!c.keepmess := true  /* keep this message in the review state -
    // REMOVED 16.10.86 PAC          added 20.7.86 */
    MOVE(p+p.m+p!c.mend-m.misize, p+c.h, m.misize) // save worst item
    resultis true
$)

