// /**
//       NFHDR - National Find header file
//       ---------------------------------
//
//       ............
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       22.8.86  1        M.F.Porter  Initial version
//       22.6.86  2        MFP         m.msize value corrected
//*****************************************************
//       9.6.87   3        MFP         CHANGES FOR UNI
//       24.7.87  3        MH          CHANGES FOR PUK
//       28.7.87  4        MH          update to manifests for hierarchy
//        6.8.87  5        MH          update to manifests for find screen
//       10.8.87  6        MH          5 word omit group added
// **/

manifest $(

// offsets down p :
// The first 20 words are alloted as follows:

c.state = 0     // internal state of FIND
c.index = 1     // locator of index file
c.names = 2     // locator of names file
c.termcount = 3 // number of terms in the query
c.m = 4         // ofsset in 'best match' vector giving 1st line of current
                // screenful
c.mend = 5      // limit of 'best match' vector
c.h = 11        // worst match from last query invocation
c.max = 14      // maximum possible D-value
c.box = 16      // currently selected screen box
c.titles = 17   // number of titles in current pagefull
c.bestmatch = 18// sum of all weights in the query
c.bestcount = 19// number of 'perfect matches'
c.maxterm = 20  // slot in p+p.z of term with highest frequency
c.ws = 24       // workspace pointer
c.wssize = 25   // workspace size
c.titlenumber = 26  // number of title on 1st line of current screenful

c.include = 30     // five words for 5 search groups 10.8.87 MH
c.good.query = 37  // set to true if query is good
c.last.function = 38 //flag to indicate what the last operation was
                     //i.e. search on key word or on file name in quotes
c.file.rec = 39  //file record number
c.last.rec = 40
p.oldq = 41     // the query from the previous invocation of find (121 bytes)
p.z = p.oldq+121/bytesperword+1
                // the query control vector. Contains 10 word slots for a
                // maximum of 30 query terms
p.m = p.z+300   // The 101 'best matches' from the last running of the query
                // - 404 (= m.msize) words required
m.msize = 404
p.t = p.m+m.msize// The 21 titles for the current page of inspection. 840 bytes

m.item.rec.size = 40 //size of record with hierarchy 3 bytes
m.item.wrec.size = m.item.rec.size/bytesperword // 28.7.87

p.q = p.t+(21*m.item.rec.size)/bytesperword
                // current query (121 bytes)
p.s = p.q+121/bytesperword+1
                // room for 16 statics

m.nf.datasize = 752+6+3+(996+84)/bytesperword  // - size of above MH 28.7.87

m.nf.max.wsize = 16000 // upper limit to workspace size

m.nf.indexlevels = 4

o.wsize = 2  // size of an O-entry in the index (words)
m.biisize = 4 // size in bytes of an index item
m.iisize = m.biisize/BYTESPERWORD // ditto in words
m.misize = 4 // size in words of a 'match' item
m.titlespp = 20 // (max) number of titles per page
m.tbsize =  36 // full size of a title (bytes)
m.tsize = m.tbsize/BYTESPERWORD
m.keyword = true  //for keyword search
m.file = false    //for file name search

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


// inserted by MH 6.8.87  for update to find screen

s.unset=0
s.outsidebox=1
s.atbox=2
s.ing=3
s.inn=4
s.inq=9

$)


