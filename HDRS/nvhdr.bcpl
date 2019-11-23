// /**
//       NV.H.NVHDR - Definitions for National Video (Film)
//       --------------------------------------------------
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       17.6.86  1        DNH      Initial version
//       22.7.86  2                 m.response.xpos
//       ***************************
//       20.5.87     3     DNH      CHANGES FOR UNI
//                                  name changes
//                                  word- to byte- offsets
//       5.6.87      4     DNH      m.nv.escape.key gone
// **/

manifest
$(

//  vector sizes
m.nv.statics.size.words =  8  // static values getvec plus a few spare
m.nv.rec.size           = 340  // 28 + 40 + (1+7)*34 = 340 bytes
m.nv.data.size.words    = m.nv.rec.size/BYTESPERWORD  // only 1 record needed

//  statics: locations in the g.nv.s statics vector
m.substate             = 0  // substate manifest (see below)
m.film                 = 1  // list number of currently highlit film title
m.recptr               = 2  // abs. ptr to data record beyond item header
m.current.entry.offset = 3  // byte offset to a current film entry
m.num.entries          = 4  // number of films available
m.film.list.on.display = 5  // boolean: saves rewriting screen sometimes
m.response.xpos        = 6  // in message area for reply char to "Eject?"

//  Byte offsets within data structure from g.nv.s!m.recptr.
//  An 'entry' contains all info for one film.
//  The '28+' in each case is to allow for the header size

// m.nv.header.size     = 28    // standard National Disc 28 byte item header
m.nv.number.offset      = 28+4  // 2 bytes: offset to number of films in list
m.nv.disc.id.offset     = 28+6  // 2 bytes  NOT USED
m.nv.disc.title.offset  = 28+8  // 32 bytes NOT USED
m.nv.first.entry.offset = 28+40 // offset to 'initial film' entry of 34 bytes
m.nv.list.offset        = 28+74 // offset to the start of the full list
                                // full list size is (num.entries * entry.size)
m.nv.entry.size = 34  // size of a film entry

// offsets in 'lines' down the screen to positions of heading and list
m.nv.screen.heading.offset = 3
m.nv.screen.list.offset    = 7

//  substates
m.nv.initial.substate        = 1  // just entered via pending state change
m.nv.entry.question.substate = 2  // awaiting go for turn over to NatB side
m.nv.play.substate           = 3  // film is playing now. Poll.
m.nv.select.substate         = 4  // menu of films on display
m.nv.help.substate           = 5  // private Help; real Help not available
m.nv.exit.question.substate  = 6  // awaiting go for turn over to NatA side

$)
