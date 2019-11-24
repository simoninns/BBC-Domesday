// /**
//         NEHDR - HEADER FOR NATIONAL ESSAY
//         ---------------------------------
//         Manifest definitions for National Essay
//
//         REVISION HISTORY:
//
//         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//         19/5/86  1        EAJ         Initial version
//         20/06/86 2        EAJ         Add opage buffer & help flag
//         25/06/86 3        EAJ         Add manifests
//          5.9.86  4        PAC         Add m.ne.none
//         30.6.87  5        PAC         ADOPTED FOR UNI
//                                       seriously reorganised !
// **/

MANIFEST
$(
   m.ne.EOS = 1216  // end of WRITE's prompt string

   m.ne.invalid = -1 // invalid photoptr
   m.ne.nul     = 0  // ASCII nul char for nul title test

   m.ne.none   = 0   // type of page output
   m.ne.print  = 1   // send to printer
   m.ne.write  = 2   // send to floppy disc
   m.ne.screen = 3   // send to display

   m.ne.text    = 1  // type of page
   m.ne.picture = 2

   m.ne.nessay   = 6 // type of essay
   m.ne.picessay = 7 //

   m.ne.for  = 1     // direction of paging
   m.ne.back = 2
                         
   // values for the 'at.end' flag - can also be m.ne.invalid
   m.ne.firstpage = 1   // first page of essay
   m.ne.lastpage  = 2   // last page of essay

   m.ne.max.worksize = 10000 // set an upper limit to workspace size

   m.ne.scaplen   = 30   // no. of chars in shortcaption
   m.ne.lcaplen   = 39   // no. of chars per line in long caption
   m.ne.capsize1  = 8    // no. of lines in 'long' long captions
   m.ne.capsize2  = 4    // no. of lines in 'shorter' long captions
   m.ne.nolines   = 22   // no. of lines in page
   m.ne.maxtitles = 20   // no. of titles on page
   m.ne.maxpage   = 99   // max. page no on Contents page

   m.ne.dataset.header.size = 28  // byte offset in dataset to picture data   
   m.ne.photo.data.size     = 200 // bytes      
   m.ne.page.no.offset      = 228 // byte offset in dataset to no. of pages  
                             
   m.ne.article.title.offset = m.ne.page.no.offset + 2 // see data struct spec.
   m.ne.title.size = 30  // bytes in a title   
   m.ne.phosize    = 25  // no. of picture data chunks in the photo area
   m.ne.rsize      = 8   // byte size of a photo data record

   //
   // offsets in G.ne.s - the context area
   //
   m.ne.type          = 0  // type of data item - essay/picture essay
   m.ne.write.pending = 1  // flag set for write pending
   m.ne.gone.to.photo = 2  // flag set if we've gone to photo
   m.ne.gone.to.help  = 3  // flag set if we've gone to help
   m.ne.nopages       = 4  // no. of pages in article
   m.ne.max.pages     = 5  // max no. of text pages allowed in buffer
   m.ne.firstinbuff   = 6  // first pageno in buff
   m.ne.notitles      = 7  // no. of non-nul titles
   m.ne.photoptr      = 8  // pointer into picture data
   m.ne.pagetype      = 9  // type of page
   m.ne.fullset      = 10  // flag indicating full photoset to be inserted
   m.ne.pictno       = 11  // picture to be displayed from photoset
   m.ne.nopics       = 12  // number of pictures in dataset
   m.ne.D1.handle    = 13  // handle of DATA1
   m.ne.D2.handle    = 14  // handle of DATA2
   m.ne.desc.size    = 15  // no. of lines in current long caption
   m.ne.at.end       = 16  // flag for first/last page of essay
   m.ne.essay.no     = 17  // number of current essay (1,2 or 3)
   m.ne.pagebuff     = 18  // pointer to page buffer used by g.sc.opage
      
   m.ne.text.is.data2  = 19 // flags to say where the 
   m.ne.photo.is.data2 = 20 // data should be read from    

   // item addresses
   //
   m.ne.itemaddress  = 30 // 32 bit address of text dataset
   m.ne.firstaddr    = 32 // 32 bit space used to cache original item address
   m.ne.photoaddr    = 34 // 32 bit address of photo dataset

   // local menubar
   //
   m.ne.box1 = 36
   m.ne.box2 = 37
   m.ne.box3 = 38
   m.ne.box4 = 39
   m.ne.box5 = 40
   m.ne.box6 = 41

   // a couple of buffers
   //
   m.ne.titlebuff  = 42   // buffer for article title + length byte 

   m.ne.contents = m.ne.titlebuff + m.ne.title.size/bytesperword + 1

   // 'contents' is a list of valid article titles - required space is
   // 30 * 20 bytes (currently) - recheck this after the init routine
   // has been sorted out

   // size of context area to be cached
   m.ne.statics.size = m.ne.contents + (m.ne.title.size*20)/bytesperword + 1
$)
