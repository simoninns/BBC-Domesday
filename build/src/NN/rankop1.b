/**
         NN.RANKOP1 - ACTION ROUTINE FOR RANK OPERATION
         ----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmRANK

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
       5.08.87    1        SRY         Initial version
      14.09.87    2        SRY         Added floating point stuff
**/

section "nmrank1"

$<RCP
needs "FLAR1"
needs "FLAR2"
needs "FLCONV"
$>RCP

get "H/libhdr.h"
$<RCP
get "H/fphdr.h"
$>RCP
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/iohd.h"
get "H/nmhd.h"
get "H/nmrehd.h"

/**
         G.NM.RANK - ACTION ROUTINE FOR RANK OPERATION
         ---------------------------------------------

         Action routine for the rank operation

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         g.nm.s

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         g.nm.rank []
         ------------

**/

let g.nm.rank() be
$( let p = G.nm.s!m.nm.rpage

   if g.nm.s!m.nm.reload g.nm.hinit.rank()

   switchon g.key into
   $(

      // If going to Help, must restore cached stuff so that the
      // cache and restore to & from Help itself doesn't
      // overwrite areal map etc. Then re-initialise on return -
      // see reload flag.
      case m.kd.Fkey1:
         restore.everything()
         g.sc.clear(m.sd.display)
         g.nm.s!m.nm.rpage := p
         g.nm.s!m.nm.reload := true
      endcase

      case m.kd.Fkey2:  // Main
      $( let h = g.nm.s!m.nm.help.visit
         restore.everything()
         G.sc.mode(2)
         g.sc.palette (m.nm.white, m.sd.white2)
         g.sc.palette (m.nm.flash.white, m.sd.flash.white2)

         // Reassign palette using physical colours that
         // were saved at start of Rank
         for i = 1 to m.nm.num.of.class.intervals do
            g.sc.palette (g.nm.class.colour!i, g.nm.s!(m.nm.pal-1 + i))
         g.nm.restore.screen(h)  // help.visit is overwritten by restores ...
         g.nm.s!m.nm.overlay.mode := g.nm.s!m.nm.prev.mode
         g.vh.video(g.nm.s!m.nm.overlay.mode)
         // NB: Video turned on in retr1: position.videodisc
      $)
      endcase

      case m.kd.Fkey3:  // First
         G.nm.rank.page(1)
      endcase

      case m.kd.Fkey4:  // End
         G.nm.rank.page(G.nm.s!m.nm.rank.pages)
      endcase

      case m.kd.Change: // Paging
         if G.screen = m.sd.display
            test G.xpoint <= m.sd.disW/3
            then try.back(p)
            else test G.xpoint >= (2*m.sd.disW)/3
                 then try.forward(p)
                 else G.sc.beep()
      endcase

      case m.kd.Fkey7:
         try.back(p)
      endcase

      case m.kd.Fkey8:
         try.forward(p)
      endcase
   $)
$)

and restore.everything() be
$( // Restore original map which simply indicates which areas are
   // accessed within the current area of interest
   g.ut.restore (g.nm.areal.map, m.nm.areal.map.size, m.io.wa.nm.areal.map)
   g.nm.restore.context()
$)

and try.forward(p) be
   test p = G.nm.s!m.nm.rank.pages
   then G.sc.beep()
   else G.nm.rank.page(p + 1)

and try.back(p) be
   test p = 1
   then G.sc.beep()
   else G.nm.rank.page(p - 1)

/*
   Display the nth page of the Ranked list of Areal units
*/

