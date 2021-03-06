//  PUK SOURCE  6.87

/**
         CHART REGROUP ACTION ROUTINE
         ----------------------------

         This section contains :

            G.nc.Regroup.Chart etc

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
       24.03.87   9        SRY         'More' highlight
*******************************************************************************
        3.06.87   10       SRY         Changes for UNI
       13.08.87   11       SRY         Modified for DataMerge
       14.08.87   12       SRY         Changed g.nc.clear calls
                                       and added narrow chars
       19.08.87   13       SRY         Too many names/abbrev bug
       19.08.87   14       MH          Modified for virtual keyboard
       24.08.87   15       MH          Bug fix for box highlighting
       03.09.87   16       MH          Bug fix for new regroup cat labels
       04.01.88   17       MH          Bug fix to i.st for non-intialised
                                       current variable
**/

section "chart5"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/nchd.h"

static $( cv=? vp=? cts=? h=? nonadd=? vars=? $)

/**
         G.NC.REGROUP.CHART
         -------------------

         PROGRAM DESIGN LANGUAGE:

         G.nc.regroup.chart []
         ---------------------

         IF change on screen and not in select var
         THEN IF in LH third
              THEN G.key:=previous
              ELSE IF in RH third THEN G.key:=next ELSE beep
         CASE OF G.key
            Fkey1: RETURN
                2: Clear chart area
                   state:=regroup
                   RETURN
                3: Initialise
                   state:=regroup
                   RETURN
                4: CASE OF state
                      include: init state category
                      category: blank box 5, go on to
                      destination: IF < 3 included groups
                                   THEN init state wait
                                   ELSE init state omit
                      omit: init state wait
                      default: clear chart area
                               state:=regroup
                   ENDCASE
                   RETURN
                7: IF not on first page THEN page back ELSE beep
                8: IF not on last page THEN page forwards ELSE beep
                5: IF on category THEN split from group
         ENDCASE
         CASE OF state
            regroup: Menu bar: help & replot
                     state select.var
            select.var: Highlight vars
                        IF action on var
                        THEN default palette
                             count total groups
                             IF any omitted groups
                             THEN state include
                             ELSE clear box 5
                                  state category
                             Set all vars to current 'all'
                             Clear box 2, 4
            include: Highlight group
                     IF action on group
                     THEN include
                          IF any groups omitted
                          THEN restore colour of group
                          ELSE init state category
                               Split -> box 5
            category: Highlight category
                      IF action on category
                      THEN IF < 3 included groups & 1 cat in group
                           THEN Error message
                           ELSE Blank box 5
                                Init state destination
            destination: Highlight group
                         IF action on group
                         THEN category -> this group
                              Split -> box 5
                              init state category
            omit: Highlight group
                  IF action on group
                  THEN omit
                       IF < 3 included groups
                       THEN init state wait
                       ELSE Change colour of group
            wait: Highlight name for input
                  IF ok init state on
            on: Highlight group name for input
                IF different
                THEN stop input
                ELSE IF G.key printing char THEN start input
            input: IF G.key not null THEN read a char
            complete: IF y position changed THEN init state wait
         ENDCASE
**/

