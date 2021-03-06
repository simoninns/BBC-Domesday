//  $MSC
//  AES SOURCE  4.87

/**
         UT.BOOKMARK - LOAD/SAVE BOOKMARK
         --------------------------------

         This file contains:

         G.ut.load.mark
         G.ut.save.mark

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.bookmark

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         27.06.86 1        PAC         Initial version
         15.07.86 2        PAC         Trap if no buffer space
         25.07.86 3        PAC         Bookmarks on ADFS
         30.07.86 4        PAC         Remove mark drive specification
         5.8.86   5        PAC         Use second processor RAM
         7.8.86   6        PAC         Use G.ut.srmove
         9.10.86  7        DNH         Clear before ermess
         19.6.87  8        PAC         ADOPTED FOR AES
         22.6.87  9        PAC         Fix nat/com bug
         7.7.87   10       PAC         Mod GBPB call
         21.7.87  11       PAC         Mod GBPB call again 
         23.12.87 12       MH          Numbered marks
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "H/sdhd.h"
get "H/sdphd.h"
get "H/iohd.h"
get "H/iophd.h"
get "H/uthd.h"

STATIC $( s.stream = 0 $) // file handle           

/**
         G.UT.LOAD.MARK - LOAD BOOKMARK FROM FLOPPY DISC
         -----------------------------------------------

         INPUTS:

         address of scratch vector - used as a buffer
         size    of scratch vector
         type of save (m.ut.Community or m.ut.National)

         OUTPUTS:

         Returns TRUE for successful save
         Outputs error messages if disc errors are detected

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         G.ut.load.mark [work.vec, work.size, type]
         --------------

         Open DOMARK file on floppy disc
         Load SCREEN and CONTEXT vector from file

         IF type is Community
         THEN Load in Community caches from disc
         ELSE Load in National caches from disc

**/

LET G.ut.load.mark( vec.addr, vec.size, type ) = VALOF
$(     
   LET w.off    = ?         // offset into cache vector
   LET buff     = vec.addr
   LET no.error = TRUE
   
   no.error := open.mark( m.ut.old.mark )
               
   // first load the screen back into the sprite area
   //
   IF no.error THEN
   $( no.error := load.screen.sprite()

      // now pick up the bookmark cache from the file
      //
      IF no.error THEN
      $( no.error := do.block( m.ut.read.op, buff*bytesperword, m.io.booksize )

         G.ut.cache( buff, m.io.booksize/bytesperword-1, m.io.context.cache )

         // now pick up all the overlay caches from the file
         //
         w.off := (type=m.ut.National -> m.io.natstart, 
                                                   m.io.comstart) / bytesperword      $)
   $)
   IF no.error THEN
   no.error := do.block( m.ut.read.op, (G.cachevec+w.off)*bytesperword, 
                                                              m.io.halfram )
   UNLESS no.error THEN error.message()

   RESULTIS (close.mark() & no.error)
$)

/**
         G.UT.SAVE.MARK - SAVE BOOKMARK TO FLOPPY DISC
         ---------------------------------------------

         INPUTS:

         address of scratch vector - used as a buffer
         size    of scratch vector
         type of save (m.ut.Community or m.ut.National)

         OUTPUTS:

         Returns TRUE for successful save
         Outputs error messages if disc errors are detected

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         G.ut.save.mark [work.vec, work.size, type]
         --------------

         Open DOMARK file on floppy disc
         Save SCREEN and CONTEXT vector to file

         IF type is Community
         THEN Save Community caches to disc
         ELSE Save National caches to disc

**/

