//  PUK SOURCE  6.87

/**
         NATIONAL CHART INITIALISATION
         -----------------------------

         This module contains
            G.nc.chartini
            G.nc.replot
            G.nc.rescale.chart
            G.nc.next.group
            G.nc.cats
            G.nc.pr

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         12.11.86 7        SRY         Additive init
         19.11.86 8        SRY         Minor regroup bug
*******************************************************************************
          2.06.87 9        SRY         Changes for UNI
         12.08.87 10       SRY         Modified for DataMerge
         14.08.87 11       SRY         Added G.nc.pr
         14.09.87 12       SRY         Allows BtoB & MTSLG as default
         04.01.88 13       MH          Update to G.nc.cats
**/

section "chart2"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "H/sdhd.h"
get "H/nchd.h"

/**
         G.NC.CHARTINI - ENTER CHART AT TOP LEVEL
         ----------------------------------------

         Display default chart & initialise data buffers

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         contents of G.nc.area
         G.menubar

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         G.nc.chartini []
         ----------------

         See Retrieval software
**/

LET G.nc.chartini() BE
$( LET ch, sv = ?, ?
   G.sc.clear(m.sd.display)
   G.sc.clear(m.sd.message)
   init.data.buffer() // Make it all defaults
   ch := G.nc.area!m.nc.cc
   sv := G.nc.area!m.nc.sv
   FOR n = 0 TO 2
   $( LET col = G.nc.area%(m.nc.colset + n)
      // G.ut.trap("NC",8,FALSE,3,col,1,7)
      G.sc.palette(n+1, col)
   $)
   UNLESS ((ch=m.nc.bar) | (ch=m.nc.STSLG) | (ch=m.nc.BtoB) |
           (ch=m.nc.pie) | (ch=m.nc.MTSLG) | (ch=m.nc.looping)) & (~t.m.t.p())
   $( G.nc.area!m.nc.cc := m.nc.bar
      ch := m.nc.bar
      G.nc.area!m.nc.sv := m.nc.unknown
   $)
   IF ch = m.nc.looping G.nc.area!m.nc.sv := m.nc.unknown
   G.nc.replot()
   IF ch = m.nc.looping G.nc.area!m.nc.sv := sv
$)


/**
         G.NC.REPLOT
         -----------

         Replot chart
**/

AND G.nc.replot() BE
$( G.nc.draw.chart(1)
   G.nc.varkey()
   G.nc.chartkey()
$)

/**
         G.NC.RESCALE.CHART
         ------------------

         Rescale Y-axis of chart
**/

AND G.nc.rescale.chart() BE
$( LET cc = G.nc.area!m.nc.cc
   IF ((cc = m.nc.bar) | (cc = m.nc.BtoB) | (cc = m.nc.looping)) &
      (G.menubar!m.box3 = m.sd.wBlank)
   $( G.nc.area!m.nc.lc := m.nc.unknown
      G.nc.draw.chart(0)
   $)
$)

/**
         G.NC.NEXT.GROUP
         ---------------

         Get next group of a variable
**/

