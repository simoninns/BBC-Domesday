/**

16.      NATIONAL FIND
         -------------

         NF.find9 - MAIN ACTION ROUTINE
         ------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         13.5.86  1        M.F.Porter  Initial working version
         23.5.86  2        PAC         Replace 'trap' with 'trap.'
         28.5.86  3        PAC         Zero exit stack on entry
                                       Comment out "Domesday" title
         28.5.86  4        DRF         Select Chart for itemtype = 4
         19.6.86  5        MFP         "gl4hd" & bug fixes marked below
         23.6.86  6        MFP         g.context settings for -m.st.ntext
         1.7.86   7        MFP         changes as marked
         14.7.86  8        MFP         changes as marked
         15.7.86  9        NRY         Enable selection from 2nd+ titles pages
         18.7.86  10       MFP         $<debug removed
                                       clear screen as marked
         18.7.86  11       MFP         code for item name selection completed
         20.7.86  12       MFP         'u' to '(g.nf.p+p.q)' as marked
         11.9.86  13       MFP         fix as marked
         30.9.86  14       NRY         Change 'Data' to 'Maps' (types 1 & 3).
*******************************************************************************
         All mods after this point are not on the system as launched
*******************************************************************************
        12.12.86  15       SRY         Unknown item name double beep fix
        ***********************************************
          9.6.87  16       MFP         CHANGES FOR UNI
********************************************************************************
          24.7.87 17       MH          CHANGES FOR PUK
          28.7.87 18       MH          update to function selectitem() for
                                       storing of hierarchy.
           6.8.87 19       MH          changes to find screen
          10.8.87 19       MH          find0 split into find0 and find9
                                       G.nf.dy.free, G.nf.dy.init, G.nf.einit,
                                       G.nf.raction and G.nf.rinit in find9
**/

section "find9"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNFhd.h"
get "GH/glDYhd.h"
get "H/vhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/iohd.h"
get "H/nfhd.h"

/**
         See Community Find for comments on this section, which
         is essentially a stripped down version of CF.FIND0,
         CF.FIND7 and CF.FIND8.

         The code for selecting an item by using its title
         (binary chopping on the NAMES file) is commented
         elsewhere in NM.COMPARE1.
**/

manifest $(
s.unset=0; s.review=10

thirdwidth = m.sd.disw/3
$)

static $( boxtables = 0 $)

let trap.(n,val,low,high) be g.ut.trap("NF",n,true,3,val,low,high)

let printtitles.() be
$(  let w = g.nf.p!c.ws  // workspace area
    g.sc.pointer(m.sd.off)
    g.sc.clear(m.sd.display)
    g.sc.high(0,0,false,100)
    g.sc.selcol(m.sd.cyan)
    g.sc.movea(m.sd.display, m.sd.disXtex, m.sd.disYtex-m.sd.linw)
    for i = 1 to g.nf.p!c.titles do
    $(  let s = g.nf.p+p.t+(i-1)*m.item.wrec.size //28.7.87 MH
        trap.(3,s%0,0,30)
        for i = 1 to s%0 do w%(i+5) := s%i
        $(  let code = s%31
            let u = code = 1 -> "Gmap ", // changed 30.9.86 NRY
                    code = 3 -> "Amap ", // changed 30.9.86 NRY
                    code = 4 -> "Data ",  // added 30.9.86 NRY
                    code = 8 -> "Pic. ",
                    code = 9 -> "Walk ",
                    code = 10 -> "Film ", "Text "
            trap.(4,code,0,10)
            for i = 1 to 5 do w%i := u%i
        $)
        w%0 := s%0+5
        g.sc.oplist(g.nf.p!c.titlenumber+i, w)
    $)
    g.sc.pointer(m.sd.on)
$)

let g.nf.rinit() be
$(
    g.context!m.stackptr := 0
    g.vh.video(m.vh.micro.only)   // added 1.7.86
//  g.sc.clear(m.sd.message)     commented out 19/6/86
    printtitles.()
$)

