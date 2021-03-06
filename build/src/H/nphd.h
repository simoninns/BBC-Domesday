// /**
//       NPHDR - HEADER FOR NATIONAL PHOTO
//       ----------------------------------
//
//       Manifest definitions for the national photo
//       operation.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       23.1.86  1        PAC      Initial version for community photo
//        6.3.86  2        SRY      Modified for national photo
//       11.4.86  3        SRY      Added manifests for print
//       15.4.86  4        SRY      Added manifests for centring caption
//       ********************************
//       9.6.87      5     DNH      CHANGES FOR UNI
//       23.7.87     6     DNH      Cache menu bar values
//       04.12.87    7     MH       Arcimedes update to photo sets
// **/

MANIFEST
$(

// Word offsets NP statics in g.np.s
m.np.index.page  = 0  // Current index page number
m.np.lastpage    = 1  // Last page possible for index for this item
m.np.local.state = 2  // either m.np.photo or m.np.index
m.np.npics       = 3  // number of pictures in current set
m.np.descr.siz   = 4  // either m.np.large.lc or m.np.small.lc
m.np.file.handle = 5  // data file for this item
m.np.vrestore    = 6  // video needs switching on after data access

// Local menu bar
m.np.box1        = 7
m.np.box2        = 8
m.np.box3        = 9
m.np.box4        = 10
m.np.box5        = 11
m.np.box6        = 12

m.np.cache.size.words = 12     // vector to cache (words)
// (the rest don't need caching)

// more that doesn't need caching: set up in dy.init
m.np.is.data2      = 13 // boolean: according to top bit of itemaddress
m.np.itemaddr32    = 14 // 32 bit: itemaddress, but trimmed of top bit
// (uses 15)
m.np.short.start32 = 16 // 32 bit offset from start of data file to sc's
// (uses 17)
m.np.long.start32  = 18 // 32 bit offset from start of data file to sc's
// (uses 19)
m.np.frame.start32  = 20 // 32 bit offset from start of data file to sc's
// (uses 21)

//DESCRIPTION buffer word space
m.np.d.buf = 22  //pointer for getvec to discription buffer
m.np.d.first = 23 //pointer to start of buffer
m.np.d.midway = 24   //pointer to end of buffer
m.np.d.n.rec = 25 //number of records in buffer


//CAPTION buffer word space
m.np.c.buf = 26  //pointer for getvec to caption buffer
m.np.c.first = 27 //pointer to start of buffer
m.np.c.midway = 28   //pointer to end of buffer
m.np.c.n.rec = 29 //number of records in buffer

//FRAME buffer word space
m.np.f.buf = 30  //pointer for getvec to frame buffer
m.np.f.first = 31 //pointer to start of buffer
m.np.f.midway = 32   //pointer to end of buffer
m.np.f.n.rec = 33 //number of records in buffer

m.np.init = 34
m.np.statics.size.words = 34   // total statics getvec size

// screen values
m.np.LHS = m.sd.disw/3      // left hand third of display
m.np.RHS = (m.sd.disw*2)/3  // right hand third of display
m.np.charwidth = 32         // 32 graphics units per character
m.np.scYpos    = m.sd.linW  // 1 line up
m.np.lcYpos    = 0


// values for data structure fields
m.np.num.pics.off = 28  // offset in data item to number of pictures

m.np.sclength  = 30     // 30 characters for short caption
m.np.lclength  = 39     // 39 chars per line for long caption

m.np.small.lc = 4       // lines per long caption: small and large varieties
m.np.large.lc = 8       // 4 or 8 lines of m.np.lclength bytes

// space is reserved for the following numbers of caption lines
m.np.max.shorts = 100   // short captions stored (one line each)
// m.np.longs  = 1      // long caption lines stored: should be increased

// sizes of the two captions buffers and line output buffer in bytes
m.np.short.buff.size = m.np.max.shorts * m.np.sclength // captions * linelength
m.np.rbuff.size      = m.np.large.lc * m.np.lclength   // lc lines * linelength
m.np.tbuff.size      = 1 + m.np.lclength        // (one extra for length byte)
                           // NB!! lclength > sclength: enough for the larger

// values for local.state
m.np.photo = 0          // for local state photo
m.np.index = 1          // for local state index

// flag parameter values for output routines
m.np.print = 0          // for printing caption
m.np.screen = 1         // for writing caption to screen

// offset in data item to number of pictures
m.np.num.pics.off = 28

// pricture frame byte size
m.np.frame.size = 2

$)

/*
   NP data has following structure:
   This must be in step with the Videodisc Data Structures Spec

   FIELD NAME              BYTES    VALUE

   Nat. item header        28

   No of pictures           2       n

   Picture frame numbers    2n

   Short captions          30n

   Long captions           156n OR
                           312n
*/
