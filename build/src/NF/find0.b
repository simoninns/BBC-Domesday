/**

16.      NATIONAL FIND
         -------------

         NF.FIND0 - MAIN ACTION ROUTINE
         ------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
        9.06.87    16      MFP         CHANGES FOR UNI
********************************************************************************
       24.07.87    17      MH          CHANGES FOR PUK
       28.07.87    18      MH          update to function selectitem() for
                                       storing of hierarchy.
        6.08.87    19      MH          changes to find screen
       10.08.87    20      MH          find0 split into find0 and find9.
                                       G.nf.dy.init, G.nf.dy.free, G.nf.einit,
                                       G.nf.raction and G.nf.rinit in find9
       18.08.87    21      SRY         DataMerge additions
       19.08.87    22      MH          Changes for virtual keybaord.
       16.12.87    23      MH          G.dh.read.names.rec added
       17.12.87    24      PAC         Tidy up list storage
**/

section "find0"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNFhd.h"
get "H/vhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/nfhd.h"

/**
         See Community Find for comments on this section, which
         is essentially a stripped down version of CF.FIND0,
         CF.FIND7 and CF.FIND8.

         The code for selecting an item by using its title
         (binary chopping on the NAMES file) is commented
         elsewhere in NM.COMPARE1.
**/

manifest
$( s.unset=0
// s.inq=9
   s.review=10
   s.atbox1=30
   thirdwidth = m.sd.disw/3
$)

static $( boxtables = 0 $)

let trap.(n,val,low,high) be g.ut.trap("NF",n,true,3,val,low,high)

let setboxtables.() be
    boxtables := table
0, m.sd.disYtex-3*m.sd.linw, 40, 3, m.sd.blue, m.sd.cyan,
0, m.sd.disYtex-13*m.sd.linw,  6, 1, m.sd.blue, m.sd.cyan,
366, m.sd.disYtex-13*m.sd.linw,  6, 1, m.sd.blue, m.sd.cyan,
721, m.sd.disYtex-13*m.sd.linw, 6, 1, m.sd.blue, m.sd.cyan,
1087, m.sd.disYtex-13*m.sd.linw, 6, 1, m.sd.blue, m.sd.cyan,
0, m.sd.disYtex-15*m.sd.linw, 6, 1, m.sd.blue, m.sd.cyan,
366, m.sd.disYtex-15*m.sd.linw, 6, 1, m.sd.blue, m.sd.cyan,
721, m.sd.disYtex-15*m.sd.linw, 6, 1, m.sd.blue, m.sd.cyan,
0,m.sd.disYtex-8*m.sd.linw, 40, 3, m.sd.cyan, m.sd.blue

let ws.(line,s) be
$(  g.sc.movea(m.sd.display, m.sd.disXtex,
                             m.sd.disYtex-(line-1)*m.sd.linw)
    g.sc.odrop(s)
$)

let g.nf.highlight() be
    for z = g.nf.p+p.z to g.nf.p+p.z+(g.nf.p!c.termcount-1)*m.h by m.h do
        g.nf.boxinput('h', z!c.hl1, z!c.hl2, m.sd.yellow, m.sd.blue)

let writetext(b, c, s) be
$(
   G.sc.movea(m.sd.display, !b+m.sd.charwidth, b!1-8)
   G.sc.selcol(c)
   G.sc.oprop(s)
$)

let list.(n) = valof switchon n into
$( case 0 : resultis "Pic."
   case 1 : resultis "Text"
   case 2 : resultis "Walk"
   case 3 : resultis "Film"
   case 4 : resultis "Data"
   case 5 : resultis "Gmap"
   case 6 : resultis "Amap"
   default: resultis "$%!@"
$)

