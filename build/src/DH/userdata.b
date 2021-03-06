/**
         DH.B.DH1 - User Primitives for the Data Handler
         -----------------------------------------------

         Based closely on primitives in dh1 & dh2

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.userdata

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
       4.02.87    1        SRY         Modified for User Data
       7.07.87    2        SRY         Bug in readframes
      24.12.87    3        MH          Updated for Arcimedes port
**/

section "userdata"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/dhhd.h"        // public header
get "H/dhphd.h"       // private header

/**
         G.ud.open (filename)
         --------------------
         opens the filename, specified as a string, for read
         only, returning a non-zero handle.  If the call fails
         for any reason this is a fatal error and an ermess is
         output.  Then 'g.ut.videodisc.error' is called.
         There is no check on the string parameter.
**/

let G.ud.open(filename) = valof
$( let handle = ?

     handle := osfind(m.osfind.open.read.op, filename)
   if handle = 0 do         // bad handle: out of range
   $( g.sc.ermess ("File %S not found", filename)
      handle := 0
   $)
 resultis handle                           // all ok
$)


/**
         G.ud.read (handle, file-pointer, destination-vector,
         ---------                             bytes-to-be-read)
         Returns the number of bytes read successfully into the
         destination vector from the file specified by 'handle'
         starting from the 32-bit offset 'file-pointer' within
         the file.  The offset is not altered by the call
         whether it succeeds or fails.
         If the call fails for any reason (eg. end of file)
         g.ut.videodisc.error is called - a fatal error - with
         the last SCSI error code.
         Uses 'osgbpb'.
**/

and G.ud.read (handle, file.pointer, dest.vec, bytes) = valof
$( 
   LET pb = VEC 6

 //  handle := (handle << 16) | m.osgbpb.gb.newptr.op  


   pb!0 := handle                 // r1
   pb!1 := dest.vec*bytesperword  // r2
   pb!2 := bytes                  // r3
   pb!3 := file.pointer!0         // r4

   bytes := bytes-Osgbpb( m.osgbpb.gb.newptr.op, pb ) // opcode


   unless result2 = 0 do g.ut.videodisc.error ()   // fatal !
   
   resultis bytes                                  // all OK
$)

and G.dh.delete.file(file) = valof
$(
   manifest $( m.delete.file.op = #x06 $)

   let pb = VEC 5 // used because osfile returns catalogue info (ignored here)
   let fs = G.dh.fstype()

   unless fs = m.dh.adfs G.vh.call.oscli("adfs*C")
   osfile(m.delete.file.op, file, pb)
   unless fs = m.dh.adfs G.vh.call.oscli("vfs*C")

   if RESULT2 ~= 0 then
   $( let string = vec 39/bytesperword
      G.ut.get.ermess(string, 39)
      G.sc.ermess(string)
      resultis false
   $)
   resultis true
$)


/**
         G.ud.readframes (frame.number, destination-vector,
                                                   frames-to-read)
         ---------------------------------------------------------
         Reads 1 frame's worth of bytes from the relative frame
         frame.no into dest.vec.
         User Data version opens and closes file from G.context and
         uses read-file.
         Returns True for success or false otherwise.
**/

and G.ud.readframes (frame.no, dest.vec) = valof
$( let itemrecord = G.context + m.itemrecord
   let fs = G.dh.fstype()
   let res = true
   let handle = ?
   let bytes = m.dh.bytes.per.frame
   let length = vec 1
   let framebytes = vec 1
   let offset = vec 1
   let filename = vec 40/bytesperword

   G.ut.set32(m.dh.bytes.per.frame, 0, framebytes)
   unless fs = m.dh.adfs G.vh.call.oscli("ADFS*C")

   G.ut.set32(frame.no, 0, offset)
   G.ut.mul32(framebytes, offset)  // byte offset in file to read

   for i = 2 TO itemrecord%0 filename%(i-1) := itemrecord%i // miss ~
   filename%0 := itemrecord%0 - 1

   handle := G.ud.open(filename)
   if handle = 0 goto error

   G.dh.length(handle, length)
   if g.ut.cmp32(offset, length) = m.gt
   $( G.sc.ermess("Error accessing dataset")
      goto error // off end of file
   $)
   G.ut.sub32(offset, length)             // length is remaining portion
   if G.ut.cmp32(length, framebytes) = m.lt bytes := !length

   if G.ud.read(handle, offset, dest.vec, bytes) > 0 goto exit

error:
   res := false

exit:
   G.dh.close(handle)
   unless fs = m.dh.adfs G.vh.call.oscli("VFS*C")
   resultis res
$)

and err.() BE
$( let string = vec 40/bytesperword
   G.ut.get.ermess(string, 39)
   G.sc.ermess(string)
$)
.
