//  AES SOURCE  6.87

/**
         HE.HELPA - AREAL HELP
         ---------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         13.05.86 1        PAC     Initial version
         25.06.86 2        PAC     Mods for new helpinit
         16.07.86 3        PAC     Use GL7HDR
         13.8.86  4        PAC     Add second page of types
         16.9.86  5        PAC     Test for display of second
                                   page.
    *****************************************************************
         16.6.87  6        PAC     ADOPTED FOR UNI
**/

SECTION "helpA"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/dhhd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/hehd.h"
get "H/nmhd.h"

STATIC $( s.highmax = 22  // maximum number to highlight
          s.highmin = 1   // minimum number to highlight
          s.max.num.areas = m.nm.max.num.areas
        $)

/**
         G.HE.AREALINI - INITIALISE FOR AREAL
         ------------------------------------

         Init routine to enter AREAL

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         Display first page of A.U. types
**/
LET G.he.arealini() BE
$(

   // initialise the various statics
   G.he.work!m.he.lastpage := FALSE
   G.he.work!m.he.name.no  := 1

   first.page()

$)

/**
         G.HE.AREAL - ACTION ROUTINE FOR AREAL HELP
         ------------------------------------------

         Handles display of areal units, and names

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         contents of G.he.work vector

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         convert a TAB in display area into a function key

         CASE key OF

            F7 : display previous page

            F8 : display next page

         ENDCASE

         IF redraw flag is set then redraw menu bar

         RETURN
**/

AND G.he.areal() BE
$( LET status = TABLE m.sd.act,m.sd.act,m.sd.act,
                      m.sd.act,m.sd.act,m.sd.act

   LET local.key = convert.key()
   LET selection = m.sd.hinvalid

   IF G.he.work!m.he.gazpage < 2
   THEN
      selection := G.sc.high( s.highmin,s.highmax,FALSE,0 )

   SWITCHON local.key INTO
   $(
      CASE m.kd.return:
      $( UNLESS selection = m.sd.hinvalid
         DO
            $(
               find.nameptr( selection )
               f.display.page(2)   // was 1...13.8.86 PAC
            $)
      $)
      ENDCASE

      CASE m.kd.Fkey7 : page.backwards()
      ENDCASE

      CASE m.kd.Fkey8 : page.forwards()
      ENDCASE

   $)

   IF G.redraw THEN G.sc.menu( status )
$)
    

// This routine sets up the 32-bit 'gazptr' number in g.he.work
// it also initialises the current name number, and the max
// number of names. It uses the gazetteer types data previously
// read in by help0 to display the status page.
//
AND find.nameptr( type.number ) BE
$(
   LET offset    = ?
   LET siz32     = VEC 1
   LET ptr       = VEC 1
   LET buffer    = G.he.work + m.he.types

   G.ut.set32( m.he.rec.size, 0, siz32 ) // 32 bit value of record size

   // point (byte) offset at required record
   //
   offset := (type.number-1)*m.he.rec.size 

   // get max number of area names from record for current AU type
   // and initialise current name number
   //
   G.he.work!m.he.max.names := G.ut.unpack16( buffer, offset+m.he.type.nos )
   G.he.work!m.he.name.no   := 1  

   // find pointer to this chunk of names
   // 
   G.ut.unpack32( buffer, offset + m.he.addr.off, ptr )

   G.ut.sub32( siz32, ptr )  // subtract 1 record (for get.record's sake)
      
   G.ut.mov32( ptr, G.he.work+m.he.gazptr) // and set up this value in statics
$)

//
// page.forwards displays the next page in the set
//
AND page.forwards() BE
$(
   LET pageno = G.he.work!m.he.gazpage

   TEST (G.he.work!m.he.lastpage) | (pageno = 1)
   THEN G.sc.beep()
   ELSE TEST pageno = 0
        THEN second.page()
        ELSE f.display.page( pageno + 1 )
$)