let init.omit() be
$(
//    G.sc.pointer(m.sd.off)

   for n = 0 to 6 do
   $( let b = boxtables+(6*(n+1))
      test g.nf.p!(c.include + n) then
      $( g.nf.boxinput('f',b,m.sd.blue)
         writetext(b, m.sd.yellow, list.(n))
      $)
      else
      $( g.nf.boxinput('f',b,m.sd.blue)
//         writetext(b, m.sd.blue, list.(n))
         
         G.sc.movea(m.sd.display, !b+m.sd.charwidth, b!1-8)
         G.sc.ecf(6)
         G.sc.oprop(list.(n))
      $)
   $)
//    G.sc.pointer(m.sd.on) 
$)

let G.nf.writerest.(s) be
$(  ws.(8, s)
    setboxtables.()
    $(
        let b = boxtables+48
        g.nf.boxinput('f',b,m.sd.blue)
        g.nf.boxinput('i',b,g.nf.p+p.q)
        g.nf.boxinput('s',g.nf.p+p.oldq); g.nf.boxinput('-')
        g.nf.highlight()
    $)
    init.omit()
    ws.(13,"Select group types not required:")
    ws.(18,"Percentage through search:")
    ws.(20,"'Perfect matches' found:")
$)

let omit(n) be
$(
   n := n - s.ing - 1
   if g.key = m.kd.action then
   $( let b = boxtables+(6*(n+1))
      test g.nf.p!(c.include + n) then
      $( let count = 0
         for i = 0 to 6 do
            if g.nf.p!(c.include + i) count := count + 1
         test count <= 1 then
            G.sc.ermess("Cannot omit all types")
         else
         $( g.nf.boxinput('f',b,m.sd.blue) 
//            writetext(b, m.sd.blue, list.(n))
            g.nf.p!(c.include + n) := false

         G.sc.movea(m.sd.display, !b+m.sd.charwidth, b!1-8)
         G.sc.ecf(6)
         G.sc.oprop(list.(n))
         $)
      $)
      else
      $( g.nf.boxinput('f',b,m.sd.blue)
         writetext(b, m.sd.yellow, list.(n))
         g.nf.p!(c.include + n) := true
      $)
      G.key := m.kd.noact
   $)
$)


let g.nf.minit() be
$(
    g.context!m.stackptr := 0
    g.sc.pointer(m.sd.off)
    g.vh.video(m.vh.micro.only)   // change of 1.7.86
    g.sc.clear(m.sd.message)
    g.sc.clear(m.sd.display)
    setboxtables.()

//  ws.(2,"               Domesday National Disc")
    ws.(1,"            BRITISH LIFE IN THE 1980s")  // reinstated 1.7.86
    ws.(3,"What do you want to know about?")
    g.nf.boxinput('f', boxtables, m.sd.blue)
    G.nf.writerest.("Previous Query:")
    if g.nf.p!c.state = s.unset | (g.nf.p+p.oldq)%0 = 0 |
         g.nf.p!c.good.query = false do
       g.sc.menu(table m.sd.act, m.sd.act, m.sd.act,
                       m.sd.act, m.sd.act, m.sd.wBlank)  // lose one !
    g.nf.p!c.state := s.outsidebox
    g.nf.boxinput('i', boxtables, g.nf.p+p.q)
    if g.screen = m.sd.menu do g.sc.moveptr(g.xpoint,g.sc.dtob(m.sd.display,4))
    g.sc.pointer(m.sd.on)
$)

let boxatcursor() = g.screen ~= m.sd.display -> -1, VALOF
$( setboxtables.()
   for i = 0 to 47  by 6 do
   $(  let d = boxtables!(i+1) - G.ypoint
       if 0 <= d <= boxtables!(i+3)*m.sd.linw + 8 & // '8' determined by
                                                    // inspection
         (boxtables!(i+2)*m.sd.charwidth) + boxtables!i >= G.xpoint >=
                  boxtables!i resultis i
   $)
   resultis -1
$)

let addch.() be if g.nf.boxinput('c',g.key) = 0 then
                   g.nf.p!c.state := G.menuon -> s.atbox, s.atbox1