let g.nf.raction() be
$(
    if g.context!m.justselected | g.context!m.itemselected do
    $( g.context!m.justselected := false
       g.context!m.itemselected := false   // addition of 19.6.86
       unless g.context!m.laststate = m.st.nfindm do
         g.sc.clear(m.sd.message)   // addition of 18.7.86
       g.nf.rinit()
    $)
    if g.key = m.kd.tab & g.screen = m.sd.display
        test g.xpoint <= thirdwidth then g.key := m.kd.fkey7 or
        test g.xpoint >= 2*thirdwidth then g.key := m.kd.fkey8 or
        g.sc.beep()
    switchon g.key into
    $(  case m.kd.noact:
            g.sc.high(g.nf.p!c.titlenumber+1,
                      g.nf.p!c.titlenumber+g.nf.p!c.titles, false, 1)
            return
        case m.kd.fkey7:
            test g.nf.p!c.last.function = m.keyword then
            $(
               if g.nf.p!c.m = 0 do $( g.sc.beep(); endcase $)
               g.nf.p!c.m := g.nf.p!c.m-m.titlespp*m.misize
               g.nf.p!c.titlenumber := g.nf.p!c.titlenumber-m.titlespp
               g.nf.extracttitles(g.nf.p)
               printtitles.(); endcase
            $)
            else
            $( 
               test turn.page.back(g.nf.p, G.nf.p+c.file.rec) then
               $(
                  g.nf.extractfiles(g.nf.p)
                  printtitles.(); endcase 
               $)
               else
               $(
                  G.sc.beep()
                  endcase 
               $)
            $)
        case m.kd.fkey8:
            test g.nf.p!c.last.function = m.keyword then
            $(
                let m = g.nf.p!c.m+m.titlespp*m.misize
                test m+m.misize >= g.nf.p!c.mend then
                $(  if g.nf.p!c.mend < m.msize do $( g.sc.beep(); endcase $)
                    g.sc.clear(m.sd.display)
                    G.nf.writerest.("Query:")
                    g.nf.runquery(g.nf.p)
                $)
                or $( g.nf.p!c.m := m; g.nf.extracttitles(g.nf.p) $)
                g.nf.p!c.titlenumber := g.nf.p!c.titlenumber+m.titlespp
               printtitles.(); endcase
             $)
            else
            $( 
               test turn.page.forward(g.nf.p, G.nf.p!c.last.rec) then
               $(
                  G.nf.p!c.file.rec := G.nf.p!c.last.rec - 1
                  g.nf.extractfiles(g.nf.p)
                  printtitles.(); endcase 
               $)
               else
               $(
                  g.sc.beep()
                  endcase 
               $)
            $)
        case m.kd.return:
            $(  let n = g.sc.high(g.nf.p!c.titlenumber+1,
                                  g.nf.p!c.titlenumber+g.nf.p!c.titles,
                                  false, 1) - g.nf.p!c.titlenumber - 1
//                              fix of 15.7.86 above
                if n < 0 endcase
                G.nf.selectitem.(g.nf.p+p.t+n*m.item.wrec.size) // fix of 15.7.86  - 4.8.87 MH
                return
            $)
    $)
$)

and turn.page.forward(p, file.rec) = VALOF    //##
$(  let c = vec 1
    let rec.len = vec 1
    let n.recs = vec 1
    let dummy = vec 1
    let one = vec 1
    let zero = vec 1
    let i = 0
    let sign = file.rec < 0 -> -1, 0

   G.ut.set32(1, 0, one)
   G.ut.set32(0, 0, zero)
   G.ut.set32(file.rec, sign, c)
   // record length in bytes
   g.ut.set32(m.item.rec.size-4,0,rec.len)  //28.7.87 MH
   // determine file length in records to set up bounds for log chopping
   g.dh.length(g.nf.p!c.names, n.recs)   // in bytes
   g.ut.div32(rec.len, n.recs, dummy)   // in records
   G.ut.mov32(n.recs, dummy)
   unless G.ut.cmp32(c, dummy) = m.lt then
     resultis false
   while i < 1 & (g.ut.cmp32(c, n.recs) = m.lt) do
   $(
      if type.included(g.dh.read.type(c)) then
        i := i + 1
      G.ut.add32(one, c)
   $)
   if i = 0  then
      resultis false
   resultis true
$)


and turn.page.back(p, file.rec) = VALOF    //##
$(  let one = vec 1
    let i = 0
    let c = vec 1
    let last.rec = vec 1
    let zero = vec 1
    let neg = vec 1
    let sign = !file.rec < 0 -> -1, 0
       
    G.ut.set32(1, 0, one)
    G.ut.set32(0, 0, zero)
    G.ut.set32(-1, -1, neg)
    G.ut.set32(!file.rec, sign, c)
    G.ut.sub32(one, c)    
    while i < m.titlespp & (g.ut.cmp32(c, neg) = m.gt) do
    $(
       if type.included(g.dh.read.type(c)) then
       $( i := i + 1
          G.ut.mov32(c, last.rec)
       $)
       G.ut.sub32(one, c)
    $)
    if i = 0  then
       resultis false
    !file.rec := !last.rec
    resultis true
$)


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


let g.nf.einit() be return

let g.nf.eaction() be
$(  test g.nf.p!c.state = s.review &
         (g.nf.p+p.oldq)%0 > 0 &        // prev. query exists
         g.nf.p!c.titlenumber ~= -1     // not a "data item" query
    then g.key := -m.st.nfindr or g.key := -m.st.nfindm
    g.redraw := false
$)

let g.nf.dy.init() be
$(
    g.nf.p := GETVEC(m.nf.datasize)
    unless g.ut.restore(g.nf.p,m.nf.datasize,m.io.nfcache) do
    $(  g.nf.p!c.state := s.unset
        g.nf.p!c.good.query := false
        (g.nf.p+p.oldq)%0 := 0
        g.nf.p!c.titlenumber := 0 // -1 means there is a previous item name
        g.nf.p!c.termcount := 0
        for i = 0 to 6 do g.nf.p!(c.include+i) := true
    $)
    g.nf.p!c.index := g.dh.open("INDEX")
    g.nf.p!c.names := g.dh.open("NAMES")
//    g.nf.p!c.names := g.dh.open("-adfs-:5.NNAMES")
    $(  let wsize = MAXVEC()
        if wsize > m.nf.max.wsize do wsize := m.nf.max.wsize
        g.nf.p!c.ws := GETVEC(wsize) // establish workspace area
        g.nf.p!c.wssize := wsize+1    // exact number of words in this area
    $)
$)

let g.nf.dy.free() be
$(
    g.dh.close(g.nf.p!c.index)
    g.dh.close(g.nf.p!c.names)
    FREEVEC(g.nf.p!c.ws)
    g.ut.cache(g.nf.p,m.nf.datasize,m.io.nfcache)
    FREEVEC(g.nf.p)
$)
.

