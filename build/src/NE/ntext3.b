//  AES SOURCE  6.87

/**
         NE.NTEXT3 - ROUTINE TO CHECK 'FIGURE' SELECTION
         -----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.text

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         1.7.87   1        PAC     ADOPTED FOR AES    
         23.7.87  2        PAC     Fix gotofig bug
**/                                         

SECTION "NText3"

get "H/libhdr.h"    

get "GH/glhd.h"
get "GH/glNEhd.h"
get "H/sdhd.h"
get "H/nehd.h"

/**
         G.NE.LOOKFORFIG - routine to determine if a figure has been selected
         --------------------------------------------------------------------


         INPUTS:

         none

         OUTPUTS:

         TRUE if the user has selected a Figure

         GLOBALS MODIFIED:

         G.context!m.picture.no set to appropriate picture no for exit to
         National Photo Operation

         SPECIAL NOTES FOR CALLERS:

         Only deals with 2 digit numbers as last entry in [string]

         PROGRAM DESIGN LANGUAGE:

         Check if page is displayed proportionally spaced
         Find current lineno of pointer
         Look for '[' on this line to left of pointer
         IF found '[' as required
         THEN
            Look for ']' on right of pointer
            IF found ']' as required
            THEN
               Find number enclosed in brackets working backwards from
               closing bracket ignoring 'leading' spaces
            ELSE
               set result to invalid
            ENDIF
        ELSE
           set result to invalid
        ENDIF
        IF result is valid
        THEN                 
           set up photo item addresss
           RETURN TRUE
        ENDIF
**/

LET g.ne.lookforfig() = VALOF
$(
   let xpos,margin = g.xpoint,m.sd.propXtex - m.sd.disXtex
   let ypos,ptr,x  = m.ne.nolines - g.ypoint/m.sd.linw,?,0
   let no,fig,k    = m.ne.invalid,FALSE,?
   let propspaced,p,past = TRUE,?,?
   let i,disc,disx = 1,?,?
                 
   let st = G.ne.buff
   let os = m.ne.photo.data.size +  // this calculation duplicated in ntext2
            (g.context!m.page.no - g.ne.s!m.ne.firstinbuff)*m.sd.pagelength
       
   if ((st%os & #x80) ~= 0) then propspaced := FALSE // a tabular text page

   os := os + (m.sd.linelength*(ypos-1)) // first char of current line   

   while ~fig & (x < m.sd.linelength) do
   $(
      if st%(os+x) = '['
      then
      $(
         disx := width(x,st, os,propspaced) + 4    

         if propspaced then disx := disx + margin

         test xpos > disx
         then
         $(
            k:=x
            past := FALSE
            while (k < m.sd.linelength) & ~fig & ~past do
            $(
               if st%(os+k) = ']'
               then
               $(
                  // add also leading space and char. width
                  disc := width(k,st,os,propspaced) + m.sd.charwidth 
                  if (propspaced~=0)
                  then disc := disc + margin - 4  // minus trailing space of ']'
                  test xpos <= disc
                  then
                  $(
                     fig := TRUE
                     while st%(os+k-i) = ' ' do i := i+1    

                     test '0' <= st%(os+(k-i-1)) <= '9'
                     then p := (st%(os+(k-i-1)) - '0')*10      
                     else p := 0

                     test '0' <= st%(os+(k-i)) <= '9'
                     then no := st%(os+(k-i)) - '0' + p
                     else no := m.ne.invalid
                  $)
                  else past := TRUE
               $)
               k := k+1
            $)
         $)
         else
         $(
            fig := TRUE
            no := m.ne.invalid
         $)
      $)
      x := x+1
   $)                                 

   IF no = m.ne.invalid RESULTIS FALSE

   RESULTIS set.up.address(no)  
$)

And width(length,wordaddress,offset,propspaced) = VALOF
$(
   let tot,sp = 0,?

   test propspaced  // find width of proportionally spaced string
   then
   $(
      for i=0 to length-1 do
      $(
         sp := g.sc.spacing%((wordaddress)%(offset+i) - ' ')
         tot := tot + m.sd.charwidth - (sp & #xF) - (sp >> 4)
      $)
      resultis tot
   $)
   else  // find width of non-prop.spaced string
      resultis (length*m.sd.charwidth)
$)

And set.up.address(picno) = VALOF
$(
   let itemaddr = vec 1
   let pnum     = g.context+m.picture.no  // added 21.10.86 PAC
   let lo,hi    = ?,?
   let photo.data.offset = (picno-1)*m.ne.rsize   

   // set globals and exit to national photo overlay
   // .. first unpack the item address                                         
   //
   G.ut.unpack32( g.ne.buff, photo.data.offset + 2, itemaddr )
                   
   lo := g.ut.get32( itemaddr, @hi )

   UNLESS( hi = lo = -1 ) & (picno ~= m.ne.invalid)
   DO
   $(
      !pnum := G.ut.unpack16.signed( G.ne.buff, photo.data.offset + 6 )
      if !pnum <= 0 then !pnum := 1 // fix 21.10.86 PAC
                       
      G.ut.mov32( itemaddr, G.context+m.itemaddress ) 
                          
      RESULTIS TRUE // ok to go to photo now
   $)                                       

   RESULTIS FALSE // no good
$)
.
