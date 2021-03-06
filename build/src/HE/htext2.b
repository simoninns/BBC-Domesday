//  AES SOURCE  6.87

/**
         HE.HTEXT2 - PAGE DISPLAY ROUTINES FOR HELPTEXT
         ----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         1.7.87   1        PAC     ADOPTED FOR AES    
         8.7.87   2        PAC     Mods for helptext
**/                                         

SECTION "HelpText2"

get "H/libhdr.h"    

get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/dhhd.h"
get "H/nehd.h"
get "H/uthd.h"
get "H/vhhd.h"

/**
         G.he.DISPLAYPAGE - routine to output text page to screen,
         --------------------------------------------------------
                            printer or floppy
                            ----------------

         INPUTS:

         Type of output : none, screen, printer or floppy

         OUTPUTS:

         None

         GLOBALS MODIFIED:

         None

         SPECIAL NOTES FOR CALLERS:

         Extra parameter added so that a call to displaypage
         will re-read current data into store, but not change
         screen output.

         PROGRAM DESIGN LANGUAGE:

         Set globals for textpage
         IF textpage to be shown is not in buffer
         THEN
            read in text
         ENDIF

         IF type is 'none', then exit.

         Find start of text
         Check if page is to be proportionally spaced
         Show page header
         Output page
         RETURN
**/

