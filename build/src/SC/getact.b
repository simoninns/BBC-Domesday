//  $MSC
//  ARC SOURCE  12.87

/**
         SC.GETACT - GET ACTION ROUTINE
         ------------------------------

         This module contains G.sc.getact and G.sc.keyboard.flush.

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE      VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87 1        PAC         ADOPTED FOR AES
         24.07.87 2        PAC         Remove pointer calls
         25.07.87 3        PAC         Also flush mouse buffer
         26.07.87 4        PAC         Cursor accel. fixes
         10.12.87 5        MH          virtual keyboard update

**/

SECTION "getact"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/sdhd.h"
get "H/sdphd.h"
get "H/sthd.h"
get "H/kdhd.h"
get "H/vhhd.h"

STATIC $( s.key = m.kd.noact $) // save of last key pressed

/**
         SC.GETACT - GET ACTION ROUTINE
         ------------------------------

         This routine provides the complete 'get action' routine
         for inclusion in the kernel.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.key    : set to latest keypress
         G.Xpoint : latest X position ( Domesday co-ordinates )
         G.Ypoint : latest Y position ( Domesday co-ordinates )
         G.screen : Domesday co-ordinate system of latest point.

         G.menuon : menu bar on/off
         G.redraw : redraw flag

         SPECIAL NOTES FOR CALLERS:

         This routine may only be called from ROOT, because of
         the way the redraw flag is handled.

         PROGRAM DESIGN LANGUAGE:

         Getact []
         ---------
         outputs are the globals G.key, G.Xpoint, G.Ypoint,
         G.screen.

         UNLESS last key was noact or a printable character
         THEN Flush keyboard buffer

         set G.key to m.kd.noact
         get present position and key press
         convert BBC to domesday co-ordinates
         store co-ordinates & co-ord system in globals

         IF key press is cursor key
         THEN
            DO cursor key handling, (and exit)
         ELSE
            IF redraw flag not set THEN
               IF key press is return AND pointer in menu bar
                  THEN fake function keypress
                  ELSE put key press into G.key
               ENDIF
               IF G.key is function 0 THEN
                  IF menu bar on
                     THEN clear bar
                     ELSE redraw menu with current parameters
                  ENDIF
                  put noact into G.key
               ENDIF
               IF G.key is function 9 THEN
                  inquire current video mode
                  set mode to player only
                  wait for a keypress
                  restore old video mode
                  put noact into G.key
               ENDIF

               IF menu bar is off AND G.key is a function key
                  THEN put noact into G.key
               ENDIF
            ENDIF
         ENDIF
         save last keypress in s.key, for use the next time around
         RETURN
**/

