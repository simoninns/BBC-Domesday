//  AES SOURCE  4.87

section "Scom"

/**
         SI.SCOM - State Inits for Community States
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         12.5.87     2     DNH      Add AAtext, AAtexopt
         6.7.87      3     DNH      Fix state for f5 in Find:
                                       ctext, not AAtext
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/sthd.h"
get "H/stphd.h"
get "H/sihd.h"


let g.st.scom () be
$(

//  transitions  for local disc

    G.sttran!((m.st.mapwal-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.mapwal-1)*m.st.barlen+2)      := m.st.mapopt
      G.sttran!((m.st.mapwal-1)*m.st.barlen+3)     := m.st.mapwal
       G.sttran!((m.st.mapwal-1)*m.st.barlen+4)    := m.st.cphoto
        G.sttran!((m.st.mapwal-1)*m.st.barlen+5)   := m.st.ctext
         G.sttran!((m.st.mapwal-1)*m.st.barlen+6)  := m.st.cfinde
    G.sttran!((m.st.mapopt-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.mapopt-1)*m.st.barlen+2)      := m.st.mapwal
      G.sttran!((m.st.mapopt-1)*m.st.barlen+3)     := m.st.mapsca
       G.sttran!((m.st.mapopt-1)*m.st.barlen+4)   := m.st.mapkey
        G.sttran!((m.st.mapopt-1)*m.st.barlen+5)  := m.st.mapopt
         G.sttran!((m.st.mapopt-1)*m.st.barlen+6) := m.st.mapopt
    G.sttran!((m.st.mapsca-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.mapsca-1)*m.st.barlen+2)     := m.st.mapwal
      G.sttran!((m.st.mapsca-1)*m.st.barlen+3)    := m.st.mapsca
       G.sttran!((m.st.mapsca-1)*m.st.barlen+4)   := m.st.mapsca
        G.sttran!((m.st.mapsca-1)*m.st.barlen+5)  := m.st.mapsca
         G.sttran!((m.st.mapsca-1)*m.st.barlen+6) := m.st.mapsca
    G.sttran!((m.st.mapkey-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.mapkey-1)*m.st.barlen+2)     := m.st.mapwal
      G.sttran!((m.st.mapkey-1)*m.st.barlen+3)    := m.st.mapkey
       G.sttran!((m.st.mapkey-1)*m.st.barlen+4)   := m.st.mapkey
        G.sttran!((m.st.mapkey-1)*m.st.barlen+5)  := m.st.mapkey
         G.sttran!((m.st.mapkey-1)*m.st.barlen+6) := m.st.mapkey
    G.sttran!((m.st.cphoto-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.cphoto-1)*m.st.barlen+2)     := m.st.picopt
      G.sttran!((m.st.cphoto-1)*m.st.barlen+3)    := m.st.mapwal
       G.sttran!((m.st.cphoto-1)*m.st.barlen+4)   := m.st.cphoto
        G.sttran!((m.st.cphoto-1)*m.st.barlen+5)  := m.st.ctext
         G.sttran!((m.st.cphoto-1)*m.st.barlen+6) := m.st.cfinde
    G.sttran!((m.st.picopt-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.picopt-1)*m.st.barlen+2)     := m.st.cphoto
      G.sttran!((m.st.picopt-1)*m.st.barlen+3)    := m.st.picopt
       G.sttran!((m.st.picopt-1)*m.st.barlen+4)   := m.st.picopt
        G.sttran!((m.st.picopt-1)*m.st.barlen+5)  := m.st.picopt
         G.sttran!((m.st.picopt-1)*m.st.barlen+6) := m.st.picopt
    G.sttran!((m.st.ctext-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.ctext-1)*m.st.barlen+2)     := m.st.ctexopt
      G.sttran!((m.st.ctext-1)*m.st.barlen+3)    := m.st.mapwal
       G.sttran!((m.st.ctext-1)*m.st.barlen+4)   := m.st.cphoto
        G.sttran!((m.st.ctext-1)*m.st.barlen+5)  := m.st.ctext
         G.sttran!((m.st.ctext-1)*m.st.barlen+6) := m.st.cfinde
    G.sttran!((m.st.ctexopt-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.ctexopt-1)*m.st.barlen+2)     := m.st.ctext
      G.sttran!((m.st.ctexopt-1)*m.st.barlen+3)    := m.st.ctexopt
       G.sttran!((m.st.ctexopt-1)*m.st.barlen+4)   := m.st.ctexopt
        G.sttran!((m.st.ctexopt-1)*m.st.barlen+5)  := m.st.ctexopt
         G.sttran!((m.st.ctexopt-1)*m.st.barlen+6) := m.st.ctexopt
    G.sttran!((m.st.AAtext-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.AAtext-1)*m.st.barlen+2)     := m.st.AAtexopt
      G.sttran!((m.st.AAtext-1)*m.st.barlen+3)    := m.st.mapwal
       G.sttran!((m.st.AAtext-1)*m.st.barlen+4)   := m.st.cphoto
        G.sttran!((m.st.AAtext-1)*m.st.barlen+5)  := m.st.AAtext
         G.sttran!((m.st.AAtext-1)*m.st.barlen+6) := m.st.cfinde
    G.sttran!((m.st.AAtexopt-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.AAtexopt-1)*m.st.barlen+2)     := m.st.AAtext
      G.sttran!((m.st.AAtexopt-1)*m.st.barlen+3)    := m.st.AAtexopt
       G.sttran!((m.st.AAtexopt-1)*m.st.barlen+4)   := m.st.AAtexopt
        G.sttran!((m.st.AAtexopt-1)*m.st.barlen+5)  := m.st.AAtexopt
         G.sttran!((m.st.AAtexopt-1)*m.st.barlen+6) := m.st.AAtexopt
    G.sttran!((m.st.cfinde-1)*m.st.barlen+1)      := m.st.cfinde   // find
     G.sttran!((m.st.cfinde-1)*m.st.barlen+2)     := m.st.cfinde   // entry
      G.sttran!((m.st.cfinde-1)*m.st.barlen+3)    := m.st.cfinde   // state
       G.sttran!((m.st.cfinde-1)*m.st.barlen+4)   := m.st.cfinde
        G.sttran!((m.st.cfinde-1)*m.st.barlen+5)  := m.st.cfinde
         G.sttran!((m.st.cfinde-1)*m.st.barlen+6) := m.st.cfinde
    G.sttran!((m.st.cfindm-1)*m.st.barlen+1)      := m.st.help    // find
     G.sttran!((m.st.cfindm-1)*m.st.barlen+2)     := m.st.cfindm  // main
      G.sttran!((m.st.cfindm-1)*m.st.barlen+3)    := m.st.mapwal  // state
       G.sttran!((m.st.cfindm-1)*m.st.barlen+4)   := m.st.cphoto
        G.sttran!((m.st.cfindm-1)*m.st.barlen+5)  := m.st.ctext
         G.sttran!((m.st.cfindm-1)*m.st.barlen+6) := m.st.cfindr
    G.sttran!((m.st.cfindr-1)*m.st.barlen+1)      := m.st.help    // find
     G.sttran!((m.st.cfindr-1)*m.st.barlen+2)     := m.st.cfindm  // review
      G.sttran!((m.st.cfindr-1)*m.st.barlen+3)    := m.st.cfindr  // state
       G.sttran!((m.st.cfindr-1)*m.st.barlen+4)   := m.st.cfindr
        G.sttran!((m.st.cfindr-1)*m.st.barlen+5)  := m.st.cfindr
         G.sttran!((m.st.cfindr-1)*m.st.barlen+6) := m.st.cfindr


// menu bar words for state

    G.stmenu!((m.st.mapwal-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.mapwal-1)*m.st.barlen+2)     := m.st.boxw  | m.wOptions
      G.stmenu!((m.st.mapwal-1)*m.st.barlen+3)    := m.st.boxw  | m.wOut
       G.stmenu!((m.st.mapwal-1)*m.st.barlen+4)   := m.st.boxw  | m.wPhoto
        G.stmenu!((m.st.mapwal-1)*m.st.barlen+5)  := m.st.boxw  | m.wText
         G.stmenu!((m.st.mapwal-1)*m.st.barlen+6) := m.st.boxw  | m.wFind
    G.stmenu!((m.st.mapopt-1)*m.st.barlen+1)      := (164 << 7) | m.wHelp
     G.stmenu!((m.st.mapopt-1)*m.st.barlen+2)     := (168 << 7) | m.wMain
      G.stmenu!((m.st.mapopt-1)*m.st.barlen+3)    := (192 << 7) | m.wScale
       G.stmenu!((m.st.mapopt-1)*m.st.barlen+4)   := (144 << 7) | m.wKey
        G.stmenu!((m.st.mapopt-1)*m.st.barlen+5)  := (268 << 7) | m.wGridRef
         G.stmenu!((m.st.mapopt-1)*m.st.barlen+6) := (264 << 7) | m.wBlank
    G.stmenu!((m.st.mapsca-1)*m.st.barlen+1)      := (160 << 7) | m.wHelp
     G.stmenu!((m.st.mapsca-1)*m.st.barlen+2)     := (164 << 7) | m.wMain
      G.stmenu!((m.st.mapsca-1)*m.st.barlen+3)    := (184 << 7) | m.wUnits
       G.stmenu!((m.st.mapsca-1)*m.st.barlen+4)   := (268 << 7) | m.wDistance
        G.stmenu!((m.st.mapsca-1)*m.st.barlen+5)  := (188 << 7) | m.wArea
         G.stmenu!((m.st.mapsca-1)*m.st.barlen+6) := (236 << 7) | m.wBlank
    G.stmenu!((m.st.mapkey-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.mapkey-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.mapkey-1)*m.st.barlen+3)    := m.st.boxw  | m.wFirst
       G.stmenu!((m.st.mapkey-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.mapkey-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.mapkey-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank
    G.stmenu!((m.st.cphoto-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.cphoto-1)*m.st.barlen+2)     := m.st.boxw  | m.wOptions
      G.stmenu!((m.st.cphoto-1)*m.st.barlen+3)    := m.st.boxw  | m.wMap
       G.stmenu!((m.st.cphoto-1)*m.st.barlen+4)   := m.st.boxw  | m.wCaption
        G.stmenu!((m.st.cphoto-1)*m.st.barlen+5)  := m.st.boxw  | m.wText
         G.stmenu!((m.st.cphoto-1)*m.st.barlen+6) := m.st.boxw  | m.wFind
    G.stmenu!((m.st.picopt-1)*m.st.barlen+1)      := (148 << 7) | m.wHelp
     G.stmenu!((m.st.picopt-1)*m.st.barlen+2)     := (152 << 7) | m.wMain
      G.stmenu!((m.st.picopt-1)*m.st.barlen+3)    := (332 << 7) | m.wDescription
       G.stmenu!((m.st.picopt-1)*m.st.barlen+4)   := (228 << 7) | m.wCaption
        G.stmenu!((m.st.picopt-1)*m.st.barlen+5)  := (172 << 7) | m.wPrint
         G.stmenu!((m.st.picopt-1)*m.st.barlen+6) := (168 << 7) | m.wWrite
    G.stmenu!((m.st.ctext-1)*m.st.barlen+1)       := (164 << 7) | m.wHelp
     G.stmenu!((m.st.ctext-1)*m.st.barlen+2)      := (244 << 7) | m.wOptions
      G.stmenu!((m.st.ctext-1)*m.st.barlen+3)     := (148 << 7) | m.wMap
       G.stmenu!((m.st.ctext-1)*m.st.barlen+4)    := (196 << 7) | m.wPhoto
        G.stmenu!((m.st.ctext-1)*m.st.barlen+5)   := (276 << 7) | m.wIndex
         G.stmenu!((m.st.ctext-1)*m.st.barlen+6)  := (172 << 7) | m.wFind
    G.stmenu!((m.st.ctexopt-1)*m.st.barlen+1)     := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.ctexopt-1)*m.st.barlen+2)    := m.st.boxw  | m.wMain
      G.stmenu!((m.st.ctexopt-1)*m.st.barlen+3)   := m.st.boxw  | m.wFirst
       G.stmenu!((m.st.ctexopt-1)*m.st.barlen+4)  := m.st.boxw  | m.wEnd
        G.stmenu!((m.st.ctexopt-1)*m.st.barlen+5) := m.st.boxw  | m.wPrint
         G.stmenu!((m.st.ctexopt-1)*m.st.barlen+6):= m.st.boxw  | m.wWrite
    G.stmenu!((m.st.AAtext-1)*m.st.barlen+1)       := (164 << 7) | m.wHelp
     G.stmenu!((m.st.AAtext-1)*m.st.barlen+2)      := (244 << 7) | m.wOptions
      G.stmenu!((m.st.AAtext-1)*m.st.barlen+3)     := (148 << 7) | m.wMap
       G.stmenu!((m.st.AAtext-1)*m.st.barlen+4)    := (196 << 7) | m.wPhoto
        G.stmenu!((m.st.AAtext-1)*m.st.barlen+5)   := (276 << 7) | m.wIndex
         G.stmenu!((m.st.AAtext-1)*m.st.barlen+6)  := (172 << 7) | m.wFind
    G.stmenu!((m.st.AAtexopt-1)*m.st.barlen+1)     := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.AAtexopt-1)*m.st.barlen+2)    := m.st.boxw  | m.wMain
      G.stmenu!((m.st.AAtexopt-1)*m.st.barlen+3)   := m.st.boxw  | m.wFirst
       G.stmenu!((m.st.AAtexopt-1)*m.st.barlen+4)  := m.st.boxw  | m.wEnd
        G.stmenu!((m.st.AAtexopt-1)*m.st.barlen+5) := m.st.boxw  | m.wPrint
         G.stmenu!((m.st.AAtexopt-1)*m.st.barlen+6):= m.st.boxw  | m.wWrite
    G.stmenu!((m.st.cfinde-1)*m.st.barlen+1)      := m.st.boxw  | m.wBlank
     G.stmenu!((m.st.cfinde-1)*m.st.barlen+2)     := m.st.boxw  | m.wBlank
      G.stmenu!((m.st.cfinde-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.cfinde-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.cfinde-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.cfinde-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank
    G.stmenu!((m.st.cfindm-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.cfindm-1)*m.st.barlen+2)     := m.st.boxw  | m.wBlank
      G.stmenu!((m.st.cfindm-1)*m.st.barlen+3)    := m.st.boxw  | m.wMap
       G.stmenu!((m.st.cfindm-1)*m.st.barlen+4)   := m.st.boxw  | m.wPhoto
        G.stmenu!((m.st.cfindm-1)*m.st.barlen+5)  := m.st.boxw  | m.wText
         G.stmenu!((m.st.cfindm-1)*m.st.barlen+6) := m.st.boxw  | m.wOld
    G.stmenu!((m.st.cfindr-1)*m.st.barlen+1)      := m.st.boxw  | m.wHelp
     G.stmenu!((m.st.cfindr-1)*m.st.barlen+2)     := m.st.boxw  | m.wMain
      G.stmenu!((m.st.cfindr-1)*m.st.barlen+3)    := m.st.boxw  | m.wBlank
       G.stmenu!((m.st.cfindr-1)*m.st.barlen+4)   := m.st.boxw  | m.wBlank
        G.stmenu!((m.st.cfindr-1)*m.st.barlen+5)  := m.st.boxw  | m.wBlank
         G.stmenu!((m.st.cfindr-1)*m.st.barlen+6) := m.st.boxw  | m.wBlank


// overlay name for state

    G.stover!m.st.startstop := m.wBlank
    G.stover!m.st.mapwal    := m.wMap
    G.stover!m.st.mapopt    := m.wMap
    G.stover!m.st.mapsca    := m.wMap
    G.stover!m.st.mapkey    := m.wMap
    G.stover!m.st.cphoto    := m.wPhtx
    G.stover!m.st.picopt    := m.wPhtx
    G.stover!m.st.ctext     := m.wPhtx
    G.stover!m.st.ctexopt   := m.wPhtx
    G.stover!m.st.AAtext    := m.wPhtx
    G.stover!m.st.AAtexopt  := m.wPhtx
    G.stover!m.st.cfinde    := m.wFind
    G.stover!m.st.cfindm    := m.wFind
    G.stover!m.st.cfindr    := m.wFind
$)
.