let g.nc.regroup.chart() be
$( let p=g.nc.area!m.nc.pg
   let l.st=g.nc.area!m.nc.l.s

   i.st()

   if g.key=m.kd.change & l.st ~= m.nc.s.v & g.screen=m.sd.display
      test g.xpoint < m.nc.vkeyx/3
           g.key:=m.kd.fkey7 // previous
      else test g.xpoint > (m.nc.vkeyx << 1)/3
                g.key:=m.kd.fkey8 // next
           else g.sc.beep()

   switchon g.key into
   $( case m.kd.fkey3:
         if blank.names() return
         lst(m.nc.regroup)
      case m.kd.fkey1:
         return
      case m.kd.fkey4:
         switchon l.st into
         $( case m.nc.inc:
               cmp(nonadd -> m.nc.wait,m.nc.cat)
               return
            case m.nc.cat: case m.nc.split:
               g.menubar!m.box5:=m.sd.wblank
               g.sc.menu(g.menubar) // on to ...
            case m.nc.dest:
               cmp(m.nc.wait)
               return
            case m.nc.wait: case m.nc.on: case m.nc.input: case m.nc.comp:
            case m.nc.on1:   // added 19,08.87 MH
               if blank.names() return
               unless vp!m.nc.incg < 3
               $( cmp(m.nc.omit)
                  return
               $)
            // omit carries on
         $)
      case m.kd.fkey2:
         if blank.names() return
         g.nc.clear(m.sd.clear,m.nc.chart)
         lst(m.nc.regroup)
         return
      case m.kd.fkey5:
         g.menubar!m.box5:=m.sd.wblank
         g.sc.menu(g.menubar)
         g.sc.mess("Select category to split")
         lst(m.nc.split)
         return
      case m.kd.fkey7:
         unless l.st=m.nc.s.v
            test p > 1
            $( let tlst = l.st
               cp(-1)
               switchon(tlst) into
               $( case m.nc.on: case m.nc.on1:
                  case m.nc.input: case m.nc.comp:
                  lst(m.nc.wait)  // bug fix MH 24.8.87
               $)
            $)
            else g.sc.beep()
         return
      case m.kd.fkey8:
         unless l.st=m.nc.s.v
            test p < g.nc.area!m.nc.mp
            $( let tlst = l.st
               cp(1)
               switchon(tlst) into
               $( case m.nc.on: case m.nc.on1:
                  case m.nc.input: case m.nc.comp:
                  lst(m.nc.wait)  // bug fix MH 24.8.87
               $)
            $)
            else g.sc.beep()
         return
   $)

   switchon l.st into
   $( case m.nc.regroup:
         for i=m.box2 to m.box5 g.menubar!i:=m.sd.wblank
         g.menubar!m.box3:=m.sd.act
         g.sc.menu(g.menubar)
         cmp(m.nc.s.v)
      endcase

      case m.nc.s.v:
      $( let a.s=g.nc.which.box()
         cv:=a.s-m.nc.var1+g.nc.area!m.nc.bv
         h:=g.nc.area!m.nc.h
         unless a.s=h
         $( hl.var(m.sd.off)
            h:=a.s
            hl.var(m.sd.on)
         $)
         if action()
            test a.s=m.nc.more
                 if vars > 7
                    cp((p < g.nc.area!m.nc.mp) -> 1,1-g.nc.area!m.nc.mp)
            else if 2 <= cv <= vars
                 $( g.nc.area!m.nc.rcv:=cv
                    i.st()
                    g.sc.setpal(m.sd.defpal)
                    tot.g()
                    g.menubar!m.box4:=m.sd.act
                    g.menubar!m.box2:=m.sd.act
                    if cts <= 2 nonadd:=true
                    cmp(a.o() -> m.nc.inc,nonadd -> m.nc.wait,m.nc.cat)
                    g.sc.menu(g.menubar)
                 $)
      $)
      endcase

      case m.nc.inc:
         h:=g.nc.highlight(1)
         if action()
         $( inc()
            test a.o()
                 g.nc.highlight(5)
            else cmp(nonadd -> m.nc.wait,m.nc.cat)
         $)
      endcase

      case m.nc.cat:
         h:=g.nc.highlight(2)
         g.nc.area!m.nc.catno:=h
         if action()
            test no.cts()=1 & vp!m.nc.incg < 3
                 g.sc.ermess("Cannot have less than 2 groups")
            else $( G.sc.mess("Select destination group")
                    g.nc.area!m.nc.h:=m.nc.unknown
                    g.menubar!m.box5:=m.sd.wblank
                    g.sc.menu(g.menubar)
                    lst(m.nc.dest)
                 $)
      endcase

      case m.nc.split:
         h:=g.nc.highlight(2)
         if action()
         $( spl.c()
            cmp(m.nc.cat)
         $)
      endcase

      case m.nc.dest:
         h:=g.nc.highlight(2)
         if action()
         $( group()
            cmp(m.nc.cat)
         $)
      endcase

      case m.nc.wait:
         h:=g.nc.highlight(3)
         unless h=m.nc.unknown | g.nc.area!m.nc.string=m.nc.unknown
         $( lst(m.nc.on)
            g.nc.area!m.nc.x,g.nc.area!m.nc.y:=g.xpoint,g.ypoint
         $)
      endcase

      case m.nc.on:        // ## find mark
         if G.key=m.kd.action & G.menuon=false & G.nc.highlight(6)=h
         $(
            lst(m.nc.on1)
            endcase
         $)
      case m.nc.on1:
         if l.st=m.nc.on1 & G.menuon
         $(
           g.nc.area!m.nc.x,g.nc.area!m.nc.y:=g.xpoint,g.ypoint
            h:=g.nc.highlight(3)
            test h=m.nc.unknown
               lst(m.nc.wait)
            else
               lst(m.nc.on)
         $)
         test g.nc.highlight(7) ~= h & (l.st=m.nc.on | (l.st=m.nc.on1 &
             G.key=m.kd.action))

             $( h:=G.nc.highlight(3)
                g.nc.area!m.nc.x,g.nc.area!m.nc.y:=g.xpoint,g.ypoint
                unless h ~= m.nc.unknown & l.st=m.nc.on1
                   stop.input()
             $)
         else if g.ut.printingchar(g.key)
              $( if l.st=m.nc.on
                    g.nc.area!m.nc.x,g.nc.area!m.nc.y:=g.xpoint,g.ypoint
                 start.input()
              $)
      endcase

      case m.nc.input:
         unless g.key=m.kd.noact char.input()
      endcase

      case m.nc.comp:
         unless (g.ypoint=g.nc.area!m.nc.y) & (g.xpoint=g.nc.area!m.nc.x)
            lst(m.nc.wait)
      endcase

      case m.nc.omit:
         h:=g.nc.highlight(1)
         if action()
         $( omit()
            test vp!m.nc.incg < 3
                 $( g.nc.clear(m.sd.clear,m.nc.chart)
                    lst(m.nc.regroup)
                 $)
            else g.nc.highlight(4)
         $)
   $)
$)


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//             Utility routines used by Regroup Chart only                  //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