//
// page forward through names
//
AND f.display.page( page.number ) BE
$(
   LET i    = 1
   LET num  = G.he.work+m.he.name.no
   LET oldnum = !num
   LET max    = G.he.work!m.he.max.names
   LET current.ptr = VEC 1

   LET oldptr = G.sc.pointer( m.sd.off )

  // LET ptr = G.he.work+m.he.gazptr
  // G.sc.mess("Page fwds 1: ptr %x4%x4 last %n num %n",ptr!1,ptr!0,
  //                                        G.he.work!m.he.lastpage,!num)

   // save current pointer
   G.ut.mov32 ( G.he.work + m.he.gazptr, current.ptr )

   IF page.number = 2 THEN unit.name.title()

   G.he.work!m.he.gazpage := page.number

   G.sc.clear( m.sd.display )
   G.sc.moveA( m.sd.display, m.sd.disXtex, m.sd.disYtex )
   G.sc.selcol( m.sd.cyan )

   WHILE (i <= 22) & (!num <= max)
   DO
   $(
      LET rec = get.record( m.he.next )
      !num := !num + 1           // increment count

      // see whether area name has valid maprecord
      //
      IF G.ut.unpack16( rec, m.he.maprec.off) ~= 0 
      THEN $( write.item( rec, -m.sd.linW ); i := i + 1 $)
   $)

   IF i = 1 THEN G.sc.oprop(" No area names available for this type")

   TEST (!num >= max)
   THEN
   $(
      // restore old file pointer, ready to page back
      // pointer is at start of last page
      G.ut.mov32( current.ptr, G.he.work+m.he.gazptr )

      !num := oldnum // restore the number as well

      G.he.work!m.he.lastpage := TRUE
   $)
   ELSE G.he.work!m.he.lastpage := FALSE

//   G.sc.mess("Page fwds 2: ptr %x4%x4 last %n num %n",ptr!1,ptr!0,
//                                    G.he.work!m.he.lastpage,!num)
   G.sc.pointer( oldptr )

$)

//
// page.backwards displays the previous page in the set
//
AND page.backwards() BE
$(
   SWITCHON G.he.work!m.he.gazpage INTO
   $(
      DEFAULT : b.display.page( G.he.work!m.he.gazpage-1 ) ENDCASE

      // n.b. skip over second types page when going backwards
      CASE 2  :
      CASE 1  : first.page() ENDCASE
      CASE 0  : G.sc.beep() ENDCASE
   $)
$)

//
// display a page of names backwards
//
AND b.display.page( page.number ) BE
$(
   LET i = 1
   LET num  = G.he.work+m.he.name.no
   LET oldptr = G.sc.pointer( m.sd.off )
   LET current.ptr = VEC 1
   LET records = 44

//   LET ptr = G.he.work+m.he.gazptr
//   G.sc.mess("Page back 1: ptr %x4%x4 last %n num %n",ptr!1,ptr!0,
//                                       G.he.work!m.he.lastpage,!num)

   IF G.he.work!m.he.lastpage = TRUE
   THEN records := 22

   G.he.work!m.he.lastpage := FALSE
   G.he.work!m.he.gazpage  := page.number

   G.sc.clear( m.sd.display )
   G.sc.moveA( m.sd.display, m.sd.disXtex, m.sd.disYtex )
   G.sc.selcol( m.sd.cyan )

   WHILE (i <= records) // search back through current AND previous page
   DO                   // except on last page !!
   $(
      LET rec = get.record( m.he.previous )
      !num := !num - 1           // decrement count

      // see whether area name has valid maprecord
      //
      IF G.ut.unpack16( rec, m.he.maprec.off) ~= 0 
      THEN i := i + 1 
   $)

   i := 1 // reset counter

   WHILE (i <= 22)
   DO
   $(
      LET rec = get.record( m.he.next )
      !num := !num + 1           // increment count

   
      // see whether area name has valid maprecord
      //
      IF G.ut.unpack16( rec, m.he.maprec.off) ~= 0 
      THEN $( write.item( rec, -m.sd.linW ); i := i + 1 $)
   $)

//   G.sc.mess("Page back 2: ptr %x4%x4 last %n num %n",ptr!1,ptr!0,
//                                       G.he.work!m.he.lastpage,!num)
   G.sc.pointer( oldptr )

$)

//
// This gets either the next or the previous record from the gazetteer
//
AND get.record( switch ) = VALOF
$(
   LET siz32 = VEC 1
   LET ptr   = G.he.work+m.he.gazptr     // pointer into Gazetteer
   LET Baddr = G.he.work+m.he.namebuff   // buffer for gazetteer record

   G.ut.set32( m.he.rec.size, 0, siz32 ) // 32 bit size of a Gazetteer record

   TEST switch = m.he.next
   THEN G.ut.add32( siz32, ptr ) // point to next record to read
   ELSE G.ut.sub32( siz32, ptr ) // point to previous record to read

   G.dh.read( G.he.work!m.he.gazhandle, ptr, Baddr, m.he.rec.size )

   RESULTIS Baddr  // return address of data
$)

