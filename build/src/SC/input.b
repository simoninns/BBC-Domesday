//  $MSC
//  AES SOURCE  4.87

/**
         SC.INPUT - TEXT INPUT PRIMITIVE
         -------------------------------

         This primitive is on its own at present, to save
         development time.

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87 1        PAC         ADOPTED FOR AES SYSTEM
         27.07.87 2        PAC         Remove pointer calls
                                       remove findmode
**/

Section "input"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/kdhd.h"
get "H/sdhd.h"

/**
         G.SC.INPUT - GET TEXT INPUT
         ---------------------------

         This routine aids in the building of an input text
         string. It handles cursor key movement, and delete.

         INPUTS:

         pointer to current string,
         current 'foreground' colour
         current 'background' colour
         maximum length of string

         gets key pressed from G.key
         gets start coords of string from current graphics cursor
         position.

         OUTPUTS:

         none

         ( adds new characters to the string )

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         Move the graphics cursor to the desired start point for
         the text before calling this routine. Note that this
         point is the top LH corner of the first character cell.

         Set up the string length to zero before first calling.

         The input routine MUST be called at least once with
         G.key = m.noact and string length zero. This will put up
         the text input cursor at the start position. It is
         envisaged that this could be done as part of the
         'highlight box' sequence before the proper text entry.

         The 'background' colour refers to the colour below the
         text, which is not necessarily the actual background
         (black). If text is being input inside a box, then the
         colour to pass is the colour of the box.

         The final call to input MUST be with m.kd.return in
         G.key (i.e. the user has entered the string). This will
         delete the text cursor, leaving the string displayed.

         PROGRAM DESIGN LANGUAGE:

         G.sc.input [ string pointer, Fg colour, Bg colour, max
         ----------                                      length ]

         IF G.key is a function key
            THEN pretend that it's a return.

         IF string length is 0 AND key id 'noaction'
         THEN save current graphics cursor X pos as string start
              cursor position := 1
         ENDIF

         IF key is a character
         THEN
            Turn off mouse pointer
            IF cursor is not at end of string
              THEN overtype character
                   increment cursor position
              ELSE IF string length < maximum length
                   THEN insert character at end of string
                        set cursor to end of string
                   ELSE do a beep
                   ENDIF
              ENDIF

         ELSE CASE OF key

            return        : reset statics

            < or > cursor : increment / decrement current cursor
                            position if possible.

            delete        : IF cursor at end of string
                            THEN decrement cursor position, clear
                                 character at present position,
                                 checking for end of line.
                            ENDIF

         ENDCASE

         IF (newcursor <= maxlen+1) & (newcursor ~= oldcursor)
         THEN IF oldcursor was displayed
              THEN delete old cursor
              ENDIF

              IF (key ~= m.kd.return) AND (newcursor <= maxlen)
              THEN display new cursor
              ENDIF

         ENDIF
         RETURN

**/

