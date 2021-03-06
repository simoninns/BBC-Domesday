//  AES SOURCE  6.87

/**
         HE.HTEXT5 - Paging routines for for Helptext
         --------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         1.7.87   1        PAC     ADOPTED FOR AES
         8.7.87   2        PAC     Got for helptext
                                   - chained essay code 
                                     modified
**/               

SECTION "HelpText5"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/dhhd.h"
get "H/nehd.h"
get "H/hehd.h"
get "H/uthd.h"

/**
         G.he.TRYTOPAGE - routine to page through essay
         ----------------------------------------------


         INPUTS:

         Direction : current direction of paging

         OUTPUTS:

         None

         GLOBALS MODIFIED:

         G.context!m.page.no incremented or decremented as appropriate


         SPECIAL NOTES FOR CALLERS:

         "Fullset" pictures (where the "picture no." is -1) are treated
         differently to single photos as it must be possible to page back
         and forward within a full photoset, as well as between single photos.


         PROGRAM DESIGN LANGUAGE:

         IF direction = backwards
         THEN
            IF on first page of essay
            THEN
               look for previous essay
            ELSE
               page backwards
               update menubar
            ENDIF
         ELSE
            IF on last page of essay
            THEN
               look for next essay
            ELSE
               page forwards
               update menubar
            ENDIF
         ENDIF

**/

Let G.he.trytopage(direction) be
$(
   LET pages  = G.he.s!m.ne.nopages 
   LET at.end = G.he.s!m.ne.at.end

   test direction = m.ne.back
   then
   $(
      test (at.end = m.ne.firstpage) |
           ( (at.end = m.ne.lastpage) &
             (G.he.s!m.ne.type = m.ne.nessay) &  
             (pages = 1) )
      then lastessay()
      else pageback()
   $)
   else
   $(
      test (at.end = m.ne.lastpage)
      then
         nextessay()
      else
         pageforwards()
   $)
$)

And pageforwards() be
$(
   let next = FALSE

   // show following page
   // if in a full set of photos then show next photo in set
   //
   if G.he.s!m.ne.fullset
   then
   $(
      test G.he.s!m.ne.pictno + 1 <= G.he.s!m.ne.nopics
      then G.he.displayphoto(m.ne.screen,m.ne.for)
      else G.he.s!m.ne.fullset := FALSE
   $)
   // if not in a full set of photos, show single photo or text page
   //
   unless G.he.s!m.ne.fullset do
   $(
      if G.he.s!m.ne.type = m.ne.picessay
      then next := nextphoto()

      test next
      then G.he.displayphoto(m.ne.screen,m.ne.for)
      else
      $(
         test (g.context!m.page.no < G.he.s!m.ne.nopages)
         then
         $(
            g.context!m.page.no := g.context!m.page.no + 1
            G.he.displaypage(m.ne.screen)
         $)
         else // can't page forwards
         $(
            g.sc.beep()  
            G.he.s!m.ne.at.end := m.ne.lastpage
            G.he.s!m.ne.fullset := TRUE
         $)
      $)
   $)
$)
     
// test whether the next page is a photo 
//
AND nextphoto() = VALOF
$(
   let ptr,next = 0,FALSE

   UNLESS g.context!m.page.no <= G.he.s!m.ne.nopages RESULTIS FALSE

   if G.he.s!m.ne.photoptr = m.ne.invalid then
   $(    
      let pp,tp = ?, g.context!m.page.no  
      let os,i  = 0,0

      // look for the current page number in the photo data
      //    
      $(    
         pp := G.ut.unpack16( G.he.buff, os )

         test pp = tp
         then
         $(
            next := TRUE
            G.he.s!m.ne.photoptr := i
            G.he.s!m.ne.pictno   := G.ut.unpack16.signed( G.he.buff, os+6 )  
            // finally, set up item address       
            set.up.photoaddress( os+2 )
         $)
         else $( i := i+1; os := os + m.ne.rsize $)

      $) REPEATUNTIL (pp = -1) | (i > 25) | next | (pp > tp)

      RESULTIS next
   $)

   // test page no of next photo in data
   //             
   ptr := (G.he.s!m.ne.photoptr+1)*m.ne.rsize 

   if G.ut.unpack16( G.he.buff, ptr ) = g.context!m.page.no
   then
   $(                                   
      next := TRUE
      G.he.s!m.ne.photoptr := G.he.s!m.ne.photoptr + 1
      G.he.s!m.ne.pictno   := G.ut.unpack16.signed( G.he.buff, ptr+6 )
      // and set up item address
      set.up.photoaddress( ptr+2 )
   $)
   resultis next
$)

