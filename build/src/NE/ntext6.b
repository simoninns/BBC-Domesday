//  AES SOURCE  6.87

/**
         NE.NTEXT6 - Display photo routines for National Essay
         -----------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.text

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         1.7.87   1        PAC     ADOPTED FOR AES 
**/                     

SECTION "NText6"   

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glNEhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/dhhd.h"
get "H/nehd.h"
get "H/vhhd.h"
get "H/uthd.h"

/**
         G.NE.DISPLAYPHOTO - Routine to output photopage to screen,
         ---------------------------------------------------------
                             printer or floppy
                             -----------------

         INPUTS:

         type of output : screen, printer or floppy
         direction of paging: forward or backward

         OUTPUTS:
         None

         GLOBALS MODIFIED:
         G.context!m.frame.no set to appropriate frame no of picture

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         Set photoitemaddress in context
         Set pagetype = picture
         Read in nopics
         IF pictureno in buffer = -1 & valid direction
         THEN
            IF direction = forward
            THEN
               IF first entry to photoset
               THEN
                  picno = 1
               ELSE
                  picno = picno + 1
               ENDIF
            ELSE
               IF first entry to photoset
               THEN
                  picno = nopics
               ELSE
                  picno = picno - 1
               ENDIF
            ENDIF
         ENDIF
         Display photo and captions
         Update menubar
         ENDIF
         Show picture(frameno)
         Show captions
         RETURN
**/

Let g.ne.displayphoto(type,direction) be
$(
   let handle = ?
   let frame  = ?                  

   // G.vh.video( m.vh.video.off)  
      
   UNLESS g.ne.s!m.ne.pagetype = m.ne.picture 
   DO $( G.vh.video( m.vh.video.off) 
         G.vh.video( m.vh.superimpose ) 
      $)

   g.ne.s!m.ne.pagetype := m.ne.picture

   handle := count.photos()   

   if (direction ~= m.ne.invalid) &   // -1 indicates a complete picture set
      ((g.ne.s!m.ne.pictno = -1) | g.ne.s!m.ne.fullset) then
   $(
      test direction = m.ne.for
      then test g.ne.s!m.ne.fullset
           then g.ne.s!m.ne.pictno := g.ne.s!m.ne.pictno + 1   
           else $( g.ne.s!m.ne.fullset := TRUE; g.ne.s!m.ne.pictno := 1 $) 

      else test g.ne.s!m.ne.fullset
           then g.ne.s!m.ne.pictno := g.ne.s!m.ne.pictno - 1  
           else $( g.ne.s!m.ne.pictno := g.ne.s!m.ne.nopics
                   g.ne.s!m.ne.fullset := TRUE
                $)
   $)

   frame := frameno(handle)
   g.sc.pointer(m.sd.off)
   displaypicture(type,handle,frame)
   g.sc.pointer(m.sd.on)
   updatemenu()
$)