LET G.he.displaypage(type) be
$(
   let propspaced,firstpic = TRUE,0
   let result = TRUE
   let tptr   = ?
   let oldptr = G.sc.pointer( m.sd.off )
   let tab.char = ?

   setglobals()

   if (G.he.s!m.ne.firstinbuff = m.ne.invalid) |
      (g.context!m.page.no < G.he.s!m.ne.firstinbuff) |
      (g.context!m.page.no >= (G.he.s!m.ne.firstinbuff +
       G.he.s!m.ne.max.pages))
   then read.data()

  // added 5.9.86 PAC
  // we've got the data, BUT don't display anything
  // so do an early exit - called on return from help
  //
  IF type = m.ne.none
  THEN $( G.sc.pointer(oldptr) ; RETURN $)
                                      
  // set up byte offset from start of G.he.buff to the page we want
  //
  tptr :=  m.ne.photo.data.size + 
          (g.context!m.page.no - G.he.s!m.ne.firstinbuff)*m.sd.pagelength

  if ((G.he.buff%tptr) & #x80) ~= 0  // extra code added 12.8.86 PAC
  then
  $( propspaced     := FALSE
     G.he.buff%tptr := G.he.buff%tptr & #x7F // mask top bit
  $)  

  result := outputheader(type)
  test type = m.ne.screen
  then
  $(
     type := m.sd.screen.page
     g.sc.clear(m.sd.display)
  $)
  else
  $(   test type = m.ne.print
       then type := m.sd.print.page
       else type := m.sd.write.page
  $)
  if result then
  g.sc.opage( G.he.buff,
              m.sd.invalid,
              (G.he.s!m.ne.max.pages)*m.sd.pagelength,
              m.sd.invalid,
              tptr,
              m.sd.invalid,
              propspaced,
              type,
              G.he.s!m.ne.pagebuff )

  updatemenu()

  unless propspaced                
  do G.he.buff%tptr := (G.he.buff%tptr) | #x80 // reset top bit

  G.sc.pointer( oldptr )
$)

//
// This routine actually reads in the text data from the videodisc
//
// Note that it it allows for a few backwards pages, so if current page
// is number 8, it will read data for pages 5,6,7,8 and as many more
// beyond as it can fit into its buffer. 32 bit maths is necessary for
// essays longer than 64k. (there are ~3 of these on the Domesday discs !)
//
AND read.data() BE
$(
   LET startpage,starttext = ?,?
   LET bytes.to.read = ?
   LET max.pg  = G.he.s!m.ne.max.pages
   LET num.pg  = G.he.s!m.ne.nopages
   LET handle  = ?
   LET ptr     = VEC 1
   LET len32   = VEC 1    // addr of EOF
   LET bytes32 = VEC 1    // len - ptr
   LET psize32 = VEC 1    // size of 'n' pages - added 23.9.86
                  
   handle := G.he.s!m.ne.text.is.data2 -> G.he.s!m.ne.D2.handle,
                                          G.he.s!m.ne.D1.handle

   bytes.to.read := (max.pg < num.pg -> max.pg, num.pg) * m.sd.pagelength

   G.dh.length( handle, len32 )
     
   G.ut.set32( bytes.to.read, 0, bytes32 )    // set up bytes to read    
   G.ut.set32( m.sd.pagelength, 0, psize32 )  // set up page size (bytes)

   // first select the 'start page' for data buffer within the essay
   startpage := g.context!m.page.no - (G.he.s!m.ne.max.pages/3)
   if startpage < 1 then startpage := 1

   G.ut.set32( startpage-1, 0 ,ptr ) // make it a 32 bit quantity 

   G.ut.mul32( psize32, ptr ) // multiply start page number by page size

   // this is the space taken by the page titles, etc.  
   //
   starttext := m.ne.article.title.offset + 
                (G.he.s!m.ne.nopages+1)*m.ne.title.size

   // re-use the psize32 vector to do the addition    
   //
   G.ut.set32( starttext, 0, psize32 )   // 32 bit value for text start

   G.ut.add32( psize32, ptr )            // add offset for titles stuff

   // By now we have calculated the offset from the start of the essay to
   // the first page of text to be read into the buffer, taking account of
   // the page titles etc., which are found in front of the actual text
   // pages within the essay data item ( see Videodisc structures doc.).
   // Next, we add this value to the item address, which gives a final
   // offset into the data file. We are then ready to read.

   G.ut.add32( G.he.s+m.ne.itemaddress,ptr) // now set pointer into DATA1/2

   // check that we're not going to read past EOF

   IF g.ut.cmp32( ptr, len32 ) = m.gt // right over the end of file
   THEN G.ut.trap("NE",10,TRUE,1,1,0,0)

   g.ut.sub32( ptr, len32)                // len32 := space between ptr & EOF

   IF g.ut.cmp32( bytes32, len32 ) = m.gt // we would go over
   THEN bytes.to.read := len32!0             // just read to EOF
                                           
   // now read data into the buffer, putting it just above the photo data
   //
   g.dh.read( handle,
              ptr,
              G.he.buff + m.ne.photo.data.size/bytesperword, 
              bytes.to.read )

   G.he.s!m.ne.firstinbuff := startpage
$)


And setglobals() be
$(
   UNLESS G.he.s!m.ne.pagetype = m.ne.text 
   DO g.vh.video(m.vh.micro.only)

   G.he.s!m.ne.pagetype := m.ne.text
   G.he.s!m.ne.photoptr := m.ne.invalid
   G.he.s!m.ne.fullset  := FALSE
$)

And updatemenu() be
$(
   let more = false

   for i=m.ne.box3 to m.ne.box6 do G.he.s!i := m.sd.act

   G.he.s!m.ne.at.end := m.ne.invalid

   if (g.context!m.page.no = 1) & (G.he.s!m.ne.notitles <=1)
   then
   $( // check first page is not a photo
      unless ( (G.he.s!m.ne.type = m.ne.picessay) &
               (g.ut.unpack16(G.he.buff,0) <= 0) )
      do
      $(
         G.he.s!m.ne.at.end := m.ne.firstpage
         G.he.s!m.ne.box3   := m.wBlank
      $)
   $)

   if (g.context!m.page.no = G.he.s!m.ne.nopages)
   then        
   $(
      let i = 0
      if G.he.s!m.ne.type = m.ne.picessay
      then
      $( // check if any more picture pages after this textpage
         while i < m.ne.phosize & ~more do
         $(
            test g.ut.unpack16(G.he.buff,i*m.ne.rsize) = g.context!m.page.no
            then more := true
            else i    := i+1       // increment pointer
         $)
      $)
      unless more do
      $(
         G.he.s!m.ne.at.end := m.ne.lastpage
         G.he.s!m.ne.box4   := m.wBlank
      $)
   $)
$)

And outputheader(type) = VALOF
$(
   let len,result = ?,TRUE

   test type = m.ne.screen
   then
   $(
      drawbluebar()
      test (G.he.s!m.ne.notitles <= 1) & (g.context!m.page.no = 1)
      then
      $( // show article title on first textpage if no Contents page
         // and move Page 1 of .. to right to give room for title
         g.sc.movea(m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
         g.sc.selcol(m.sd.yellow)
         g.sc.oprop(G.he.s+m.ne.titlebuff)
         len := 13
      $)
      else len := 16   

      g.sc.movea(m.sd.message,m.sd.mesXtex+m.sd.mesw-m.sd.charwidth*len,
                 m.sd.mesYtex)
      g.sc.selcol(m.sd.cyan)

      // mod of 25.9.86 - on chained essays, output More... on all but last page
      TEST chained.essays() ~= 0
      THEN UNLESS chained.essays() = m.ne.lastpage
        DO $( G.sc.movea(m.sd.message,m.sd.mesW-m.sd.charwidth*10,m.sd.mesYtex)
              G.sc.ofstr("More...")
           $)
      ELSE G.sc.ofstr("Page %n of %n",g.context!m.page.no,
                                 G.he.s!m.ne.nopages)
   $)
   else    
      result := printwrite(type)
   resultis result
$)

And printwrite(type) = VALOF
$(
   let buff = vec 40/bytesperword
   let num  = vec  6/bytesperword  
   let page,no,p = ?,?,?
   let result = TRUE

   if type = m.ne.print then result := g.ut.print( TABLE 0 )

   // prepare for printing or writing page
   if (G.he.s!m.ne.notitles <= 1) & (g.context!m.page.no = 1)
   then
   $(
      buff%0 := m.ne.title.size
      for i=1 to 30 do buff%i := (G.he.s+m.ne.titlebuff)%i   
      if result then result := doprintwrite(type,buff) 
   $)
   buff%0 := m.ne.title.size + 9
   for i=1 to m.ne.title.size + 9 do buff%i := ' ' // initialise buffer

   TEST chained.essays() ~= 0
   THEN UNLESS chained.essays() = m.ne.lastpage DO
   $(
      page := "More..."                          
      for i = 29 to 35 do buff%i := page%(i-28)   // set up string
   $)
   ELSE
   $(
      page := "Page     of "

      for i = 25 to 36 do buff%i := page%(i-24) // set up string

      for j = 1 to 2 do  // work out page no digits
      $(
         test j=1
         then $( no := g.context!m.page.no ; p := 30 $)
         else $( no := G.he.s!m.ne.nopages ; p := 37 $)
         g.vh.word.asc(no,num)

         // suppress leading zeroes - modified 22.10.86 PAC
         for i=1 to num%0 do test num%i = '0' then num%i := '*s' else break

         for i=p to p+2 do buff%i := num%(i-p+3) // insert 3rd,4th & 5th byte in num
      $)
   $)

   if result
   then resultis doprintwrite(type,buff) // return value added 25.9.86 PAC
   resultis false                        // must have failed
$)

// print or write page - considerably simplified PAC 14.10.86
And doprintwrite(type,buff) = VALOF
$(
   TEST type = m.ne.print
   THEN
      RESULTIS g.ut.print(buff)
   ELSE
      RESULTIS( g.ut.write(buff*bytesperword+1,buff%0,m.ut.text)=m.ut.success )
$)

// this added by PAC 25.9.86
//
// it returns 0 if essays are not chained (second and third item
// addresses are BOTH invalid - i.e. equal to -1)
// it returns a non-zero result if essays are chained, and this is
// set to m.ne.lastpage ONLY when the current essay is the last
// one in the chain, AND the current page is the last page in the
// essay. (Not a very elegant routine, I'm afraid)
//
AND chained.essays() = 0

/* chained.essays() REMOVED for HELPTEXT - always returns FALSE now.
   This is because we use the second item address for other
   purposes, which would confuse this routine.

VALOF
$(
   LET essay.no = G.he.s!m.ne.essay.no
   LET minus.one = VEC 1
   LET two.invalid   = FALSE
   LET three.invalid = FALSE

   G.ut.set32( -1,-1,minus.one )

   two.invalid   := g.ut.cmp32( G.context+m.itemadd2, minus.one ) = m.eq
   three.invalid := g.ut.cmp32( G.context+m.itemadd3, minus.one ) = m.eq 
                 
   IF (two.invalid & three.invalid) RESULTIS 0

   // test for last page of last essay
   // last essay is either the third, or the second when there's only 2
   // last page is when the page number = number of pages

   IF (essay.no = 3) | ((essay.no = 2) & two.invalid)
   THEN IF (G.he.s!m.ne.nopages = g.context!m.page.no) // test last page
   THEN RESULTIS m.ne.lastpage

   RESULTIS m.ne.lastpage + 1   // not on last essay
$)
*/

AND drawbluebar() be
$(
   g.sc.selcol(m.sd.blue)
   g.sc.movea(m.sd.message,0,0)
   g.sc.rect(m.sd.plot,m.sd.mesw-1,m.sd.mesh-1)
$)
.