and G.nm.rank.page(n) be
$( let menu = G.nm.s + m.nm.menu
   let top.item = (n-1) * m.nm.ritems.page + 1
   let bottom.item = top.item + 7
   let cum.tot = vec 2

   G.ut.set48(0, 0, 0, cum.tot)
   if bottom.item > G.nm.s!m.nm.num.values
      bottom.item := G.nm.s!m.nm.num.values

   G.sc.pointer(m.sd.off)
   G.sc.selcol(m.sd.cyan)

   // Clear paging area
   G.sc.movea(m.sd.display, 0, 0)
   G.sc.rect(m.sd.clear, m.sd.disW, m.nm.rpage.top)

   // Set up cumulative total for previous pages
   $( let nptr = g.nm.areal
      for i = 1 to top.item - 1
      $( G.nm.mpadd(nptr, cum.tot)
         nptr := nptr + m.nm.max.data.size
      $)
   $)

   // Draw up to m.nm.ritems.page (8) items
   for i = top.item to bottom.item
      draw.item(i, m.nm.rpage.top - 4 - (i - top.item)*m.sd.linW*2, cum.tot)

   // Update context & menu bar
   G.nm.s!m.nm.rpage := n
   menu!m.box3 := (n = 1) -> m.sd.wBlank, m.sd.act
   menu!m.box4 := (n = G.nm.s!m.nm.rank.pages) -> m.sd.wBlank, m.sd.act
   unless menu!m.box3 = g.menubar!m.box3 & menu!m.box4 = g.menubar!m.box4
      G.sc.menu(menu)

   G.sc.pointer(m.sd.on)
$)

and draw.item(item, ypos, cum.tot) be
$( let areas = 0
   let area.name = vec 40/bytesperword
   let rel.item = g.nm.frame!(item-1)+1
   let abs.item = 0

   // First get absolute area number by going through areal map
   for i = 1 to g.nm.s!m.nm.nat.num.areas
   $( if g.nm.map.hit(i) areas := areas + 1
      if areas = rel.item
      $( abs.item := i
         break
      $)
   $)

   // Get area name from item number using index in frame buffer
   G.nm.get.area.name(abs.item, area.name)

   // Write out area name
   G.sc.movea(m.sd.display, m.sd.disXtex, ypos)
   G.sc.ofstr("%i4*s", item)
   g.sc.oprop(area.name)

   write.line(item, ypos-m.sd.linW, cum.tot)
$)

and write.line(item, ypos, cum.tot) be
$( let percent = ?
   let nptr = G.nm.areal + (item-1) * m.nm.max.data.size
   let exp = g.nm.dual.data.type(g.nm.s!m.nm.value.data.type) ->
             G.nm.s!m.nm.secondary.norm.factor,
             G.nm.s!m.nm.primary.norm.factor // exponent for data values
   let fw = ?

   // Write out line of data info
   G.sc.movea(m.sd.display, m.sd.disXtex+3*m.sd.charwidth, ypos)
   G.sc.opnum(nptr, exp, 8) // Value
   G.nm.mpadd(nptr, cum.tot)
   percent := muldiv(item, 100, G.nm.s!m.nm.num.areas)
   G.sc.ofstr("%i5*S", percent) // Percent thru' list
   unless g.nm.s!m.nm.cum return
   fw := G.nm.mpdisp(cum.tot, exp) // Cum. total. Field width <= 15
                                   // eg 1.234567890E-10
   G.sc.mover(m.sd.charwidth*(17-fw), 0)
   do.percent(g.nm.s+m.nm.grand.total, nptr)
$)

// (This routine only works for all positive values!)
and do.percent(total, value) be
$( let lo16, mid16 = ?, ?
   let percent = ?
   let t = vec 2
   let fp1 = vec FP.LEN
   let fp2 = vec FP.LEN
   let fp.100 = vec FP.LEN

   FFLOAT(100, fp.100)

   // Convert total to FP
   g.nm.int48.to.fp(total, fp1)

   // Convert value to FP .. assume positive
   lo16 := g.ut.get32(value, @mid16)
   g.ut.set48(lo16, mid16, 0, t) // NB: only works if value is positive
   g.nm.int48.to.fp(t, fp2)

   // Multiply value by 100
   FMULT(fp2, fp.100, fp2)

   // Perform division
   FDIV(fp2, fp1, fp2)

   // Convert to 16-bit number
   percent := FFIX(fp2)

   // Display number
   g.sc.ofstr("%i3", percent)
$)
.