AND G.ut.save.mark( vec.addr, vec.size, type ) = VALOF
$(                                   
   LET w.off    = ?         // offset into cache vector
   LET buff     = vec.addr
   LET no.error = TRUE

   no.error := open.mark( m.ut.new.mark ) 
   g.ut.mark.w := g.ut.mark.w + 1

   // first put the screen sprite into the file
   // 
   IF no.error THEN
   $( no.error := save.screen.sprite()

      // now put the bookmark cache into the file
      //  
      IF no.error THEN                     
      $( G.ut.restore( buff, m.io.booksize/bytesperword-1, m.io.context.cache )
         
         IF no.error THEN 
         $( no.error := do.block( m.ut.write.op, buff*bytesperword, 
                                                                m.io.booksize )             // now put all the overlay caches into the file
            //                   
            w.off := (type=m.ut.National -> m.io.natstart, 
                                                 m.io.comstart) / bytesperword
         $)
      $)
   $)
   IF no.error THEN 
   no.error := do.block( m.ut.write.op, (G.cachevec+w.off)*bytesperword,
                                                                m.io.halfram )
   UNLESS no.error THEN
   $( error.message()
      g.ut.mark.w := g.ut.mark.w - 1
   $)

   RESULTIS (close.mark() & no.error)  // all o.k
$)                             

AND error.message() BE
$(
manifest $( buff.size = 48 $)

   LET hed = "*SFloppy disc error:*S"
   LET str = VEC buff.size/bytesperword    

   G.ut.get.ermess( str, buff.size - hed%0 - 1)        

   g.ut.movebytes( str, 1, str, hed%0+1, str%0 )   
   g.ut.movebytes( hed, 1, str, 1,       hed%0 )

   str%0 := str%0 + hed%0     

   G.sc.clear (m.sd.message)     // DNH  9.10.86
   G.sc.ermess( str )
$)

//
//////////////////////////////////////////////////////////////////
//         the routines below are machine specific              //
//////////////////////////////////////////////////////////////////
//
// OPEN.MARK( type ) - opens a file called DOMARK on an ADFS disc
//
// IF the type is m.ut.new.mark, then any file on the disc called
//    DOMARK is explicitly deleted before the new one is opened.
// ELSE a file called DOMARK on the disc is opened for read only
//
// The procedure returns TRUE if the operation was successful,
// FALSE otherwise.
//
AND open.mark( type ) = VALOF
$(
   LET filename = "-adfs-MARK*s*s*c"  // filename - no fix now 30.07.86 PAC
   LET block    = VEC 5 
   let no = type = m.ut.new.mark -> g.ut.mark.w, g.ut.mark.r

   IF s.stream ~= 0 THEN close.mark()  // tidy up a previously opened file

   test no < 10 then   
   $( filename%12 := '*s'
      filename%11 := no rem 10 + '0'
   $)
   else
   $( filename%12 := no rem 10 + '0'
      filename%11 := (no rem 100)/10 + '0'
   $)

   TEST type = m.ut.new.mark
   THEN
   $( 
      Osfile( m.ut.delete.file, filename, block )       // first delete it
      s.stream := Osfind( m.ut.open.write, filename )   // then open it
   $)
   ELSE s.stream := Osfind( m.ut.open.read, filename )  // open it

   IF s.stream = 0 // file not found - early exit
   THEN
   $( 
// G.sc.ermess(" Floppy disc error: MARK%c%c not found",
//                  filename%11, filename%12)
      RESULTIS FALSE
   $)
   RESULTIS TRUE
$)
//
// CLOSE.MARK() - closes a previously opened file
//
// This procedure uses the static s.stream, which should contain
// the file handle for the previously opened bookmark file.
//
// IF s.stream = 0, THEN return TRUE
// ELSE call osfind to close the file
//
// The procedure returns TRUE if the operation was successful,
// FALSE otherwise.
//
AND close.mark() = VALOF
$(
   TEST s.stream = 0
      THEN RESULTIS TRUE // no file to close
      ELSE Osfind( m.ut.close, s.stream )

   s.stream := 0    // we've closed the open file

   RESULTIS TRUE // no error handling, I'm afraid
$)
//
// DO.BLOCK (opcode, main ram byte address, size in bytes )
//
// entry point to operating system block transfer routine
//
// reads/writes (according to opcode) a block of memory between
// core and floppy disc file.
//
AND do.block( opcode, buffer, n.bytes ) = VALOF
$(
   LET pb = VEC 6
   let t.res2 = ?

   pb!0 := s.stream
   pb!1 := buffer
   pb!2 := n.bytes
   pb!3 := 0

   Osgbpb( opcode, pb )

   t.res2 := Result2
   Check.( t.res2 = 0, 0 )

   RESULTIS (t.res2 = 0) // true if succesful
$)

