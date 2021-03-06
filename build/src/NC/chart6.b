//  PUK SOURCE  6.87

/**
         CHART REGROUP GRAPHICS ROUTINES
         -------------------------------

         This section contains :

            G.nc.highlight, G.nc.page and their utility routines

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
       17.10.86   7        SRY         Fix group bug
*******************************************************************************
        3.06.87   8        SRY         Changes for UNI
       16.06.87   9        SRY         Fix latent bug !!!
       13.08.87  10        SRY         Modified for DataMerge
       14.08.87  11        SRY         Changed g.nc.clear calls
       19.08.87  12        SRY         Too many names/abbrev bug
       19.08.87  13        MH          update to G.nc.highlight for V.keyboard
**/

SECTION "Chart6"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/nchd.h"

STATIC
$( cv=? vp=? cats=? groups=? gno=? ypos=? catno=? type=?
   oldx=? newx=? col=? state=? o.nm=? gplines=?
$)

/**
         G.NC.PAGE
         ---------

         Display a page: Regroup Chart

         INPUTS:

         type: Type of page (Regroup)
               0: variables
               1: Group nos, abb.s & names
               2: Group nos & category names
               3: As 1 but with backgrounds for input

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         contents of G.nc.area

         SPECIAL NOTES FOR CALLERS:

         Used entirely by G.nc.regroup.chart

         PROGRAM DESIGN LANGUAGE:

         G.nc.page [type]
         ----------------
         Get first & last lines from page number & max line no.
         Set y position from G.ypoint
         Set highlighted unknown
         Turn pointer off
         IF not variables THEN clear chart area ENDIF
         CASE OF type
            0: Set basevar from page no.
               Display variable key
            1, 3: FOR group = first to last line
                     Select blue if omitted, otherwise cyan
                     Display group no.
                     IF not omitted & type = 3
                     THEN Select blue
                          draw background boxes
                          Select yellow
                     ENDIF
                     Display abbreviation
                     Display name
                     Set y position
                  ENDFOR
                  IF type = 3 THEN Set oldx from xpoint ENDIF
            2: Get group number & category number for first line
               Find if 'first cat in group'
               Select cyan
               FOR each line
                  IF 'first cat in group'
                  THEN Select blue if omitted, cyan otherwise
                       Display group no
                       Set 'first cat in group' to false
                       Get first cat of group
                  ENDIF
                  Display cat. name
                  Get next category
                  IF no more & group is not 'all'
                  THEN Draw yellow line under this entry
                       Set 'first cat in group' to true
                       update line for group vector
                       increase group number
                  ENDIF
                  Set y position
               ENDFOR
         ENDCASE
         Turn pointer on
**/

let g.nc.page(t) be
$( let page = g.nc.area!m.nc.pg
   let l1 = (page - 1)*m.nc.lines + 1
   let l2 = l1 + m.nc.lines - 1
   let print.number = ?
   gplines := g.nc.area + m.nc.gplines
   type := t
   unless type = 0
   $( g.sc.pointer(m.sd.off)
      g.nc.clear(m.sd.clear, m.nc.chart)
      ypos := m.nc.tly
      i.st()
      if page = g.nc.area!m.nc.mp l2 := (type=2 -> maxl2(), groups)
   $)
   g.nc.area!m.nc.h := m.nc.unknown

   switchon type into
   $( case 0:
         g.nc.area!m.nc.bv := page*6 - 4
         g.nc.varkey()
      endcase
      case 1: case 3:
         gno := l1
         $( let o = omitted()
            g.sc.selcol(o -> m.sd.blue, m.sd.cyan)
            gr.no()
            unless o | (type = 1)
            $( col := m.sd.blue
               backg(m.nc.abx)
               backg(m.nc.namex)
               g.sc.selcol(m.sd.yellow)
            $)
            ab()
            gr.name()
            ypos := ypos - m.sd.linW
            gno := gno + 1
         $) repeatuntil gno > l2
         if type=3
         $( oldx := g.xpoint < m.nc.namex -> m.nc.abx, m.nc.namex
            g.nc.area!m.nc.oldx := oldx
         $)
      endcase
      case 2:  // groups & categories
         gno := group.of.l2(l1)
         catno := cat.of.l2(l1)
         print.number := l1 = gplines%gno
         g.sc.selcol(m.sd.cyan)
         for i=l1 to l2
         $( if print.number
            $( g.sc.selcol(omitted() -> m.sd.blue, m.sd.cyan)
               gr.no()
               print.number := false
               catno := 0
               next.cat()
            $)
            gr.name()
            next.cat()
            if (catno=m.nc.unknown) & (gno ~= 'C')
            $( let y = ypos - m.sd.linW + 8
               g.sc.movea(m.sd.display, 0, y)
               g.sc.selcol(m.sd.yellow)
               g.sc.linea(m.sd.plot, m.sd.display, m.nc.cw - 2, y)
               print.number := true
               if gno < groups gplines%(gno + 1) := i + 1
               gno := gno = groups -> 'C', gno + 1
            $)
            ypos := ypos - m.sd.linW
         $)
      endcase
   $)
   g.sc.pointer(m.sd.on)
$)

