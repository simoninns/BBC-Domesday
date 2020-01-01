//  AES SOURCE  4.87

section "SNM"

/**
         SI.SNM - State Inits for Mappable Data
         --------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.stinit

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87     1     DNH      Created from stiniXX
         5.5.87      2     DNH      Remove mwrite, mtext
         14.01.88    3     MH       Updated for area
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/sthd.h"
get "H/stphd.h"
get "H/sihd.h"


let g.st.snm () be
$(

    G.stover!m.st.datmap    := m.wmapproc
    G.stover!m.st.manal     := m.wmapproc
    G.stover!m.st.mdetail   := m.wmapproc
    G.stover!m.st.resol     := m.wmapproc
    G.stover!m.st.mareas    := m.wmapproc
    G.stover!m.st.mclass    := m.wmapproc
    G.stover!m.st.manual    := m.wmapproc
    G.stover!m.st.autom     := m.wmapproc
    G.stover!m.st.equal     := m.wmapproc
    G.stover!m.st.nested    := m.wmapproc
    G.stover!m.st.quant     := m.wmapproc
    G.stover!m.st.retri     := m.wmapproc
    G.stover!m.st.compare   := m.wmapproc
    G.stover!m.st.rank      := m.wmapproc

//  menus for National Mappable

    G.stmenu!((m.st.datmap-1)*m.st.barlen+1)       := (160 << 7) | m.wHelp
     G.stmenu!((m.st.datmap-1)*m.st.barlen+2)      := (160 << 7) | m.wMain
      G.stmenu!((m.st.datmap-1)*m.st.barlen+3)     := (256 << 7) | m.wOptions
       G.stmenu!((m.st.datmap-1)*m.st.barlen+4)    := (256 << 7) | m.wArea
        G.stmenu!((m.st.datmap-1)*m.st.barlen+5)   := (160 << 7) | m.wText
         G.stmenu!((m.st.datmap-1)*m.st.barlen+6)  := (208 << 7) | m.wKey
    G.stmenu!((m.st.manal-1)*m.st.barlen+1)       := (152 << 7) | m.wHelp
     G.stmenu!((m.st.manal-1)*m.st.barlen+2)      := (152 << 7) | m.wMain
      G.stmenu!((m.st.manal-1)*m.st.barlen+3)     := (184 << 7) | m.wClass
       G.stmenu!((m.st.manal-1)*m.st.barlen+4)    := (216 << 7) | m.wDetail
        G.stmenu!((m.st.manal-1)*m.st.barlen+5)   := (216 << 7) | m.wWindow
         G.stmenu!((m.st.manal-1)*m.st.barlen+6)  := (280 << 7) | m.wRetrieve
    G.stmenu!((m.st.mdetail-1)*m.st.barlen+1)      := (152 << 7) | m.wHelp
     G.stmenu!((m.st.mdetail-1)*m.st.barlen+2)     := (152 << 7) | m.wMain
      G.stmenu!((m.st.mdetail-1)*m.st.barlen+3)    := (344 << 7) | m.wResolution
       G.stmenu!((m.st.mdetail-1)*m.st.barlen+4)   := (184 << 7) | m.wAreas
        G.stmenu!((m.st.mdetail-1)*m.st.barlen+5)  := (184 << 7) | m.wBlank
         G.stmenu!((m.st.mdetail-1)*m.st.barlen+6) := (184 << 7) | m.wBlank
    G.stmenu!((m.st.resol-1)*m.st.barlen+1)       := (176 << 7) | m.wHelp
     G.stmenu!((m.st.resol-1)*m.st.barlen+2)      := (176 << 7) | m.wMain
      G.stmenu!((m.st.resol-1)*m.st.barlen+3)     := (240 << 7) | m.wReplot
       G.stmenu!((m.st.resol-1)*m.st.barlen+4)    := (208 << 7) | m.wAreas
        G.stmenu!((m.st.resol-1)*m.st.barlen+5)   := (200 << 7) | m.wBlank
         G.stmenu!((m.st.resol-1)*m.st.barlen+6)  := (200 << 7) | m.wBlank
    G.stmenu!((m.st.mareas-1)*m.st.barlen+1)       := (152 << 7) | m.wHelp
     G.stmenu!((m.st.mareas-1)*m.st.barlen+2)      := (152 << 7) | m.wMain
      G.stmenu!((m.st.mareas-1)*m.st.barlen+3)     := (344 << 7) | m.wResolution
       G.stmenu!((m.st.mareas-1)*m.st.barlen+4)    := (216 << 7) | m.wReplot
        G.stmenu!((m.st.mareas-1)*m.st.barlen+5)   := (168 << 7) | m.wBlank
         G.stmenu!((m.st.mareas-1)*m.st.barlen+6)  := (168 << 7) | m.wBlank
    G.stmenu!((m.st.mclass-1)*m.st.barlen+1)       := (136 << 7) | m.wHelp
     G.stmenu!((m.st.mclass-1)*m.st.barlen+2)      := (136 << 7) | m.wMain
       G.stmenu!((m.st.mclass-1)*m.st.barlen+3)    := (200 << 7) | m.wManual
      G.stmenu!((m.st.mclass-1)*m.st.barlen+4)     := (296 << 7) | m.wAutomatic
        G.stmenu!((m.st.mclass-1)*m.st.barlen+5)   := (264 << 7) | m.wBlank
         G.stmenu!((m.st.mclass-1)*m.st.barlen+6)  := (168 << 7) | m.wBlank
    G.stmenu!((m.st.manual-1)*m.st.barlen+1)       := (152 << 7) | m.wHelp
     G.stmenu!((m.st.manual-1)*m.st.barlen+2)      := (152 << 7) | m.wMain
      G.stmenu!((m.st.manual-1)*m.st.barlen+3)     := (312 << 7) | m.wAutomatic
       G.stmenu!((m.st.manual-1)*m.st.barlen+4)    := (216 << 7) | m.wReplot
        G.stmenu!((m.st.manual-1)*m.st.barlen+5)   := (184 << 7) | m.wBlank
         G.stmenu!((m.st.manual-1)*m.st.barlen+6)  := (184 << 7) | m.wBlank
    G.stmenu!((m.st.autom-1)*m.st.barlen+1)       := (136 << 7) | m.wHelp
     G.stmenu!((m.st.autom-1)*m.st.barlen+2)      := (136 << 7) | m.wMain
      G.stmenu!((m.st.autom-1)*m.st.barlen+3)     := (176 << 7) | m.wEqual
       G.stmenu!((m.st.autom-1)*m.st.barlen+4)    := (192 << 7) | m.wNested
        G.stmenu!((m.st.autom-1)*m.st.barlen+5)   := (288 << 7) | m.wQuantiles
         G.stmenu!((m.st.autom-1)*m.st.barlen+6)  := (272 << 7) | m.wNational
    G.stmenu!((m.st.equal-1)*m.st.barlen+1)       := (136 << 7) | m.wHelp
     G.stmenu!((m.st.equal-1)*m.st.barlen+2)      := (136 << 7) | m.wMain
      G.stmenu!((m.st.equal-1)*m.st.barlen+3)     := (192 << 7) | m.wReplot
       G.stmenu!((m.st.equal-1)*m.st.barlen+4)    := (192 << 7) | m.wNested
        G.stmenu!((m.st.equal-1)*m.st.barlen+5)   := (288 << 7) | m.wQuantiles
         G.stmenu!((m.st.equal-1)*m.st.barlen+6)  := (256 << 7) | m.wNational
    G.stmenu!((m.st.nested-1)*m.st.barlen+1)       := (136 << 7) | m.wHelp
     G.stmenu!((m.st.nested-1)*m.st.barlen+2)      := (136 << 7) | m.wMain
      G.stmenu!((m.st.nested-1)*m.st.barlen+3)     := (176 << 7) | m.wEqual
       G.stmenu!((m.st.nested-1)*m.st.barlen+4)    := (192 << 7) | m.wReplot
        G.stmenu!((m.st.nested-1)*m.st.barlen+5)   := (288 << 7) | m.wQuantiles
         G.stmenu!((m.st.nested-1)*m.st.barlen+6)  := (272 << 7) | m.wNational
    G.stmenu!((m.st.quant-1)*m.st.barlen+1)       := (152 << 7) | m.wHelp
     G.stmenu!((m.st.quant-1)*m.st.barlen+2)      := (152 << 7) | m.wMain
      G.stmenu!((m.st.quant-1)*m.st.barlen+3)     := (192 << 7) | m.wEqual
       G.stmenu!((m.st.quant-1)*m.st.barlen+4)    := (216 << 7) | m.wNested
        G.stmenu!((m.st.quant-1)*m.st.barlen+5)   := (216 << 7) | m.wReplot
         G.stmenu!((m.st.quant-1)*m.st.barlen+6)  := (272 << 7) | m.wNational
    G.stmenu!((m.st.retri-1)*m.st.barlen+1)       := (144 << 7) | m.wHelp
     G.stmenu!((m.st.retri-1)*m.st.barlen+2)      := (144 << 7) | m.wMain
      G.stmenu!((m.st.retri-1)*m.st.barlen+3)     := (204 << 7) | m.wValues
       G.stmenu!((m.st.retri-1)*m.st.barlen+4)    := (152 << 7) | m.wRank
        G.stmenu!((m.st.retri-1)*m.st.barlen+5)   := (272 << 7) | m.wUnit
         G.stmenu!((m.st.retri-1)*m.st.barlen+6)  := (284 << 7) | m.wDownload
    G.stmenu!((m.st.compare-1)*m.st.barlen+1)      := (152 << 7) | m.wHelp
     G.stmenu!((m.st.compare-1)*m.st.barlen+2)     := (152 << 7) | m.wMain
      G.stmenu!((m.st.compare-1)*m.st.barlen+3)    := (280 << 7) | m.wAnalyse
       G.stmenu!((m.st.compare-1)*m.st.barlen+4)   := (152 << 7) | m.wLink
        G.stmenu!((m.st.compare-1)*m.st.barlen+5)  := (312 << 7) | m.wCorrelate
         G.stmenu!((m.st.compare-1)*m.st.barlen+6) := (152 << 7) | m.wName
    G.stmenu!((m.st.rank-1)*m.st.barlen+1)      := (200 << 7) | m.wHelp
     G.stmenu!((m.st.rank-1)*m.st.barlen+2)     := (200 << 7) | m.wMain
      G.stmenu!((m.st.rank-1)*m.st.barlen+3)    := (200 << 7) | m.wFirst
       G.stmenu!((m.st.rank-1)*m.st.barlen+4)   := (200 << 7) | m.wEnd
        G.stmenu!((m.st.rank-1)*m.st.barlen+5)  := (200 << 7) | m.wBlank
         G.stmenu!((m.st.rank-1)*m.st.barlen+6) := (200 << 7) | m.wBlank

//  next state on change

    G.sttran!((m.st.datmap-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.datmap-1)*m.st.barlen+2)      := m.st.datmap
      G.sttran!((m.st.datmap-1)*m.st.barlen+3)     := m.st.compare
       G.sttran!((m.st.datmap-1)*m.st.barlen+4)    := m.st.uarea
        G.sttran!((m.st.datmap-1)*m.st.barlen+5)   := m.st.datmap
         G.sttran!((m.st.datmap-1)*m.st.barlen+6)  := m.st.datmap
    G.sttran!((m.st.manal-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.manal-1)*m.st.barlen+2)      := m.st.compare
      G.sttran!((m.st.manal-1)*m.st.barlen+3)     := m.st.mclass
       G.sttran!((m.st.manal-1)*m.st.barlen+4)    := m.st.mdetail
        G.sttran!((m.st.manal-1)*m.st.barlen+5)   := m.st.manal
         G.sttran!((m.st.manal-1)*m.st.barlen+6)  := m.st.retri
    G.sttran!((m.st.mdetail-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.mdetail-1)*m.st.barlen+2)      := m.st.manal
      G.sttran!((m.st.mdetail-1)*m.st.barlen+3)     := m.st.resol
       G.sttran!((m.st.mdetail-1)*m.st.barlen+4)    := m.st.mareas
        G.sttran!((m.st.mdetail-1)*m.st.barlen+5)   := m.st.mdetail
         G.sttran!((m.st.mdetail-1)*m.st.barlen+6)  := m.st.mdetail
    G.sttran!((m.st.resol-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.resol-1)*m.st.barlen+2)      := m.st.manal
      G.sttran!((m.st.resol-1)*m.st.barlen+3)     := m.st.resol
       G.sttran!((m.st.resol-1)*m.st.barlen+4)    := m.st.mareas
        G.sttran!((m.st.resol-1)*m.st.barlen+5)   := m.st.resol
         G.sttran!((m.st.resol-1)*m.st.barlen+6)  := m.st.resol
    G.sttran!((m.st.mareas-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.mareas-1)*m.st.barlen+2)      := m.st.manal
      G.sttran!((m.st.mareas-1)*m.st.barlen+3)     := m.st.resol
       G.sttran!((m.st.mareas-1)*m.st.barlen+4)    := m.st.mareas
        G.sttran!((m.st.mareas-1)*m.st.barlen+5)   := m.st.mareas
         G.sttran!((m.st.mareas-1)*m.st.barlen+6)  := m.st.mareas
    G.sttran!((m.st.mclass-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.mclass-1)*m.st.barlen+2)      := m.st.manal
      G.sttran!((m.st.mclass-1)*m.st.barlen+3)     := m.st.manual
       G.sttran!((m.st.mclass-1)*m.st.barlen+4)    := m.st.autom
        G.sttran!((m.st.mclass-1)*m.st.barlen+5)   := m.st.mclass
         G.sttran!((m.st.mclass-1)*m.st.barlen+6)  := m.st.mclass
    G.sttran!((m.st.manual-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.manual-1)*m.st.barlen+2)      := m.st.mclass
      G.sttran!((m.st.manual-1)*m.st.barlen+3)     := m.st.autom
       G.sttran!((m.st.manual-1)*m.st.barlen+4)    := m.st.manual
        G.sttran!((m.st.manual-1)*m.st.barlen+5)   := m.st.manual
         G.sttran!((m.st.manual-1)*m.st.barlen+6)  := m.st.manual
    G.sttran!((m.st.autom-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.autom-1)*m.st.barlen+2)      := m.st.mclass
      G.sttran!((m.st.autom-1)*m.st.barlen+3)     := m.st.equal
       G.sttran!((m.st.autom-1)*m.st.barlen+4)    := m.st.nested
        G.sttran!((m.st.autom-1)*m.st.barlen+5)   := m.st.quant
         G.sttran!((m.st.autom-1)*m.st.barlen+6)  := m.st.autom
    G.sttran!((m.st.equal-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.equal-1)*m.st.barlen+2)      := m.st.mclass
      G.sttran!((m.st.equal-1)*m.st.barlen+3)     := m.st.autom
       G.sttran!((m.st.equal-1)*m.st.barlen+4)    := m.st.nested
        G.sttran!((m.st.equal-1)*m.st.barlen+5)   := m.st.quant
         G.sttran!((m.st.equal-1)*m.st.barlen+6)  := m.st.equal
    G.sttran!((m.st.nested-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.nested-1)*m.st.barlen+2)      := m.st.mclass
      G.sttran!((m.st.nested-1)*m.st.barlen+3)     := m.st.equal
       G.sttran!((m.st.nested-1)*m.st.barlen+4)    := m.st.autom
        G.sttran!((m.st.nested-1)*m.st.barlen+5)   := m.st.quant
         G.sttran!((m.st.nested-1)*m.st.barlen+6)  := m.st.nested
    G.sttran!((m.st.quant-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.quant-1)*m.st.barlen+2)      := m.st.mclass
      G.sttran!((m.st.quant-1)*m.st.barlen+3)     := m.st.equal
       G.sttran!((m.st.quant-1)*m.st.barlen+4)    := m.st.nested
        G.sttran!((m.st.quant-1)*m.st.barlen+5)   := m.st.autom
         G.sttran!((m.st.quant-1)*m.st.barlen+6)  := m.st.quant
    G.sttran!((m.st.retri-1)*m.st.barlen+1)       := m.st.help
     G.sttran!((m.st.retri-1)*m.st.barlen+2)      := m.st.manal
      G.sttran!((m.st.retri-1)*m.st.barlen+3)     := m.st.retri
       G.sttran!((m.st.retri-1)*m.st.barlen+4)    := m.st.rank
        G.sttran!((m.st.retri-1)*m.st.barlen+5)   := m.st.retri
         G.sttran!((m.st.retri-1)*m.st.barlen+6)  := m.st.retri
    G.sttran!((m.st.compare-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.compare-1)*m.st.barlen+2)     := m.st.datmap
      G.sttran!((m.st.compare-1)*m.st.barlen+3)    := m.st.manal
       G.sttran!((m.st.compare-1)*m.st.barlen+4)   := m.st.compare
        G.sttran!((m.st.compare-1)*m.st.barlen+5)  := m.st.compare
         G.sttran!((m.st.compare-1)*m.st.barlen+6) := m.st.compare
    G.sttran!((m.st.rank-1)*m.st.barlen+1)      := m.st.help
     G.sttran!((m.st.rank-1)*m.st.barlen+2)     := m.st.retri
      G.sttran!((m.st.rank-1)*m.st.barlen+3)    := m.st.rank
       G.sttran!((m.st.rank-1)*m.st.barlen+4)   := m.st.rank
        G.sttran!((m.st.rank-1)*m.st.barlen+5)  := m.st.rank
         G.sttran!((m.st.rank-1)*m.st.barlen+6) := m.st.rank
$)
.