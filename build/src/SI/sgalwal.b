//  AES SOURCE  4.87

section "Sgalwal"

/**
         SI.SGALWAL - State Inits for Gallery and Walk
         ---------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/sthd.h"
get "H/stphd.h"
get "H/sihd.h"

let g.st.sgalwal () be
$(

// Overlay name for Gallery states

    G.stover!m.st.gallery   := m.wWalk
    G.stover!m.st.galmove   := m.wWalk
    G.stover!m.st.gplan1    := m.wWalk
    G.stover!m.st.gplan2    := m.wWalk

// Transitions for states

    G.sttran!((m.st.gallery-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.gallery-1)*m.st.barlen+2)     := m.st.gplan1
      G.sttran!((m.st.gallery-1)*m.st.barlen+3)    := m.st.gplan1 //14.01.88 MH
       G.sttran!((m.st.gallery-1)*m.st.barlen+4)   := m.st.galmove
        G.sttran!((m.st.gallery-1)*m.st.barlen+5)  := m.st.conten
         G.sttran!((m.st.gallery-1)*m.st.barlen+6) := m.st.nfinde
    G.sttran!((m.st.galmove-1)*m.st.barlen+1)      := m.st.gplan2
     G.sttran!((m.st.galmove-1)*m.st.barlen+2)     := m.st.gallery
      G.sttran!((m.st.galmove-1)*m.st.barlen+3)    := m.st.galmove
       G.sttran!((m.st.galmove-1)*m.st.barlen+4)   := m.st.galmove
        G.sttran!((m.st.galmove-1)*m.st.barlen+5)  := m.st.galmove
         G.sttran!((m.st.galmove-1)*m.st.barlen+6) := m.st.galmove
    G.sttran!((m.st.gplan1-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.gplan1-1)*m.st.barlen+2)     := m.st.gallery
      G.sttran!((m.st.gplan1-1)*m.st.barlen+3)    := m.st.gplan1
       G.sttran!((m.st.gplan1-1)*m.st.barlen+4)   := m.st.gplan1
        G.sttran!((m.st.gplan1-1)*m.st.barlen+5)  := m.st.gplan1
         G.sttran!((m.st.gplan1-1)*m.st.barlen+6) := m.st.gplan1
    G.sttran!((m.st.gplan2-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.gplan2-1)*m.st.barlen+2)     := m.st.galmove
      G.sttran!((m.st.gplan2-1)*m.st.barlen+3)    := m.st.gplan2
       G.sttran!((m.st.gplan2-1)*m.st.barlen+4)   := m.st.gplan2
        G.sttran!((m.st.gplan2-1)*m.st.barlen+5)  := m.st.gplan2
         G.sttran!((m.st.gplan2-1)*m.st.barlen+6) := m.st.gplan2

// menu bar words

    G.stmenu!((m.st.gallery-1)*m.st.barlen+1)     := (180 << 7) | m.wHelp
     G.stmenu!((m.st.gallery-1)*m.st.barlen+2)    := (180 << 7) | m.wPlan
      G.stmenu!((m.st.gallery-1)*m.st.barlen+3)   := (188 << 7) | m.wBlank 
                                     //area removed 14.01.88 MH
       G.stmenu!((m.st.gallery-1)*m.st.barlen+4)  := (192 << 7) | m.wMove
        G.stmenu!((m.st.gallery-1)*m.st.barlen+5) := (292 << 7) | m.wContents
         G.stmenu!((m.st.gallery-1)*m.st.barlen+6):= (168 << 7) | m.wFind
    G.stmenu!((m.st.galmove-1)*m.st.barlen+1)     := (272 << 7) | m.wPlanHelp
     G.stmenu!((m.st.galmove-1)*m.st.barlen+2)    := (144 << 7) | m.wMain
      G.stmenu!((m.st.galmove-1)*m.st.barlen+3)   := (200 << 7) | m.wLmove
       G.stmenu!((m.st.galmove-1)*m.st.barlen+4)  := (236 << 7) | m.wForward
        G.stmenu!((m.st.galmove-1)*m.st.barlen+5) := (148 << 7) | m.wBack
         G.stmenu!((m.st.galmove-1)*m.st.barlen+6):= (200 << 7) | m.wRmove
    G.stmenu!((m.st.gplan1-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.gplan1-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.gplan1-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.gplan1-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.gplan1-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.gplan1-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank
    G.stmenu!((m.st.gplan2-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.gplan2-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.gplan2-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.gplan2-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.gplan2-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.gplan2-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank


// Overlay name for Walk states

    G.stover!m.st.walk      := m.wWalk
    G.stover!m.st.walmove   := m.wWalk
    G.stover!m.st.wplan1    := m.wWalk
    G.stover!m.st.wplan2    := m.wWalk
    G.stover!m.st.detail    := m.wWalk

// menu words

    G.stmenu!((m.st.walk-1)*m.st.barlen+1)        := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.walk-1)*m.st.barlen+2)       := m.st.boxw  | m.wMain
      G.stmenu!((m.st.walk-1)*m.st.barlen+3)      := m.st.boxw  | m.wMove
       G.stmenu!((m.st.walk-1)*m.st.barlen+4)     := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.walk-1)*m.st.barlen+5)    := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.walk-1)*m.st.barlen+6)   := m.st.boxw  | m.wPlan
    G.stmenu!((m.st.walmove-1)*m.st.barlen+1)     := (272 << 7) | m.wPlanHelp
     G.stmenu!((m.st.walmove-1)*m.st.barlen+2)    := (144 << 7) | m.wMain
      G.stmenu!((m.st.walmove-1)*m.st.barlen+3)   := (200 << 7) | m.wLmove
       G.stmenu!((m.st.walmove-1)*m.st.barlen+4)  := (236 << 7) | m.wForward
        G.stmenu!((m.st.walmove-1)*m.st.barlen+5) := (148 << 7) | m.wBack
         G.stmenu!((m.st.walmove-1)*m.st.barlen+6):= (200 << 7) | m.wRmove
    G.stmenu!((m.st.wplan1-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.wplan1-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.wplan1-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.wplan1-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.wplan1-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.wplan1-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank
    G.stmenu!((m.st.wplan2-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.wplan2-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.wplan2-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.wplan2-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.wplan2-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.wplan2-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank
    G.stmenu!((m.st.detail-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.detail-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.detail-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.detail-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.detail-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.detail-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank

// Transitions for National Walk states

    G.sttran!((m.st.walk-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.walk-1)*m.st.barlen+2)     := m.st.walk
      G.sttran!((m.st.walk-1)*m.st.barlen+3)    := m.st.walmove
       G.sttran!((m.st.walk-1)*m.st.barlen+4)   := m.st.walk
        G.sttran!((m.st.walk-1)*m.st.barlen+5)  := m.st.walk
         G.sttran!((m.st.walk-1)*m.st.barlen+6) := m.st.wplan1
    G.sttran!((m.st.walmove-1)*m.st.barlen+1)      := m.st.wplan2
     G.sttran!((m.st.walmove-1)*m.st.barlen+2)     := m.st.walk
      G.sttran!((m.st.walmove-1)*m.st.barlen+3)    := m.st.walmove
       G.sttran!((m.st.walmove-1)*m.st.barlen+4)   := m.st.walmove
        G.sttran!((m.st.walmove-1)*m.st.barlen+5)  := m.st.walmove
         G.sttran!((m.st.walmove-1)*m.st.barlen+6) := m.st.walmove
    G.sttran!((m.st.wplan1-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.wplan1-1)*m.st.barlen+2)     := m.st.walk
      G.sttran!((m.st.wplan1-1)*m.st.barlen+3)    := m.st.wplan1
       G.sttran!((m.st.wplan1-1)*m.st.barlen+4)   := m.st.wplan1
        G.sttran!((m.st.wplan1-1)*m.st.barlen+5)  := m.st.wplan1
         G.sttran!((m.st.wplan1-1)*m.st.barlen+6) := m.st.wplan1
    G.sttran!((m.st.wplan2-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.wplan2-1)*m.st.barlen+2)     := m.st.walmove
      G.sttran!((m.st.wplan2-1)*m.st.barlen+3)    := m.st.wplan2
       G.sttran!((m.st.wplan2-1)*m.st.barlen+4)   := m.st.wplan2
        G.sttran!((m.st.wplan2-1)*m.st.barlen+5)  := m.st.wplan2
         G.sttran!((m.st.wplan2-1)*m.st.barlen+6) := m.st.wplan2
    G.sttran!((m.st.detail-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.detail-1)*m.st.barlen+2)     := m.st.detail
      G.sttran!((m.st.detail-1)*m.st.barlen+3)    := m.st.detail
       G.sttran!((m.st.detail-1)*m.st.barlen+4)   := m.st.detail
        G.sttran!((m.st.detail-1)*m.st.barlen+5)  := m.st.detail
         G.sttran!((m.st.detail-1)*m.st.barlen+6) := m.st.detail
$)
.





