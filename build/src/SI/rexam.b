//  AES SOURCE  4.87

section "Rexam"

/**
         SI.REXAM - Routine Inits for NC, NE, NP, NV
         -------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glHEhd.h"
get "GH/glNChd.h"
get "GH/glNEhd.h"
get "GH/glNPhd.h"
get "GH/glNVhd.h"
get "H/sthd.h"
get "H/stphd.h"



let g.st.rexam () be
$(

//  action routines when in state

    G.stactr!m.st.chart  := @G.nc.chart - @G.dummy
    G.stactr!m.st.rchart := @G.nc.regroup.chart - @G.dummy

    G.stactr!m.st.film   := @G.nv.film - @G.dummy

    G.stactr!m.st.nphoto := @G.np.photo - @G.dummy
    G.stactr!m.st.ntext  := @G.ne.essay - @G.dummy

// ini routine in changing state

    G.stinit!((m.st.nphoto-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.nphoto-1)*m.st.barlen+2)     := @G.ov.exit - @G.dummy
      G.stinit!((m.st.nphoto-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.nphoto-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.nphoto-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.nphoto-1)*m.st.barlen+6) := 0
    G.stinit!((m.st.ntext-1)*m.st.barlen+1)       := @G.he.helpini - @G.dummy
     G.stinit!((m.st.ntext-1)*m.st.barlen+2)      := @G.ov.exit - @G.dummy
      G.stinit!((m.st.ntext-1)*m.st.barlen+3)     := 0
       G.stinit!((m.st.ntext-1)*m.st.barlen+4)    := 0
        G.stinit!((m.st.ntext-1)*m.st.barlen+5)   := 0
         G.stinit!((m.st.ntext-1)*m.st.barlen+6)  := 0
    G.stinit!((m.st.chart-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.chart-1)*m.st.barlen+2)     := @G.ov.exit - @G.dummy
      G.stinit!((m.st.chart-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.chart-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.chart-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.chart-1)*m.st.barlen+6) := 0
    G.stinit!((m.st.rchart-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.rchart-1)*m.st.barlen+2)     := 0
      G.stinit!((m.st.rchart-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.rchart-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.rchart-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.rchart-1)*m.st.barlen+6) := 0
    G.stinit!((m.st.film-1)*m.st.barlen+1)      := @G.he.helpini - @G.dummy
     G.stinit!((m.st.film-1)*m.st.barlen+2)     := @G.ov.exit - @G.dummy
      G.stinit!((m.st.film-1)*m.st.barlen+3)    := 0
       G.stinit!((m.st.film-1)*m.st.barlen+4)   := 0
        G.stinit!((m.st.film-1)*m.st.barlen+5)  := 0
         G.stinit!((m.st.film-1)*m.st.barlen+6) := 0
$)