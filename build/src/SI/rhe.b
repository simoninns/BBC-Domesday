//  AES SOURCE  4.87

section "Rhe"

/**
         SI.RHE - Routine Inits for HE
         -----------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         1.5.87      2     DNH      G.he.exit -> G.ov.helpexit
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sthd.h"
get "H/stphd.h"




let g.st.rhe () be
$(

//  action routines when in state

    G.stactr!m.st.help   := @G.he.help - @G.dummy
    G.stactr!m.st.helptxt:= @G.he.text - @G.dummy
    G.stactr!m.st.areal  := @G.he.areal - @G.dummy
    G.stactr!m.st.demo   := @G.he.demo - @G.dummy
    G.stactr!m.st.book   := @G.he.book - @G.dummy
    G.stactr!m.st.config := @G.he.config - @G.dummy

//  ini routine on changing state

    G.stinit!((m.st.help-1)*m.st.barlen+1)     := @G.ov.helpexit - @G.dummy
     G.stinit!((m.st.help-1)*m.st.barlen+2)    := @G.he.textini - @G.dummy
      G.stinit!((m.st.help-1)*m.st.barlen+3)   := @G.he.demoini - @G.dummy
       G.stinit!((m.st.help-1)*m.st.barlen+4)  := @G.he.bookini - @G.dummy
        G.stinit!((m.st.help-1)*m.st.barlen+5) := @G.he.configini - @G.dummy
         G.stinit!((m.st.help-1)*m.st.barlen+6):= @G.he.arealini - @G.dummy
    G.stinit!((m.st.helptxt-1)*m.st.barlen+1)     := @G.ov.helpexit - @G.dummy
     G.stinit!((m.st.helptxt-1)*m.st.barlen+2)    := @G.he.to.main - @G.dummy
      G.stinit!((m.st.helptxt-1)*m.st.barlen+3)   := 0
       G.stinit!((m.st.helptxt-1)*m.st.barlen+4)  := 0
        G.stinit!((m.st.helptxt-1)*m.st.barlen+5) := 0
         G.stinit!((m.st.helptxt-1)*m.st.barlen+6):= 0
    G.stinit!((m.st.areal-1)*m.st.barlen+1)     := @G.ov.helpexit - @G.dummy
     G.stinit!((m.st.areal-1)*m.st.barlen+2)    := @G.he.to.main - @G.dummy
      G.stinit!((m.st.areal-1)*m.st.barlen+3)   := @G.he.demoini - @G.dummy
       G.stinit!((m.st.areal-1)*m.st.barlen+4)  := @G.he.bookini - @G.dummy
        G.stinit!((m.st.areal-1)*m.st.barlen+5) := @G.he.configini - @G.dummy
         G.stinit!((m.st.areal-1)*m.st.barlen+6):= 0
    G.stinit!((m.st.demo-1)*m.st.barlen+1)     := @G.ov.helpexit - @G.dummy
     G.stinit!((m.st.demo-1)*m.st.barlen+2)    := @G.he.to.main - @G.dummy
      G.stinit!((m.st.demo-1)*m.st.barlen+3)   := 0
       G.stinit!((m.st.demo-1)*m.st.barlen+4)  := 0
        G.stinit!((m.st.demo-1)*m.st.barlen+5) := 0
         G.stinit!((m.st.demo-1)*m.st.barlen+6):= 0
    G.stinit!((m.st.book-1)*m.st.barlen+1)     := @G.ov.helpexit - @G.dummy
     G.stinit!((m.st.book-1)*m.st.barlen+2)    := @G.he.to.main - @G.dummy
      G.stinit!((m.st.book-1)*m.st.barlen+3)   := @G.he.setmark - @G.dummy
       G.stinit!((m.st.book-1)*m.st.barlen+4)  := @G.he.savemark - @G.dummy
        G.stinit!((m.st.book-1)*m.st.barlen+5) := @G.ov.helpexit - @G.dummy
         G.stinit!((m.st.book-1)*m.st.barlen+6):= @G.he.loadmark - @G.dummy
    G.stinit!((m.st.config-1)*m.st.barlen+1)     := @G.ov.helpexit - @G.dummy
     G.stinit!((m.st.config-1)*m.st.barlen+2)    := @G.he.to.main - @G.dummy
      G.stinit!((m.st.config-1)*m.st.barlen+3)   := 0
       G.stinit!((m.st.config-1)*m.st.barlen+4)  := 0
        G.stinit!((m.st.config-1)*m.st.barlen+5) := 0
         G.stinit!((m.st.config-1)*m.st.barlen+6):= 0
$)
.

















