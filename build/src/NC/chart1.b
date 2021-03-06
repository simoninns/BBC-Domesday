//  PUK SOURCE  6.87

/**
         NATIONAL CHART ACTION ROUTINE
         -----------------------------

         This section contains :

            G.nc.chart and its utility routines

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         26.11.86 13       SRY         Disallow current var=sec var
         21.01.87 14       SRY         Var.key replot after looping
******************************************************************************
          2.06.87 15       SRY         Changes for UNI
         12.08.87 16       SRY         Modified for DataMerge
         14.08.87 17       SRY         Added background plot
                                       and narrow chars
**/

SECTION "Chart1"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/nchd.h"

static $( sv=? s.a=? bv=? cv=? c.r=? cc=? n.v=? o.nm=? buff=?
          u.s=? u.s1=?
       $)

/**
         G.NC.CHART - CONTROL CHART DRAWING
         ----------------------------------

         Specific action routine for Main Chart

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         contents of G.nc.area

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         G.nc.chart []
         -------------

         See Domesday Retrieval software
**/

LET G.nc.chart() BE
$( LET o.b,l.st=?,?

   IF G.context!m.justselected & (g.nc.area!m.nc.l.s ~= m.nc.error)
      G.nc.chartini()

   o.b := G.nc.area!m.nc.h
   l.st := G.nc.area!m.nc.l.s
   bv := G.nc.area!m.nc.bv
   cv := G.nc.area!m.nc.cv
   sv := G.nc.area!m.nc.sv
   cc := G.nc.area!m.nc.cc
   c.r := false
   n.v := G.nc.area%m.nc.vars
   buff := G.nc.area!m.nc.name.buff

   switchon l.st into
   $( case m.nc.regroup:
         for i=2 to n.v d.g(i) // on to ...
      case m.nc.text:
         g.nc.chartini()
         if g.nc.area!m.nc.cc=m.nc.looping lst(m.nc.looping)
         return
      case m.nc.looping:
         if t.s.e()
         $( g.nc.next.group(sv)
            g.nc.area!m.nc.sv := m.nc.unknown
            g.nc.draw.chart(1)
            g.nc.area!m.nc.sv := sv
            g.sc.keyboard.flush()
         $)
      endcase
      case m.nc.write:
         unless g.key=m.kd.noact
            g.sc.input(u.s,m.sd.blue,m.sd.cyan,32)
         if g.key=m.kd.return | g.key=m.kd.fkey1
         $( if g.key=m.kd.return
            $( g.key := m.kd.noact
               unless u.s%0=0
                  unless do.write() return
            $)
            g.menubar!m.box5 := m.sd.act
            g.sc.menu(g.menubar)
            g.sc.clear(m.sd.message)
            lst(cc=m.nc.looping -> m.nc.looping,m.nc.main)
         $)
         unless m.kd.fkey2 <= g.key <= m.kd.fkey6 return
      endcase
      case m.nc.overwrite:
         unless g.key=m.kd.noact
            g.sc.input(u.s1,m.sd.blue,m.sd.cyan,1)
         if g.key=m.kd.return | g.key=m.kd.fkey1
         $( if g.key=m.kd.return & capch(u.s1%1)='Y'
               if g.dh.delete.file(u.s)
               $( g.key := m.kd.noact
                  unless do.write() return
               $)
            g.menubar!m.box5 := m.sd.act
            g.sc.menu(g.menubar)
            g.sc.clear(m.sd.message)
            lst(cc=m.nc.looping -> m.nc.looping,m.nc.main)
         $)
         unless m.kd.fkey2 <= g.key <= m.kd.fkey6 return
      endcase
      case m.nc.error:
         g.key := m.kd.fkey2 // simulate Main
      endcase
      default:
   $)

   s.a := g.nc.which.box()
   unless s.a.d() s.a := m.nc.unknown

   unless s.a=o.b
   $( let s=s.a
      s.a := o.b
      h(m.sd.off)
      s.a := s
      h(m.sd.on)
   $)

   switchon g.key into
   $( case m.kd.fkey2:
         g.ut.set32(#xffff,#xffff,g.context+m.itemadd2)
         g.ut.set32(#xffff,#xffff,g.context+m.itemadd3)
         g.ut.mov32(g.nc.area+m.nc.itemsave,g.context+m.itemaddress)
         reset.()
         return
      case m.kd.fkey3:
         if r.p()
         $( g.menubar!m.box3 := m.sd.wblank
            g.menubar!m.box5 := m.sd.act
            g.sc.menu(g.menubar)
         $)
      endcase
      case m.kd.fkey4:
         lst(m.nc.regroup)
         return
      case m.kd.fkey5:
         g.sc.mess("File:")
         g.sc.movea(m.sd.message,m.sd.mesXtex+4*m.sd.charwidth,m.sd.mesYtex)
         u.s :=
         "*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S"
         u.s1 := table 0,0
         u.s%0 := 0
         u.s1%0 := 0
         g.key := m.kd.noact
         g.sc.input(u.s,m.sd.blue,m.sd.cyan,32)
         if g.screen=m.sd.menu
            g.sc.moveptr(g.xpoint,g.sc.dtob(m.sd.display,4))
         g.menubar!m.box5 := m.sd.wBlank
         g.sc.menu(g.menubar)
         lst(m.nc.write)
         return
      case m.kd.fkey6:
         reset.()
         g.key := - m.st.ntext
         lst(m.nc.text)
         return
      case m.kd.action:
         switchon s.a into
         $( case m.nc.more:
               g.nc.area!m.nc.bv := bv <= n.v-6 -> bv+6,2
               g.nc.varkey()
            endcase
            case m.nc.var1: case m.nc.var2: case m.nc.var3:
            case m.nc.var4: case m.nc.var5: case m.nc.var6:
            $( let o=vptr(s.a+bv-m.nc.var1)
               g.sc.mess("%s",G.ut.align(G.nc.area,o,buff,m.nc.lsize.b))
            $)
            endcase
            case m.nc.group1: case m.nc.group2: case m.nc.group3:
            case m.nc.group4: case m.nc.group5: case m.nc.group6:
            $( let v=s.a+bv-m.nc.group1
               let o=gptr(v,!(vpr(v)))
               G.sc.mess("%s",G.ut.align(G.nc.area,o,buff,m.nc.lsize.b))
            $)
            endcase
            case m.nc.chart:
               if (g.ypoint >= m.nc.origy) & (cc ~= m.nc.pie) g.nc.value()
            endcase
            case m.nc.colkey:
               if cc=m.nc.pie g.nc.value()
         $)
      endcase
      case m.kd.change:
         switchon s.a into
         $( case m.nc.ckey:
               n.c.t()
            endcase
            case m.nc.ab.key:
               n.a()
            endcase
            case m.nc.yaxis: g.nc.rescale.chart(); endcase
            case m.nc.var1: case m.nc.var2: case m.nc.var3:
            case m.nc.var4: case m.nc.var5: case m.nc.var6:
               c.v(s.a+bv-m.nc.var1)
            endcase
            case m.nc.group1: case m.nc.group2: case m.nc.group3:
            case m.nc.group4: case m.nc.group5: case m.nc.group6:
               c.g(s.a+bv-m.nc.group1)
            endcase
         $)
   $)

   if c.r & (g.menubar!m.box3 ~= m.sd.act)
   $( g.menubar!m.box3 := m.sd.act
      g.menubar!m.box5 := m.sd.wblank
      g.sc.menu(g.menubar)
      if l.st=m.nc.looping
      $( d.g(sv)
         g.nc.varkey()
         lst(m.nc.main)
      $)
      spl()
   $)
$)

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//             Utility routines used by Chart only                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

and reset.() be
$( g.sc.clear(m.sd.display)
   g.sc.clear(m.sd.message)
   g.sc.setpal(m.sd.defpal)
$)

and do.write()=valof
$( let h=g.ud.open.file(u.s)
   test 0 < h < #x80 // strictly m.ut.min.error but no room!
   then $( u.s1%0 := 0
           g.key := m.kd.noact
           g.sc.input(u.s1,m.sd.blue,m.sd.cyan,1)
           lst(m.nc.overwrite)
           resultis false
        $)
   else $( test h = 0 // strictly m.ut.success but no room!
           then $( g.nc.write()
                   g.ud.close.file()
                $)
           else $( g.sc.input(0,m.sd.blue,m.sd.cyan,32)
                   resultis false
                $)
           g.sc.keyboard.flush()
           resultis g.nc.area!m.nc.l.s ~= m.nc.error
        $)
$)

and c.v(v) be // select current or second variable
$( test sv.ok()
   then $( if v=sv return
           test sv=m.nc.unknown
           then if v=cv return
           else cv := sv
           sv := v
           d.g(sv)
        $)
   else $( if v=cv return
           cv := v
        $)
   d.g(cv)
   g.nc.area!m.nc.cv := cv
   g.nc.area!m.nc.sv := sv
   g.nc.area!m.nc.lc := m.nc.unknown
   c.r := true
   g.nc.varkey()
$)

and n.c.t() be // select next chart type
$( let c=vec 10/bytesperword
   G.ut.movebytes(G.nc.area,m.nc.dm,c,0,10)
   for i=0 to m.nc.nm-1
      if cc=c%i
      $( let lp=cc=m.nc.looping
         let j=i
         $( j := (j=m.nc.nm-1) | (c%(j+1)=0) -> 0,j+1
            cc := c%j
         $) repeatwhile (cc=m.nc.stacked) | (cc=m.nc.abtob) |
                        (cc=m.nc.astack)  | (cc=m.nc.sg)
         g.nc.area!m.nc.cc := cc
         c.h(m.sd.on)
         unless sv.ok()
         $( g.nc.area!m.nc.sv := m.nc.unknown
            unless (sv=m.nc.unknown) | lp g.nc.varkey()
         $)
         c.r := true
         return
      $)
$)


and r.p()=valof // attempt to replot chart
$( if sv.ok() & (sv=m.nc.unknown)
   $( g.sc.ermess("Please select secondary variable")
      resultis false
   $)
   if t.m.t.p()
   $( G.sc.ermess("Too many groups to plot- Please Regroup")
      resultis false
   $)
   if cc=m.nc.looping
   $( lst(m.nc.looping)
      g.nc.area!m.nc.time := m.nc.ts+1
      !(vpr(sv)) := 0
      resultis true
   $)
   if (cc=m.nc.btob) & (i.g(sv) > i.g(cv))
   $( g.nc.area!m.nc.cv := sv
      g.nc.area!m.nc.sv := cv
   $)
   g.nc.replot()
   resultis true
$)


and h(on.off) be // Highlight an area of the screen
$( switchon s.a into
   $( case m.nc.more:
         do.sa(s.a, on.off)
         G.sc.oprop("More...")
      endcase
      case m.nc.ckey:
         do.sa(s.a, on.off)
         g.sc.oprop(valof switchon cc into
         $( case m.nc.bar: resultis "Bar chart"
            case m.nc.btob: resultis "Back-back"
            case m.nc.looping: resultis "Loop bar"
            case m.nc.pie: resultis "Pie chart"
            case m.nc.stslg: resultis "Sing.line"
            case m.nc.mtslg: resultis "Mult.line"
         $) )
      endcase
      case m.nc.ab.key:
      $( let o=gptr(cv,G.nc.area!m.nc.ca)
         let s="  = "
         if g.menubar!m.box3=m.sd.act return
         do.sa(s.a, on.off)
         s%1 := G.nc.area%(o+(o.nm -> m.nc.oaoff,m.nc.aoff))
         g.sc.oprop(s)
         G.sc.oprop(G.ut.align(G.nc.area,o,buff,m.nc.lsize.b))
      $)
      endcase
      case m.nc.var1: case m.nc.var2: case m.nc.var3:
      case m.nc.var4: case m.nc.var5: case m.nc.var6:
      $( let v=s.a+bv-m.nc.var1
         if v <= n.v
         $( do.sa(s.a, on.off)
            if (on.off=m.sd.off) & ((v=cv) | (v=sv)) g.sc.selcol(m.sd.blue)
            g.nc.pr(G.ut.align(G.nc.area,vptr(v),buff,m.nc.lsize.b),18)
         $)
      $)
      endcase
      case m.nc.group1: case m.nc.group2: case m.nc.group3:
      case m.nc.group4: case m.nc.group5: case m.nc.group6:
      $( let v=s.a+bv-m.nc.group1
         if v <= n.v
         $( let o=gptr(v,!(vpr(v)))
            do.sa(s.a, on.off)
            if on.off=m.sd.off g.sc.selcol(m.sd.blue)
            g.nc.pr(G.ut.align(G.nc.area,o,buff,m.nc.lsize.b),16)
         $)
      $)
      endcase
      default:
         G.nc.area!m.nc.h := m.nc.unknown
         return
   $)
   g.nc.area!m.nc.h := s.a
$)

and do.sa(s.a, on.off) be
$( test on.off=m.sd.on
   then $( g.sc.selcol(m.sd.blue)
           g.nc.clear(m.sd.plot,s.a)
           g.sc.selcol(m.sd.yellow)
        $)
   else $( g.nc.clear(m.sd.clear, s.a)
           g.sc.selcol(m.sd.cyan)
        $)
   g.nc.move(s.a)
$)

and n.a() be // display nect abbreviation & group name
$( if g.menubar!m.box3=m.sd.act return
   !(vpr(cv)) := g.nc.area!m.nc.ca
   g.nc.area!m.nc.ca := g.nc.next.group(cv)
      repeatwhile !(vpr(cv))=m.nc.all
   c.h(m.sd.on)
   d.g(cv)
$)

and c.g(v) be // select next group
$( g.nc.next.group(v)
   c.h(m.sd.on)
   c.r := true
$)

and c.h(on.off) be // clear area then highlight it
$( g.nc.clear(m.sd.clear,s.a)
   h(on.off)
$)

and vptr(v)=valof // byte offset to name of variable
$( let l=1
   for i=1 to v-1
      l := l+g.nc.cats(i)+1
   resultis m.nc.labels.b+l*m.nc.lsize.b
$)

and gptr(v,g)=valof // byte offset to name of group of variable
$( unless (g & #xff00)=0
   $( o.nm := true
      resultis m.nc.gname*bytesperword+(g >> 8)*m.nc.olsize.b
   $)
   o.nm := false
   for i=1 to g.nc.cats(v)
      if (vpr(v))!i=g
         resultis vptr(v)+i*m.nc.lsize.b
$)

and s.a.d()=valof switchon s.a into // true if a screen area is displayed
   $( case m.nc.more: resultis n.v > 7
      case m.nc.var1: case m.nc.var2: case m.nc.var3:
      case m.nc.var4: case m.nc.var5: case m.nc.var6:
         resultis s.a-m.nc.var1+bv <= n.v
      case m.nc.ab.key: resultis g.nc.area!m.nc.abbrevs
      case m.nc.group1: case m.nc.group2: case m.nc.group3:
      case m.nc.group4: case m.nc.group5: case m.nc.group6:
         resultis (cv-bv ~= s.a-m.nc.group1) & (sv-bv ~= s.a-m.nc.group1) &
                  (s.a-m.nc.group1+bv <= n.v)
      default: resultis true
   $)

and t.s.e()=valof // time ten seconds
$( if g.nc.area!m.nc.time > m.nc.ts
   $( g.nc.area!m.nc.time := 0
      resultis true
   $)
   g.nc.area!m.nc.time := g.nc.area!m.nc.time+1
   resultis false
$)

and t.m.t.p()=valof // see if can plot graph
   switchon cc into
   $( case m.nc.mtslg: resultis i.g(sv) > 4
      case m.nc.pie: resultis i.g(cv) > 12
      case m.nc.btob: resultis i.g(cv)*i.g(sv) > 24
      default: resultis false
   $)

and spl() be // display replot warning
$( g.sc.selcol(m.sd.blue)
   g.sc.movea(m.sd.display,m.nc.tx,m.nc.ty) // was +4
   g.sc.rect(m.sd.plot,224,m.nc.td-12) // was -8
   g.sc.movea(m.sd.display,m.nc.tx+12,m.nc.ty+m.nc.td-16) // was -12
   g.sc.selcol(m.sd.yellow)
   g.sc.ofstr("Replot")
$)

and d.g(v) be // return variable to default group
$( !(vpr(v)) := m.nc.all
   if g.nc.area%m.nc.add = 2 | g.nc.area%v > 24
      g.nc.next.group(v)
$)

and i.g(v)=(vpr(v))!m.nc.incg

and vpr(v)=g.nc.area+m.nc.gcats+(v*m.nc.gpwords)

and sv.ok()=cc ~= m.nc.bar & cc ~= m.nc.pie & cc ~= m.nc.stslg

and lst(s) be g.nc.area!m.nc.l.s := s
.

