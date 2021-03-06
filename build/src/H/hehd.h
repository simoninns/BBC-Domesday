// /**
//       HEHDR - HELP HEADER
//       -------------------
//
//       Manifest definitions for the HELP package
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR  DETAILS OF CHANGE
//       17.6.87  1        PAC     ADOPTED FOR UNI
//       23.12.87 2        MH      Numbered marks / ARC
// **/

get "H/iohd"  // for m.io.flagsize

MANIFEST $(

// constant definitions
m.he.ncolours     = 15 // colours go from 0 to 15
m.he.mode.invalid = -1 // impossible value for video mode
m.he.invalid      = -1

m.he.LHS = m.sd.disw/3      // left hand third of display
m.he.RHS = (m.sd.disw*2)/3  // right hand third of display
m.he.EOS = 1216             // end of question string in bookmark

// for help areal
m.he.rec.size   = 48 // byte size of a gazetteer record
// ??? m.he.wrecsize   = m.he.recordsize>>1 // rec size in words
m.he.end.of.types = #xFF01 // end marker for AU types
m.he.max.num.types = 25

// byte offsets into a gazetteer record
m.he.name.off = 2    // offset to name/type string - either record
m.he.type.nos = 34   // number of AU names              - type record
m.he.addr.off = 36   // offset to names area            - type record

m.he.nth.name.off = 42 // offset to Nth name record no. - name record
m.he.maprec.off   = 46 // offset to mapdata record no.  - name record

// for areal subroutines - opcodes
m.he.next = 0
m.he.previous = 1

// for help bookmark
m.he.none = 10
m.he.save = 20
m.he.load = 30
m.he.loadpend = 40 // SRY 24.8

// for help text state
//
// these are offsets into the data item header
// for finding the private text address which
// is used as the chain link pointer for help essays

m.he.ptext.offset = 2

// G.he.SAVE vector
//
// All this area is saved as part of BOOKMARK

// areas for things in chunks
m.he.context.start = 0  // the G.context vector has the same offsets
                        // as G.he.save
m.he.menubar.start = m.he.context.start + m.contextsize + 1
m.he.palette = m.he.menubar.start + m.menubarsize + 1

// separate variables here
m.he.vars = m.he.palette + m.he.ncolours
m.he.oldmode  = m.he.vars + 1  // old screen mode
m.he.oldvideo = m.he.vars + 2  // old video  mode
m.he.oldptr   = m.he.vars + 3  // old mouse pointer state
                               // N.B. 4 words reserved for
m.he.cursor   = m.he.vars + 4  // old graphics cursor position
m.he.cacheflags = m.he.vars + 8
m.he.savesize   = m.he.cacheflags + m.io.flag.size  // N.B. m.io.contextcache
                                                   // must be this big

// G.he.WORK vector
//
// vector for help context, and scratch space
// none of this area is preserved
//

// Help's working menu bar
m.he.box1 = 0
m.he.box2 = 1
m.he.box3 = 2
m.he.box4 = 3
m.he.box5 = 4
m.he.box6 = 5

// various flags and statics

m.he.worksize  = 6   // store total size of area
m.he.gotmark   = 7   // Flag set if a mark exists
m.he.gazhandle = 8
m.he.gazpage   = 9   // current page number of gazetteer names
m.he.max.names = 10  // maximum number of names to display
m.he.lastpage  = 11  // flag set true if it's the last page of names
m.he.name.no   = 12  // sequential number of current name record
m.he.show.areal= 13  // flag for having 'areal' on the menubar
m.he.gazptr    = 14  // offset into the Gazetteer file
m.he.redraw    = 16  //
m.he.tstats    = 17  // pointer to text's statics vector
m.he.page.buff = 18  // pointer to OPAGE's private buffer
m.he.dirtybuff = 19  // flag set true if TEXT's buffer has been corrupted
m.he.gopend    = 20  // go MARK pending
m.he.discpend  = 21  // load/save MARK pending
m.he.esstackptr= 22  // chained essays stack pointer
m.he.show.demo = 23  // flag for having 'demo' on the menubar

m.he.string     = 24 // string for System function
m.he.stringsize = 41/bytesperword // = 41 chars

// Areas for status page to use
m.he.AOI.type.str = m.he.string+m.he.stringsize
m.he.AOI.name.str = m.he.AOI.type.str + m.he.stringsize
m.he.AU.type.str  = m.he.AOI.name.str + m.he.stringsize
m.he.essays       = m.he.AU.type.str  + m.he.stringsize

// ?????????
// essays have 'state' table
m.he.esstack   = m.he.essays + 1   // essay link stack
m.he.stacksize = 24/bytesperword   // max chain = 6 essays

m.he.types    = m.he.esstack+m.he.stacksize // area for AREAL to use
m.he.typesize = 26*(1+m.he.rec.size/bytesperword) // room for 26 areal units

m.he.namebuff = m.he.types + m.he.typesize

m.he.bm = m.he.namebuff + m.he.rec.size   // copy of SAVE vector for bookmark
m.he.buf = m.he.bm + m.he.savesize        // end of currently used area
m.he.next.entry = m.he.buf                // anything between this and worksize
                                          // is assumed to be free
$)