//
// first.page displays the first page of areal unit types
//
AND first.page() BE
$(
   LET i = 1
   LET ptr    = G.he.work+m.he.types
   LET oldptr = G.sc.pointer( m.sd.off )
   LET offset = 0      
   LET buff   = VEC 40/bytesperword      

   G.he.work!m.he.gazpage  := 0
   G.he.work!m.he.lastpage := FALSE

   unit.type.title() // display the page title

   G.sc.clear( m.sd.display )
   G.sc.selcol( m.sd.cyan )
   G.sc.moveA( m.sd.display, m.sd.disXtex, m.sd.disYtex )

   WHILE (i <= 22) & 
         (G.ut.unpack16(ptr, offset+m.he.name.off) ~= m.he.end.of.types) DO
   $( 
      IF G.ut.unpack16(ptr, offset+m.he.type.nos) <= s.max.num.areas THEN  
      $( G.sc.oplist( i, 
                      G.ut.align( ptr, 
                                  offset+m.he.name.off, 
                                  buff, 
                                  ptr%(offset+m.he.name.off)+1 ) )

         i := i + 1 
      $)    
      offset := offset + m.he.rec.size
   $)

   s.highmin := 1     // set min limit for highlight
   s.highmax := i - 1 // set max limit for highlight

   G.sc.high(0,0,false,100) // reset highlight's static

   G.sc.pointer(oldptr)
$)

//
// second.page displays the second page of areal unit types
// n.b. exits early if it can't display anything.
//
AND second.page() BE
$(
   LET i      = 23    // n.b. this page starts at type 23
   LET ptr    = G.he.work+m.he.types 
   LET oldptr = ?
   LET offset = 22*m.he.rec.size
   LET buff   = VEC 40/bytesperword

   // first check whether to display anything at all
   //
   UNLESS G.ut.unpack16( ptr, offset+m.he.type.nos) <= s.max.num.areas
   DO $( G.sc.beep() ; RETURN $)

   G.he.work!m.he.gazpage  := 1
   G.he.work!m.he.lastpage := FALSE

   oldptr := G.sc.pointer( m.sd.off )

   unit.type.title()           // display the page title

   G.sc.clear( m.sd.display )
   G.sc.selcol( m.sd.cyan )
   G.sc.moveA( m.sd.display, m.sd.disXtex, m.sd.disYtex )

   WHILE (i <= m.he.max.num.types) & 
         (G.ut.unpack16(ptr, offset+m.he.name.off) ~= m.he.end.of.types) DO
   $( 
      IF G.ut.unpack16(ptr, offset+m.he.type.nos) <= s.max.num.areas THEN  
      $( G.sc.oplist( i, 
                      G.ut.align( ptr, 
                                  offset+m.he.name.off, 
                                  buff, 
                                  ptr%(offset+m.he.name.off)+1 ) )

         i := i + 1 
      $)    
      offset := offset + m.he.rec.size
   $)

   s.highmin := 23
   s.highmax := i - 1 // set max limit for highlight

   // this should never happen now - 16.9.86
   IF i = 23 THEN G.sc.oprop(" No more types available")

   G.sc.high(0,0,false,100) // reset highlight's static

   G.sc.pointer(oldptr)
$)

//
// write the name string from the record, and 
// move 1 line up or down the screen
//
AND write.item( record, direction ) BE
$( LET coords = VEC 3
   LET tbuff  = VEC 40/bytesperword
   LET string = G.ut.align( record, m.he.name.off, 
                            tbuff, record%m.he.name.off+1)

   G.sc.savcur( coords )
   G.sc.mover( 3*m.sd.charwidth,0 ) // move in a bit
   G.sc.oprop( string )
   coords!3 := coords!3 + direction
   G.sc.rescur( coords )
$)

AND unit.type.title() BE G.sc.mess("List of areal units: Areal unit types")

AND unit.name.title() BE G.sc.mess("List of areal units: Areal unit names")

//
// convert a TAB to a function key
//
AND convert.key() = VALOF
$( IF (G.key = m.kd.change) & (G.screen = m.sd.display)
   THEN TEST G.Xpoint < (m.he.LHS)
        THEN RESULTIS m.kd.Fkey7
        ELSE TEST G.Xpoint > (m.he.RHS)
             THEN RESULTIS m.kd.Fkey8
             ELSE G.sc.beep()
   RESULTIS G.key
$)
.
