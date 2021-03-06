//  $MSC
//  AES SOURCE  4.87

/**
         TEXTLNK - LINKABLE TEXT PRIMITIVES
         ----------------------------------

         This file contains the routines :

         G.sc.opage - output text page
         G.sc.2high - special highlight routine

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.textlnk

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87 1        PAC         ADOPTED FOR AES SYSTEM
           6.7.87 2        PAC         Fix write bug
         24.07.87 3        PAC         Remove pointer calls
**/

Section "text.lnk"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/sdhd.h"
get "H/sdphd.h"
get "H/uthd.h"

static $( s.olditem = m.sd.hinvalid $) // used by G.sc.2high

/**

         G.SC.OPAGE - OUTPUT TEXT PAGE
         -----------------------------

         Output a text page, optionally proportionally spaced.
         The text is output line by line, and the cursor moved to
         the start of the next row. If the text has a highlight
         code in it, then highlight the required words. This
         routine is intended for use when a whole page of text is
         required. If it is only required to output a single
         word, then the lower level primitives g.sc.oprop and
         WRITES are available.

         INPUTS:

         Addresses of two vectors containing the text: VecA and
         VecB,

         Sizes of these vectors (in BYTES) : SizA, SizB

         Pointers to start of text in the vectors ( BYTE offsets)
         PtrA, PtrB.

         Proportional spacing flag ( true for proportional
                                       spacing on )
         Type of output :

         m.sd.screen.page - O/P page to screen
         m.sd.print.page  - O/P page to printer
         m.sd.write.page  - O/P page to floppy disc

         Pointer to workspace vector of size m.sd.opage.buffsize

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Calls G.sc.oprop if proportional spacing flag is set
         true, otherwise uses BCPL WRITES procedure.

         Normal text  is in cyan
         Highlighting is in yellow

         Highlighting begins with { and ends with } or C/R.
         These symbols are all declared in the SDHDR manifests
         file.

         If the text starts in VecA, and continues in VecB, then
         PtrA must be the start of text in buffer A, and PtrB the
         offset to the continuation of text in VecB (normally 0).

         If the text is contained wholly within VecB, then PtrA
         MUST be set to m.sd.invalid.

         <------SizA---------->
         XXXXXXXXXXXXXXXXXXXXXX
         ^          ^
         | VecA     | PtrA

         <------SizB---------->
         XXXXXXXXXXXXXXXXXXXXXX
         ^       ^
         | VecB  | PtrB


         Note that if the print as write facilities are to be
         used, then the file l.printwrite must also be part of
         the overlay. Also, there must be an open file for
         write.page to work (you will get a trap if there isn't )

         I.E. open the file using G.ut.open.file()
              do any writes required, (including calls to
                                       G.sc.opage)
              close the file using G.ut.close.file()

         There must be at least 500 words spare in the heap for
         OPAGE to work, because it does a GETVEC for its buffer
         space.

         PROGRAM DESIGN LANGUAGE:

         G.sc.opage [ VecA, VecB, SizA, SizB, PtrA, PtrB,
         ----------                       prop, type, workspace ]

         Define vector for output string 40 chars long

         move text from vectors A and B into workspace, making
         one contiguous 'page'

         CASE OF type

         screen.page : display page on screen
         print.page  : display page on printer
         write.page  : write page to floppy disc

         screen page
         -----------
         output string pointer := 1
         Save current cursor position
         Set text colour to cyan

         FOR line = 1 TO 22
            FOR i = 1 to length of line
               get next char from page buffer
               IF next char = "{" or "}"
                  THEN  print string ,length output string pointer
                        toggle colour, print space
                        output string pointer := 1
                  ELSE  add next char to string
                        increment output string pointer
            NEXT i
            print string , length output string pointer
            move to saved X,(Y - linewidth)
         NEXT line
         END ( output page )

         print string [ length ]
         ------------
         set length of output string to length
         IF proportional
            THEN g.sc.oprop ( output string )
            ELSE writes ( output string )
         END ( print string )

**/
LET G.sc.opage( VecA, VecB, SizA, SizB, PtrA, PtrB, prop, type, outbuff ) BE
$(
   LET outstr = VEC(42/bytesperword)     // space for 41 chars + length
   // LET status = G.sc.pointer( m.sd.off ) 

   setup.buffer( outbuff, VecA, VecB, SizA, SizB, PtrA, PtrB )

   SWITCHON type INTO
   $(
      CASE m.sd.screen.page : screen.page( outbuff, outstr, prop ) ; ENDCASE

      CASE m.sd.print.page  : print.page( outbuff, outstr ) ; ENDCASE

      CASE m.sd.write.page  : write.page( outbuff ) ; ENDCASE
   $)

   // G.sc.pointer( status ) 

$) // end of opage

