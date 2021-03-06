//  AES SOURCE  4.87

section "Ssear"

/**
         SI.SSEAR - State Inits for Nat Searching States
         -----------------------------------------------

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


let g.st.ssear () be
$(

// NT

    G.stover!m.st.conten    := m.wContents

    G.stmenu!((m.st.conten-1)*m.st.barlen+1)      := (172 << 7) | m.wHelp
     G.stmenu!((m.st.conten-1)*m.st.barlen+2)     := (124 << 7) | m.wUp
      G.stmenu!((m.st.conten-1)*m.st.barlen+3)    := (180 << 7) | m.wBlank
             //area removed 14.01.88 MH
       G.stmenu!((m.st.conten-1)*m.st.barlen+4)   := (248 << 7) | m.wGallery
        G.stmenu!((m.st.conten-1)*m.st.barlen+5)  := (312 << 7) | m.wCrossRef
         G.stmenu!((m.st.conten-1)*m.st.barlen+6) := (164 << 7) | m.wFind

    G.sttran!((m.st.conten-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.conten-1)*m.st.barlen+2)     := m.st.conten
      G.sttran!((m.st.conten-1)*m.st.barlen+3)    := m.st.conten
       G.sttran!((m.st.conten-1)*m.st.barlen+4)   := m.st.gallery
        G.sttran!((m.st.conten-1)*m.st.barlen+5)  := m.st.conten
         G.sttran!((m.st.conten-1)*m.st.barlen+6) := m.st.nfinde

// NF

    G.stover!m.st.nfinde    := m.wNatFind
    G.stover!m.st.nfindm    := m.wNatFind
    G.stover!m.st.nfindr    := m.wNatFind

    G.stmenu!((m.st.nfinde-1)*m.st.barlen+1)      := m.st.boxw  | m.wBlank
     G.stmenu!((m.st.nfinde-1)*m.st.barlen+2)     := m.st.boxw  | m.wBlank
      G.stmenu!((m.st.nfinde-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.nfinde-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.nfinde-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.nfinde-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank
    G.stmenu!((m.st.nfindm-1)*m.st.barlen+1)      := (152 << 7) | m.wHelp
     G.stmenu!((m.st.nfindm-1)*m.st.barlen+2)     := (244 << 7) | m.wBlank
      G.stmenu!((m.st.nfindm-1)*m.st.barlen+3)    := (160 << 7) | m.wBlank 
          // area removed 14.01.88 MH
       G.stmenu!((m.st.nfindm-1)*m.st.barlen+4)   := (228 << 7) | m.wGallery
        G.stmenu!((m.st.nfindm-1)*m.st.barlen+5)  := (264 << 7) | m.wContents
         G.stmenu!((m.st.nfindm-1)*m.st.barlen+6) := (152 << 7) | m.wOld
    G.stmenu!((m.st.nfindr-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.nfindr-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.nfindr-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.nfindr-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.nfindr-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.nfindr-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank

    G.sttran!((m.st.nfinde-1)*m.st.barlen+1)      := m.st.nfinde
     G.sttran!((m.st.nfinde-1)*m.st.barlen+2)     := m.st.nfinde
      G.sttran!((m.st.nfinde-1)*m.st.barlen+3)    := m.st.nfinde
       G.sttran!((m.st.nfinde-1)*m.st.barlen+4)   := m.st.nfinde
        G.sttran!((m.st.nfinde-1)*m.st.barlen+5)  := m.st.nfinde
         G.sttran!((m.st.nfinde-1)*m.st.barlen+6) := m.st.nfinde
    G.sttran!((m.st.nfindm-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.nfindm-1)*m.st.barlen+2)     := m.st.nfindm
      G.sttran!((m.st.nfindm-1)*m.st.barlen+3)    := m.st.nfindm
                      // area removed 14.01.88 MH
       G.sttran!((m.st.nfindm-1)*m.st.barlen+4)   := m.st.gallery
        G.sttran!((m.st.nfindm-1)*m.st.barlen+5)  := m.st.conten
         G.sttran!((m.st.nfindm-1)*m.st.barlen+6) := m.st.nfindr
    G.sttran!((m.st.nfindr-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.nfindr-1)*m.st.barlen+2)     := m.st.nfindm
      G.sttran!((m.st.nfindr-1)*m.st.barlen+3)    := m.st.nfindr
       G.sttran!((m.st.nfindr-1)*m.st.barlen+4)   := m.st.nfindr
        G.sttran!((m.st.nfindr-1)*m.st.barlen+5)  := m.st.nfindr
         G.sttran!((m.st.nfindr-1)*m.st.barlen+6) := m.st.nfindr

// NA

    G.stover!m.st.area      := m.wArea
    G.stover!m.st.uarea     := m.wArea

    G.stmenu!((m.st.area-1)*m.st.barlen+1)        := (148 << 7) | m.wHelp
     G.stmenu!((m.st.area-1)*m.st.barlen+2)       := (152 << 7) | m.wMain
      G.stmenu!((m.st.area-1)*m.st.barlen+3)      := (256 << 7) | m.wReselect
       G.stmenu!((m.st.area-1)*m.st.barlen+4)     := (228 << 7) | m.wBlank
        G.stmenu!((m.st.area-1)*m.st.barlen+5)    := (264 << 7) | m.wBlank
         G.stmenu!((m.st.area-1)*m.st.barlen+6)   := (152 << 7) | m.wBlank
                  //gallery, find and contents removed from above
    G.stmenu!((m.st.uarea-1)*m.st.barlen+1)       := (148 << 7) | m.wHelp
     G.stmenu!((m.st.uarea-1)*m.st.barlen+2)      := (148 << 7) | m.wMain
      G.stmenu!((m.st.uarea-1)*m.st.barlen+3)     := (260 << 7) | m.wReselect
       G.stmenu!((m.st.uarea-1)*m.st.barlen+4)    := (228 << 7) | m.wBlank
        G.stmenu!((m.st.uarea-1)*m.st.barlen+5)   := (264 << 7) | m.wBlank
         G.stmenu!((m.st.uarea-1)*m.st.barlen+6)  := (152 << 7) | m.wBlank

    G.sttran!((m.st.uarea-1)*m.st.barlen+1)      := m.st.help    // Unforced Area
     G.sttran!((m.st.uarea-1)*m.st.barlen+2)     := m.st.datmap
      G.sttran!((m.st.uarea-1)*m.st.barlen+3)    := m.st.uarea  
       G.sttran!((m.st.uarea-1)*m.st.barlen+4)   := m.st.uarea
        G.sttran!((m.st.uarea-1)*m.st.barlen+5)  := m.st.uarea
         G.sttran!((m.st.uarea-1)*m.st.barlen+6) := m.st.uarea
    G.sttran!((m.st.area-1)*m.st.barlen+1)      := m.st.help    // Forced Area
     G.sttran!((m.st.area-1)*m.st.barlen+2)     := m.st.area
      G.sttran!((m.st.area-1)*m.st.barlen+3)    := m.st.area
       G.sttran!((m.st.area-1)*m.st.barlen+4)   := m.st.area
        G.sttran!((m.st.area-1)*m.st.barlen+5)  := m.st.area
         G.sttran!((m.st.area-1)*m.st.barlen+6) := m.st.area
$)
.