LET G.sc.getact() BE
$( LET retpos = VEC 2 // return co-ordinates from sc.mouse
   LET keypress,rawX,rawY = ?,?,?

   G.key := m.kd.noact        // default (nothing happens)

   G.sc.mouse (retpos)        // get co-ords & keypress
   keypress := retpos!2
   rawY     := retpos!1       // y co-ordinate needs adjusting
   rawX     := retpos!0       //

   G.Xpoint := rawX           // x co-ordinate unchanged
   G.screen := G.sc.btod(rawY, @G.Ypoint)  // calculate system and Y position

   IF G.redraw                     // early exit
   THEN $( G.sc.keyboard.flush() ; RETURN $) // added 10.9.86 PAC

   // flush kbd buffer on entry unless a printable char
   UNLESS (s.key = m.kd.noact) | G.ut.printingchar(s.key)
   DO $( G.sc.keyboard.flush()
         keypress := m.kd.noact
      $)

   TEST (keypress >= m.kd.curstart) & (keypress <= m.kd.cursend)

   THEN
   $( cursor( keypress, rawX, rawY )        // handle cursor keys
      G.key := keypress  // only setup key if ~redraw
   $)

   ELSE
   $(
      TEST (keypress = m.kd.return) & (G.screen = m.sd.menu)

         THEN G.key := functionkey( G.xpoint )
         ELSE G.key := keypress

      IF G.key = m.kd.Fkey0
      THEN
      $( menu.bar() ; G.key := m.kd.noact $)

      IF G.key = m.kd.Fkey9
      THEN
      $( clear.display() ; G.key := m.kd.noact $)

      IF ( m.kd.keybase < G.key <= m.kd.keybase+m.st.barlen)
      THEN                                // this block modified 28.8.86 PAC
      $( LET key.no = G.key-m.kd.keybase  // make it 1,2,3 etc.
         LET st.ptr = (G.context!m.state-1)*m.st.barlen // pointer to menus
         IF ~G.menuon |
            (G.menubar!(key.no-1) = m.sd.wBlank) |
            ((G.stmenu!(st.ptr + key.no) & #x1FF) = m.sd.wBlank)
         THEN G.key := m.kd.noact
      $)
   $)
   unless G.menuon G.key := G.sc.virtual.key() //get any input form VK
   s.key := G.key // save current key for next time round
$)

// handle menu bar on/off (F0)
AND menu.bar() BE
$( TEST G.menuon
      THEN  $( clearbar()         //below 0 = m.sd.menY0
               G.sc.TMAX := 0 //set pointer
               G.sc.setup.vk()  //set up virtual keyboard
               G.menuon := false
               g.ut.wait(m.sd.cursor.time*4)  
                  // wait to stop double bounce from switching VK on
            $)
      ELSE  $( let cursor = vec m.sd.coordsize
               G.sc.savcur(cursor)  // added 3.9.87 MH
               G.menuon := TRUE   //below 76 = m.sd.disY0
               G.sc.TMAX := 76 //set pointer
               G.sc.clear(m.sd.menu)
               G.sc.menu( G.menubar )
               G.sc.rescur(cursor)   // added 3.9.87 MH
               g.ut.wait(m.sd.cursor.time*4)  
                  // wait to stop double bounce from switching VK off
            $)
   G.sc.keyboard.flush() // clear keyboard buffer added 9.9.86 PAC

$)

// handle clearing micro output from the display (F9)

AND clear.display() BE
$(
   LET pollvec = VEC m.vh.poll.buf.words
   LET retvec  = VEC 2
   LET previous.mode = m.vh.superimpose // default mode
   LET j = 0

   // find current video mode
   G.vh.video( m.vh.inquire)

   // looping added 21.10.86 PAC
   G.vh.poll( m.vh.read.reply, pollvec ) REPEATWHILE pollvec%0 = '*C'

   // examine reply buffer
   // the character before the C/R is the (ascii) mode number
   j := j+1 REPEATUNTIL pollvec%(j+1) = '*C'

   previous.mode := pollvec%j

   IF previous.mode = m.vh.micro.only
   THEN G.vh.video( m.vh.video.off )

   // display video only
   G.vh.video( m.vh.lv.only )

   G.sc.keyboard.flush() // flush kbd buffer - added 8.9.86 PAC

   // then wait for a key press
   G.sc.mouse( retvec ) REPEATUNTIL retvec!2 ~= m.kd.noact

   G.sc.keyboard.flush() // clear keyboard buffer

   // restore old video mode
   G.vh.video( previous.mode )

// these two lines moved here 11.8.86 PAC (used to be above prev.mode call)
   IF previous.mode = m.vh.micro.only
   THEN G.vh.video( m.vh.video.on )
$)

// handle cursor key movement / acceleration
AND cursor( key, presX, presY ) BE
$( LET newY      = presY
   LET int.key   = ?
   LET move.op   = ?
   LET count     = 0
   LET mode      = 1 // G.sc.findmode()
   LET speed1    = m.sd.speed1

   IF (mode = 2) & ((key = m.kd.left) | (key = m.kd.right))
      THEN speed1 := (speed1 << 1)  // double initial speed
                                    // in mode 2
   G.Xpoint := presX
   G.Ypoint := presY

   SWITCHON key INTO
      $( CASE m.kd.up    :
         $( int.key := m.kd.Iup ; move.op := move.up $)
         ENDCASE

         CASE m.kd.down  :
         $( int.key := m.kd.Idown ; move.op := move.down $)
         ENDCASE

         CASE m.kd.right :
         $( int.key := m.kd.Iright ; move.op := move.right $)
         ENDCASE

         CASE m.kd.left  :
         $( int.key := m.kd.Ileft ; move.op := move.left $)
         ENDCASE
      $)

   move.op( speed1 ) // initial move
   G.ut.wait( 2 )    // wait a little before repeating

   WHILE key.pressed( int.key ) & ( count < m.sd.cursor.dly.1 )
      $( move.op ( speed1 )
         g.ut.wait(m.sd.cursor.time)
         count := count + 1
      $)

   WHILE key.pressed( int.key ) & ( count < m.sd.cursor.dly.2 )
      $( move.op ( m.sd.speed2 )
         g.ut.wait(m.sd.cursor.time)
         count := count + 1
      $)

   WHILE key.pressed( int.key ) DO 
      $( move.op ( m.sd.speed3 )
         g.ut.wait(m.sd.cursor.time)
      $)

      newY := G.Ypoint

      // fall out of cursor key accelerator here
      // calculate new co-ord system, X and Y positions
      G.screen := G.sc.btod ( newY, @G.Ypoint ) // calculate system and Y position

      G.sc.keyboard.flush() // clear keyboard buffer
$)
/**
         G.SC.KEYOARD.FLUSH - FLUSH KEYBOARD BUFFER
         ------------------------------------------

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Flushes the keyboard buffer, using OSBYTE call
         call is *FX 21,0 - see BBC manual for details.

**/
AND G.sc.keyboard.flush() BE $( OsByte(21,0) ; OsByte(21,9) $)

AND key.pressed( key.val ) = VALOF
$(
   Let r = OsByte(#x81, key.val, #xFF)  // X = INKEY value, Y = #xFF
   RESULTIS (r | Result2 << 8) = #xFFFF // X = Y = #xFF if key is pressed
$)  

AND move.up( speed ) BE
$( LET newY = G.Ypoint + speed
   G.Ypoint := (newY > m.sd.maxY) -> m.sd.maxY, newY
   G.sc.moveptr(G.Xpoint,G.Ypoint)
$)

AND move.down( speed ) BE
$( LET newY = G.Ypoint - speed
   G.Ypoint := (newY < m.sd.minY) -> m.sd.minY, newY
   G.sc.moveptr(G.Xpoint,G.Ypoint)
$)

AND move.right( speed ) BE
$( LET newX = G.Xpoint + speed
   G.Xpoint := (newX > m.sd.maxX) -> m.sd.maxX, newX
   G.sc.moveptr(G.Xpoint,G.Ypoint)
$)

AND move.left( speed ) BE
$( LET newX = G.Xpoint - speed
   G.Xpoint := (newX < m.sd.minX) -> m.sd.minX, newX
   G.sc.moveptr(G.Xpoint,G.Ypoint)
$)

// fake function key press
AND functionkey(xpos) = VALOF
$( /* G.sc.clear(m.sd.message)         // debug code - left out now
   G.sc.movea(m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
   writef("Fn key @ %n",xpos)
   until rdch()=32 do xpos:=xpos+0
   */

   // first test for F0
   TEST xpos < m.st.box0width         // m.st.box0width (=80)
   THEN TEST G.menuon              // if menu bar on and < 80
        THEN RESULTIS m.kd.keybase // function 0
        ELSE                       // test pixel colour with osword  
        $( LET coords = VEC m.sd.coordsize
           // LET oldstate = G.sc.pointer( m.sd.off )

           coords!0:= G.xpoint | G.sc.dtob(G.screen,G.ypoint) << 16
           Osword( 9, coords )       // this tests whether the mouse 
           // G.sc.pointer( oldstate )  // pointer is actually on the yellow
                                        // triangle
           
           RESULTIS coords%4 = m.sd.yellow -> m.kd.keybase, m.kd.noact
        $)

   ELSE TEST G.menuon THEN  // only if menu bar is on do we check other keys 
        $( LET statptr  = (G.context!m.state-1)*m.st.barlen 
           LET boxwidth,tot = ?,m.st.box0width

           FOR i = 1 to m.st.barlen DO
           $( boxwidth := (G.stmenu!(statptr+i) & #xFE00) >>7
              IF (xpos >= tot) & (xpos < tot+boxwidth) RESULTIS m.kd.keybase+i
              tot:=tot+boxwidth
           $)
        $)
        ELSE
           RESULTIS m.kd.action // added 10.12.87
   RESULTIS m.kd.noact      // default - can't find a key
$)

// clear menu bar area
AND clearbar() BE
$( // LET oldstate = G.sc.pointer( m.sd.off )
   LET coords   = VEC m.sd.coordsize
   G.sc.savcur( coords )
   G.sc.clear( m.sd.menu )
   FOR i = 4 to 0 by -4 do
      $( G.sc.selcol( i>1 ->m.sd.blue,m.sd.yellow ) // blue first, then yellow
         G.sc.movea ( m.sd.menu,32+i,16-i )
         G.sc.triangle ( m.sd.plot,0,32, 36,-16 )
      $)
   G.sc.selcol(m.sd.blue)     // added 26.9.86 PAC
   // G.sc.pointer( oldstate )
   G.sc.rescur( coords )
$)

// end of getact
.
