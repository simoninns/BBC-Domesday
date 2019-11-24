// /**
//       CPHDR - HEADER FOR COMMUNITY PHOTO
//       ----------------------------------
//
//       Manifest definitions for the community photo
//       operation.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       25.07.86    14    PAC      Add m.cp.phosub
//       19.9.86     15    PAC      Add m.cp.data.error
//       **************************
//       6.5.87      16    DNH      CHANGES FOR UNI
//                                  word to byte offsets in data
//       8.5.87      17    DNH      new Text stuff
//       12.5.87     18    DNH      text changes
//                                  txtbuff2 scrapped
//                                  wordsize independent context
//       18.5.87     19    DNH      bugfix numbers size
// **/

MANIFEST
$(
m.cp.LHS = m.sd.disw/3      // left hand third of display
m.cp.RHS = (m.sd.disw*2)/3  // right hand third of display

// opcodes for G.cp.page
m.cp.forwards  = 1          // page forwards opcode
m.cp.back      = 2          // page back opcode

// substates in photo
m.cp.capt = 1 // short cap up
m.cp.desc = 2 // long  cap up
m.cp.none = 3 // nothing up
m.cp.data.error = -1 // error in data bundle - temporary state !

// caption lengths (in chars)
m.cp.sclength  = 30         // 30 chars per line for short caption (1 line)
m.cp.lclength  = 39         // 39 chars per line for long caption
m.cp.charwidth = 32         // 32 graphics units per character

m.cp.invalid = -1           // invalid frame number

m.cp.scXpos    = 10*m.cp.charwidth // 10 chars in
m.cp.scYpos    = m.sd.linW         // 1 line up
m.cp.lcXpos    = 3*m.cp.charwidth  // 3 chars in
m.cp.lcYpos    = 0
m.cp.EOS       = 1216              // where to place a char for Write message

m.cp.framesize = 6*1024   // in bytes: a frame has 6K of data

m.cp.print  = 1  // id codes for 2oplist
m.cp.write  = 2
m.cp.screen = 3

m.cp.invalid   = -1 // an invalid frame number for empty data buffer

// data structure sizes for schools and AA. (Not all fields relevant to AA)
m.cp.sizepageno   =   2 // length of pageno in bytes
m.cp.titlelen     =  30 // length of title including page bytes
m.cp.crossrefsize =   4 // length of crossref pointer in bytes
m.cp.pagesize     = 858 // size of a text page in bytes


// values for AA text
m.cp.header    =  39 // length of AA pageheader in bytes
m.cp.AA.textoff= 228 // offset to no of pages in AA text

// $MSC     THIS SIZE MUST BE DIVISIBLE BY BYTESPERWORD
m.cp.index.entry.size = 36 // size in bytes of a title entry in index buffer
m.cp.max.titles = 20    // max number of titles on an index/contents page

// word offsets into G.cp.context - the statics for CP
m.cp.level     = 0 // lo byte level
m.cp.type      = 1
m.cp.picoff    = 2
m.cp.textoff   = 3
m.cp.map.no    = 4 // frame number of current map
m.cp.maprec.no = 5
m.cp.grbleast  = 6
m.cp.grblnorth = 7


// local menu bar offsets into g.cp.context
m.cp.box1 = 8
m.cp.box2 = 9
m.cp.box3 = 10
m.cp.box4 = 11
m.cp.box5 = 12
m.cp.box6 = 13


// photo's (non-exclusive) context data
m.cp.textbox     = 14  // what the "Text" box should contain
m.cp.npics       = 15  // number of pictures in current set
m.cp.descr.siz   = 16  // number of lines in long caption
m.cp.short.start = 17  // start of short caption data
m.cp.long.start  = 18  // start of long caption data
m.cp.phosub      = 19  // photo's substate
m.cp.frameA      = 20  // frame no of current frame in buffA
m.cp.frameB      = 21  //   ditto...             ...in buffB
m.cp.turn.on     = 22  // video needs restoring
m.cp.write.pending=23  // flag indicating WRITE is about to start


// text's (additional) context data
m.cp.pagebuff    = 26  // pointer to buffer for opage
m.cp.nopages     = 27
m.cp.crossref    = 28        // crossref itemaddress to AA text from schools
m.cp.page.start.offset = 29  // byte offset to text within first buffer
m.cp.page.cont.offset  = 30  // byte offset to text in second buffer
m.cp.contents.exist = 31     // boolean, true if contents/index page exists
m.cp.numtitles = 32          // number of section titles for this essay
m.cp.first.page.offset = 33  // byte offset to first byte of first real page
                             // from start of first frame (in buffA)

// buffer areas
// numbers vector: a vector of 20 words, one for each title
m.cp.numbers = 34    // buffer area for page numbers: max.titles words + 1
m.cp.NSW = m.cp.max.titles + 1    // Numbers Size Words

// index/contents page: max.titles lines * index.entry.size bytes
m.cp.index = m.cp.numbers + m.cp.NSW
m.cp.ISW = m.cp.max.titles * m.cp.index.entry.size / BYTESPERWORD  // Index Size Words

// scratch workspace: one linesworth = 40 bytes
m.cp.txtbuff = m.cp.index + m.cp.ISW
m.cp.TBSW = 40 / BYTESPERWORD             // Text Buff Size Words

//  total CP context data vec size IN WORDS
//  13.12.87      434 words for Acorn 16 bit
m.cp.consize = m.cp.txtbuff + m.cp.TBSW

$)