//
// Save bookmark screen sprite area: 
//
// We know that there exists a sprite called 'bookscrn' somewhere
// in the sprite area. To find its absolute address, we select it,
// and look at the value returned in R2.
// Next, the sprite attributes are unpacked from this address.
// The format of the sprite is as follows:
//
//  OFFSET   CONTENTS
//  ------   --------
//  !0       Offset to next sprite
//  !1-!3    sprite name (12 chars, null padded)
//  ...
//  ...
//  !8       Offset to sprite image
//  !9       Offset to transparency mask (= sprite image if none)
//  !10      screen mode for sprite
//  !11...   palette data (not used in this case)
//
//  We need to: a) find the sprite
//              b) find how big it is
//              c) save it to the bookmark
//
AND save.screen.sprite() = VALOF
$(
   LET pb   = VEC 7
   LET name = "bookscrn*c" * bytesperword + 1
   LET addr = ?
   LET sprite.size = ?
   let t.res2 = ?

   pb!0 := G.sc.sprite.area              // unused if system sprite
   pb!1 := name                          // sprite name

   Check.( OsSprite( m.sd.select.sprite, pb ),1 ) // traps if it fails  

   addr := pb!1   // this is the absolute address of the sprite image

   // now we can unpack the information from the block
   // size of sprite is the same as the offset to next sprite
   // this is to be found at addr!0. BUT addr is a m/c address !
   // so unpack from 0, offset by addr.
   //
   G.ut.unpack32( 0, addr, @sprite.size )

   // now save the sprite
   //
   t.res2 := do.block( m.ut.write.op, addr, sprite.size )

   RESULTIS (t.Res2) // means success
$)

//
// Load bookmark screen sprite area:
//
// From the (succesfully opened) bookmark, load the bookmark sprite.
//
// (There may or may not be a bookmark sprite already defined.)
//
// First, find out the size of the screen, which will be contained 
// in the first 4 bytes of the bookmark.
//
// Next, clear the sprite area to ensure that there will be enough 
// space to load the bookmark screen.
// Also, find the address for the first free byte in the user sprite
// area.
//
// Now load the sprite into this area, and update the area control 
// block to show that there is a sprite there.
//
AND load.screen.sprite() = VALOF
$(
   LET pb   = VEC 7             // general parameter block
   LET dest = ? 
   LET sprite.size = ?
   LET sprite.area.vec = G.sc.sprite.area / bytesperword

   //
   // N.B. The sprite area global will ALWAYS 
   //      be divisible by bytesperword.
   //

   // find the sprite size
   //
   do.block( m.ut.read.op, @sprite.size * bytesperword, 4 )

   // n.b. file pointer updated !!

   // now clear the sprite area - see comments in INIT
   //
   pb!0 := G.sc.sprite.area        // R1 = sprite workspace 
   Check.( OsSprite( m.sd.clear.sprite.area, pb ),2) // reinit. sprite area
   pb!0 := G.sc.sprite.area        // to be safe
   Check.( OsSprite( m.sd.read.control.blk, pb),3)   // read sprite CB

   dest := pb!4             // byte offset to free area

   // read the sprite in from the disc 
   // - remember that the file pointer is 4 bytes up !!
   //  
   do.block( m.ut.read.op, 
             G.sc.sprite.area + dest + 4,  // mc address - skip size
             sprite.size - 4 )             // read 'size' - 4 bytes

   // set up the sprite size
   //
   G.ut.movebytes( @sprite.size,     // data source
                   0,                // source byte offset
                   sprite.area.vec,  // data destination
                   dest,             // dest. byte offset
                   4 )               // 4 bytes
     
   // finally... update the sprite area control block
   //
   sprite.area.vec!1 := 1                   // contains 1 sprite
   sprite.area.vec!2 := dest                // offset to 1st sprite
   sprite.area.vec!3 := dest + sprite.size  // offset to first free wd.

   RESULTIS (Result2 = 0)
$)

AND check.( ok, num ) BE UNLESS ok DO G.ut.trap("UT",50+num,FALSE,1,#xFF,0,0)
.