and start.input() be
$( let t=g.key
   let sb=g.nc.area!m.nc.ca=m.nc.unknown ->
            g.nc.area!m.nc.string,m.nc.ca*bytesperword
   g.key:=m.kd.noact
//   G.nc.area%sb:=0     // taken out 3.9.87 MH
   (G.nc.area!m.nc.name.buff)%0:=0
   char.input()
   g.key:=t
   char.input()
   lst(m.nc.input)
$)

and stop.input() be
$( let s=vec 1
   s%0:=0
   g.key:=m.kd.return
   g.sc.input(s,m.sd.cyan,m.sd.black,1) // cursor in black
   lst(m.nc.wait)
$)

and char.input() be
$( let l=m.nc.gnb
   let sb=G.nc.area!m.nc.string
   let s=G.nc.area!m.nc.name.buff
   let ab=false
   unless g.nc.area!m.nc.ca=m.nc.unknown // abb. input
   $( l := 1
      s := G.nc.area+m.nc.ca
      ab := true
   $)
   g.sc.input(s,m.sd.blue,m.sd.cyan,l)
   test g.key=m.kd.return
        $( let x1,y1=g.xpoint,g.ypoint
           let x2,y2=g.nc.area!m.nc.x,g.nc.area!m.nc.y
           let oldx=g.nc.area!m.nc.x < m.nc.namex -> 1,2
           let newx=x1 < m.nc.namex -> 1,2
           test ab
                G.nc.area%(sb+m.nc.oaoff) := s%1
           else G.ut.movebytes(s,0,G.nc.area,sb,s%0+1)
           update()
           g.xpoint,g.ypoint := m.nc.abx,g.nc.area!m.nc.y
           g.nc.highlight(3) // correct abb. of inputted one
           test oldx=newx & g.nc.area!m.nc.y=y1
                $( g.ypoint := m.nc.unknown
                   g.nc.highlight(3) // dehighlight abbreviation
                   lst(m.nc.comp)
                $)
           else $( g.ypoint := m.nc.unknown
                   g.nc.highlight(3) // dehighlight abbreviation
                   lst(m.nc.wait)
                 $)
           g.xpoint,g.ypoint := x1,y1
           g.nc.area!m.nc.x,g.nc.area!m.nc.y := x2,y2
           g.key := m.kd.noact
        $)
   else if s%0=0 & g.key ~= m.kd.noact // below taken out 3.9.87 MH
//        $( let rno=(sb-m.nc.gname*bytesperword)/m.nc.olsize.b
//          for i=1 to cts if record(vp!i)=rno s%0 := 1
//           G.nc.area%sb := s%0
           lst(G.menuon -> m.nc.on,m.nc.on1)
//        $)
$)