/**
         g.nc.highlight - highlight an item
         ----------------------------------

         INPUTS:

         type: As for G.nc.page plus
               4: Display current group entry in cyan
               5: Display current group entry in blue

         OUTPUTS:

         Returns the following values:
           type: 0 - not called
                 1 - group number
                 2 - category number if state category else group number
                 3 - group number
                 4 - group number
                 5 - group number
           all types: unknown if not on an entry

         GLOBALS MODIFIED:

         contents of G.nc.area: highlighted, string and curabbrev

         SPECIAL NOTES FOR CALLERS:

         called only from G.nc.regroup.chart

         PROGRAM DESIGN LANGUAGE:

         G.nc.highlight [type]
         ---------------------

         Set item no, first & last lines from page & max line
         IF type = 3
         THEN IF not on a box THEN set item no unknown
         ENDIF
         IF type > 3
         THEN if type = 4 select blue else cyan
              Display current group entry
              RETURN
         ENDIF
         IF old one needs dehighlighting
         THEN select blue if omitted, cyan otherwise
              write old item
         ENDIF
         IF type = 2
         THEN Set item no to group first line unless category state
         ENDIF
         IF this item illegal
         THEN set highlighted to unknown
              RETURN
         ENDIF
         IF ok to highlight this item
         THEN select yellow
              write new item
         ENDIF
**/