and g.nc.next.group(v) = valof
$( let vp = vpr(v)
   let c.gr, s, b = (!vp) & #xff, #xff, #xff
let notall = ?
   for i = 1 to g.nc.area%v
   $( let g = (vp!i) & #xff
      unless ((vp!i) & #x8000) = 0 loop
      if (g > c.gr) & (g < (b & #xff)) b := vp!i
      if g < (s & #xff) s := vp!i
   $)
   if b = #xff
   $( 
      notall := (vp!0 = m.nc.all)|(g.nc.area%m.nc.add = 2)|(g.nc.area%v > 24)
      b := notall -> s, m.nc.all
   $) 

   !vp := b
   resultis b
$)

and vpr(v) = g.nc.area + m.nc.gcats + (v*m.nc.gpwords)

/**
         G.NC.CATS
         ---------

         Return number of categories for variable
**/

and g.nc.cats(v) = valof
$( let c = g.nc.area%v
   let OR.flag =  bytesperword = 2 -> #xFF00, #xFFFFFF00 // Unified 04.01.88 MH
   if v = 1
      test c = 1
      then resultis 1
      else goto error
   if G.nc.area%m.nc.add ~= 4     // old-style dataset
      test 2 <= c <= 24
      then resultis c
      else goto error
   if c > 24 c := - (c | OR.flag)  // non-additive variable
   if 2 <= c <= 24 resultis c

error:
   G.sc.ermess("Invalid number of categories: %n", c)
   G.nc.area!m.nc.l.s := m.nc.error
   resultis 0
$)


/**
         G.NC.PR
         -------

         Print truncated narrow string
**/

and g.nc.pr(string, chars) be
$( let l = string%0
   if l > chars string%0 := chars
   g.sc.narrow(string)
   string%0 := l
$)

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//          Utility Routines used by G.nc.chartini only                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


AND init.data.buffer() BE // Initialise data areas
$( let minus.one = vec 1
   G.ut.set32(#XFFFF, #XFFFF, minus.one)
   G.nc.area!m.nc.bv := 2
   G.nc.area!m.nc.lc := m.nc.unknown
   G.nc.area!m.nc.string := m.nc.unknown
   G.nc.area!m.nc.l.s := m.nc.main
   FOR i=m.box1 TO m.box6 G.menubar!i := m.sd.act
   G.menubar!m.box3 := m.sd.wBlank  // Initially no Replot
   if G.ut.cmp32(G.context+m.itemaddress, minus.one) = m.eq
      G.menubar!m.box6 := m.sd.wBlank // No Text
   IF G.context!m.justselected // could come from Regroup
   $( LET defg = ?
      G.nc.area!m.nc.cv := 2
      G.nc.area!m.nc.h := m.nc.unknown
      G.nc.area!m.nc.cc := G.nc.area%m.nc.defdis
      test ((g.nc.area!m.nc.cc=m.nc.BtoB) | (g.nc.area!m.nc.cc=m.nc.MTSLG)) &
            (g.nc.area%m.nc.vars > 2)
      then g.nc.area!m.nc.sv := 3
      else g.nc.area!m.nc.sv := m.nc.unknown
      // G.ut.trap("NC",2,FALSE,3,G.nc.area!m.nc.cc,1,10)
      G.context!m.justselected := FALSE
      unless G.nc.area%m.nc.add = 2 groupname(1, "All", 'A')
      FOR i = 2 TO m.nc.maxnames groupname(i, (TABLE 0), ' ')
      FOR n = 2 TO G.nc.area%m.nc.vars
      $( let c = g.nc.area%n
         test c > 24 // non-additive var.
         then $( defg := 1
                 c := g.nc.cats(n)
              $)
         else defg := (g.nc.area%m.nc.add = 2) -> 1, m.nc.all
         group(n, G.nc.area%n, defg)
      $)
   $)
   // FOR i = m.box1 TO m.box6 DO (G.nc.area+m.nc.menu)!i := G.menubar!i
   move(g.menubar, g.nc.area+m.nc.menu, 6)
   G.sc.menu(G.menubar)
$)

AND group(var, numcats, defg) BE
$( LET varptr = vpr(var)
   !varptr := defg
   FOR i=1 TO numcats varptr!i := i
   varptr!m.nc.incg := numcats
$)

AND groupname(number, name, ab) BE
$( LET gb = number*m.nc.olsize.b
   G.ut.movebytes(name, 0, G.nc.area+m.nc.gname, gb, name%0+1)
   (G.nc.area+m.nc.gname)%(gb+m.nc.oaoff) := ab
$)

AND t.m.t.p() = VALOF
$( LET cv = G.nc.area!m.nc.cv
   LET sv = G.nc.area!m.nc.sv
   LET ic = (vpr(cv))!m.nc.incg
   LET is = (vpr(sv))!m.nc.incg
   IF sv = cv RESULTIS TRUE
   SWITCHON G.nc.area!m.nc.cc INTO
   $( CASE m.nc.MTSLG: RESULTIS is > 4
      CASE m.nc.pie: RESULTIS ic > 12
      CASE m.nc.Looping: RESULTIS sv = m.nc.unknown
      CASE m.nc.BtoB:
         IF (is*ic > 24) | (sv = m.nc.unknown) RESULTIS TRUE
         IF is > ic
         $( G.nc.area!m.nc.cv := sv
            G.nc.area!m.nc.sv := cv
         $)
   $)
   RESULTIS FALSE
$)
.
