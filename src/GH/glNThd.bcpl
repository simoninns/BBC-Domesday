// /**
//       GLNTHDR - GLOBALS HEADER for National Contents
//       ----------------------------------------------
//
//       This is a master system Global definition file
//       Reserved for state, routine and data globals
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       23.4.87  1        PAC      ADOPTED FOR UNI SYSTEM
//       3.6.87      2     DNH      name changes & new routines
// **/

GLOBAL
$(

// state table routines
g.nt.content        :FGNT+0  // action routine
g.nt.conini         :FGNT+1  // init routine to top of thesaurus


// main display routines
g.nt.show.terms     :FGNT+2   // show thesaurus terms
g.nt.show.items     :FGNT+3   // show items names: bottom level
g.nt.show.xrefs     :FGNT+4   // show cross references from the top
g.nt.show.xref.page :FGNT+5   // show the current cross reference page

// record read routines
g.nt.read.thes.recs :FGNT+6   // read one or more thesaurus records
g.nt.read.item.rec  :FGNT+7   // read one item record

// utility routines
      // (+9 are spare)
g.nt.is.nill32      :FGNT+10  // check for nill pointer
g.nt.xrefs.exist    :FGNT+11  // check whether xrefs exist for this term
g.nt.min            :FGNT+12  // minimum of 2 values

g.nt.trytopage      :FGNT+13  // paging of xrefs
g.nt.coni2          :FGNT+14  // restore on return from item examination state

// data globals
g.nt.s              :FGNT+15  // statics area for NT
g.nt.thes.data      :FGNT+16  // Hierarchy record and xref data storage
g.nt.item.data      :FGNT+17  // Item Names File records storage area
g.nt.menubar        :FGNT+18  // internal menubar
g.nt.thes.handle    :FGNT+19  // thesaurus ("HIERARCHY") file handle
g.nt.names.handle   :FGNT+20  // item names ("NAMES") file handle

$)