and g.nc.highlight(t) = valof
$( let no1 = (g.nc.area!m.nc.pg - 1)*m.nc.lines + 1
   let ino = no1 + (m.nc.tly - g.ypoint)/m.sd.linw
   let maxl = no1 + m.nc.lines - 1
   let old = g.nc.area!m.nc.h
   gplines := g.nc.area + m.nc.gplines
   state := g.nc.area!m.nc.l.s
   type := t
   i.st()
   test g.screen = m.sd.display | // (g.screen = m.sd.menu &
          g.nc.area!m.nc.l.s = m.nc.on1 // ) // 20.8.87 MH
   then test type = 3 | type >= 6     // 19.8.87 MH
        then $(
             test g.xpoint < m.nc.namex
             then if (g.xpoint < m.nc.abx) |
                     (g.xpoint > m.nc.abx+m.sd.charwidth) ino := m.nc.unknown
             else if (g.xpoint > m.nc.namex + m.sd.charwidth*20)
                     ino := m.nc.unknown
             if type = 6  // 19.8.87 MH
                resultis no1 <= ino <= maxl -> ino, m.nc.unknown
             if type = 7 // 20.8.97
             $(
                test ((m.nc.abx-4 < g.xpoint < m.nc.abx+4+m.sd.charwidth) &
                 (m.nc.abx-4 < g.nc.area!m.nc.x < m.nc.abx+m.sd.charwidth+4)) |
                ((m.nc.namex-4 < g.xpoint < m.nc.namex+4+m.sd.charwidth*20) &
                 (m.nc.namex-4 < g.nc.area!m.nc.x < m.nc.namex+4+m.sd.charwidth*20))
                   resultis ino
                else
                   resultis m.nc.unknown
                unless g.screen = m.sd.display resultis m.nc.unknown
             $)
             unless g.screen = m.sd.display ino := m.nc.unknown
             $)
        else if type > 3
             $( g.sc.pointer(m.sd.off)
                gno := g(ino)
                col := type = 4 -> m.sd.blue, m.sd.cyan
                hwrite(ino, no1)
                g.sc.pointer(m.sd.on)
                resultis true
             $)
   else
   $(
      ino := m.nc.unknown
      if type >= 6 resultis ino
   $)
   if do.old(ino)
   $( g.sc.pointer(m.sd.off)
      gno := g(old)
      col := omitted() -> m.sd.blue, m.sd.cyan
      hwrite(old, no1)
   $)
   gno := g(ino)
   test type = 2
   then $( if maxl > cats maxl := cats
           if state = m.nc.dest ino := gno = 'C' -> m.nc.unknown, gplines%gno
        $)
   else if maxl > g.nc.area!m.nc.groups maxl := g.nc.area!m.nc.groups
   unless (no1 <= ino <= maxl) & (state = m.nc.inc -> omitted(), ~omitted())
   $( g.nc.area!m.nc.h := m.nc.unknown
      g.sc.pointer(m.sd.on)
      resultis m.nc.unknown
   $)
   if (ino ~= old) | (type = 3 & newx ~= oldx)
   $( g.sc.pointer(m.sd.off)
      col := m.sd.yellow
      hwrite(ino, no1)
      g.nc.area!m.nc.h := ino
   $)
   g.sc.pointer(m.sd.on)
   resultis (state = m.nc.cat | state = m.nc.split) -> cat.of.l2(ino), gno
$)


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//            Utility routines used by Page & Highlight only                //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


and do.old(ino) = valof
$( let old = g.nc.area!m.nc.h
   newx := g.xpoint < m.nc.namex -> m.nc.abx, m.nc.namex
   if old = m.nc.unknown resultis false
   if type = 3 & oldx ~= newx resultis true
   if state = m.nc.dest & g(ino) = g(old) resultis false
   resultis ino ~= old
$)

and hwrite(ino, no1) be  // write out a highlight item
$( ypos := m.nc.tly - (ino - no1)*m.sd.linw
   g.sc.selcol(col)
   switchon type into
   $( case 3:
         col := col = m.sd.cyan -> m.sd.blue, m.sd.cyan
         test col = m.sd.blue
         then $( backg(oldx)
                 g.sc.selcol(m.sd.yellow)
                 test oldx = m.nc.abx
                 then ab()
                 else gr.name()
              $)
         else $( let s = g.nc.area + m.nc.ca
                 G.nc.area!m.nc.string := own.name()
                 oldx := g.xpoint < m.nc.namex -> m.nc.abx, m.nc.namex
                 g.nc.area!m.nc.oldx := oldx
                 if g.nc.area!m.nc.string = m.nc.unknown return
                 backg(oldx)
                 !s := 0
                 g.key := m.kd.noact
                 g.sc.movea(m.sd.display, oldx, ypos)
                 g.sc.input(s, m.sd.blue, m.sd.cyan, 1)
                 if oldx = m.nc.namex g.nc.area!m.nc.ca := m.nc.unknown
              $)
      endcase
      case 2:
         unless state = m.nc.dest
         $( catno := cat.of.l2(ino)
            gr.name()
            endcase
         $)
      case 1:
         gr.no()
      endcase
      case 4: case 5:
         gr.no()
         ab()
         gr.name()
   $)
$)

and backg(x) be // display background rectangle
$( let width = (x = m.nc.namex -> m.nc.gnb, 1)*m.sd.charwidth
   let depth = (col = m.sd.cyan -> 4, 8) - m.sd.linW
   g.sc.selcol(col)
   g.sc.movea(m.sd.display, x, ypos+4)
   g.sc.rect(m.sd.clear, width, 4 - m.sd.linW)
   g.sc.movea(m.sd.display, x, ypos + 4)
   g.sc.rect(m.sd.plot, width, depth)
$)

