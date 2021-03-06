//  AES SOURCE  6.87

/**
         NE.NTEXT1 - Specific action and init routines for NE
         ----------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.text

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         30.6.87  1        PAC     Adopted for AES
         16.12.87 2        PAC     Fix help visited flag
**/      

SECTION "Ntext1"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glNEhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/sthd.h"
get "H/kdhd.h"
get "H/dhhd.h"
get "H/nehd.h"
get "H/uthd.h"
get "H/vhhd.h"

/**
         G.NE.ESSINI - Initialization routine for National Essay
         -------------------------------------------------------

         INPUTS:

         Direction : Direction of paging through essays.
                     Set to invalid if not paging through essays &
                     only tested if NOT justselected.

         OUTPUTS:

         None

         GLOBALS MODIFIED:

         None


         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         Read in no. of pages in the essay
         Read in the page titles
         Initialise globals
         Extract valid titles and store in context
         Move photo data to start of buffer
         IF just selected
         THEN
            show first page of essay
         ELSE
            IF paging backwards between essays
            THEN
               show last page of previous essay
            ELSE
               show first page of next essay
            ENDIF
         ENDIF
**/


LET g.ne.essini(direction) be
$(
   let ptr   = vec 1
   let bytes.to.read = ?
   let IAL, IAH = ?,? // components of the item address
   let data.file = ?          

   // this sets flag to show which data file our stuff is in
   // and also tidies up our own copy of the item address
   // Only has to be done when a new essay is being displayed
   //        
   IAL := g.ut.get32( g.context+m.itemaddress, @IAH ) // extract address
   g.ne.s!m.ne.text.is.data2 := (IAH & #x8000) ~= 0   // set flag
   IAH := IAH & #x7FFF                                // strip top bit
   g.ut.set32 (IAL, IAH, g.ne.s+m.ne.itemaddress )    // and save it

   data.file := g.ne.s!m.ne.text.is.data2 -> g.ne.s!m.ne.D2.handle,
                                             g.ne.s!m.ne.D1.handle

   // find the number of pages in the essay   
   // 
   g.ut.set32( m.ne.page.no.offset, 0, ptr )
 
   // add it to the item address 
   //
   g.ut.add32(g.ne.s+m.ne.itemaddress,ptr)  

   // now read the two byte value   
   // 
   g.ne.s!m.ne.nopages := 0   // initialise value
   g.dh.read( data.file, ptr, g.ne.s+m.ne.nopages, 2 )

   // read page titles and photo data into the buffer
   //               
   // we need to read :
   // 1) the dataset header                                           
   // 2) the photo data
   // 3) the 2 bytes containing the number of pages (again!)
   // 4) npages + 1 page titles
   // ... see On Disc data structures document
   //
   bytes.to.read := m.ne.dataset.header.size +
                    m.ne.photo.data.size + 2 +
                    (g.ne.s!m.ne.nopages+1)*m.ne.title.size

   g.dh.read( data.file,
              g.ne.s+m.ne.itemaddress,
              g.ne.buff,
              bytes.to.read )     

   // initialise private statics
   //
   g.ne.s!m.ne.gone.to.help  := FALSE   // pac 16.12.87
   g.ne.s!m.ne.gone.to.photo := FALSE       
   g.ne.s!m.ne.write.pending := FALSE
   g.ne.s!m.ne.firstinbuff   := m.ne.invalid
   g.ne.s!m.ne.fullset       := FALSE
   g.ne.s!m.ne.at.end        := m.ne.invalid
   g.ne.s!m.ne.photoptr      := m.ne.invalid
   g.ne.s!m.ne.type          := g.ne.buff%1  // second byte of dataset header

   // initialise menubar
   //
   for i=m.ne.box1 to m.ne.box6 do g.ne.s!i := m.sd.act
                                             
   // trap if the data item type is incorrect
   //
   g.ut.trap("NE",1,TRUE,3, g.ne.s!m.ne.type,m.ne.nessay,m.ne.picessay)

   // extract the essay title, and put it as a BCPL string in our buffer
   //                                                                     
   (g.ne.s+m.ne.titlebuff)%0 := m.ne.title.size

   G.ut.movebytes( g.ne.buff,
                   m.ne.article.title.offset,
                   g.ne.s+m.ne.titlebuff,     // n.b. A WORD address
                   1,                         // taking care of length byte
                   m.ne.title.size )

   // now sort out the contents page
   //
   initcontents()     

   // move photo data to start of buffer, stomping on the 28 byte header     
   // 
   G.ut.movebytes( g.ne.buff,
                   m.ne.dataset.header.size,
                   g.ne.buff,
                   0,
                   m.ne.photo.data.size )      

   // finally...display something 
   //
   test (g.context!m.justselected) | (direction ~= m.ne.back)
   then gotofirst()
   else gotolast()
$)
                 
//
//  REINITIALISE []
//  ------------
//
//  This routine is called when the essay code needs to restore
//  its data, and possibly its screen as well. This occurs after
//  we've returned from Help, or back from examining a photo set.
//
//

AND reinitialise() BE
$(
   let ptr       = vec 1
   let data.file = g.ne.s!m.ne.text.is.data2 -> g.ne.s!m.ne.D2.handle,
                                                g.ne.s!m.ne.D1.handle

   // read in photo data to start of data buffer
   // 
   G.ut.set32( m.ne.dataset.header.size, 0, ptr )

   G.ut.add32( g.ne.s+m.ne.itemaddress,ptr)

   G.dh.read( data.file,
              ptr,
              g.ne.buff,
              m.ne.photo.data.size )
  
   // set up our statics
   // 
   g.ne.s!m.ne.write.pending := FALSE
   g.ne.s!m.ne.firstinbuff   := m.ne.invalid

   TEST g.ne.s!m.ne.gone.to.help      
   THEN TEST g.ne.s!m.ne.pagetype = m.ne.text
        THEN g.ne.displaypage(m.ne.none) // this call re-reads the data after
        ELSE g.ne.displayphoto(m.ne.none,m.ne.invalid) 
   ELSE                                  // help has been exited
   $(                                    // ... but doesn't alter screen.
      g.ne.s!m.ne.fullset := FALSE       // not sure about these 
      g.ne.s!m.ne.at.end  := m.ne.invalid // 2 statics being reset here

      TEST g.ne.s!m.ne.pagetype = m.ne.text
      THEN
      $(
         TEST g.context!m.page.no = 0
         THEN g.ne.displaycontents(m.ne.screen)
         ELSE g.ne.displaypage(m.ne.screen)
      $)
      ELSE g.ne.displayphoto(m.ne.screen,m.ne.invalid)
   $)  

   // finally, restore the video to be on - necessary after HELP
   //
   IF g.ne.s!m.ne.pagetype = m.ne.picture THEN G.vh.video(m.vh.video.on)
$)

                    
//
// INITCONTENTS() - put list of contents into statics vector
//
AND initcontents() BE
$(
   LET notitles,i = 1,1
   LET s   = g.ne.buff            // word pointer to source
   LET d   = g.ne.s+m.ne.contents // word pointer to destination       
   LET soff,doff = ?,0            // source,destination byte offsets

   // set offset pointer to first page title
   //
   soff := m.ne.article.title.offset + m.ne.title.size

   while (i <= g.ne.s!m.ne.nopages) &  
         (notitles <= m.ne.maxtitles) & // safety measure
         (i <= m.ne.maxpage) do         // ditto
   $(
      if s%soff ~= m.ne.nul             // we've found a valid title
      then                              // so move title into title buffer 
      $( 
         g.ut.movebytes( s, soff, d, doff, m.ne.title.size )
            
         doff := doff + m.ne.title.size 
                                                                   
         notitles := notitles + 1
      $)                                

      soff := soff + m.ne.title.size   // point to next candidate
      i    := i  + 1                   // increment count
   $)
   g.ne.s!m.ne.notitles := notitles - 1  // save number of titles
$)

/**
         G.NE.ESSAY - Specific action routine for National Essay
         -------------------------------------------------------


         INPUTS:

         None

         OUTPUTS:

         None

         GLOBALS MODIFIED:

         None


         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         IF justselected
         THEN
            Set current file handle and essay no.
            Call initialisation routine
            Set justselected to FALSE
         ENDIF
         IF just returned from help or photo
         THEN
            Call re-initialization routine
         ENDIF      

         IF reply to write question is not 'R'
         THEN
            Print character reply
            Restore header
         ENDIF   

         IF G.key is display area & change button pressed
         THEN
            convert key to f7/f8
         ENDIF                  

         Do highlighting of contents list

         CASE local.key OF

         CASE Fkey3 : show first page of essay
         ENDCASE

         CASE Fkey4 : show last page of essay
         ENDCASE

         CASE Fkey5 : print page
         ENDCASE

         CASE Fkey6 : save header
                 display write message
                 set write.pending flag TRUE
         ENDCASE

         CASE 'R' or 'r' :  write page
         ENDCASE

         CASE Fkey7 : page backwards
         ENDCASE

         CASE Fkey8 : page forwards
         ENDCASE

         CASE action key :
            IF on Contents page & valid title selection
            THEN
               Get selected page
            ELSE
               Look for a selected figure
            ENDIF
        ENDCASE

        Redraw menubar
**/

And g.ne.essay() be
$(
   let local.key = g.key
   let itemno = ?

   if g.context!m.justselected
   then
   $(
      g.ne.s!m.ne.essay.no := 1 // the first essay
      g.ne.essini(m.ne.invalid)
      g.context!m.justselected := FALSE
   $)

   if (g.ne.s!m.ne.gone.to.photo) | 
      (g.ne.s!m.ne.gone.to.help)
   then
   $(
      reinitialise()
      g.ne.s!m.ne.gone.to.photo := FALSE
      g.ne.s!m.ne.gone.to.help  := FALSE
   $)                                   

   // if reply to "write question" is not 'R'
   // then show character reply and restore header
   // 
   if g.ne.s!m.ne.write.pending & 
      (g.key ~= m.kd.noact) & 
      (CAPCH(g.key) ~= 'R') 
   then
   $(
      let ch = ((g.key > ' ') & (g.key <= 'z')) -> g.key,'Q'
      g.sc.movea(m.sd.message,m.ne.EOS,m.sd.mesYtex)
      g.sc.ofstr("%C",ch)
      g.ut.wait(100)
      g.sc.cachemess(m.sd.restore)
      g.ne.s!m.ne.write.pending := FALSE
   $)
        
   // convert a function key for paging
   //
   if (local.key = m.kd.change) & (g.screen = m.sd.display)
   then local.key := convert.key()

   itemno := highlight()

   switchon local.key into
   $(
      case m.kd.Fkey1 : g.ne.s!m.ne.gone.to.help := TRUE
      endcase

      case m.kd.Fkey3 : gotofirst()
      endcase

      case m.kd.Fkey4 : gotolast()
      endcase

      case m.kd.Fkey5 : printit()
      endcase

      case m.kd.Fkey6 :
      $(
         g.sc.cachemess(m.sd.save)
         g.sc.mess("Insert floppy disc; type R (ready) or Q (quit): ")
         g.ne.s!m.ne.write.pending := TRUE
      $)
      endcase

      case 'R' :
      case 'r' :  writeit()
      endcase

      case m.kd.Fkey7 : g.ne.trytopage(m.ne.back)
      endcase

      case m.kd.Fkey8 : g.ne.trytopage(m.ne.for)
      endcase

      case m.kd.return :
      $(
         test (g.context!m.page.no = 0) & (itemno ~= m.sd.hinvalid) &
              (g.ne.s!m.ne.pagetype = m.ne.text)
         then
            getpage(itemno)   // a contents selection
         else
            gotofig()         // a 'see figure' selection
      $)
      endcase
   $)
   if g.redraw | check.menu(g.ne.s+m.ne.box1)
   then g.sc.menu(g.ne.s+m.ne.box1)

   g.sc.pointer(m.sd.on) 
$)

AND convert.key() = VALOF
$(
   if (g.xpoint < m.sd.disW/3)   resultis m.kd.Fkey7
   if (g.xpoint > m.sd.disW*2/3) resultis m.kd.Fkey8
   g.sc.beep()
   resultis m.kd.change // what it was before
$)

And highlight() = VALOF
$(
   let lastitem,firstitem = ?,1
   let itemno = m.sd.hinvalid

   // show highlighting as pointer is positioned on title lines
   // and return highlighted number 

   if (g.context!m.page.no = 0) & (g.ne.s!m.ne.pagetype=m.ne.text)
   then
   $(
      lastitem := g.ne.s!m.ne.notitles
      if (g.ne.s+m.ne.contents)%1 ~= '1'
      then
         lastitem := lastitem + 1
      itemno := g.sc.high(firstitem,lastitem,false,0)
   $)
   resultis itemno
$)

And gotofirst() be
$(
   // show first page of essay
   test g.ne.s!m.ne.notitles > 1
   then
      g.ne.displaycontents(m.ne.screen)
   else
   $(
   // simulate contents page and page forward
      g.context!m.page.no := 0
      setprivglobals()
      g.ne.trytopage(m.ne.for)
   $)
$)

And gotolast() be
$(
   // show last page of essay
   // simulate last pagetext + 1
   g.context!m.page.no := g.ne.s!m.ne.nopages + 1
   setprivglobals()
   g.ne.trytopage(m.ne.back)
$)

And setprivglobals() be
$(
   g.ne.s!m.ne.photoptr := m.ne.invalid
   g.ne.s!m.ne.at.end  := m.ne.invalid
   g.ne.s!m.ne.fullset := FALSE
$)

And getpage(itemno) be
$(
   // Display selected page
   // Check if "Introduction" title has been added
   if (g.ne.s+m.ne.contents)%1 ~= '1'
   then
      itemno := itemno - 1

   test itemno = 0
   then
      g.context!m.page.no := 1
   else
   $(
      // this section considerably modified PAC 22.10.86

      let cts = g.ne.s+m.ne.contents          // pointer to titles buffer
      let itm = (itemno-1)*m.ne.title.size    // offset to selected item
      let p,c1,c2 = 0, cts%itm-'0', cts%(itm+1)-'0' // pick up 2 number chars

      if 0 <= c1 <= 9 then p := c1             // convert to a page number
      if 0 <= c2 <= 9 then p := p*10 + c2

      g.context!m.page.no := (p = 0) -> 1, p // safety measure - p non zero
   $)
   g.ne.displaypage(m.ne.screen)
$)

And printit() be
$(
   // print page
   test g.context!m.page.no = 0 & g.ne.s!m.ne.pagetype = m.ne.text
   then
      g.ne.displaycontents(m.ne.print)
   else
   $(
      test g.ne.s!m.ne.pagetype = m.ne.text
      then
         g.ne.displaypage(m.ne.print)
      else
         g.ne.displayphoto(m.ne.print,m.ne.invalid)
   $)
$)

And writeit() be
$(
   // write page to floppy
   if g.ne.s!m.ne.write.pending
   then
   $(
      g.sc.movea(m.sd.message,m.ne.EOS,m.sd.mesYtex)
      if (g.key >= ' ') | (g.key <= 'z')
      then
         g.sc.ofstr("%C",g.key)
      g.sc.cachemess(m.sd.restore)
      g.ne.s!m.ne.write.pending := FALSE
      if (g.ut.open.file() = m.ut.success)
      then
      $(
         test (g.context!m.page.no = 0) &
              (g.ne.s!m.ne.pagetype = m.ne.text)
         then
            g.ne.displaycontents(m.ne.write)
         else
         $(
            test g.ne.s!m.ne.pagetype = m.ne.text
            then
               g.ne.displaypage(m.ne.write)
            else
               g.ne.displayphoto(m.ne.write,m.ne.invalid)
         $)
         g.ut.close.file()

         UNLESS g.ne.s!m.ne.pagetype = m.ne.text
         $( g.vh.frame(g.context!m.frame.no)
            g.vh.video( m.vh.video.on )  
         $)
      $)
      G.sc.keyboard.flush() // kill typeahead
   $)
$)

And gotofig() be
$(
   // determine if valid figure could be selected 
   //
   if g.context!m.page.no ~= 0 & (g.ne.s!m.ne.type = m.ne.nessay)
   then if g.ne.lookforfig()
        then $( g.ne.s!m.ne.gone.to.photo := TRUE
                g.key := -m.st.nphoto
             $)
$)

AND check.menu(boxes) = VALOF
$(
   for i = 0 to 5
   unless boxes!i = g.menubar!i resultis true
   resultis false
$)
.