and update() be
$( let gno=g.nc.area!m.nc.h
   let sb=g.nc.area!m.nc.string
   let rno=(sb-m.nc.gname*bytesperword)/m.nc.olsize.b
   let cno=0
   for i=1 to cts if low(vp!i)=gno
      $( if cno=0 cno:=i
         vp!i:=(gno | (rno << 8))
      $)
   if g.nc.area%sb=0
   $( let c=vptr()+cno * m.nc.lsize.b
      // let l=G.nc.cats(c)+1
      // if l > m.nc.olsize.b l:=m.nc.olsize.b
      g.ut.movebytes(g.nc.area,c,g.nc.area,sb,g.nc.area%c+1)
      // last param was 'l'
   $)
$)

and spl.c() be
   for i=1 to cts if vp!i=vp!h & i ~= h
      $( vp!m.nc.incg:=vp!m.nc.incg+1
         g.nc.area!m.nc.groups:=g.nc.area!m.nc.groups+1
         vp!h:=g.nc.area!m.nc.groups
         return
      $)

and cp(inc) be
$( g.nc.area!m.nc.pg:=g.nc.area!m.nc.pg+inc
   switchon g.nc.area!m.nc.l.s into
   $( case m.nc.s.v: g.nc.page(0); endcase
      case m.nc.inc: case m.nc.omit: g.nc.page(1); endcase
      case m.nc.cat: case m.nc.split: case m.nc.dest:
         g.nc.page(2)
         endcase
      default: g.nc.page(3)
   $)
$)

and fp(t) be
$( let maxl=t=2 -> maxl2(),(t=0 -> vars-1,g.nc.area!m.nc.groups)
   let lines=t=0 -> 6,m.nc.lines
   g.nc.area!m.nc.mp:=(maxl-1)/lines+1
   g.nc.area!m.nc.pg:=1
   if t=2  // set up group -> line index
   $( let g=g.nc.area+m.nc.gplines
      for i=1 to 25 g%i:=#Xff // largest values
      g%1:=1
   $)
   g.nc.page(t)
$)

and hl.var(on.off) be
$( let s,l=?,?
   let v=h+g.nc.area!m.nc.bv-m.nc.var1
   let col= (on.off=m.sd.on) -> m.sd.yellow,(cv=v) -> m.sd.blue,m.sd.cyan
   unless (m.nc.var1 <= h <= m.nc.var6 & v <= vars) | (h=m.nc.more & vars > 7)
   $( g.nc.area!m.nc.h:=m.nc.unknown
      return
   $)
   test on.off=m.sd.on
        $( g.sc.selcol(m.sd.blue)
           g.nc.clear(m.sd.plot,h)
        $)
   else g.nc.clear(m.sd.clear,h)
   g.nc.move(h)
   g.sc.selcol(col)
   test h=m.nc.more
        g.sc.oprop("More...")
   else $( let save=cv
           cv:=v
           s:=G.ut.align(G.nc.area,vptr(),
                         G.nc.area!m.nc.name.buff,m.nc.lsize.b)
           g.nc.pr(s,18)  // was 10
           cv:=save
        $)
   g.nc.area!m.nc.h:=h
$)

