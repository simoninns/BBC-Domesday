//  AES SOURCE  12.87

/**
         PHOTO - NATIONAL PHOTO OVERLAY
         ------------------------------


         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.photo

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         04.12.87 1        MH          initial versiotn for Arcimedes update 
                                       to photo sets

         GLOBALS DEFINED:
         
**/


SECTION "natpho3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNPhd.h"
get "GH/gldyhd.h"
get "H/iohd.h"
get "H/sdhd.h"
get "H/nphd.h"


/**
         proc G.NP.D.READ (NO)
              ----------------

         Reads in descrition data into intermediate buffer

         PROGRAM DESIGN LANGUAGE:
         get description size
         page.no = no / number of records per page
         page.pos = no - (no of recs per page * page no)
         IF buffer can be completely filled THEN
            bytes.to.read = description size * no.recs per page
         ELSE
            bytes.to.read = (total no of pics - no) * description size)
         file.pos = (no.pages * description size) + offset to start of data
         read data
         position in buffer = page.pos * description size

         
**/

let g.np.d.read(no) be
$(
   let l = g.np.s!m.np.descr.siz * m.np.lclength
   let bytes.to.read = vec 1
   let f.pos = vec 1
   let t = vec 1
   let n = ?

   G.ut.set32(G.np.s!m.np.d.n.rec * l, 0, bytes.to.read)
   test no - G.np.s!m.np.d.midway < 0 then
      n := 1
   else test no + G.np.s!m.np.d.n.rec > G.np.s!m.np.npics then
      n := G.np.s!m.np.npics - (G.np.s!m.np.d.n.rec - 1)
   else
      n := no - G.np.s!m.np.d.midway
   G.ut.set32(n - 1, 0, t)
   G.ut.set32(l, 0, f.pos)
   G.ut.mul32(t, f.pos)
   G.ut.add32(g.np.s+m.np.long.start32, f.pos)
   g.dh.read(g.np.s!m.np.file.handle, f.pos, g.np.s!m.np.d.buf, !bytes.to.read)
   g.np.s!m.np.d.first := n
   UNLESS G.np.s!m.np.init G.np.show.picture()
$)

/**
         proc G.NP.C.READ (NO)
              ----------------

         Reads in caption data into intermediate buffer

         PROGRAM DESIGN LANGUAGE:
         get caption size
         page.no = no / number of records per page
         page.pos = no - (no of recs per page * page no)
         IF buffer can be completely filled THEN
            bytes.to.read = caption size * no.recs per page
         ELSE
            bytes.to.read = (total no of pics - no) * caption size)
         file.pos = (no.pages * caption size) + offset to start of data
         read data
         position in buffer = page.pos * caption size

         
**/

let g.np.c.read(no) be
$(
   let l = m.np.sclength
   let bytes.to.read = vec 1
   let f.pos = vec 1
   let t = vec 1
   let n = ?

   G.ut.set32(G.np.s!m.np.c.n.rec * l, 0, bytes.to.read)
   test no - G.np.s!m.np.c.midway < 0 then
      n := 1
   else test no + G.np.s!m.np.c.n.rec > G.np.s!m.np.npics then
      n := G.np.s!m.np.npics - (G.np.s!m.np.c.n.rec - 1)
   else
      n := no - G.np.s!m.np.c.midway
   G.ut.set32(n - 1, 0, t)
   G.ut.set32(l, 0, f.pos)
   G.ut.mul32(t, f.pos)
   G.ut.add32(g.np.s+m.np.short.start32, f.pos)
   g.dh.read(g.np.s!m.np.file.handle, f.pos, g.np.s!m.np.c.buf, !bytes.to.read)
   g.np.s!m.np.c.first := n
   UNLESS G.np.s!m.np.init G.np.show.picture()
$)

/**
         proc G.NP.F.READ (NO)
              ----------------

         Reads in frame data into intermediate buffer

         PROGRAM DESIGN LANGUAGE:
         get frame size
         page.no = no / number of records per page
         page.pos = no - (no of recs per page * page no)
         IF buffer can be completely filled THEN
            bytes.to.read = frame size * no.recs per page
         ELSE
            bytes.to.read = (total no of pics - no) * description size)
         file.pos = (no.pages * frame size) + offset to start of data
         read data
         position in buffer = page.pos * frame size

         
**/

let g.np.f.read(no) be
$(
   let l = m.np.frame.size
   let bytes.to.read = vec 1
   let f.pos = vec 1
   let t = vec 1
   let n = ?

   G.ut.set32(G.np.s!m.np.f.n.rec * l, 0, bytes.to.read)
   test no - G.np.s!m.np.f.midway < 0 then
      n := 1
   else test no + G.np.s!m.np.f.n.rec > G.np.s!m.np.npics then
      n := G.np.s!m.np.npics - (G.np.s!m.np.f.n.rec - 1)
   else
      n := no - G.np.s!m.np.f.midway
   G.ut.set32(n - 1, 0, t)
   G.ut.set32(l, 0, f.pos)
   G.ut.mul32(t, f.pos)
   G.ut.add32(g.np.s+m.np.frame.start32, f.pos)
   g.dh.read(g.np.s!m.np.file.handle, f.pos, g.np.s!m.np.f.buf, !bytes.to.read)
   g.np.s!m.np.f.first := n
   UNLESS G.np.s!m.np.init G.np.show.picture()
$)


/**
         proc G.NP.READ.DESCR (BUFF, NO)
              --------------------------

         PROGRAM DESIGN LANGUAGE:
         get page number for no
         get position in page for no
         IF page no ~= current page no THEN
            read in next page
            update current page
         END IF
         move the data into output buffer

         
**/

let g.np.read.descr(buff, no) be
$(
   let l = g.np.s!m.np.descr.siz * m.np.lclength

   if (no < G.np.s!m.np.d.first) | 
       (no > (G.np.s!m.np.d.first + G.np.s!m.np.d.n.rec - 1)) then
         g.np.d.read(no)
   g.ut.movebytes(g.np.s!m.np.d.buf, (no-G.np.s!m.np.d.first)*l, buff, 0, l)
$)

/**
         proc G.NP.READ.CAP (BUFF, NO)
              ------------------------

         PROGRAM DESIGN LANGUAGE:
         get page number for no
         get position in page for no
         IF page no ~= current page no THEN
            read in next page
            update current page
         END IF
         move the data into output buffer

         
**/

let g.np.read.cap(buff, no) be
$(
   let l = m.np.sclength 

   if (no < G.np.s!m.np.c.first) | 
       (no > (G.np.s!m.np.c.first + G.np.s!m.np.c.n.rec - 1)) then
      g.np.d.read(no)
   g.ut.movebytes(g.np.s!m.np.c.buf, (no-G.np.s!m.np.c.first)*l, buff, 0, l)
$)

/**
         proc G.NP.READ.FRAME (BUFF, NO)
              --------------------------

         PROGRAM DESIGN LANGUAGE:
         get page number for no
         get position in page for no
         IF page no ~= current page no THEN
            read in next page
            update current page
         END IF
         move the data into output buffer

         
**/

let g.np.read.frame(buff, no) be
$(
   let l = m.np.frame.size 

   if (no < G.np.s!m.np.f.first) | 
       (no > (G.np.s!m.np.f.first + G.np.s!m.np.f.n.rec - 1)) then
      g.np.d.read(no)
   g.ut.movebytes(g.np.s!m.np.f.buf, (no-G.np.s!m.np.c.first)*l, buff, 0, 2)
   !buff := !buff & #xFFFF
$)
.
