
// /**
//       NT.HDR - NATIONAL CONTENTS DEFINITIONS
//       ----------------------------------------
//
//       This file contains manifest definitions for the display
//       of contents lists from the National disc.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       21.1.86     1     H.B.     Initial version
//       25.6.86     2     EAJ      Add reclen manifest
//       *****************************
//       29.5.87     3     DNH      CHANGES FOR UNI
//       4.6.87      4     DNH      new statics
//       *****************************
//       24.7.87     5     MH       CHANGES FOR PUK
//       27.7.87     6     MH       record size in NAMES file increased to
//                                  40 bytes per record
// **/

MANIFEST
$(

// word offsets into g.nt.s: cached statics
m.nt.curr.high.no = 0    // current highlighted list item number
m.nt.in.xref      = 1    // boolean, true if showing Xrefs
m.nt.xref.page.no = 2    // page number (from 0) of page of xrefs
m.nt.num.items    = 3    // total number of bottom level items for this term
m.nt.num.xrefs    = 4    // total number of Xref items for this term
m.nt.num.lines    = 5    // number of list lines on current screen
m.nt.check.menu   = 6    // true if menubar needs checking
m.nt.statics.size.words = 6     // getvec parameter for g.nt.s


// offsets into Thesaurus record in bytes
// see Data Structures Spec.
m.nt.father       = 0   // 4  father record 32 bit offset
m.nt.pic          = 4   // 2  unused
m.nt.text         = 6   // 4  text itemaddress for level2 node essay
m.nt.title        = 10  // 32 for title string: len, 30 chars, pad => BCPL
                        //   string but NOT necessarily 4 byte aligned
m.nt.bottomflag   = 42  // 1  bottom level flag: value 128 => bottom level
m.nt.level        = 43  // 1  level: thesaurus level
m.nt.HDPs         = 44  // 20 * 4 heir. descendent ptrs: 32 bit offsets

m.nt.xref         = 124 // 4 for xref area pointer: 32 bit offset

// size of Thesaurus (=hierarchy file) record in bytes
m.nt.thes.rec.size= 128

// size of a heirarchy descendant pointer
m.nt.HDPsize      = 4
// number of heirarchy descendant pointers
m.nt.numHDPs      = 20

// size of area for Thesaurus records: one for the current term, and a full
// page's worth of descendents.
m.nt.thes.area.size = (1+m.nt.numHDPs) * m.nt.thes.rec.size


// offset of Xref area in data vector:
m.nt.xrefpos        = m.nt.thes.rec.size

// size of xref record: a single pointer
m.nt.xref.rec.size  = 4

// max allowable number of cross references
m.nt.maxxrefs       = 500

// The Xref area and the Thes area overlap since when the xrefs are
// read all thes recs beyond the first one have been displayed and are
// no longer required.  When a getvec is called to obtain the data vector
// it should obtain enough words for
//          max (m.nt.thes.area.size, m.nt.xref.area.size)
// size of area for Xref records: 2 for length; the rest for xref records
m.nt.xref.area.size = 2 + m.nt.maxxrefs * m.nt.xref.rec.size


// offsets into Item record
m.nt.itemname     = 0    // 31 bytes of name
m.nt.itemtype     = 31   // offset of type byte in item record
m.nt.itemaddr     = 32   // 4 for itemaddress: 32 bit

// size of Item record
m.nt.item.rec.size  = 36  //
// size of NAMES item record
m.nt.NAMES.rec.size = 40  // MH 27.7.87

// number of items to make 1 screen, whether terms, items or xrefs
m.nt.max.items      = 20

// max size in bytes of any string that may be output.
// Use this for obtaining vec space for temporary buffers.
m.nt.title.size     = 40

// size in bytes of vector to store a page full of item records
m.nt.item.area.size = m.nt.max.items * m.nt.NAMES.rec.size

m.nt.must.read.data = TRUE    // flag for 'show' routines
$)