and group() be   // put category c in group h
$( let c=g.nc.area!m.nc.catno
   let o.v=low(vp!c)
   let nptrb=record(vp!c)*m.nc.olsize.b
   for i=1 to cts if low(vp!i)=h
      $( vp!c:=vp!i
         break
      $)
   for i=1 to cts if low(vp!i)=o.v return
   for i=1 to cts
   $( let v=low(vp!i)
      if v > o.v vp!i:=(v-1) | top(vp!i)
   $)
   vp!m.nc.incg:=vp!m.nc.incg-1
   g.nc.area!m.nc.groups:=g.nc.area!m.nc.groups-1
   (G.nc.area+m.nc.gname)%nptrb:=0
$)

and vptr()=valof
$( let l=1
   for i=1 to cv-1
      l:=l+g.nc.cats(i)+1
   resultis m.nc.labels.b+l*m.nc.lsize.b
$)

and cmp(s) be
$( let t=1
   g.sc.mess(valof switchon s into
   $( case m.nc.wait:
         t:=3
         resultis "Enter new group names and abbreviations"
      case m.nc.omit:
         resultis "Select groups to omit"
      case m.nc.s.v:
         t:=0
         resultis "Select variable to regroup"
      case m.nc.inc:
         resultis "Select groups to re-include"
      case m.nc.cat:
         unless cts=g.nc.area!m.nc.groups // No split if all single
         $( G.menubar!m.box5:=m.sd.act
            G.sc.menu(G.menubar)
         $)
         t:=2
         resultis "Select category to regroup"
   $) )
   lst(s)
   fp(t)
$)

and maxl2()=valof
$( let no=0
   for i=1 to cts if tb(vp!i)=0 no:=no+1
   resultis no+cts
$)

and tot.g() be
$( let max=0
   for i=1 to cts if low(vp!i) > max max:=low(vp!i)
   g.nc.area!m.nc.groups:=max
$)

and no.cts()=valof
$( let n=0
   let gp=vp!(g.nc.area!m.nc.catno)
   for i=1 to cts if vp!i=gp n:=n+1
   resultis n
$)

and blank.names()=valof
$( let ok=true
   if g.nc.area!m.nc.l.s=m.nc.s.v resultis false
   for i=1 to cts
   $( let r=record(vp!i)
      if r > 0
      $( let nptrb=r*m.nc.olsize.b
         let g=G.nc.area+m.nc.gname
         ok:=false
         unless g%(nptrb+m.nc.oaoff)=' '
            for j=1 to g%nptrb
               unless g%(nptrb+j)=' '
               $( ok:=true
                  break
               $)
         unless ok break
      $)
   $)
   test ok
        resultis false
   else $( g.sc.ermess("Supply all names and abbreviations")
           G.key:=m.kd.noact
           resultis true
        $)
$)

and i.st() be
$( cv:=g.nc.area!m.nc.rcv
   vars:=g.nc.area%m.nc.vars  //bug fix for non-initialised current variable
   unless 2 <= cv <= vars cv := 2 //values 04.01.88 MH
   vp:=cv*m.nc.gpwords+g.nc.area+m.nc.gcats
   cts:=g.nc.area%cv
   test cts > 24
        $( cts:=g.nc.cats(cv)
           nonadd:=true
        $)
   else nonadd:=(g.nc.area%m.nc.add=2)
$)

and i.o(a.s,inc) be // include or omit
$( for i=1 to cts if low(vp!i)=h a.s(vp+i)
   vp!m.nc.incg:=vp!m.nc.incg+inc
$)

and omit() be i.o(atb,-1)

and inc() be i.o(stb,1)

and a.o()=vp!m.nc.incg ~= g.nc.area!m.nc.groups

and lst(s) be g.nc.area!m.nc.l.s:=s

and low(x)=x & #xff

and top(x)=x & #xff00

and tb(x)=x & #x8000

and stb(ptr) be !ptr:=(!ptr) & #x7fff

and atb(ptr) be !ptr:=(!ptr) | #x8000

and record(g)=(g >> 8) & #x7f

and action()=g.key=m.kd.action & h ~= m.nc.unknown
.

