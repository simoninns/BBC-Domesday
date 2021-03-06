//  AES SOURCE  6.87

/**
         NE.NTEXT4 - Contents Display routines
         -------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.text

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         1.7.87   1        PAC     ADOPTED FOR AES
**/                                  

SECTION "NText4"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNEhd.h"
get "H/sdhd.h"
get "H/sihd.h"
get "H/dhhd.h"
get "H/nehd.h"
get "H/uthd.h"
get "H/vhhd.h"

/**
         G.NE.DISPLAYCONTENTS - routine to output Contents page to screen,
         ----------------------------------------------------------------
                                printer or floppy
                                -----------------


         INPUTS:

         Type of output : screen, printer or floppy

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.context!m.page.no set to 0

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:

         IF output is to screen
         THEN
            Prepare screen
         ENDIF
         Output header to screen, printer or floppy
         Extract titles from context area
         IF first title is not on page 1
         THEN
            Add "Introduction" title
         ENDIF
         Output list of titles
**/

LET g.ne.displaycontents(type) be
$(
   let notitles,i = 1,1
   let ptr    = 0
   let buff   = vec 40/bytesperword
   let result = TRUE
   let C = G.ne.s+m.ne.contents // word pointer to contents buffer         

   setglobals()  

   if type = m.ne.screen
   then
   $(
      g.sc.high(0,0,false,100)
      g.sc.pointer(m.sd.off)
      g.sc.clear(m.sd.display)
   $)

   result := showheader(type)

   buff%0 := m.ne.title.size + 4

   while (notitles <= g.ne.s!m.ne.notitles) do
   $(
      if (C%(ptr+1) ~= '1') & (notitles = 1)   // narsty frig to generate
      then                      // an 'intro' title if it doesn't exist
      $(
         LET intro = "  Introduction                   1"
         test type = m.ne.screen
         then g.sc.oplist(1,intro)
         else if result then result := NToplist(1,intro,type)
         i := i+1
      $)
                         
      if C%ptr = '0' then C%ptr := ' '         // stomp on leading zero

      // now set up the buffer; format is :   l=length, S=space, 
      // lSSccccccccccccccccccccccccccccSSnn  c=char,   n=digit
 
      for k =  1 to  2 do buff%k := '*S'         // 2 spaces  
      for k =  3 to 30 do buff%k := C%(ptr+k-1)  // then 28 bytes of title
      for k = 31 to 32 do buff%k := '*S'         // 2 more spaces
      for k = 33 to 34 do buff%k := C%(ptr+k-33) // put in the number 

      test type = m.ne.screen
      then g.sc.oplist(i,buff)
      else if result then result := NToplist(i,buff,type)

      notitles := notitles + 1
      ptr      := ptr+m.ne.title.size
      i        := i+1
   $)
   g.sc.pointer(m.sd.on)
$)

And setglobals() be
$(
   UNLESS g.ne.s!m.ne.pagetype = m.ne.text // only change if not already text
   DO g.vh.video(m.vh.micro.only) 

   g.context!m.page.no  := 0
   g.ne.s!m.ne.photoptr := m.ne.invalid
   g.ne.s!m.ne.pagetype := m.ne.text
   g.ne.s!m.ne.at.end   := m.ne.firstpage
   g.ne.s!m.ne.fullset  := FALSE
   g.ne.s!m.ne.box3     := m.wBlank
   g.ne.s!m.ne.box4     := m.wEnd
$)

And showheader(type) = VALOF
$(
   let result = true
   let title  = G.ne.s+m.ne.titlebuff                             

   // output header to screen, printer or floppy

   test type = m.ne.screen
   then
   $(
      drawbluebar()
      g.sc.movea( m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
      g.sc.selcol( m.sd.yellow)
      g.sc.oprop( title )
      g.sc.movea( m.sd.display,m.sd.disXtex,m.sd.disYtex)
      g.sc.selcol( m.sd.cyan)
   $)
   else
   $(
      test type = m.ne.print
      then
      $( 
         result := g.ut.print( TABLE 0 )                 // line feed
         if result then result := g.ut.print( title )
         if result then result := g.ut.print( TABLE 0 )  // ...another
      $)
      else
      $(
          result := g.ut.write( title*bytesperword+1, // byte address
                                title%0, m.ut.text)
          resultis (result = m.ut.success)
      $)
   $)
   resultis result
$)

And NToplist(itemno,textptr,type) = VALOF
$(
   LET len,see = 39,?
   LET buff    = vec 40/bytesperword // to do the output
   LET num     = vec  6/bytesperword // to convert number in
   LET result  = ?

   // output Contents line to printer or floppy taking itemno as parameter
   IF itemno > 9999
      THEN itemno := itemno REM 10000 // truncate itemno if too big

   TEST itemno = m.sd.seenumber
   THEN
   $( // add SEE line at bottom of Contents page
      for i=1 to 5 do buff%i := "See: "%i
      len := 38
   $)
   ELSE
   $(
      LET temp,sp = itemno,4  

      WHILE (temp > 0) DO $( sp := sp-1; temp := temp/10 $)
      g.vh.word.asc(itemno,num)
      for i = 1 to 4 do // strip leading zeroes 
      $(
         IF i <= sp THEN num%(i+1) := ' '
         buff%i := num%(i+1)
      $)
      buff%5 := ' '
   $)         

   buff%0 := len; for i=6 to len do buff%i := textptr%(i-5)    

   TEST type = m.ne.print
   THEN resultis g.ut.print(buff)
   ELSE resultis ( g.ut.write( buff*bytesperword+1,
                   buff%0, m.ut.text ) = m.ut.success )
$)

AND drawbluebar() be
$(
   g.sc.selcol(m.sd.blue)
   g.sc.movea(m.sd.message,0,0)
   g.sc.rect(m.sd.plot,m.sd.mesw-1,m.sd.mesh-1)
$)
.