And pageback() be
$(
   let page,last = ?,FALSE

   // show previous page
   page := g.context!m.page.no      

   // test if paging back within a fullset of photos, and if so then decrement
   // pictno within set. Else if on last pict. in set, set priv. global to FALSE   //
   if G.he.s!m.ne.fullset then
   $(
      test G.he.s!m.ne.pictno > 1
      then G.he.displayphoto(m.ne.screen,m.ne.back)    
      else G.he.s!m.ne.fullset := FALSE
   $)                           

   unless G.he.s!m.ne.fullset do
   $(
      // page back on first textpage of photos with pageno 0 in photo data
      test ((page = 0) & (G.he.s!m.ne.pagetype = m.ne.picture)) |
           ((page = 1) & (G.he.s!m.ne.pagetype = m.ne.text))
      then
      $(
         test lastisphoto( page )
         then $( g.context!m.page.no := 0
                 G.he.displayphoto(m.ne.screen,m.ne.back)
              $)
         else if G.he.s!m.ne.notitles > 1
              then G.he.displaycontents(m.ne.screen)
      $)
      else
      $(
         // page backwards in essay
         if (G.he.s!m.ne.pagetype = m.ne.text) | 
            (page > G.he.s!m.ne.nopages)
         then page := page -1
         
         g.context!m.page.no := page

         test lastisphoto( page )
         then G.he.displayphoto(m.ne.screen,m.ne.back)
         else G.he.displaypage(m.ne.screen)
      $)
   $)
$)

And lastisphoto(page) = VALOF
$(
   let next,ptr = FALSE,?

   unless G.he.s!m.ne.type = m.ne.picessay resultis false

   // test if previous page is a photo

   // look in photo data for photo with appropriate page no
   //
   if G.he.s!m.ne.photoptr = m.ne.invalid then
   $( 
      let tp,pp = page, ?
      let os, i = 24*m.ne.rsize,24    

      $(     
         pp := G.ut.unpack16( G.he.buff, os )

         test pp = tp
         then
         $(
            next := TRUE
            G.he.s!m.ne.photoptr := i
            G.he.s!m.ne.pictno   := G.ut.unpack16.signed( G.he.buff, os+6 )
            set.up.photoaddress( os+2 )
         $)
         else 
         $( i := i-1; os := os-m.ne.rsize $)

      $) repeatuntil ((pp ~= -1) & (pp < tp)) | next | (i < 0)

      RESULTIS next
   $)              

   // look at page no of previous photo in photo data
   //  
   ptr := (G.he.s!m.ne.photoptr-1)*m.ne.rsize // pointer to previous photo rec.

   unless G.he.s!m.ne.photoptr > 0 resultis false 

   if G.ut.unpack16( G.he.buff, ptr ) = page then
   $(
      next := TRUE
      G.he.s!m.ne.photoptr := G.he.s!m.ne.photoptr - 1
      G.he.s!m.ne.pictno   := G.ut.unpack16.signed( G.he.buff, ptr + 6 )
      set.up.photoaddress( ptr+2 )
   $)      

   resultis next
$)


// this sets flag to show which data file photo data is in
// and also tidies up our own copy of the item address
//        
And set.up.photoaddress(offset) be
$(
   let IAL, IAH = ?,? // components of the item address
                              
   g.ut.unpack32( G.he.buff, offset, G.he.s+m.ne.photoaddr )   

   IAL := g.ut.get32( G.he.s+m.ne.photoaddr, @IAH )   // extract address
   G.he.s!m.ne.photo.is.data2 := (IAH & #x8000) ~= 0  // set flag
   IAH := IAH & #x7FFF                                // strip top bit
   g.ut.set32 (IAL, IAH, G.he.s+m.ne.photoaddr ) // and save it
$)
                  

// MODIFICATIONS for HELPTEXT - the routines nextessay()
// and lastessay() are completely changed to use the stack
// mechanism for next/previous addresses.
//

And nextessay() be
$(
   let minus.one = VEC 1

   g.ut.set32( -1,-1, minus.one )

   test g.ut.cmp32( g.context+m.itemadd2, minus.one ) = m.eq 
   then 
      g.sc.beep() // we're at the end of the chain
   else
   $(
      push32.( G.context+m.itemaddress )

      G.ut.mov32( G.context+m.itemadd2, G.context+m.itemaddress )

      G.he.essini( m.ne.for )
   $)
$)

And lastessay() be
$(
   let essay.no  = G.he.s!m.ne.essay.no

   // show last page of previous essay
   //
   test g.he.work!m.he.esstackptr = 0
   then   
      g.sc.beep() // we're at the end of the chain
   else
   $(
      G.ut.mov32( G.context+m.itemaddress, G.context+m.itemadd2 )
      
      pop32.( G.context+m.itemaddress ) 

      G.he.essini( m.ne.back )
   $)
$)                   

AND push32.( a32adr ) BE
$(
   LET sp  = G.he.work!m.he.esstackptr  
   LET stk = G.he.work+m.he.esstack          

   G.ut.mov32( a32adr, stk + sp )
   sp := sp + 4/bytesperword // moved 4 bytes  

   G.he.work!m.he.esstackptr := sp

   G.ut.trap("HE",1,true,3,sp,0,m.he.stacksize ) 
$)
  
AND pop32.( a32adr ) BE   
$(
   LET sp  = G.he.work!m.he.esstackptr 
   LET stk = G.he.work+m.he.esstack   

   sp := sp - 4/bytesperword          // move 4 bytes
   G.ut.mov32( stk + sp, a32adr )
                       
   G.he.work!m.he.esstackptr := sp

   G.ut.trap("HE",2,true,3,sp,0,m.he.stacksize )
$)
.
