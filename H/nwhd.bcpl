// /**
//       NWHDR - HEADER FILE FOR NATIONAL WALK
//       -------------------------------------
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       8.9.86   1        MFP      Initial version
//       9.9.86   2        PAC      Fix thirdwidth
//       15.6.87     3     DNH      Nobble bytesperword
//       21.9.87     4     MH       Base.pos added to G.nw
// **/

manifest $(

film.start = 705  // start of gallery entry film

thirdwidth = m.sd.disw/3   // one third of the BBCmicro screen width

lmarg = 372             // (11*thirdwidth)/16 // marks end pos of 1/3 of TV screen width
rmarg = m.sd.disW-lmarg // lmarg+thirdwidth   // marks start pos of 2/3 of TV screen width

m.titlesize = 36  // size of an entry in the NAMES file in bytes

m.lens.size = 45  // radius of magnifying glass lens (slightly over)
m.picwidth = 64   // average picture width in the gallery
m.picheight = 64  // average picture height

m.datasize = 13000/BYTESPERWORD
                  // size of vector to hold a NW datastructure
// offsets down g.nw :

view = -1         // current position in datastructure
cubase = -2       // base of close-up list
cu = -3           // pointer into close-up list
fiddlemenu = -4   // true following a move in the datastructure
wmess = -5        // true if something written in message area
wdisp = -6        // true if something written in display area
vrestore = -7     // set true if video needs restoring
ltable = -8       // g.nw!ltable is the 'link' table
ctable = -9       // g.nw!ctable is the control table
ptable = -10      // g.nw!ptable is the plan table
dtable = -11      // g.nw!dtable is the detail table
m.baseview = -12  // first frame of the views
m.baseplan = -13  // first frame of the plans
m.syslev = -14    // value 1 means 'gallery'
addr1 = -15
addr0 = -16       // these two slots hold the byte offset of the current
                  // datastructure - addition of 15/7/86
gallerydetail = -17 // true if in detail walked into from gallery, false
                  // if in detail of a pure walk
base.pos = -18    // position on entry to new walk   21.9.87
m.h = 18          // size of the above

$)