let itemname.(s) = valof
$(  let len = s%0
    let j = 1
    if s%len ~= '"' resultis false // doesn't end with "
    while j < len & s%j = ' ' do j := j+1
    if j = len | s%j ~= '"' resultis false // doesn't begin with "
    resultis true
$)

let copyname.(s,u) be
$(  let len = s%0-1  let i = 1
    while s%i = ' ' do i := i+1
    i := i+1
    while s%i = ' ' do i := i+1
    while len > i & s%len = ' ' do len := len-1
    for j = 1 to len-i+1 do u%j := s%(i+j-1)
    u%0 := len-i+1  // may have zero length
$)

and G.nf.selectitem.(q) be
$(  let type = q%31
    g.ut.movebytes(q,0,g.context+m.itemrecord,0,m.item.rec.size-8) // MH 28.7.87
    g.ut.unpack32(q,32,g.context+m.itemaddress)
    g.ut.unpack32(q,36,g.context+m.itemh.level) //unpack hierachy MH 28.7.87

    g.key := -(type!table 0, m.st.datmap, m.st.datmap, m.st.datmap,
                             m.st.chart, 0, m.st.ntext, m.st.ntext,
                             m.st.nphoto, m.st.walk, m.st.film) 
    g.context!m.itemselected := true // 19.6.86
    if g.key = -m.st.nphoto do g.context!m.picture.no := 1
    if g.key = -m.st.ntext do    // addition of 23.6.86
    $( g.ut.set32(-1,-1,g.context+m.itemadd2)
       g.ut.set32(-1,-1,g.context+m.itemadd3)
    $)
$)

and searchforname.(string, item.record.ptr) = valof
$(
   let match, result = false, ?
   and length = vec 1
   and rec.len = vec 1
   and lwb = vec 1
   and upb = vec 1
   and middle = vec 1
   and byte.offset = vec 1
   and dummy = vec 1
   and one = vec 1
   and two = vec 1

   // record length in bytes
   g.ut.set32(m.item.rec.size-4,0,rec.len)  //28.7.87 MH
// $<debug
//   g.ut.set32(36,0,rec.len)
// $>debug

   // determine file length in records to set up bounds for log chopping
   g.dh.length(g.nf.p!c.names, length)   // in bytes
   g.ut.div32(rec.len, length, dummy)   // in records

   g.ut.set32(1,0,one); g.ut.set32(2,0,two)
   g.ut.sub32(one,length)   // recs are from 0 to n-1
   g.ut.set32(0,0,lwb); g.ut.mov32(length,upb)

   while (NOT match) & g.ut.cmp32(lwb, upb) <= 0 do

      $(
         // find mid-point of current bounds
         g.ut.mov32(lwb,middle)
         g.ut.add32(upb, middle)
         g.ut.div32(two, middle, dummy) // in records

         g.dh.read.names.rec (g.nf.p!c.names, middle, item.record.ptr,
                      m.item.rec.size)  //MH 16.12.87
// $<debug
//         g.dh.read (g.nf.p!c.names, byte.offset, item.record.ptr, 36)
// $>debug

         result := COMPSTRING (string, item.record.ptr)

         match := (result = 0)

         unless match do

            test result < 0
            then $( g.ut.sub32(one, middle); g.ut.mov32(middle,upb) $)
            else $( g.ut.add32(one, middle); g.ut.mov32(middle,lwb) $)
      $)
test G.ut.cmp32(lwb, upb) = m.lt then
   g.nf.p!c.file.rec := G.ut.unpack16.signed(lwb, 0)
else
   g.nf.p!c.file.rec := G.ut.unpack16.signed(upb, 0)
//   g.nf.p!c.file.rec := !middle
   resultis match
$)

