//  AES SOURCE  4.87

section "Rsear"

/**
         SI.RSEAR - Routine Inits for National Searching States
         ------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         Handles action and init routine table initialisations
         for NA, NF, NT.

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         14.01.88    2     MH       area removed from find and contents
                                    and removed gallery, find and contents 
                                    from area
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glHEhd.h"
get "GH/glNAhd.h"
get "GH/glNFhd.h"
get "GH/glNThd.h"
get "GH/glNWhd.h"
get "GH/glNMhd.h"
get "H/sthd.h"
get "H/stphd.h"


let g.st.rsear () be
$(

//  action routines when in state

    G.stactr!m.st.conten := @G.nt.Content - @G.dummy

    G.stactr!m.st.uarea  := @G.na.Area - @G.dummy
    G.stactr!m.st.area   := @G.na.Area - @G.dummy

    G.stactr!m.st.nfinde := @G.nf.eAction - @G.dummy
    G.stactr!m.st.nfindm := @G.nf.mAction - @G.dummy
    G.stactr!m.st.nfindr := @G.nf.rAction - @G.dummy


// ini routines for changing state

    G.stinit!((m.st.conten-1)*m.st.barlen+1)      := @G.he.Helpini - @G.dummy
     G.stinit!((m.st.conten-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.conten-1)*m.st.barlen+3)    := 0 //area removed 14.01.88
       G.stinit!((m.st.conten-1)*m.st.barlen+4)   := @G.nw.init0 - @G.dummy
        G.stinit!((m.st.conten-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.conten-1)*m.st.barlen+6) := @G.nf.eInit - @G.dummy

    G.stinit!((m.st.nfinde-1)*m.st.barlen+1)      := 0
     G.stinit!((m.st.nfinde-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.nfinde-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.nfinde-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.nfinde-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.nfinde-1)*m.st.barlen+6) := 0
    G.stinit!((m.st.nfindm-1)*m.st.barlen+1)      := @G.he.Helpini - @G.dummy
     G.stinit!((m.st.nfindm-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.nfindm-1)*m.st.barlen+3)    := 0 //area removed 14.01.88
       G.stinit!((m.st.nfindm-1)*m.st.barlen+4)   := @G.nw.init0 - @G.dummy
        G.stinit!((m.st.nfindm-1)*m.st.barlen+5)  := @G.nt.Conini - @G.dummy
         G.stinit!((m.st.nfindm-1)*m.st.barlen+6) := @G.nf.rInit - @G.dummy
    G.stinit!((m.st.nfindr-1)*m.st.barlen+1)      := @G.he.Helpini - @G.dummy
     G.stinit!((m.st.nfindr-1)*m.st.barlen+2)     := @G.nf.mInit - @G.dummy
      G.stinit!((m.st.nfindr-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.nfindr-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.nfindr-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.nfindr-1)*m.st.barlen+6) := 0

    G.stinit!((m.st.uarea-1)*m.st.barlen+1)     := @G.he.Helpini - @G.dummy
     G.stinit!((m.st.uarea-1)*m.st.barlen+2)    := @G.nm.map.to.com - @G.dummy
                                               //added 14.01.88 MH
      G.stinit!((m.st.uarea-1)*m.st.barlen+3)   := @g.na.areaini - @G.dummy
       G.stinit!((m.st.uarea-1)*m.st.barlen+4)  := 0  //delete 14.01.88
        G.stinit!((m.st.uarea-1)*m.st.barlen+5) := 0
         G.stinit!((m.st.uarea-1)*m.st.barlen+6):= 0
    G.stinit!((m.st.area-1)*m.st.barlen+1)      := @G.he.Helpini - @G.dummy
     G.stinit!((m.st.area-1)*m.st.barlen+2)     := @G.ov.exit - @G.dummy
      G.stinit!((m.st.area-1)*m.st.barlen+3)    := @G.na.Areaini - @G.dummy
       G.stinit!((m.st.area-1)*m.st.barlen+4)   := @G.nw.init0 - @G.dummy
        G.stinit!((m.st.area-1)*m.st.barlen+5)  := @G.nt.Conini - @G.dummy
         G.stinit!((m.st.area-1)*m.st.barlen+6) := @G.nf.eInit - @G.dummy
$)
.
