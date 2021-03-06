//  AES SOURCE  4.87

section "Rgalwal"

/**
         SI.RGALWAL - Routine Inits for NW - Gallery & Walk
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         14.01.88    2     MH       Removed area from gallery
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glHEhd.h"
get "GH/glNAhd.h"
get "GH/glNFhd.h"
get "GH/glNThd.h"
get "GH/glNWhd.h"
get "H/sthd.h"
get "H/stphd.h"


let g.st.Rgalwal () be
$(

//  action routines when in state

    G.stactr!m.st.gallery := @G.nw.action - @G.dummy
    G.stactr!m.st.galmove := @G.nw.action - @G.dummy
    G.stactr!m.st.Gplan1  := @G.nw.action2 - @G.dummy
    G.stactr!m.st.Gplan2  := @G.nw.action2 - @G.dummy

    G.stactr!m.st.walk    := @G.nw.action - @G.dummy
    G.stactr!m.st.walmove := @G.nw.action - @G.dummy
    G.stactr!m.st.wplan1  := @G.nw.action2 - @G.dummy
    G.stactr!m.st.wplan2  := @G.nw.action2 - @G.dummy
    G.stactr!m.st.detail  := @G.nw.action1 - @G.dummy

// Walk ini routines on changing state

    G.stinit!((m.st.walk-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.walk-1)*m.st.barlen+2)     := @G.ov.exit - @G.dummy
      G.stinit!((m.st.walk-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.walk-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.walk-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.walk-1)*m.st.barlen+6) := @G.nw.init2 - @G.dummy
    G.stinit!((m.st.walmove-1)*m.st.barlen+1)      := @G.nw.init2 - @G.dummy
     G.stinit!((m.st.walmove-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.walmove-1)*m.st.barlen+3)    := @G.nw.goleft - @G.dummy
       G.stinit!((m.st.walmove-1)*m.st.barlen+4)   := @G.nw.goforward - @G.dummy
        G.stinit!((m.st.walmove-1)*m.st.barlen+5)  := @G.nw.goback - @G.dummy
         G.stinit!((m.st.walmove-1)*m.st.barlen+6) := @G.nw.goright - @G.dummy
    G.stinit!((m.st.wplan1-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.wplan1-1)*m.st.barlen+2)     := @G.nw.init - @G.dummy
      G.stinit!((m.st.wplan1-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.wplan1-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.wplan1-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.wplan1-1)*m.st.barlen+6) := 0
    G.stinit!((m.st.wplan2-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.wplan2-1)*m.st.barlen+2)     := @G.nw.init - @G.dummy
      G.stinit!((m.st.wplan2-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.wplan2-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.wplan2-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.wplan2-1)*m.st.barlen+6) := 0
    G.stinit!((m.st.detail-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.detail-1)*m.st.barlen+2)     := @G.ov.exit - @G.dummy
      G.stinit!((m.st.detail-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.detail-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.detail-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.detail-1)*m.st.barlen+6) := 0

// Gallery ini routines on changing state

    G.stinit!((m.st.gallery-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.gallery-1)*m.st.barlen+2)     := @G.nw.init2 - @G.dummy
      G.stinit!((m.st.gallery-1)*m.st.barlen+3)    := 0 //removed area 14.01.88
       G.stinit!((m.st.gallery-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.gallery-1)*m.st.barlen+5)  := @G.nt.conini - @G.dummy
         G.stinit!((m.st.gallery-1)*m.st.barlen+6) := @G.nf.eInit - @G.dummy
    G.stinit!((m.st.galmove-1)*m.st.barlen+1)      := @G.nw.init2 - @G.dummy
     G.stinit!((m.st.galmove-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.galmove-1)*m.st.barlen+3)    := @G.nw.goleft - @G.dummy
       G.stinit!((m.st.galmove-1)*m.st.barlen+4)   := @G.nw.goforward - @G.dummy
        G.stinit!((m.st.galmove-1)*m.st.barlen+5)  := @G.nw.goback - @G.dummy
         G.stinit!((m.st.galmove-1)*m.st.barlen+6) := @G.nw.goright - @G.dummy
    G.stinit!((m.st.gplan1-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.gplan1-1)*m.st.barlen+2)      := @G.nw.init - @G.dummy
      G.stinit!((m.st.gplan1-1)*m.st.barlen+3)     := 0
       G.stinit!((m.st.gplan1-1)*m.st.barlen+4)    := 0
        G.stinit!((m.st.gplan1-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.gplan1-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.gplan2-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.gplan2-1)*m.st.barlen+2)      := @G.nw.init - @G.dummy
      G.stinit!((m.st.gplan2-1)*m.st.barlen+3)     := 0
       G.stinit!((m.st.gplan2-1)*m.st.barlen+4)    := 0
        G.stinit!((m.st.gplan2-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.gplan2-1)*m.st.barlen+6)  := 0
$)
.
