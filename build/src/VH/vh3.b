//  $MSC
//  AES SOURCE  4.87

section "vh3"
/**
         VH.VH3 - VIDEO HANDLER POLL PRIMITIVE
         -------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         21.3.86   1       D.Hepper    Initial version
         24/03/86  2       JIBC        Mods following Philips
                                        recommendations
         06/05/86  3       PAC         Remove RUNPROG
         25.06.86  4       DNH         fatal error handling
         27.06.86  5       DNH         use g.vh.send.fcode
          5.8.86   6       DNH         Error handling
         21.10.86  7       DNH         Wait for reply to a
                                       "?x" type poll
          8.5.87   8       PAC         Adopted for AES
                                       Fixed read.fcode.reply
                   9       PAC         New A500 read.fcode.reply
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/dhhd.h"
get "H/dhphd.h"
get "H/vhhd.h"


/**
         g.vh.poll (mode, reply.buffer)
         ------------------------------
         Polls the disc using the specified mode.  These test for
         player status, frame number or chapter number; use
         manifests from vhhdr.  Returns word value; look up in
         vhhdr.
         Reply buffer MUST be set up by the caller to a vector of
         m.vh.poll.buf.words.  This is filled in by VFS.  It may
         be examined if more info is required, for example from a
         poll status request.  The valid bytes are terminated by
         a carriage return.

         Uses 'osword', testing for VFS filing system. Returns
         m.vh.bad.filing.system unless VFS is the currently
         selected filing system.

         Program Design
         --------------
         rc = g.vh.poll [mode, reply.buffer]
         do
            if filing system not VFS return 'bad filing system'
            send fcode request according to mode
            repeatedly read fcode reply  (aborts on failure)
               while the reply is not ready, for any mode other
               than 'read.reply'
            if player returns 'O' return 'lid open'
            if player returns 'X' return 'missing'
            if mode is frame or chapter poll
            then
               decode frame number
               return frame number
            endif
            if mode is player status
            then
               if player returns without 'Normal mode' bit set
                  return 'not ready'
               return disc type bits - these indicate CLV/CAV
            endif
         end
**/

let g.vh.poll (mode, buf) = valof
$(
   let rc = ?
   let cs = "?x"  // command string

   $<DEBUG
   unless g.dh.fstype () = m.dh.vfs resultis m.vh.bad.filing.system
   $>DEBUG

   unless mode = m.vh.read.reply do
   $( cs%2 := mode         // mode is an ascii letter
      g.vh.send.fcode (cs)
   $)

$<debug show.delay() $>debug

   read.fcode.reply (buf) repeatwhile buf%0 = '*C' &
                                      mode ~= m.vh.read.reply       
$<debug show.delay() $>debug 

   if buf%0 = 'O' resultis m.vh.lid.open
   if buf%0 = 'X' resultis m.vh.missing
   SWITCHON mode INTO
   $(
      CASE m.vh.read.reply:
         if buf%0 = 'A' resultis m.vh.finished
         resultis m.vh.unfinished      // eg. buffer contains '*C'

      CASE m.vh.frame.poll  :
      CASE m.vh.chapter.poll:
         unless buf%0 = mode resultis m.vh.bad.result
               // should return same code as was sent. eg. 'F'
               // ?F or ?C sent: return the frame or
               // chapter number reply as a word
         resultis asc.bin (buf, 1) // starts at buf%1

      CASE m.vh.player.status.poll:
               // return type of disc playing, or not ready
         if (buf%1 & m.vh.N.mode) = 0 resultis m.vh.not.ready
         resultis buf%2 & (m.vh.CLV | m.vh.CAV)

      DEFAULT:
         resultis m.vh.bad.mode        // calling mode is undefined!
   $)
$)


/*
         asc.bin () converts a CR-terminated digit string
         starting at p%d to a word value using up to 16 bits and
         returns this.

         val16 := asc.bin (p, d)
*/

and asc.bin (p, d) = valof
$( let sum = 0
   $( let ch = p%d
      if ch = #X0d resultis sum       // CR is terminator of fcode reply
      sum := sum * 10 + ch - '0'
      d := d + 1
   $) repeat
$)


/*
         read.fcode.reply [reply.buffer] sends a request to VFS
         to read the LVDOS reply buffer.  A buffer must be
         provided for the reply.
         If the call failed a fatal error is reported.  This
         may abort the program.
*/

and read.fcode.reply (buf) be
$(
   LET rcb = VEC 256/bytesperword // private buffer for reply

   unless OSReadFcode( rcb ) do   // read the fcode
      g.ut.videodisc.error()      // fatal error !!!

   Movewords( 1, m.vh.poll.buf.words, rcb, buf ) // set up reply buffer
$)

/* *****************************************************

   buf := buf * bytesperword      // machine address of buffer    

   rcb%1 := buf                   // setup byte address of buffer
   rcb%2 := buf >> 8   
   rcb%3 := buf >> 16   
   rcb%4 := buf >> 24
   rcb%5 := m.osword.get.fcode.result

   // n.b. m.vh.poll.buff.words must be less than 64 !!
   rcb%11 := m.vh.poll.buf.words * bytesperword  // convert to bytes

   Osword( m.vfs.osword.read.write, rcb )

   unless rcb%0 = 0 do              // non-zero = failed
   $(
      g.ut.videodisc.error ()  // fatal disc error !!
   $)
$)

  This is the format of the OSWORD buffer

  Wordsize-specific, but it's M/C specific anyway.

  %   RCB

* 0   buffer%0        - reply
                 _
  1   buffer%1    \
  2   buffer%2     \  - buffer address (H/W) address
  3   buffer%3     /
* 4   buffer%4   _/
                _
  5   buffer%5    \
  6   buffer%6     \
  7   buffer%7      \
* 8   buffer%8       >- disc controller command word(s)
                    /
  9   buffer%9     /
  10  buffer%10  _/
  11  buffer%11   \
* 12  buffer%12    \
                    \ - data length in bytes
  13  buffer%13     /
  14  buffer%14    /
  15  buffer%15  _/
* 16  buffer%X        - null

************************************************************** */
    
$<debug
and show.delay() be 
$(
   G.sc.movea ( 1,40,4 )         // into menu
   G.sc.XOR.selcol( 2 )         // set colour = blue
   VDU("25,%,%;%;",#x61 , 32 , 47 )    // plot over first box  
   G.sc.selcol( 2 ) 
$)
$>debug
.