LET G.sc.input ( string,FG,BG,maxlen ) BE
$( LET key,mo = ?,?
   LET pos = vec m.sd.coordsize
   LET oldcursor = ?
   LET newcursor = G.context!m.curpos     // new cursor position
   LET oldstate = m.sd.on                 // default is pointer on
   key := G.key                           // local copy of key

   mo := 1 // G.sc.findmode()       // find screen mode
   mo := ((mo=2) -> #x80,0)   // make 'mo' a mask to set top bit in mode 2

   // horrible fix to make cursor appear again for AREA
   IF string = 0
      THEN $( movcur( G.context!m.curpos )
              IF (G.context!m.curpos <= maxlen)
                 THEN cursor( FG )      // update displayed cursor
              RETURN
           $)

   IF( m.kd.keybase < key < m.kd.keybase+6 )
      THEN key := m.kd.return

   IF( string%0 = 0 ) & ( key = m.kd.noact )
      THEN $( G.context!m.curpos  := 0        // initialise cursor
              newcursor := 1
              G.sc.savcur( pos )              // get graphics cursor coords
              G.context!m.xpos := pos!2       // save original x position
           $)


   TEST G.ut.printingchar( key )   // a normal character key
      THEN  $( // do insert
               // G.sc.pointer( m.sd.off )          // turn off mouse pointer
               TEST (string%0 > (newcursor-1))      // insert or overtype ?
                  THEN $( string%newcursor := key   // overtype
                          movcur(newcursor)         // update screen here
                          delch( BG )
                          G.sc.selcol( FG )
                          WRCH( key | mo )
                          newcursor := newcursor+1
                       $)
                  ELSE TEST string%0 < maxlen            // check there's room
                       THEN $( string%newcursor := key   // insert at end
                               string%0 := string%0+1    // update length
                               movcur(newcursor)         // update screen
                               G.sc.selcol( FG )
                               WRCH( key | mo )
                               newcursor := string%0+1   // update cursor
                            $)
                        ELSE G.sc.beep()  // can't insert, so beep
            $)

      ELSE SWITCHON key INTO
            $( CASE m.kd.noact  :
               CASE m.kd.stop   :
               CASE m.kd.up     :
               CASE m.kd.down   : ENDCASE
               CASE m.kd.return :
               newcursor := -1
               ENDCASE

               CASE m.kd.delete :
               TEST (newcursor = (string%0+1))&(string%0>0)
               THEN $( newcursor := string%0
                       string%0 := string%0-1
                       movcur(newcursor)   // update screen
                       delch( BG )
                    $)
               ELSE G.sc.beep()
               ENDCASE

               CASE m.kd.left   :
               IF newcursor > 1
               THEN newcursor := newcursor-1
               ENDCASE

               CASE m.kd.right  :
               IF newcursor < (string%0+1)
               THEN newcursor := newcursor+1
               ENDCASE

               DEFAULT          : G.sc.beep(); ENDCASE
            $)

   oldcursor := G.context!m.curpos
   G.context!m.curpos  := newcursor // default is new cursor , unless...

   IF (newcursor <= maxlen+1) & (newcursor ~= oldcursor)
      THEN $( // G.sc.pointer(m.sd.off)    // turn off the pointer

              IF (oldcursor < maxlen+1) & (oldcursor>0) // not just initialised
              THEN $( movcur(oldcursor)  // move to cursor pos
                      cursor( BG )      // turn off the old cursor
                   $)

              TEST (key ~= m.kd.return)
              THEN $( movcur(newcursor) // move to cursor pos
                      IF (newcursor<= maxlen)
                         THEN cursor( FG )      // update displayed cursor
                      G.context!m.curpos := newcursor
                   $)
              ELSE G.context!m.curpos := oldcursor
           $)

/* debug stuff
   G.sc.savcur (pos)
   G.sc.clear (m.sd.message)
   G.sc.clear (m.sd.menu)
   G.sc.movea(m.sd.message,m.sd.mesXtex,m.sd.mesYtex)
   WRITEF("key: %C %x2 cursr: %n len: %n",key&#x7f,key,G.context!m.curpos,string%0)
   G.sc.movea (m.sd.menu,m.sd.menXtex,m.sd.menYtex)
   WRITES(string)
   G.sc.rescur (pos)
*/
   // G.sc.pointer(m.sd.on) // restore mouse pointer
$) // exit

// move graphics cursor (in X direction only)
// to our own 'text cursor' position
AND movcur(newcursor) BE
$( LET coords = vec m.sd.coordsize
   G.sc.savcur (coords)
   coords!2 := G.context!m.xpos + (newcursor-1)*m.sd.charwidth // 32 graphics units per char
   G.sc.rescur (coords)
$)

// plot a box of background colour over the
// current character position  (col is always background colour)
AND delch(col) BE
$( G.sc.selcol (col)
   G.sc.rect ( m.sd.plot,m.sd.charwidth,-m.sd.charwidth) // plot in BG
   G.sc.mover( -m.sd.charwidth,m.sd.charwidth )          // restore cursor
$)

// draw a cursor in either foreground or background colour
// cursor is at the current 'text cursor' position
AND cursor( col ) BE
$( G.sc.selcol (col)             // select plotting colour
   G.sc.mover (0,-m.sd.charwidth)            // ready to plot a cursor
   G.sc.liner ( m.sd.plot,m.sd.charwidth,0 ) // draw line
   G.sc.mover (-m.sd.charwidth,m.sd.charwidth)  // and move back
$)
.


