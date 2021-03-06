//  AES SOURCE  4.87

section "Sexam"

/**
         SI.SEXAM - State Inits for Nat. Examination
         -------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         State & words inits for NC, NE, NP, NV.

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         05.01.88    2     MH       Updated national chart for download
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/sthd.h"
get "H/stphd.h"
get "H/sihd.h"


let g.st.sexam () be
$(
    G.sttran!((m.st.nphoto-1)*m.st.barlen+1)      := m.st.help    //nat. photo
     G.sttran!((m.st.nphoto-1)*m.st.barlen+2)     := m.st.nphoto
      G.sttran!((m.st.nphoto-1)*m.st.barlen+3)    := m.st.nphoto
       G.sttran!((m.st.nphoto-1)*m.st.barlen+4)   := m.st.nphoto
        G.sttran!((m.st.nphoto-1)*m.st.barlen+5)  := m.st.nphoto
         G.sttran!((m.st.nphoto-1)*m.st.barlen+6) := m.st.nphoto
    G.sttran!((m.st.ntext-1)*m.st.barlen+1)       := m.st.help   //nat. essay
     G.sttran!((m.st.ntext-1)*m.st.barlen+2)      := m.st.ntext
      G.sttran!((m.st.ntext-1)*m.st.barlen+3)     := m.st.ntext
       G.sttran!((m.st.ntext-1)*m.st.barlen+4)    := m.st.ntext
        G.sttran!((m.st.ntext-1)*m.st.barlen+5)   := m.st.ntext
         G.sttran!((m.st.ntext-1)*m.st.barlen+6)  := m.st.ntext
    G.sttran!((m.st.chart-1)*m.st.barlen+1)       := m.st.help    //nat. chart
     G.sttran!((m.st.chart-1)*m.st.barlen+2)      := m.st.chart
      G.sttran!((m.st.chart-1)*m.st.barlen+3)     := m.st.chart
       G.sttran!((m.st.chart-1)*m.st.barlen+4)    := m.st.rchart
        G.sttran!((m.st.chart-1)*m.st.barlen+5)   := m.st.chart
         G.sttran!((m.st.chart-1)*m.st.barlen+6)  := m.st.chart
    G.sttran!((m.st.rchart-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.rchart-1)*m.st.barlen+2)     := m.st.rchart
      G.sttran!((m.st.rchart-1)*m.st.barlen+3)    := m.st.chart
       G.sttran!((m.st.rchart-1)*m.st.barlen+4)   := m.st.rchart
        G.sttran!((m.st.rchart-1)*m.st.barlen+5)  := m.st.rchart
         G.sttran!((m.st.rchart-1)*m.st.barlen+6) := m.st.rchart
    G.sttran!((m.st.film-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.film-1)*m.st.barlen+2)     := m.st.film
      G.sttran!((m.st.film-1)*m.st.barlen+3)    := m.st.film
       G.sttran!((m.st.film-1)*m.st.barlen+4)   := m.st.film
        G.sttran!((m.st.film-1)*m.st.barlen+5)  := m.st.film
         G.sttran!((m.st.film-1)*m.st.barlen+6) := m.st.film

    G.stover!m.st.nphoto    := m.wPhoto
    G.stover!m.st.ntext     := m.wText
    G.stover!m.st.chart     := m.wChart
    G.stover!m.st.rchart    := m.wChart
    G.stover!m.st.film      := m.wFilm

    G.stmenu!((m.st.nphoto-1)*m.st.barlen+1)      := (148 << 7) | m.wHelp
     G.stmenu!((m.st.nphoto-1)*m.st.barlen+2)     := (152 << 7) | m.wMain
      G.stmenu!((m.st.nphoto-1)*m.st.barlen+3)    := (332 << 7) | m.wDescription
       G.stmenu!((m.st.nphoto-1)*m.st.barlen+4)   := (228 << 7) | m.wCaption
        G.stmenu!((m.st.nphoto-1)*m.st.barlen+5)  := (172 << 7) | m.wPrint
         G.stmenu!((m.st.nphoto-1)*m.st.barlen+6) := (168 << 7) | m.wIndex
    G.stmenu!((m.st.ntext-1)*m.st.barlen+1)       := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.ntext-1)*m.st.barlen+2)      := m.st.boxw  | m.wMain
      G.stmenu!((m.st.ntext-1)*m.st.barlen+3)     := m.st.boxw  | m.wFirst
       G.stmenu!((m.st.ntext-1)*m.st.barlen+4)    := m.st.boxw  | m.wEnd
        G.stmenu!((m.st.ntext-1)*m.st.barlen+5)   := m.st.boxw  | m.wPrint
         G.stmenu!((m.st.ntext-1)*m.st.barlen+6)  := m.st.boxw  | m.wWrite
    G.stmenu!((m.st.chart-1)*m.st.barlen+1)       := (156 << 7) | m.wHelp
     G.stmenu!((m.st.chart-1)*m.st.barlen+2)      := (156 << 7) | m.wMain
      G.stmenu!((m.st.chart-1)*m.st.barlen+3)     := (220 << 7) | m.wReplot
       G.stmenu!((m.st.chart-1)*m.st.barlen+4)    := (256 << 7) | m.wRegroup
        G.stmenu!((m.st.chart-1)*m.st.barlen+5)   := (256 << 7) | m.wDownload
         G.stmenu!((m.st.chart-1)*m.st.barlen+6)  := (156 << 7) | m.wText
    G.stmenu!((m.st.rchart-1)*m.st.barlen+1)      := (164 << 7) | m.wHelp
     G.stmenu!((m.st.rchart-1)*m.st.barlen+2)     := (164 << 7) | m.wMain
      G.stmenu!((m.st.rchart-1)*m.st.barlen+3)    := (220 << 7) | m.wReplot
       G.stmenu!((m.st.rchart-1)*m.st.barlen+4)   := (296 << 7) | m.wContinue
        G.stmenu!((m.st.rchart-1)*m.st.barlen+5)  := (200 << 7) | m.wSplit
         G.stmenu!((m.st.rchart-1)*m.st.barlen+6) := (156 << 7) | m.wBlank
    G.stmenu!((m.st.film-1)*m.st.barlen+1)        := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.film-1)*m.st.barlen+2)       := m.st.boxw  | m.wMain
      G.stmenu!((m.st.film-1)*m.st.barlen+3)      := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.film-1)*m.st.barlen+4)     := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.film-1)*m.st.barlen+5)    := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.film-1)*m.st.barlen+6)   := m.st.boxw  | m.wBlank
$)
.