AND setup.buffer( dest.buffer, VecA, VecB, SizA, SizB, PtrA, PtrB ) BE
$(
   TEST PtrA ~= m.sd.invalid // text starts in first vector

   THEN
   $( LET text.in.A = (SizA - PtrA)
      LET text.in.B = 0      // assume it's ALL in first vector

      TEST text.in.A >= m.sd.pagelength

         THEN text.in.A := m.sd.pagelength  // it's all in first vector

         ELSE $( text.in.B := m.sd.pagelength - text.in.A
                 PtrB := 0                  // ensure correct offset
              $)

      FOR ptr = 0 TO (text.in.A-1)
         DO dest.buffer%ptr := VecA%(PtrA + ptr)

      FOR ptr = 0 TO (text.in.B-1)
         DO dest.buffer%(text.in.A+ptr) := VecB%(PtrB + ptr)
   $)

   ELSE
   $( G.ut.trap("SC",32,TRUE,2,(SizB-PtrB),m.sd.pagelength,0 )

      FOR ptr = 0 TO m.sd.pagelength
        DO dest.buffer%ptr := VecB%(PtrB + ptr)
   $)

$)

AND screen.page( outbuff, outstr, prop ) BE
$(
   LET oldstate,ch = ?,?       // old pointer state, next char
   LET Xpos = m.sd.disXtex
   LET Ypos = m.sd.disYtex

   IF prop THEN Xpos := m.sd.propXtex

   G.sc.selcol( m.sd.cyan )

   // oldstate := G.sc.pointer ( m.sd.off )

   FOR line = 1 TO m.sd.pagelength/m.sd.linelength
   DO
   $( LET pointer    = (line-1)*m.sd.linelength
      LET outptr,col = 0,m.sd.cyan  // output pointer and current colour
      LET spaces = 0 

      G.sc.movea( m.sd.display, Xpos, Ypos )

      FOR i = pointer TO (pointer+m.sd.linelength-1)
      DO
      $( ch := outbuff%i

         IF ch = ' ' THEN spaces := spaces + 1

         TEST (ch=m.sd.histart) | (ch=m.sd.histop)
         THEN
         $(
            outstr%(outptr+1) := ' '  // add a space at the end
                                      // for { or }
            outstr%0 := outptr        // set string length

            IF G.sc.addspace THEN outstr%0 := outstr%0 + 1 // add the space

            TEST prop THEN G.sc.oprop( outstr )
                      ELSE WRITES( outstr )   // print string

            col := ( ch=m.sd.histart -> m.sd.yellow,m.sd.cyan ) // new colour

            G.sc.selcol( col )

            outptr := 0   // reset output string pointer
            spaces := 0   // reset spaces counter - added 13.9.86 PAC
         $)
         ELSE $( outptr := outptr+1 ; outstr%outptr := ch $)

      $)

      // print last bit of string if not all spaces
      UNLESS spaces = outptr // modified 13.8.86 PAC
      DO
      $( outstr%0 := outptr                    // set string length
         TEST prop THEN G.sc.oprop( outstr )
                   ELSE WRITES( outstr )
      $)

      Ypos := Ypos - m.sd.linw     // set new pos one line down
      col  := m.sd.cyan            // reset colour
      G.sc.selcol( col )
   $)
   // G.sc.pointer( oldstate )        // restore pointer
$)

AND print.page( buffer, outstr ) BE
$(
   G.ut.print( TABLE 0 ) // initial blank line

   kill.highlights( buffer ) // remove highlight chars

   FOR line = 1 TO m.sd.pagelength/m.sd.linelength
   DO
   $( LET pointer = (line-1)*m.sd.linelength
      LET outptr  = 0                       // output pointer

      FOR i = pointer TO (pointer+m.sd.linelength-1)
      DO
         $( outptr := outptr+1
            outstr%outptr := buffer%i
         $)

      outstr%0 := outptr // set string length

      IF G.ut.print( outstr ) = FALSE THEN BREAK
   $)

$) // end of print.page

AND write.page( buffer, outstr ) BE
$(
   LET result = m.ut.success

   kill.highlights( buffer ) // remove highlight chars - PAC 14.10.86
                            
   buffer := buffer * bytesperword  // make it a machine address

   FOR line = 1 TO m.sd.pagelength/m.sd.linelength
   DO
   $( 
      IF result = m.ut.success
         THEN result := G.ut.write( buffer, m.sd.linelength, m.ut.text )

      buffer := buffer + m.sd.linelength   // increment pointer
   $)

$) // end of write.page


// remove highlight characters from a print or write page
//
AND kill.highlights( buffer ) BE
$(
   LET ch = ?

   FOR ptr = 0 TO m.sd.pagelength DO

   $( ch := buffer%ptr
      IF (ch = m.sd.histart) | (ch = m.sd.histop)
      THEN buffer%ptr := ' ' // put space for highlight char
   $)
$)