and ab() be // display abbreviation
$( let ab = '?'
   let p = ?
   g.sc.movea(m.sd.display, m.nc.abx, ypos)
   for i = 1 to cats if eql(i)
   $( p := gptr(vp!i)
      p := o.nm -> (p+m.nc.oaoff), (p+m.nc.aoff)
      ab := g.nc.area%p
   $)
   g.sc.ofstr("%C", ab)
$)

and gr.name() be
$( let gnameb = (type = 2 -> cname(), name())
   let s = G.ut.align(G.nc.area, gnameb,
                      G.nc.area!m.nc.name.buff, m.nc.lsize.b)
   let l = s%0
   g.sc.movea(m.sd.display, m.nc.namex, ypos)
   if l > 20 s%0 := 20
   g.sc.ofstr("%s", s)
   s%0 := l
$)

and gr.no() be
$( g.sc.movea(m.sd.display, 0, ypos)
   test gno = 'C'
   then g.sc.ofstr(" C")
   else g.sc.ofstr("%i2", gno)
$)

and i.st() be // initialise static variables
$( cv := g.nc.area!m.nc.rcv
   vp := g.nc.area + m.nc.gcats + cv*m.nc.gpwords
   cats := g.nc.cats(cv)
   groups := g.nc.area!m.nc.groups
   oldx := g.nc.area!m.nc.oldx
$)

and own.name() = valof // assign byte offset pointer to new name
$( let i = 0
   let gb = m.nc.gname * bytesperword
   $( i := i + 1
      if eql(i) break
   $) repeatwhile i < cats
   unless record(vp!i) = 0 resultis gptr(vp!i)
   for i = 1 to m.nc.maxnames
   $( gb := gb + m.nc.olsize.b
      if G.nc.area%gb = 0 resultis gb
   $)
   g.sc.ermess("No space for names - please regroup")
   resultis m.nc.unknown
$)

and maxl2() = valof // included categories for combined group+cats
$( let no = 0
   for i = 1 to cats if incd(i) no := no+1
   resultis no + cats
$)

and next.cat() be // next category in group from catno
$( let s = gno = 'C' -> incd, eql
   for i = catno + 1 to cats if s(i)
      $( catno := i
         return
      $)
   catno := m.nc.unknown
$)

and cat.of.l2(ln) = valof   // get category no for line no & group
$( let n = 0
   let s, nth = ?, ?
   test gno = 'C'
   then s, nth := incd, ln - cats
   else s, nth := eql, ln - gplines%gno + 1
   for i = 1 to cats
   $( if s(i) n := n + 1
      if n = nth resultis i
   $)
$)

and group.of.l2(ln) = valof // get group no for line no
$( if ln > cats resultis 'C'
   for i = 2 to groups + 1 if gplines%i > ln resultis i - 1
$)

and vptr() = valof // pointer to name of variable
$( let l = 1
   for i = 1 to cv - 1
      l := l + g.nc.cats(i) + 1
   resultis m.nc.labels.b + l*m.nc.lsize.b
$)

and gptr(g) = valof // byte offset to name of group - could be omitted group
$( unless record(g) = 0
   $( o.nm := true
      resultis m.nc.gname*bytesperword + record(g)*m.nc.olsize.b
   $)
   o.nm := false
   for i=1 to cats if vp!i = g resultis vptr() + i*m.nc.lsize.b
$)

and name() = valof // get group name
   for i = 1 to cats if eql(i) resultis gptr(vp!i)

and omitted() = valof // find out if group is omitted
$( if gno = 'C' resultis false
   for i = 1 to cats if eql(i) resultis ~incd(i)
   resultis false
$)

and cname() = vptr() + catno*m.nc.lsize.b // byte offset to category name

and low(x) = x & #xff

and tb(x) = x & #x8000

and record(g) = (g >> 8) & #x7f

and g(ino) = type = 2 -> group.of.l2(ino), ino

and incd(i) = tb(vp!i) = 0

and eql(i) = low(vp!i) = gno
.
