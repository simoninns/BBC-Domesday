// /**
//       CFHDR - COMMUNITY FIND HEADER
//       -----------------------------
//
//       ............
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       1.5.86   1        M.F.Porter  Initial version
//       22.5.86  2        PAC         Add stuff from b.find0
//       20.7.86  3        MFP         c.keepmess introduced
//       28.7.86  4        MFP         c.vrestore introduced
//       17.9.86  5        MFP         c.side, c.qforthisside added
//       ******************************
//       8.6.87   6        MFP         changes for UNI
//       17.6.87  7        PAC         fix max wsize
//       11.12.87 8        MH           s.atbox1 added for VK box locking
// **/

manifest $(

// offsets down p :
// The first 30 words are alloted as follows:

c.state = 0     // internal state of FIND
c.index = 1     // locator of index file
c.names = 2     // locator of names file
c.termcount = 3 // number of terms in the query
c.m = 4         // ofsset in 'best match' vector giving 1st line of current
                // screenful
c.mend = 5      // limit of 'best match' vector
c.lev = 6       // query map level
c.x0 = 7; c.y0 = 8; c.x1 = 9; c.y1 = 10
                // bottom left to top right easting & northing of query map
c.h = 11        // worst match from last query invocation
c.max = 14      // maximum possible D-value
c.box = 16      // currently selected screen box
c.titles = 17   // number of titles in current pagefull
c.bestmatch = 18// sum of all weights in the query
c.bestcount = 19// number of 'perfect matches'
c.maxterm = 20  // slot in p+p.z of term with highest frequency
c.gaz = 21      // locator of gazetteer file
c.gazsize = 22  // size in bytes of gaz. file (2 words)
c.ws = 24       // workspace pointer
c.wssize = 25   // workspace size
c.titlenumber = 26  // number of title on 1st line of current screenful
c.gaztitles = 27// number of gaz titles in current pagefull
c.itemaddress =28// slot for g.context!m.itemaddress
c.keepmess = 29 // true if message in Main state is to be kept on screen
                // in the Review state
c.vrestore = 30 // true if video needs restoring (after return from help)
c.side = 31     // last observed side of disc
c.qforthisside = 32
                // true if the previous query relates to this side of disc

p.oldq = 33     // the query from the previous invocation of find (121 bytes)
p.z = p.oldq+121/BYTESPERWORD+1
                // the query control vector. Contains 10 word slots for a
                // maximum of 30 query terms
p.m = p.z+300   // The 101 'best matches' from the last running of the query
                // - 404 (= m.msize) words required
m.msize = 404
p.t = p.m+m.msize// The 21 titles for the current page of inspection.
                // 756 bytes
p.q = p.t+756/BYTESPERWORD
                // current query (121 bytes)
p.s = p.q+121/BYTESPERWORD+1
                // room for 16 statics

m.cf.datasize = 755+996/BYTESPERWORD
                // 33+x+300+404+y+x+16 - size of the above
                // where x = 121/BYTESPERWORD+1,
                //       y = 756/BYTESPERWORD          

m.cf.max.wsize = 16000 // upper limit to workspace size

m.cf.indexlevels = 4
m.cf.gazlevels = 4

// inserted by PAC 22/05/86 - from b.find0

s.unset=0
s.outsidebox=1
s.atbox=2
s.ing=3
s.inn=4
s.inq=5
s.gr.ambig=6
s.review=7
s.atbox1 = 8 // added for virtual keyboard 11.12.87 MH
thirdwidth = m.sd.disw/3

// end of inserts by PAC

o.wsize = 2  // size of an O-entry in the index (words)
m.biisize = 8 // size in bytes of an index item
m.iisize = m.biisize/BYTESPERWORD // ditto in words
m.misize = 4 // size in words of a 'match' item
m.titlespp = 20 // (max) number of titles per page -1
m.tbsize = 36 // full size of a title (bytes)
m.tsize = m.tbsize/BYTESPERWORD

// offsets in the query control vector:
c.f = 0    // frequency
c.w = 1    // weight
c.hl1 = 2  // highlighting base point in query string
c.hl2 = 3  // highlighting top point in query string
c.p = 4    // pointer to base of buffer space
c.sp = 5   // size of buffer space
c.i = 6    // number of items read
c.c = 7    // 'cursor' along the buffer space
c.o = 8    // offset into index file (2 words)

m.h = 10   // size of the above

m.vsize = 210/bytesperword+50  /* workspace size used by extractwords.()
and lookupwords.(). Overgenerous by about 20 words. */


$)

/**
         FIND works under the control of a single large vector of
         size m.cf.datasize BCPL words. This vector is pointer to
         by the global:

             g.cf.p

         The 1st 30 words contain miscellaneous control
         information. The subsequent areas at certain fixed
         offsets p.q, p.z ... contain:


         p.q    : the user's current query
         p.oldq : the user's previous query
         p.m    : the 101 best matches
         p.t    : the 21 current titles
         p.z    : the query control vector
         p.s    : cache area for certain BCPL static variables

         Thus FIND has a batch of (up to) 101 matches of the
         query at p.m, out of which (up to) 21 titles are held at
         p.t. The titles are 18 words long, and are just records
         pulled out of the NAMES file. The entries in p.m occupy
         4 words as follows:

         the weight (= sigma log(N/freq), summed over the terms)
         - 1 word
         The 'D-value' (= the rec. number in the NAMES file) - 2
         words
         the number of previous entries in the batch of 101 with
         the same weight - 1 word

         The data in p.z contains T vectors of size m.h words,
         where T is the number of terms in the current query.
         There is room for 30 such vectors, 30 being the absolute
         maximum number of terms which a user could supply,
         although it would require some ingenuity to achieve
         this!

         The m.h words per term contain values which are used in
         the processing of a query. When the query is run, a
         buffer B(t) is created for term number t. The buffers
         B(1),B(2) ... all reside in a second 'workspace' vector
         which is created  upon entry to FIND, but unlike the
         main FIND vector, is not cached on exit.

         g.cf.p ! c.ws  gives the address of the workspace
                        vector, and
         g.cf.p ! c.wssize  gives its size.

         During processing of a query, the m.h words are utilised
         as follows:

         offset      use
         ------      ---
         c.f         the term frequency (= number of items
                     indexed by the term)
         c.w         the weight (log N/frequency roughly)
         c.hl1       the base point of this term in the query string
         c.hl2       the top point of this term in the query
                     string. These two values are used when the
                     term is highlighted
         c.p         the pointer to B(t), the term buffer
         c.sp        the size of B(t) (in BCPL words)
         c.i         the number of indexed items for this term so
                     far read from the videodisc. Runs from 0 to
                     the term frequency.
         c.c         the current offset down B(t)
         c.o         the start point in the INDEX file for this
                     term (2 words).

         The workspace vector is also used to contain successive
         blocks of gazetteer data, and the slot for the query
         (p.q) is also used for the user's place name in
         gazetteer look up.

**/