/**

         G.SC.2HIGH - HIGHLIGHT LIST ITEM
         -------------------------------

         Highlights the currently selected list item number, and
         returns this item number to the caller.

         INPUTS:

         Item number of first list item
         Item number of last  list item
         Flag set true if "See:" is present,
                  false otherwise
         (Uses global G.Ypoint to find pointer position)
         Offset of first item in list, given in lines from the
         display top
         Vector of numbers to be used( see below )

         OUTPUTS:

         Number of current 'active' list item

         GLOBALS MODIFIED:

         none
         maintains static for 'old item number'

         SPECIAL NOTES FOR CALLERS:

         The list is assumed to be set up on the screen
         beforehand, with the first item being positioned at
         m.sd.disYtex-(offset*m.sd.linw). Use the list output
         primitive for generating the list.

         The vector of numbers gives the actual number to be
         associated with the positions on the display :
         E.G.
         display top________________________number in list
             1 xxxxxxxxxxxxxxxxxxxxxxxxx        1
             3 xxxxxxxxxxxxxxxxxxxxxxxxx        2
             4 xxxxxxxxxxxxxxxxxxxxxxxxx        3
             7 xxxxxxxxxxxxxxxxxxxxxxxxx        4
             9 xxxxxxxxxxxxxxxxxxxxxxxxx        5
            10 xxxxxxxxxxxxxxxxxxxxxxxxx        6
            15 xxxxxxxxxxxxxxxxxxxxxxxxx        7
            19 xxxxxxxxxxxxxxxxxxxxxxxxx        8

         Vector = [0,1,3,4,7,9,10,15,19]


         In other words, if n is the number within the list, then
         vector!n gives the number displayed.

         Here, the call to G.sc.2high will be

         item.selected := G.sc.2high( 1,8,false,0,Vector )

         PROGRAM DESIGN LANGUAGE:

         G.sc.2high [ first no,last no,seeflag,offset,numbers
         ----------                               -> selection ]
         { Step 1 }
         { Find the new item number on the current Ypoint line }

         IF pointer is not on display
            THEN new item number is 'invalid'
            ELSE IF Y position <= 'SeeY' AND "See:" is present
                 THEN new item number is 'See number'
                 ELSE IF Y position > bottom of list
                      THEN calculate new item number
                      ELSE new item number is 'invalid'
                      ENDIF
                 ENDIF
         ENDIF
         { Step 2 }
         { Do the necessary highlighting }

         IF new item number <> old item number
            THEN
                 { unhighlight old item }
                 IF old item number was 'See number'
                    AND 'see' is present in current list
                 THEN unhighlight "See:"
                 ELSE IF old item is in current list
                      THEN unhighlight old item number
                      ENDIF
                 ENDIF

                 { highlight new item }
                 IF new item number is 'See number'
                 THEN highlight "See:"
                 ELSE highlight new item number
                 ENDIF
         ENDIF

         Save new item number in static

         RETURN ( new item number )

**/
AND G.sc.2high ( firstno, lastno, seeflag, offset, numbers ) = VALOF
$( LET line,newitem,oldptr,pos = ?,?,?,?
   LET see = "See:"

   TEST G.screen ~= m.sd.display
      THEN newitem := m.sd.hinvalid
      ELSE TEST (G.Ypoint <= m.sd.seeY) & seeflag
           THEN newitem := m.sd.seenumber
           ELSE $( newitem := firstno+(m.sd.displines-(G.ypoint/m.sd.linw)-1)
                   newitem := newitem-offset // account for list starting lower
                   IF (newitem < firstno)|(newitem > lastno)
                   THEN newitem := m.sd.hinvalid
                $)
   IF newitem ~= s.olditem
      THEN $( G.sc.selcol ( m.sd.cyan )
              TEST (s.olditem = m.sd.seenumber) & seeflag
              THEN $( G.sc.movea ( m.sd.display,m.sd.seeX,m.sd.seeY )
                      G.sc.ofstr ( see )  // unhighlight "See:"
                   $)
              ELSE IF (s.olditem >= firstno) & (s.olditem <= lastno)
                   THEN padnum ( s.olditem,firstno,offset,numbers ) 
                                                           // unhighlight old
              G.sc.selcol ( m.sd.yellow )
              TEST newitem = m.sd.seenumber
              THEN $( G.sc.movea ( m.sd.display,m.sd.seeX,m.sd.seeY )
                      G.sc.ofstr ( see ) // highlight "See:"
                   $)
              ELSE IF (newitem >= firstno) & (newitem <= lastno)
                   THEN padnum ( newitem,firstno,offset,numbers )
           $)

   s.olditem := newitem

   TEST (newitem ~= m.sd.hinvalid) & (newitem ~= m.sd.seenumber)
      THEN RESULTIS numbers!newitem
      ELSE RESULTIS newitem
$)

AND padnum (itemno, topno, offset, numbers) BE
$( LET temp,pos,sp =?,?,4
   LET actual.no = numbers!itemno

   pos := (m.sd.displines-(itemno-topno)-offset)*m.sd.linw
   g.sc.movea (m.sd.display, 0, pos-4 )

   IF actual.no > 9999
   THEN actual.no := actual.no REM 10000 // truncate
   temp := actual.no

   // pad with spaces
   WHILE temp > 0 DO $( sp:=sp-1; temp := temp/10 $)
   G.sc.mover(32*sp,0)    // move to pad
   G.sc.ofstr ("%N", actual.no )
$)
// end of textlnk package
.

