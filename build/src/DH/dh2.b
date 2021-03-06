//  $MSC
//  AES SOURCE  4.87

/**
         DH.B.DH2 - More Primitives for the Data Handler
         -----------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         18.11.85 1        D.Hepper    Initial version
         17.1.86  2        DNH         Trap calls in
         12.2.86  3        DNH         Changes to avoid VFS
                                       /ADFS clash of oswords
         14.3.86  4        DNH         New routine for discid
         25.6.86  5        DNH         Fatal error handling
         27.6.86  6        DNH         readfr. back as function
         23.7.86  7        DNH         Add g.dh.SCSI.error
          5.8.86  8        DNH         Discid using User Code,
                                       Further error changes
         21.10.86  9       DNH         Loop in discid to read
                                       fcode reply
          8.5.87   10      PAC         Adopted for AES
                                       Fixed G.dh.readframes
         22.5.87   11      PAC         Bug fixed in readframes      
         25.7.87   12      PAC         New A500 readframes

         g.dh.readframes
         g.dh.discid
         g.dh.SCSI.error
**/

section "dh2"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/dhhd.h"
get "H/dhphd.h"
get "H/vhhd.h"


/**
         g.dh.readframes (frame.number, destination-vector,
                                                   frames-to-read)
         ---------------------------------------------------------
         Reads frames-to-read's worth of bytes from the sector
         starting at 'frame.number' into 'destination-vector'.
         Returns true.  Returns only if successful, otherwise
         it calls g.ut.videodisc.error - fatal error.
         Uses 'OsSCSILoad'.

         N.B. no tests for filing system - always reads VFS
**/

let g.dh.readframes (frame.no, dest.vec, frames) = valof
$(
   let res             = ?
   let start.sector    = ?       
   let num.of.words    = ?

   num.of.words := ( m.dh.bytes.per.frame * frames ) / bytesperword
   start.sector := m.dh.sectors.per.frame * frame.no

   $<debug show.delay() $>debug                                                

   res := OsSCSILoad( dest.vec, 
                      dest.vec + num.of.words, 
                      start.sector, 
                      m.SCSI.Control.word )

   $<debug show.delay() $>debug                                                

   unless res do 
   $( G.ut.videodisc.error() // a fatal error - does not return...
      resultis false         // ...so this line is only for neatness
   $)

   resultis true
$)

$<debug
and show.delay() be 
$(  
   LET coords = VEC 3
   G.sc.savcur( coords )
   G.sc.movea ( 1,4,4 )                // into menu
   G.sc.XOR.selcol( 2 )                // set colour = blue
   VDU("25,%,%;%;",#x61 , 32 , 47 )    // plot over first box  
   G.sc.selcol( 3 )     
   G.sc.rescur(coords)
$)
$>debug

/* *******************************************************************

   Fillwords( rcb, m.cbsw, 0 )      // clear the buffer

   // now fill in the details of the control block for reading
   //         (See VFS manual)
               
   dest.vec := dest.vec * bytesperword // machine address of buffer

   rcb%1    := dest.vec          // byte address
   rcb%2    := dest.vec >> 8
   rcb%3    := dest.vec >> 16
   rcb%4    := dest.vec >> 24

   rcb%5    := m.osword.read
   rcb%6    := (start.sector>>16) & #X1f
                                    // top 3 bits is drive 0, bottom 5 bits
                                    // is top of start-sector number
   rcb%7    := start.sector>>8      // middle byte (n.b. backwards order!)
   rcb%8    := start.sector         // bottom byte of start-sector
   rcb%9    := sectors.to.read      // (won't overflow one byte)

   read.write.code := m.vfs.osword.read.write
                                    // debugging code only. r/w code is
   $<DEBUG                          // different for ADFS. see manuals.
   if g.dh.fstype () = m.dh.adfs do
      read.write.code := m.adfs.osword.read.write
   show.delay()
   $>DEBUG

   Osword( read.write.code, rcb )
               
   $<debug show.delay() $>debug                                                

   unless rcb%0 = 0 do              // failed so find the error
   $(
      g.ut.videodisc.error ()       // fatal error
      resultis false                // (should never get this far)
   $)
   resultis true                    // success status
$)
***************************************************************** */
                
/*
  This is the format of the OSWORD buffer

  Wordsize-specific, but it's M/C specific anyway.

  %   RCB

  0   buffer%0        - reply
                 _
  1   buffer%1    \
  2   buffer%2     \  - buffer address (H/W) address
  3   buffer%3     /
  4   buffer%4   _/
                 _
  5   buffer%5    \
  6   buffer%6     \
  7   buffer%7      \
  8   buffer%8       >- disc controller command 
                    /
  9   buffer%9     /
  10  buffer%10  _/
  11  buffer%11   \
  12  buffer%12    \
                    \ - data length in bytes
  13  buffer%13     /
  14  buffer%14    /
  15  buffer%15  _/
  16  buffer%X        - null

*/

/*
         g.dh.SCSI.error () returns the value of the last SCSI
         error from LVDOS via VFS.
         Uses osword.
*/

let g.dh.SCSI.error () = valof
$(
   let rcb = vec m.cbsw                         // read control block
   let get.error.code = m.vfs.osword.get.error  // (doesn't need a buf)

   $<DEBUG
   if g.dh.fstype () = m.dh.adfs do
      get.error.code := m.adfs.osword.get.error
   $>DEBUG

   Osword( get.error.code, rcb ) 

   resultis rcb%3                               // SCSI error code
$)

/*
         g.dh.discid () returns a manifest for the disc side
         currently logged into the player.
         The disc must be up to speed before the call is made.
         Only genuine Domesday discs return the manifests for
         these discs.  The default for an unknown disc is
         'm.dh.not.domesday'.
         Uses g.vh.send.fcode to send a "?U" to the player
         and g.vh.poll to read the reply.  Ensures that the
         player has provided a reply string of some sort by
         repeatedly calling read.reply.
*/

let g.dh.discid () = valof
$(
   let reply = vec m.vh.poll.buf.words

   g.vh.send.fcode ("?U")              // mod. DNH 21.10.86
   g.vh.poll (m.vh.read.reply, reply) repeatwhile reply%0 = '*C'
   if reply%0 = 'U' do
   $(             // reply format of south, for eg., is "U1=066"
      let user.code = (reply%1-'0') * 1000 +
                      (reply%3-'0') *  100 +
                      (reply%4-'0') *   10 +
                      (reply%5-'0')
      switchon user.code into
      $(
         case 1066: resultis m.dh.south
         case 1067: resultis m.dh.north
         case 1986: resultis m.dh.natA
         case 1987: resultis m.dh.natB
      $)
   $)
   resultis m.dh.not.domesday             // any other reply
$)
.