let g.nf.maction() be
$(  let query = g.nf.p + p.q
    let oldquery = g.nf.p + p.oldq
    if g.context!m.justselected | g.context!m.itemselected do
    $(
       g.nf.minit()
       g.context!m.justselected := false
       g.context!m.itemselected := false
    $)

       if g.key = m.kd.fkey6
       test g.nf.p!c.titlenumber = -1
       then $( G.nf.selectitem.(g.nf.p+p.t)
               return
            $)
       else if g.nf.p!c.titlenumber = -2 // user file
            $(
               userfile(oldquery)
               return
            $)

    switchon g.nf.p!c.state into
    $(
        case s.outsidebox:
        $( let n = boxatcursor()       // find currently selected box
           if n >= 0                   // change state if it exists
           $( g.nf.p!c.state, g.nf.p!c.box := s.atbox, n
              if n = 0
              $( g.nf.boxinput('f', boxtables+n, m.sd.cyan) // fill with cyan
                 query%0 := 0     // empty the input string
                 g.nf.boxinput('i', boxtables+n, query) // initialise box
              $)
              loop
           $)
        $)
        endcase
        case s.atbox: if G.key = m.kd.action & G.menuon = false &
                         G.nf.p!c.box = 0 then
                      $(
                         G.nf.p!c.state := s.atbox1
                         endcase
                      $)
        case s.atbox1:
        $( let n = boxatcursor()       // find currently selected box
           if G.nf.p!c.state = s.atbox1 & G.menuon G.nf.p!c.state := s.atbox
             // change state if different
           if n ~= g.nf.p!c.box & (G.nf.p!c.state = s.atbox |
               (G.nf.p!c.state = s.atbox1 & G.key = m.kd.action)) do
           $( g.nf.p!c.state := s.outsidebox
              if g.nf.p!c.box = 0
                 g.nf.boxinput('f', boxtables+g.nf.p!c.box, m.sd.blue)
              loop                   // fill with blue
           $)
           if g.key = m.kd.noact endcase     // continue if no character
           g.nf.p!c.state := s.ing+n/6; loop // otherwise enter the box
           unless g.nf.p!c.state = s.ing endcase     // continue if no character
        $)
        case s.ing:
            // add the character to the box
             test g.key = m.kd.copy
             then g.nf.boxinput('s',oldquery)
             else addch.()
             unless g.key = m.kd.return
             $( if (g.nf.p+p.s)!2 = 0 then
                   g.nf.p!c.state := G.menuon -> s.atbox, s.atbox1
                return
             $)
             if query%0 = 0 do
             $( tidy("Query is blank")
                g.nf.p!c.state := G.menuon -> s.atbox, s.atbox1
                return
             $)
             if itemname.(query) do
             $( let u = g.nf.p!c.ws
                let v = u+m.tsize
                copyname.(query, u)
                test searchforname.(u, v) then 
                $( G.nf.selectitem.(v)
                   for i = 0 to m.tsize-1 do (g.nf.p+p.t)!i := v!i
                   hk(-1)
                   G.nf.p!c.good.query := true
                $)
                else
                $( back.one.rec(g.nf.p+c.file.rec)
                   g.nf.extractfiles(g.nf.p)
                   g.nf.p!c.titlenumber := 0
                   g.nf.p!c.good.query := true
                   g.nf.p!c.state := s.review
                   hk(0)
                   g.key := -m.st.nfindr
                   G.nf.p!c.last.function := m.file
                $)
                return
             $)
             if query%1 = '~'
             $( if userfile(query) hk(-2)
                return
             $)
             unless g.nf.makequery(g.nf.p)
             $( g.nf.boxinput('+')
                return
             $)
             unless g.nf.runquery(g.nf.p)
             $( update.screen()
                endcase
             $)
             g.nf.p!c.titlenumber := 0
             g.nf.p!c.good.query := true
             g.nf.p!c.state := s.review
             G.nf.p!c.last.function := m.keyword
             g.key := -m.st.nfindr
             endcase
        case s.ing+1:
        case s.ing+2:
        case s.ing+3:
        case s.ing+4:
        case s.ing+5:
        case s.ing+6:
        case s.ing+7: omit(G.nf.p!c.state)
                      g.nf.p!c.state := s.outsidebox
                      endcase
  $)
  return
$) repeat

