//  AES SOURCE  6.87

/**
         PHOTO - NATIONAL PHOTO OVERLAY
         ------------------------------

         This module contains only DY.INIT and DY.FREE

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.photo

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         24.1.86  1        PAC         Initial version of Community Photo
          6.3.86  2        SRY         Modified for National Photo
          6.6.86  3        SRY         Fixed bug in Data1/2
         24.6.86  4        SRY         Video mode
         30.6.86  5        SRY         More video
          6.7.86  6        PAC         Remove unused dh manifests
         23.7.86  7        DNH         Set vrestore for Help unmute
         04.12.87 8        MH          Arcimedes update to photo sets

         GLOBALS DEFINED:
         g.np.dy.init
         g.np.dy.free
**/


SECTION "natinit"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNPhd.h"
get "GH/gldyhd.h"
get "H/iohd.h"
get "H/sdhd.h"
get "H/nphd.h"


/**
         proc G.NP.DY.INIT ()
              ------------

         General overlay initialisation routine

         PROGRAM DESIGN LANGUAGE:

         Get heap space for statics and data buffers
         Restore statics buffer from I/O processor memory
         Read data
**/

let g.np.dy.init() be
$(
   let bytes, temp = ?,?
   let npics = ?
   let fileptr32 = vec 1
   let t32 = vec 1
   let IAL, IAH = ?,?

   g.np.s := getvec (m.np.statics.size.words)
   g.ut.restore (g.np.s, m.np.cache.size.words, m.io.NPcache)

   g.np.short.buff := getvec (m.np.short.buff.size/bytesperword)
   g.np.rbuff := getvec (m.np.rbuff.size/bytesperword)
   g.np.tbuff := getvec (m.np.tbuff.size/bytesperword)

   // decode itemaddress to file flag and byte offset; store in statics
   IAL := g.ut.get32 (g.context+m.itemaddress, @IAH)
   g.np.s!m.np.is.data2 := (IAH & #X8000) ~= 0
   IAH := IAH & #X7fff                               // strip top bit
   g.ut.set32 (IAL, IAH, g.np.s + m.np.itemaddr32)   // store stripped value

   $<DEBUG
   if g.ut.diag () do
   $(
      g.sc.clear ( m.sd.display )
      g.sc.selcol( m.sd.yellow )
      g.sc.movea ( m.sd.display,0,m.sd.disYtex )

      writef ("Reading %S", g.np.s!m.np.is.data2 -> "DATA2", "DATA1")
      writes ("*NByte offset in data file:")
      writef ("*N   #X%X4%X4", IAH, IAL)
      writef ("*NInitial picture no: %N", g.context!m.picture.no)
   $)
   $>DEBUG

   // open data file and read number of pictures
   g.np.s!m.np.file.handle := g.dh.open ( g.np.s!m.np.is.data2 ->
                                                            "DATA2", "DATA1" )
   g.ut.set32 (m.np.num.pics.off, 0, fileptr32)
   g.ut.add32 (g.np.s + m.np.itemaddr32, fileptr32)
   g.dh.read (g.np.s!m.np.file.handle, fileptr32, @temp, 2)

   // unpack number of pics and set up according to top bit setting
   npics := g.ut.unpack16 (@temp, 0)
   g.np.s!m.np.descr.siz := (npics & #X8000) = 0 -> m.np.small.lc,
                                                            m.np.large.lc
   g.np.s!m.np.npics := npics & #X7fff

   // set frame.start32: absolute byte offset in data file
   g.ut.set32 (m.np.num.pics.off + 2, 0, g.np.s + m.np.frame.start32)
   g.ut.add32(g.np.s + m.np.itemaddr32, g.np.s + m.np.frame.start32)

   // set short.start32: absolute byte offset in data file
   g.ut.set32 (m.np.num.pics.off + 2 + 2 * npics, 0,
                                             g.np.s + m.np.short.start32)
   g.ut.add32 (g.np.s + m.np.itemaddr32, g.np.s + m.np.short.start32)

   // set long.start32: start with short.start32 and add length of sc's
   g.ut.mov32 (g.np.s + m.np.short.start32, g.np.s + m.np.long.start32)
   g.ut.set32 (npics * m.np.sclength, 0, t32)
   g.ut.add32 (t32, g.np.s + m.np.long.start32)

   // read short captions up to a maximum of m.np.max.shorts
   bytes := npics <= m.np.max.shorts -> npics, m.np.max.shorts
   bytes := bytes * m.np.sclength
   g.ut.mov32 (g.np.s + m.np.short.start32, fileptr32)
   g.dh.read (g.np.s!m.np.file.handle, fileptr32, g.np.short.buff, bytes)

   G.np.s!m.np.init := true
   get.f.buff()  //get smallest buffer 1st
   g.np.f.read(1)
   get.c.buff()  //get 2nd smallest buffer 2nd
   g.np.c.read(1)
   get.d.buff()  //get largest buffer last
   g.np.d.read(1)
   // ??? read some long captions ???
 
   if g.np.s!m.np.local.state = m.np.photo do
      g.np.s!m.np.vrestore := TRUE
   G.np.s!m.np.init := false
$)

and get.d.buff() be
$( let max.word = MAXVEC()
   let max.size = max.word > #x1FFF -> #x1FFF*bytesperword, 
                                                       max.word*bytesperword
   let l = g.np.s!m.np.descr.siz * m.np.lclength
   let n = g.np.s!m.np.npics
   let d.size = n * l
   
   if d.size > max.size then
   $(
      n := max.size / l
      d.size := n * l
   $)
   G.np.s!m.np.d.buf := GETVEC(d.size/bytesperword) 
                                         //get maximum buffer size allowed
                               //set end to point to last record in buffer
   G.np.s!m.np.d.n.rec := n //set to number of records in buffer
   G.np.s!m.np.d.midway := n / 2 //set midway pointer to midway
$)


and get.c.buff() be
$( let max.word = MAXVEC()
   let max.size = max.word > #x1FFF -> #x1FFF*bytesperword, 
                                                       max.word*bytesperword
   let l = m.np.sclength
   let n = g.np.s!m.np.npics
   let c.size = n * l
   
   if c.size > max.size then
   $(
      n := max.size / l
      c.size := n * l
   $)
   G.np.s!m.np.c.buf := GETVEC(c.size/bytesperword) 
                                        //get maximum buffer size allowed
                               //set end to point to last record in buffer
   G.np.s!m.np.c.n.rec := n //set to number of records in buffer
   G.np.s!m.np.c.midway := n / 2 //set midway pointer to midway
$)

and get.f.buff() be
$( let max.word = MAXVEC()
   let max.size = max.word > #x1FFF -> #x1FFF*bytesperword, 
                                                       max.word*bytesperword
   let l = m.np.frame.size
   let n = g.np.s!m.np.npics
   let f.size = n * l
   
   if f.size > max.size then
   $(
      n := max.size / l
      f.size := n * l
   $)
   G.np.s!m.np.f.buf := GETVEC(f.size/bytesperword) 
                                          //get maximum buffer size allowed
                               //set end to point to last record in buffer
   G.np.s!m.np.f.n.rec := n //set to number of records in buffer
   G.np.s!m.np.f.midway := n / 2 //set midway pointer to midway
$)

/**
         proc G.NP.DY.FREE ()
              ------------

         PROGRAM DESIGN LANGUAGE:

         Cache current data buffer in I/O processor
         Free the data buffer vector
         Switch video to micro only
**/

AND g.np.dy.free () BE
$(
   g.dh.close (g.np.s!m.np.file.handle)

   FREEVEC (g.np.tbuff)
   FREEVEC (g.np.rbuff)
   FREEVEC (g.np.short.buff)
   g.ut.cache (g.np.s, m.np.cache.size.words, m.io.NPcache)
   FREEVEC(g.np.s!m.np.d.buf)
   FREEVEC(g.np.s!m.np.c.buf)
   FREEVEC(g.np.s!m.np.f.buf)
   FREEVEC (g.np.s)
$)
.
