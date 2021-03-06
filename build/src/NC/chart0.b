//  PUK SOURCE  6.87

/**
         CHART - NATIONAL CHART OVERLAY
         ----------------------------

         This module contains only DY.INIT and DY.FREE

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
        8.10.86   6        SRY         Streamlining
        3.11.86   7        SRY         Scaling factor not exp.
*******************************************************************************
        3.06.87   8        SRY         Changes for UNI
       12.06.87   9        PAC         Fix dy.free comment
       12.08.87  10        SRY         Modified for DataMerge
       21.09.87  11        SRY         Floating point
**/

section "chart0"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "GH/glDYhd.h"
get "H/sdhd.h"
get "H/iohd.h"
get "H/vhhd.h"
get "H/nchd.h"

/**
         G.NC.DY.INIT - OVERLAY INITIALISATION
         ----------------------------------

         General overlay initialisation routine

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.nc.area is assigned to the vector of storage needed
         G.context!m.itemaddress changed to point to text essay for chart

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         Get heap space for data buffer
         Restore buffer from I/O processor memory
         Open data file & read dataset header
         Pass text addresses to G.context
         Shuffle addresses up to front
         Read dataset
         Assign abbreviations if any are blank
         Adjust exponent
         Set video mode
**/


LET G.nc.dy.init() BE
$( let low.16, high.16 = ?, ?
   let tb, vp = ?, ?
   let handle = ?
   let itemrecord = g.context + m.itemrecord
   let header = vec 1
   let length = vec 1
   let t = vec 1
   let string =
   "-ADFS-*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S*S"

   G.vh.video(m.vh.micro.only)
   G.ut.set32(m.nc.head, 0, header)
   G.nc.area := getvec(m.nc.lhead/bytesperword + m.nc.cache)
   G.ut.restore(G.nc.area+m.nc.gname, m.nc.cache, m.io.NCcache)
   $<debug
   IF G.ut.diag()
   $( let instream = input()
      LET command = "**dir :4"
      selectinput(findinput("/C"))
      G.sc.clear(m.sd.display)
      G.sc.selcol(m.sd.yellow)
      G.sc.movea(m.sd.display, 0, m.sd.disYtex)
      writes ("*n*nA/V: ")
      TEST capch(rdch()) = 'A'
      THEN $( runprog("**adfs")
              writes("*nDrive: ")
              command%7 := '0' + readn()
              runprog(command)
           $)
      ELSE RUNPROG ("**vfs")
      writef("*NAddress: LO <%n>", G.context!m.itemaddress)
      G.context!m.itemaddress := readn()
      writef("*NAddress: HI <%n>", G.context!(m.itemaddress+1))
      G.context!(m.itemaddress+1) := readn()
      writef("*NJS: (1=true, 0=false) <%n>", G.context!m.justselected)
      G.context!m.justselected := readn()
      endread()
      selectinput(instream)
   $)
   $>debug
   G.nc.area!m.nc.name.buff := getvec(m.nc.lsize.b/bytesperword)
   TEST G.context!m.justselected  // first time - might be help or text
   THEN $( G.ut.mov32(G.context+m.itemaddress, G.nc.area+m.nc.itemsave)
           g.nc.area!m.nc.l.s := m.nc.main
        $)
   ELSE G.ut.mov32(G.nc.area+m.nc.itemsave, G.context+m.itemaddress)
   low.16 := G.ut.get32(G.context+m.itemaddress, @high.16)
   tb := (high.16 & #X8000) ~= 0
   G.ut.set32(low.16, high.16 & #X7FFF, g.nc.area + m.nc.dataptr)
   test itemrecord%1 = '~'
   then $( g.ut.movebytes(itemrecord, 2, string, 7, itemrecord%0 - 1)
           string%0 := itemrecord%0 + 5
           handle := G.ud.open(string)
         $)
   else handle := G.dh.open(tb -> "DATA2", "DATA1")
   G.nc.area!m.nc.handle := handle
   if handle = 0
   $( g.nc.area!m.nc.l.s := m.nc.error
      return
   $)
   g.dh.length(handle, length)
   low.16 := m.nc.head
   if G.ut.cmp32(length, header) = m.lt low.16 := G.ut.get32(length, @high.16)
   if G.ud.read(handle, G.nc.area+m.nc.dataptr, G.nc.area, low.16) = 0
   $( g.nc.area!m.nc.l.s := m.nc.error
      return
   $)
   // Assign text essay pointers
   assign(1, 1)
   assign(2, 2)
   assign(3, 3)
   TEST missing(1)
   THEN TEST missing(2)
        THEN $( assign(1, 3)
                assign(2, -1)
             $)
        ELSE $( assign(1, 2)
                assign(2, 3)
                assign(3, -1)
             $)
   ELSE IF missing(2)
        $( assign(2, 3)
           assign(3, -1)
        $)
   G.ut.add32(header, G.nc.area+m.nc.dataptr)
   low.16 := m.nc.lhead
   G.ut.sub32(header, length)
   G.ut.set32(m.nc.lhead, 0, t)
   if G.ut.cmp32(length, t) = m.lt low.16 := G.ut.get32(length, @high.16)
   G.ud.read(handle, G.nc.area+m.nc.dataptr, G.nc.area, low.16)
   G.ut.sub32(header, G.nc.area+m.nc.dataptr)
   G.ut.unpack32(G.nc.area, m.nc.datoff, header)
   G.ut.add32(header, G.nc.area+m.nc.dataptr)
   vp := m.nc.labels.b + 3*m.nc.lsize.b // Abbreviations

   if g.nc.area%m.nc.vars > 25
   $( g.nc.area!m.nc.l.s := m.nc.error
      return
   $)

   FOR v=2 TO G.nc.area%m.nc.vars
   $( LET ab = 'A'
      let cats = g.nc.cats(v)
      vp := vp + m.nc.lsize.b
      if g.nc.area!m.nc.l.s = m.nc.error return

      FOR i = 1 TO cats
      $( IF G.nc.area%(vp+m.nc.aoff) <= ' '
         $( G.nc.area%(vp+m.nc.aoff) := ab
            ab := ab + 1
         $)
         vp := vp + m.nc.lsize.b
      $)
   $)
   // G.ut.trap("NC", 7, TRUE, 1, vp, 0, m.nc.lhead-m.nc.lsize.b)
   G.ut.unpack32(G.nc.area, m.nc.norm, t)
   G.ut.mov32(t, G.nc.area + m.nc.norm/bytesperword)
   IF (G.nc.area%m.nc.s.f = 'D') & (G.nc.area%m.nc.sfe = 'E') // neg. exp.
     G.nc.area!(m.nc.norm/bytesperword) := - G.nc.area!(m.nc.norm/bytesperword)
$)

and missing(no) = valof
$( let x = no=1 -> 2, 6
   let offset = vec 1
   let minus.one = vec 1
   g.ut.set32(#xffff, #xffff, minus.one)
   g.ut.unpack32(g.nc.area, x, offset)
   resultis g.ut.cmp32(offset, minus.one) = m.eq
$)

and assign(tono, from) be
$( let ptr = g.context + valof switchon tono into
      $( case 1: resultis m.itemaddress
         case 2: resultis m.itemadd2
         case 3: resultis m.itemadd3
      $)
   test from = -1
   then g.ut.set32(#xffff, #xffff, ptr)
   else g.ut.unpack32(g.nc.area, from * 4 - 2, ptr)
$)


/**
         G.NC.DY.FREE - FREE OVERLAY
         ---------------------------

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         Cache current data buffer in I/O processor
         Free the data buffer vector
         Close data file
**/


AND G.nc.dy.free() BE
$( G.ut.cache(G.nc.area + m.nc.gname, m.nc.cache, m.io.NCcache)
   G.dh.close(G.nc.area!m.nc.handle)
   freevec(G.nc.area!m.nc.name.buff)
   freevec(G.nc.area)
$)
.
