//  $MSC
//  AES SOURCE  4.87

/**
         DH.B.DH1 - Primitives for the Data Handler
         ------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         15.11.85 1        D.Hepper    Initial version
         17.1.86  2        DNH         Trap calls in
          3.2.86  3                    Change g.dh.reset
         14.3.86  4        DNH         Make read failure in
                                       g.dh.read non-fatal
         27.5.86  5        DNH         Remove local debug tag
         25.6.86  6        DNH         Fatal error handling
         22.7.86  7        DNH         open & read err handling
          5.8.86  8        DNH         further error changes
          8.5.87    9      PAC         Adopted for AES system
                                       Fixed open, etc.
          21.7.87   10     PAC         New GBPB
          31.7.87   11     PAC         Fix adfs files
          16.12.87  12     PAC         Fix horrendous bug !!
          21.12.87  13     MH          Update to G.dh.read, 
                                       G.context!m.video.mode to OFF.
          
         g.dh.open
         g.dh.read
         g.dh.close
         g.dh.fstype
         g.dh.length
         g.dh.reset
**/

section "dh1"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/dhhd.h"        // public header
get "H/dhphd.h"       // private header
get "H/uthd.h"
get "H/vhhd.h"

$$adfsnames // to pick up names file from adfs

/**
         g.dh.open (filename)
         --------------------
         opens the filename, specified as a string, for read
         only, returning a non-zero handle.  If the call fails
         for any reason this is a fatal error and an ermess is
         output.  Then 'g.ut.videodisc.error' is called.
         There is no check on the string parameter.
**/

let g.dh.open (filename) = valof
$( 
   let handle = ?

 $<adfsnames 
   let buf      = VEC 20/bytesperword
   let ourhand  = 0

   if we.want.this( filename ) then 
   $(
      Let adfsname = concat.("-adfs-", filename, buf) 
      ourhand  := Osfind( m.osfind.open.read.op, adfsname )
   $)

   test ourhand ~= 0
   then handle := ourhand
   else
 $>adfsnames     
   handle := Osfind( m.osfind.open.read.op, filename )

   if handle = 0 do               // bad handle: file not found
   $(
      g.sc.mess ("File %S not found", filename)
      g.ut.abort (m.ut.videodisc.abort)      // fatal error !!
   $)
   resultis handle                           // all ok
$)

$<adfsnames    
AND we.want.this( name ) = VALOF
$(
   if G.context!m.discid ~= m.dh.natA resultis false

   if compstring( "Gallery"   , name ) = 0 resultis true
   if compstring( "Gazetteer" , name ) = 0 resultis true
   if compstring( "Hierarchy" , name ) = 0 resultis true
   if compstring( "Index"     , name ) = 0 resultis true
   if compstring( "Mapdata"   , name ) = 0 resultis true
   if compstring( "Names"     , name ) = 0 resultis true

   resultis false
$)

AND concat.( s1, s2, buf ) = VALOF
$(
   g.ut.movebytes (s1, 1, buf, 1,      s1%0)
   g.ut.movebytes (s2, 1, buf, s1%0+1, s2%0)
   buf%0 := s1%0 + s2%0
   resultis buf
$)
$>adfsnames

/**
         g.dh.read (handle, file-pointer, destination-vector,
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

and g.dh.read (handle, file.pointer, dest.vec, bytes) = valof
$( 
   LET pb = VEC 6

 //  handle := (handle << 16) | m.osgbpb.gb.newptr.op  

$<debug show.delay() $>debug

   pb!0 := handle                 // r1
   pb!1 := dest.vec*bytesperword  // r2
   pb!2 := bytes                  // r3
   pb!3 := file.pointer!0         // r4

   bytes := bytes-Osgbpb( m.osgbpb.gb.newptr.op, pb ) // opcode

$<debug show.delay() $>debug   

   G.context!m.video.mode := m.vh.video.off //added 21.12.87 MH
   unless result2 = 0 do g.ut.videodisc.error ()   // fatal !
   
   resultis bytes                                  // all OK
$)

/**
         g.dh.close (handle)
         -------------------
         Closes the file whose handle is specified.  If a handle of
         zero is passed ALL open files of the current filing system
         are closed.
         No indication of success is returned.
         Uses 'osfind'.
**/

and g.dh.close (handle) be Osfind( m.osfind.close.op, handle )
                           
/**
         g.dh.fstype ()
         --------------
         Returns the type of the current filing system, which
         should be looked up in the manifest header 'dhhdr'.
         Uses 'osargs'.
**/