and update.screen() be
$( manifest $( c4 = m.sd.charwidth*4
               h = m.sd.linw
               x = m.sd.disXtex+24*m.sd.charwidth
               y1 = m.sd.disYtex-17*h
               y2 = m.sd.disYtex-19*h  $)
   let b = boxtables
   g.sc.pointer(m.sd.off)
   g.sc.movea(m.sd.display,x,y1+4)
   g.sc.rect(m.sd.clear,c4,-h)
   g.sc.movea(m.sd.display,x,y2+4)
   g.sc.rect(m.sd.clear,c4,-h)
   g.nf.boxinput('f',b,m.sd.blue)
   b := b + 48
   g.nf.boxinput('f',b,m.sd.blue)
   g.nf.boxinput('i',b,g.nf.p+p.q)
   g.nf.boxinput('s',g.nf.p+p.oldq)
   g.nf.boxinput('-')
   g.nf.highlight()
   g.sc.pointer(m.sd.on)
   G.nf.p!c.state := s.outsidebox
   if G.nf.p!c.good.query then
      g.sc.menu(table m.sd.act, m.sd.act, m.sd.act,
                      m.sd.act, m.sd.act, m.sd.wBlank)  // redraw menu bar
   G.nf.p!c.good.query := false
$)

/* temporay routine
and userfile(query) = valof
$(
G.sc.ermess("not updated yet MH")
resultis false
$)
*/

and userfile(query) = valof  // attempt to access user data
$( let handle = ?
   let leveltype = vec 1
   let zero = vec 1
   let string =
      "-ADFS-*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S"
   g.ut.set32(0, 0, zero)
   if query%0 > 30 // number of characters in item name
   $( tidy("File name is longer than 30 characters")
      resultis false
   $)
   g.ut.movebytes(query, 2, string, 7, query%0-1)
   string%0 := query%0 + 5
   handle := g.ud.open(string)
   if handle = 0
   $( tidy(" ")
      resultis false
   $)
   if g.ud.read(handle, zero, leveltype, 2) = 0
   $( tidy(" ")
      g.dh.close(handle)
      resultis false
   $)
   g.key := valof switchon leveltype%1 into
   $( case 1: case 2: case 3:
         resultis -m.st.datmap
      case 4:
         resultis -m.st.chart
      default:
         tidy("File is not a dataset")
         resultis g.key
   $)
   g.dh.close(handle)
   if g.key < 0
   $( g.ut.movebytes(query, 0, g.context+m.itemrecord, 0, m.item.rec.size)
      g.ut.set32(0, 0, g.context+m.itemaddress)
      g.context!m.itemselected := true
      g.nf.p!c.good.query := true
      resultis true
   $)
   resultis false
$)

and tidy(string) be
$( unless string%1 = ' ' g.sc.ermess(string)
   if g.screen = m.sd.message g.key := m.kd.noact
   g.nf.boxinput('+')
$)

and hk(tn) be
$( let query = g.nf.p + p.q
   g.ut.movebytes(query, 0, g.nf.p+p.oldq, 0, query%0+1)
   g.nf.p!c.termcount := 1
   (g.nf.p+p.z)!c.hl1 := 1
   (g.nf.p+p.z)!c.hl2 := query%0
   g.nf.p!c.titlenumber := tn
$)

/* This routine reads back one INCLUDED record only if the current record
   is NOT of the included type
*/
and back.one.rec(rec) be
$( let c = vec 1
   let one = vec 1
   let sign = !rec < 0 -> -1, 0

   G.ut.set32(!rec, sign, c)
   G.ut.set32(1, 0, one)
   for i = !rec to 0 by -1 do
   $( if type.included(g.dh.read.type(c)) break
      G.ut.sub32(one, c)
   $)
   !rec := G.ut.unpack16.signed(c, 0)
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


.