And count.photos() = VALOF
$(
   let itemaddress = VEC 1                          
   let offset      = VEC 1
   let numpics     = VEC 1                           

   let handle = g.ne.s!m.ne.photo.is.data2 -> g.ne.s!m.ne.D2.handle,
                                               g.ne.s!m.ne.D1.handle
   // find no of pics
   //
   g.ut.set32( m.ne.dataset.header.size, 0, offset )
   g.ut.add32( g.ne.s+m.ne.photoaddr, offset )
   g.dh.read( handle,offset,numpics,2 )  // read 2 bytes (=number of pics)
  
   g.ne.s!m.ne.desc.size := (!numpics & #x8000 = 0) -> m.ne.capsize2, 
                                                       m.ne.capsize1
   g.ne.s!m.ne.nopics := (!numpics & #x7FFF)   

   resultis handle
$)

And frameno(handle) = VALOF
$(
   let offset = vec 1
   let number = vec 1

   // find frame no of photo
   //        
   g.ut.set32( m.ne.dataset.header.size +   // header
               (g.ne.s!m.ne.pictno) * 2,    // point at appropriate frame no.
               0,                           // high 16 bits = 0
               offset )                     // 32 bit value


   g.ut.add32( g.ne.s+m.ne.photoaddr, offset )  // point into data file

   g.dh.read(handle,offset,number,2) // read 2 bytes 
                                       
   !number := !number & #xFFFF       // ensure only 16 bits
   $<debug
      g.sc.movea(m.sd.display,m.sd.disX0,m.sd.disYtex)
      g.sc.rect(m.sd.clear,m.sd.disW,-m.sd.linW)
      g.sc.movea(m.sd.display,m.sd.disXtex,m.sd.disYtex)
      g.sc.ofstr("Pic %n Fr &%x4", g.ne.s!m.ne.pictno,!number)
   $>debug
   resultis !number
$)

And displaypicture(type,handle,frame) be
$(
   let result = TRUE

   // read in short and long captions, show photo and then captions
   if type = m.ne.screen | type = m.ne.none
   then
   $(
      UNLESS type = m.ne.none clearscreen()  
      shortcap(handle)   
      longcap(handle)    
      g.vh.frame(frame)
      g.vh.video(m.vh.video.on)
   $)

   IF (type = m.ne.none) | nulcap() RETURN // added 31.10.86 PAC

   result := show.sh.cap(type)    

   if result then show.long.cap(type)
$)

// find WORD offset to buffer area for photo captions
//
and calc.buff() = VALOF 
$( LET buff = m.ne.photo.data.size + g.ne.s!m.ne.max.pages*m.sd.pagelength
   RESULTIS g.ne.buff + buff/bytesperword
$)

And shortcap(handle) be  
$(
   let buff     = ?  
   let offset   = VEC 1 
   let result   = TRUE    
   let pic.no   = g.ne.s!m.ne.pictno-1

   // read in short captions to buffer
   // the buffer is at the end of the text page data in g.ne.buff
   //
   buff := calc.buff()

   g.ut.set32( m.ne.dataset.header.size + 2+ // header     
               g.ne.s!m.ne.nopics * 2 +      // the frame numbers
               pic.no*m.ne.scaplen,          // point at appropriate caption
               0,                            // high 16 bits = 0
               offset )                      // 32 bit value


   g.ut.add32( g.ne.s+m.ne.photoaddr, offset )  // point into data file

   g.dh.read(handle,offset,buff,m.ne.scaplen)

   // make room for length byte - shift up the caption by 1 byte
   for i=1 to m.ne.scaplen do buff%i := buff%(i-1) 
                 
   // strip trailing spaces
   //
   $( let len = m.ne.scaplen
      while (buff%len = m.ne.nul) | 
            (buff%len = '*s') & (len > 1) do len := len-1  
      buff%0 := len // set length byte 
   $)
$)

And show.sh.cap(type) = VALOF
$(
   let buff   = ?
   let result = TRUE

   // show short caption       
   //
   buff := calc.buff()

   test type = m.ne.screen
   then
   $(
      g.sc.movea(m.sd.display,centreit(),m.sd.linw*10)
      g.sc.odrop( buff )
   $)
   else
   $(
      if type = m.ne.print                 // initial blank line in print
      then result := g.ut.print( TABLE 0 ) 

      if result then result := printwrite(buff,type)

      if (type = m.ne.print) & result 
      then g.ut.print(TABLE 0)
   $)
   resultis result
$)

And centreit(ptr) = ( m.sd.disw - g.sc.width(ptr) )/2

And longcap(handle) be     // mod 31.10.86 PAC
$(
   let buff   = ?
   let offset = VEC 1
   let result = TRUE
   let pic.no = G.ne.s!m.ne.pictno - 1
   let bytes.in.caption = ?                       

   // read in long caption to buffer
   //
   buff := calc.buff() + m.ne.scaplen/bytesperword + 1
  
   bytes.in.caption := g.ne.s!m.ne.desc.size*m.ne.lcaplen 

   g.ut.set32( m.ne.dataset.header.size+2 +  // header     
               g.ne.s!m.ne.nopics *          // the frame numbers
               ( 2 + m.ne.scaplen ) +        // and short captions
               pic.no * bytes.in.caption,    // point at appropriate caption
               0,                            // high 16 bits = 0
               offset )                      // 32 bit value
                                            
   g.ut.add32( g.ne.s+m.ne.photoaddr, offset )  // point into data file

   g.dh.read(handle,offset,buff,bytes.in.caption)
$)

And show.long.cap(type) = VALOF
$(
   let buff   = ?
   let result = TRUE   
   let lbuff  = VEC m.ne.lcaplen/bytesperword + 1
   let os     = 0     
   let lcsize = g.ne.s!m.ne.desc.size

   buff := calc.buff() + m.ne.scaplen/bytesperword + 1 // points at the caption

   // display/print/write caption line by line
   //
   for j=0 to lcsize-1 do
   $(  
      lbuff%0 := m.ne.lcaplen

      for i=1 to m.ne.lcaplen do
      $( lbuff%i := buff%os; os := os + 1 $)

      test type = m.ne.screen
      then
      $(
         g.sc.movea( m.sd.display,m.sd.propXtex,(lcsize-j)*m.sd.linw )
         g.sc.odrop(lbuff)
      $)
      else if result then result := printwrite(lbuff,type)
   $)
   resultis result
$)

// print out or write line of caption
//    
And printwrite(buffptr,type) = VALOF
$(
   let result = ?

   test type = m.ne.print
   then
      resultis g.ut.print(buffptr)
   else
      resultis (g.ut.write( buffptr*bytesperword+1,
                            buffptr%0, m.ut.text) = m.ut.success )
$)

And updatemenu() be
$(
   let lastptr = ?      
   let pic.ptr = G.ne.s!m.ne.photoptr

   // update boxes 3,4,5 & 6 of menubar

   for i=m.ne.box3 to m.ne.box6 do g.ne.s!i := m.sd.act

   if nulcap()
   then for i=m.ne.box5 to m.ne.box6 do g.ne.s!i := m.wBlank

   g.ne.s!m.ne.at.end := m.ne.invalid
              
   lastptr := (G.ut.unpack16( g.ne.buff,(pic.ptr+1)*m.ne.rsize) =m.ne.invalid)|
              (pic.ptr = m.ne.phosize-1)
              
   if ( (g.ne.s!m.ne.fullset & (g.ne.s!m.ne.pictno = g.ne.s!m.ne.nopics)) |
        (~g.ne.s!m.ne.fullset & lastptr) ) &
      (g.context!m.page.no = g.ne.s!m.ne.nopages)
   then
   $(
      g.ne.s!m.ne.at.end := m.ne.lastpage
      g.ne.s!m.ne.box4 := m.wBlank
   $)

   if (pic.ptr = 0) &
      (g.context!m.page.no = 0) & (g.ne.s!m.ne.notitles <= 1) &
      ((g.ne.s!m.ne.fullset & (g.ne.s!m.ne.pictno = 1)) |
      ~g.ne.s!m.ne.fullset)
   then
   $(
         g.ne.s!m.ne.at.end := m.ne.firstpage
         g.ne.s!m.ne.box3 := m.wBlank
   $)
$)

And nulcap() = VALOF
$(
   let sc.is.nul, lc.is.nul = FALSE,FALSE
   let buff    = ?
   let lc.size = g.ne.s!m.ne.desc.size*m.ne.lcaplen

   // check whether both short and long captions are blank
   //
   buff := calc.buff() // points to start of short caption

   sc.is.nul := valof $( for i = 1 to m.ne.scaplen
                         if buff%i ~= '*S' resultis false
                         resultis true
                      $)
                       
   buff := buff + m.ne.scaplen/bytesperword + 1 // points at the long caption
                                                                            
   lc.is.nul := valof $( for i = 0 to lc.size-1 
                         if buff%i ~= '*S' resultis false
                         resultis true
                      $)

   resultis (sc.is.nul = lc.is.nul = TRUE)
$)

And clearscreen() be
$(
   g.sc.clear(m.sd.display)
   g.sc.clear(m.sd.message)
$)
.
