//  AES SOURCE  4.87

section "Rnm"

/**
         SI.RNM - Routine Inits for NM
         -----------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         5.5.87      2     DNH      Remove mwrite, mtext
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNMhd.h"
get "GH/glHEhd.h"
get "GH/glNAhd.h"
get "H/sthd.h"
get "H/stphd.h"

let g.st.rnm () be
$(

//  action routines when in NM state

    G.stactr!m.st.datmap := @G.nm.map - @G.dummy
    G.stactr!m.st.manal  := @G.nm.analyse - @G.dummy
    G.stactr!m.st.mdetail:= @G.nm.detail - @G.dummy
    G.stactr!m.st.resol  := @G.nm.resolution - @G.dummy
    G.stactr!m.st.mareas := @G.nm.Areas - @G.dummy
    G.stactr!m.st.mclass := @G.nm.class - @G.dummy
    G.stactr!m.st.manual := @G.nm.manual - @G.dummy
    G.stactr!m.st.autom  := @G.nm.automatic - @G.dummy
    G.stactr!m.st.equal  := @G.nm.auto.opt - @G.dummy
    G.stactr!m.st.nested := @G.nm.auto.opt - @G.dummy
    G.stactr!m.st.quant  := @G.nm.auto.opt - @G.dummy
    G.stactr!m.st.retri  := @G.nm.retrieve - @G.dummy
    G.stactr!m.st.compare:= @G.nm.compare - @G.dummy
    G.stactr!m.st.Rank   := @G.nm.rank - @G.dummy


//  ini routines for NM state changes

    G.stinit!((m.st.datmap-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.datmap-1)*m.st.barlen+2)      := @G.ov.exit - @G.dummy
      G.stinit!((m.st.datmap-1)*m.st.barlen+3)     := @G.nm.map.to.com - @G.dummy
       G.stinit!((m.st.datmap-1)*m.st.barlen+4)    := @G.na.areaini - @G.dummy
        G.stinit!((m.st.datmap-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.datmap-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.manal-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.manal-1)*m.st.barlen+2)      := @G.nm.map.to.com - @G.dummy
      G.stinit!((m.st.manal-1)*m.st.barlen+3)     := @G.nm.anal.to.clas - @G.dummy
       G.stinit!((m.st.manal-1)*m.st.barlen+4)    := @G.nm.to.detail - @G.dummy
        G.stinit!((m.st.manal-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.manal-1)*m.st.barlen+6)  := @G.nm.anal.to.ret - @G.dummy
    G.stinit!((m.st.mdetail-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.mdetail-1)*m.st.barlen+2)      := @G.nm.to.anal - @G.dummy
      G.stinit!((m.st.mdetail-1)*m.st.barlen+3)     := @G.nm.to.res - @G.dummy
       G.stinit!((m.st.mdetail-1)*m.st.barlen+4)    := @G.nm.to.areas - @G.dummy
        G.stinit!((m.st.mdetail-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.mdetail-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.resol-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.resol-1)*m.st.barlen+2)      := @G.nm.to.anal - @G.dummy
      G.stinit!((m.st.resol-1)*m.st.barlen+3)     := 0
       G.stinit!((m.st.resol-1)*m.st.barlen+4)    := @G.nm.to.areas - @G.dummy
        G.stinit!((m.st.resol-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.resol-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.mareas-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.mareas-1)*m.st.barlen+2)      := @G.nm.to.anal - @G.dummy
      G.stinit!((m.st.mareas-1)*m.st.barlen+3)     := @G.nm.to.res - @G.dummy
       G.stinit!((m.st.mareas-1)*m.st.barlen+4)    := 0
        G.stinit!((m.st.mareas-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.mareas-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.mclass-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.mclass-1)*m.st.barlen+2)      := @G.nm.to.anal - @G.dummy
      G.stinit!((m.st.mclass-1)*m.st.barlen+3)     := @G.nm.clas.to.man - @G.dummy
       G.stinit!((m.st.mclass-1)*m.st.barlen+4)    := @G.nm.to.auto - @G.dummy
        G.stinit!((m.st.mclass-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.mclass-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.manual-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.manual-1)*m.st.barlen+2)      := @G.nm.up.to.class - @G.dummy
      G.stinit!((m.st.manual-1)*m.st.barlen+3)     := @G.nm.man.to.auto - @G.dummy
       G.stinit!((m.st.manual-1)*m.st.barlen+4)    := @G.nm.man.to.man - @G.dummy
        G.stinit!((m.st.manual-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.manual-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.autom-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.autom-1)*m.st.barlen+2)      := @G.nm.up.to.class - @G.dummy
      G.stinit!((m.st.autom-1)*m.st.barlen+3)     := @G.nm.to.equal - @G.dummy
       G.stinit!((m.st.autom-1)*m.st.barlen+4)    := @G.nm.to.nested - @G.dummy
        G.stinit!((m.st.autom-1)*m.st.barlen+5)   := @G.nm.to.quantile - @G.dummy
         G.stinit!((m.st.autom-1)*m.st.barlen+6)  := @G.nm.to.auto - @G.dummy
    G.stinit!((m.st.equal-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.equal-1)*m.st.barlen+2)      := @G.nm.up.to.class - @G.dummy
      G.stinit!((m.st.equal-1)*m.st.barlen+3)     := @G.nm.to.auto - @G.dummy
       G.stinit!((m.st.equal-1)*m.st.barlen+4)    := @G.nm.to.nested - @G.dummy
        G.stinit!((m.st.equal-1)*m.st.barlen+5)   := @G.nm.to.quantile - @G.dummy
         G.stinit!((m.st.equal-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.nested-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.nested-1)*m.st.barlen+2)      := @G.nm.up.to.class - @G.dummy
      G.stinit!((m.st.nested-1)*m.st.barlen+3)     := @G.nm.to.equal - @G.dummy
       G.stinit!((m.st.nested-1)*m.st.barlen+4)    := @G.nm.to.auto - @G.dummy
        G.stinit!((m.st.nested-1)*m.st.barlen+5)   := @G.nm.to.quantile - @G.dummy
         G.stinit!((m.st.nested-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.quant-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.quant-1)*m.st.barlen+2)      := @G.nm.up.to.class - @G.dummy
      G.stinit!((m.st.quant-1)*m.st.barlen+3)     := @G.nm.to.equal - @G.dummy
       G.stinit!((m.st.quant-1)*m.st.barlen+4)    := @G.nm.to.nested - @G.dummy
        G.stinit!((m.st.quant-1)*m.st.barlen+5)   := @G.nm.to.auto - @G.dummy
         G.stinit!((m.st.quant-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.retri-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.retri-1)*m.st.barlen+2)      := @G.nm.to.anal - @G.dummy
      G.stinit!((m.st.retri-1)*m.st.barlen+3)     := 0
       G.stinit!((m.st.retri-1)*m.st.barlen+4)    := @G.nm.init.rank - @G.dummy
        G.stinit!((m.st.retri-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.retri-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.compare-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.compare-1)*m.st.barlen+2)     := @G.nm.comp.to.map.ini - @G.dummy
      G.stinit!((m.st.compare-1)*m.st.barlen+3)    := @G.nm.to.anal - @G.dummy
       G.stinit!((m.st.compare-1)*m.st.barlen+4)   := @G.nm.to.link.ini - @G.dummy
        G.stinit!((m.st.compare-1)*m.st.barlen+5)  := @G.nm.to.correl.ini - @G.dummy
         G.stinit!((m.st.compare-1)*m.st.barlen+6) := @G.nm.to.name.ini - @G.dummy
    G.stinit!((m.st.rank-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.rank-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.rank-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.rank-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.rank-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.rank-1)*m.st.barlen+6) := 0
$)
.
