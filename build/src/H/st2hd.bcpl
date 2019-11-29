//  UNI SOURCE  23.4

// /**
//       ST2HDR - STATE TABLE HEADER FILE
//       --------------------------------
//
//       Contains the constant definitions for the various states
//       that the system can be in.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       23.4.87     1     DNH      Created from PAS version
//                                  manifests for offsets
//       18.5.87     2     DNH      Fix m.st.totalsize: + 2

MANIFEST
$(

// state table offsets used to initialise table globals g.stover etc.
m.st.over.size = m.st.nostates
m.st.actr.size = m.st.nostates
m.st.tran.size = m.st.nostates * m.st.barlen
m.st.init.size = m.st.nostates * m.st.barlen
m.st.menu.size = m.st.nostates * m.st.barlen

// offsets into vector for the various components
m.st.over.offset = 2                   // (2 extra words for filetovec)
m.st.actr.offset = m.st.over.offset + m.st.over.size
m.st.tran.offset = m.st.actr.offset + m.st.actr.size
m.st.init.offset = m.st.tran.offset + m.st.tran.size
m.st.menu.offset = m.st.init.offset + m.st.init.size

// total size of getvec that is vectofile'd by STINIT and FILETOVEC'ed
// by ROOT.  The '+2' is for the 2 extra words needed by FILETOVEC.
m.st.total.size = m.st.menu.offset + m.st.menu.size + 2

$)

