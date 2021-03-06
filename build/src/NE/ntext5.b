//  AES SOURCE  6.87

/**
         NE.NTEXT5 - Paging routines for for National Essay
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.text

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         1.7.87   1        PAC     ADOPTED FOR AES
**/               

SECTION "NText5"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glNEhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/dhhd.h"
get "H/nehd.h"
get "H/uthd.h"

/**
         G.NE.TRYTOPAGE - routine to page through essay
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

Let g.ne.trytopage(direction) be
$(
   LET pages  = g.ne.s!m.ne.nopages 
   LET at.end = g.ne.s!m.ne.at.end

   test direction = m.ne.back
   then
   $(
      test (at.end = m.ne.firstpage) |
           ( (at.end = m.ne.lastpage) &
             (g.ne.s!m.ne.type = m.ne.nessay) &  
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
   if g.ne.s!m.ne.fullset
   then
   $(
      test g.ne.s!m.ne.pictno + 1 <= g.ne.s!m.ne.nopics
      then g.ne.displayphoto(m.ne.screen,m.ne.for)
      else g.ne.s!m.ne.fullset := FALSE
   $)
   // if not in a full set of photos, show single photo or text page
   //
   unless g.ne.s!m.ne.fullset do
   $(
      if g.ne.s!m.ne.type = m.ne.picessay
      then next := nextphoto()

      test next
      then g.ne.displayphoto(m.ne.screen,m.ne.for)
      else
      $(
         test (g.context!m.page.no < g.ne.s!m.ne.nopages)
         then
         $(
            g.context!m.page.no := g.context!m.page.no + 1
            g.ne.displaypage(m.ne.screen)
         $)
         else // can't page forwards
         $(
            g.sc.beep()  
            g.ne.s!m.ne.at.end := m.ne.lastpage
            g.ne.s!m.ne.fullset := TRUE
         $)
      $)
   $)
$)
     
// test whether the next page is a photo 
//
AND nextphoto() = VALOF
$(
   let ptr,next = 0,FALSE

   UNLESS g.context!m.page.no <= g.ne.s!m.ne.nopages RESULTIS FALSE

   if g.ne.s!m.ne.photoptr = m.ne.invalid then
   $(    
      let pp,tp = ?, g.context!m.page.no  
      let os,i  = 0,0

      // look for the current page number in the photo data
      //    
      $(    
         pp := G.ut.unpack16( g.ne.buff, os )

         test pp = tp
         then
         $(
            next := TRUE
            g.ne.s!m.ne.photoptr := i
            g.ne.s!m.ne.pictno   := G.ut.unpack16.signed( g.ne.buff, os+6 )  
            // finally, set up item address       
            set.up.photoaddress( os+2 )
         $)
         else $( i := i+1; os := os + m.ne.rsize $)

      $) REPEATUNTIL (pp = -1) | (i > 25) | next | (pp > tp)

      RESULTIS next
   $)

   // test page no of next photo in data
   //             
   ptr := (g.ne.s!m.ne.photoptr+1)*m.ne.rsize 

   if G.ut.unpack16( g.ne.buff, ptr ) = g.context!m.page.no
   then
   $(                                   
      next := TRUE
      g.ne.s!m.ne.photoptr := g.ne.s!m.ne.photoptr + 1
      g.ne.s!m.ne.pictno   := G.ut.unpack16.signed( g.ne.buff, ptr+6 )
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
   if g.ne.s!m.ne.fullset then
   $(
      test g.ne.s!m.ne.pictno > 1
      then g.ne.displayphoto(m.ne.screen,m.ne.back)    
      else g.ne.s!m.ne.fullset := FALSE
   $)                           

   unless g.ne.s!m.ne.fullset do
   $(
      // page back on first textpage of photos with pageno 0 in photo data
      test ((page = 0) & (g.ne.s!m.ne.pagetype = m.ne.picture)) |
           ((page = 1) & (g.ne.s!m.ne.pagetype = m.ne.text))
      then
      $(
         test lastisphoto( page )
         then $( g.context!m.page.no := 0
                 g.ne.displayphoto(m.ne.screen,m.ne.back)
              $)
         else if g.ne.s!m.ne.notitles > 1
              then g.ne.displaycontents(m.ne.screen)
      $)
      else
      $(
         // page backwards in essay
         if (g.ne.s!m.ne.pagetype = m.ne.text) | 
            (page > g.ne.s!m.ne.nopages)
         then page := page -1
         
         g.context!m.page.no := page

         test lastisphoto( page )
         then g.ne.displayphoto(m.ne.screen,m.ne.back)
         else g.ne.displaypage(m.ne.screen)
      $)
   $)
$)

And lastisphoto(page) = VALOF
$(
   let next,ptr = FALSE,?

   unless g.ne.s!m.ne.type = m.ne.picessay resultis false

   // test if previous page is a photo

   // look in photo data for photo with appropriate page no
   //
   if g.ne.s!m.ne.photoptr = m.ne.invalid then
   $( 
      let tp,pp = page, ?
      let os, i = 24*m.ne.rsize,24    

      $(     
         pp := G.ut.unpack16( g.ne.buff, os )

         test pp = tp
         then
         $(
            next := TRUE
            g.ne.s!m.ne.photoptr := i
            g.ne.s!m.ne.pictno   := G.ut.unpack16.signed( g.ne.buff, os+6 )
            set.up.photoaddress( os+2 )
         $)
         else 
         $( i := i-1; os := os-m.ne.rsize $)

      $) repeatuntil ((pp ~= -1) & (pp < tp)) | next | (i < 0)

      RESULTIS next
   $)              

   // look at page no of previous photo in photo data
   //  
   ptr := (g.ne.s!m.ne.photoptr-1)*m.ne.rsize // pointer to previous photo rec.

   unless g.ne.s!m.ne.photoptr > 0 resultis false 

   if G.ut.unpack16( g.ne.buff, ptr ) = page then
   $(
      next := TRUE
      g.ne.s!m.ne.photoptr := g.ne.s!m.ne.photoptr - 1
      g.ne.s!m.ne.pictno   := G.ut.unpack16.signed( g.ne.buff, ptr + 6 )
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
                              
   g.ut.unpack32( g.ne.buff, offset, g.ne.s+m.ne.photoaddr )   

   IAL := g.ut.get32( g.ne.s+m.ne.photoaddr, @IAH )   // extract address
   g.ne.s!m.ne.photo.is.data2 := (IAH & #x8000) ~= 0  // set flag
   IAH := IAH & #x7FFF                                // strip top bit
   g.ut.set32 (IAL, IAH, g.ne.s+m.ne.photoaddr ) // and save it
$)

And nextessay() be
$(
   let essay.no  = g.ne.s!m.ne.essay.no
   let ess2      = VEC 1
   let ess3      = VEC 1       
   let minus.one = VEC 1

   g.ut.set32( -1,-1, minus.one )

   g.ut.mov32( g.context+m.itemadd2, ess2 )
   g.ut.mov32( g.context+m.itemadd3, ess3 )

   // show first page of next essay        
   //
   test (essay.no = 1 & (g.ut.cmp32( ess2, minus.one) ~= m.eq )) |
        (essay.no = 2 & (g.ut.cmp32( ess3, minus.one) ~= m.eq )) 
   then
   $(
      test essay.no = 1
      then $(
              g.ut.mov32( g.ne.s+m.ne.itemaddress, g.ne.s+m.ne.firstaddr )
              g.ut.mov32( ess2, g.context+m.itemaddress )
              g.ne.s!m.ne.essay.no := 2 
           $)    

      else $( g.ut.mov32( ess3, g.context+m.itemaddress )     
              g.ne.s!m.ne.essay.no := 3
           $)
      g.ne.essini(m.ne.for)
   $)
   else g.sc.beep()
$)

And lastessay() be
$(
   let essay.no  = g.ne.s!m.ne.essay.no

   // show last page of previous essay
   //
   test essay.no ~= 1
   then
   $(
     test essay.no = 2
     then $( g.ut.mov32( g.ne.s+m.ne.firstaddr, g.context+m.itemaddress )
             g.ne.s!m.ne.essay.no := 1
          $)
     else $( g.ut.mov32( g.context+m.itemadd2, g.context+m.itemaddress )
             g.ne.s!m.ne.essay.no := 2
          $)
     g.ne.essini(m.ne.back)
   $)
   else g.sc.beep()
$)
.