and g.dh.fstype () = valof
$(          // returns the current filing system code, as defined in h.dhhdr
   Let rc = Osargs( m.osargs.fstype.op, m.osargs.fstype.op, 0 ) // A = Y = 0  
   resultis rc                                      // filing system from A
$)

/**
         g.dh.length (handle, destination-vector)
         ----------------------------------------
         Returns the length in bytes of file specified by handle
         in the 32-bit destination vector, or 0 for failure or
         zero length.
         Uses 'osargs'.
**/

and g.dh.length (handle, dest.vec) be
$( 
   Osargs( m.osargs.flength.op, handle, 0 )

   dest.vec!0 := Result2   // copy out to caller's vec
$)

/**
         g.dh.reset ()           3.2.86
         -------------
         Special routine currently for testing of CMOS ram for
         boot purposes.  Returns the value of location 30.
**/

and g.dh.reset () = valof
$(
   Osbyte( m.osbyte.read.ram, 30)
   resultis Result2        // Y reg.
$)

$<debug
and show.delay() be 
$(  
   LET coords = VEC 3
   G.sc.savcur(coords)
   G.sc.movea ( 1,4,4 )         // into menu
   G.sc.XOR.selcol( 2 )         // set colour = blue
   VDU("25,%,%;%;",#x61 , 32 , 47 )    // plot over first box  
   G.sc.selcol( 3 )  
   G.sc.rescur(coords)
$)
$>debug


/**
         g.dh.read.names.rec (handle, rec.no, des.vec, bytes)
         ----------------------------------------------------
         This routine reads 36 bytes from the NAMES record and 
         4 bytes from the TYPE and HIERARCHY data vector and
         combines them into a 40 byte record with the TYPE nibble
         removed
**/

and G.dh.read.names.rec(handle, rec.no, des.vec, bytes) = valof
$(
   let names.ptr = vec 1 // file pointer for the names record
   let h.ptr = vec 1 //pointer to TYPE and HIERARCHY data
   let t = vec 1  
   let t1 = vec 1 
   let bytes.read = 0

   G.ut.set32(bytes-4, 0, names.ptr)
   G.ut.mul32(rec.no, names.ptr)   //get names offset in NAMES file
   bytes.read := g.dh.read(handle, names.ptr, des.vec, bytes-4) 
                  //read from NAMES file
   
   G.ut.set32(2, 0, h.ptr) 
   G.ut.mul32(rec.no, h.ptr) //get TYPE and HIERARCHY record pointer
   G.ut.set32(0, 0, t)
   G.ut.movebytes(G.context!m.hie.ptr, !h.ptr, t, 0, 2)
   !t := !t & #xFFF //get rid of type nibble
   G.ut.set32(128, 0, t1)
   G.ut.mul32(t1, t)
   G.ut.movebytes(t, 0, des.vec, bytes-4, 4) //move in hierarchy record
   resultis bytes.read + 4
$)
   

/**
         g.dh.read.type (rec.no)
         ---------------------------
         This routine returns the TYPE of the record number passed to it.
**/

and G.dh.read.type(rec.no) = valof
$(
   let t.ptr = vec 1
   let type = 0
   
   G.ut.set32(2, 0, t.ptr)
   G.ut.mul32(rec.no, t.ptr)
   G.ut.movebytes(G.context!m.hie.ptr, !t.ptr, @type, 0, 2)
   resultis (type >> 12)
$)
   

/**
         g.dh.read.THES.rec (rec.no, des.vec)
         ----------------------------------------------------
         This routine reads 4 bytes from the TYPE and HIERARCHY 
         data vector into the destination vector des.vec.
**/

and G.dh.read.thes.rec(rec.no, des.vec) be
$(
   let h.ptr = vec 1 //pointer to TYPE and HIERARCHY data
   let t = vec 1  
   let t1 = vec 1 
   
   G.ut.set32(2, 0, h.ptr) 
   G.ut.mul32(rec.no, h.ptr) //get TYPE and HIERARCHY record pointer
   G.ut.set32(0, 0, t)
   G.ut.movebytes(G.context!m.hie.ptr, !h.ptr, t, 0, 2)
   !t := !t & #xFFF //get rid of type nibble
   G.ut.set32(128, 0, t1)
   G.ut.mul32(t1, t)
   G.ut.movebytes(t, 0, des.vec, 0, 4) //move in hierarchy record
$)  
.
