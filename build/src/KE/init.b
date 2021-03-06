//  AES SOURCE  4.87

/**
         INIT - MACHINE SPECIFIC INITIALISATION
         --------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel - unfortunately. 

         N.B. This was throwaway code in the original system.

         REVISION HISTORY:

         DATE      VERSION  AUTHOR  DETAILS OF CHANGE
         28.4.87   1        PAC     ADOPTED FOR AES SYSTEM
                                    - Tidied up a lot     
                                    - G.IN.dy.xxxx
         27.5.87   2        PAC     Remove G.in.dy.free
                                    & set up uninit globals   
          1.6.87   3        PAC     Initialise Escape key
         15.6.87   4        PAC     Add call to debug()
         23.7.87   5        PAC     New A500 mouse handling,
                                    and screen setup
         29.7.87   6        PAC     Fix sprite handling for 
                                    Acorn bug
         17.9.87   7        PAC     Remove globals setup
         23.12.87  8        MH      G.ut.mark.r and G.ut.mark.w initialised to
                                    1 for numbered book marks
**/

SECTION "b.Init"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/gldyhd.h"
get "H/sdhd.h"
get "H/sdphd.h"
get "H/kdhd.h"
get "H/uthd.h"
get "H/iophd.h"

LET G.IN.dy.init() BE
$(    
   check.configuration()
//   setup.globals() removed PAC 17.9.87 ARM is OK
   setup.screen()
   setup.player()
   setup.keyboard()
   setup.font()

   //  ut.write globals - set up ONLY on startup.
   G.ut.stream      := 0 // file handle
   G.ut.sequence.no := 1 // file number
   G.ut.mark.r := 1      //added for numbered book marks 23.12.87 MH
   G.ut.mark.w := 1

$<debug
   if g.ut.diag() do Debug(0)
$>debug

   G.sc.keyboard.flush() // Flush keyboard buffer last    
$)

//
// need to do something here to ensure that the system has
// enough screen memory configured, etc.
//
AND check.configuration() BE RETURN

/* ***********************************************************

AND check.( runprog.result ) BE UNLESS runprog.result fall.over()

AND fall.over() BE
$( G.sc.mess("Error: System wrongly Configured")
   G.ut.abort(m.ut.init.abort)
$)
********************************************************************** */


//
// Initialise unused globals to point at the 'undefined global' 
// handling routine.
//
AND setup.globals() BE
$(                              
   LET gv = @g0                 // address of global vector

   FOR i = 1 to globsize 
   IF (gv!i) >> 16 = #xAE95 DO 
   $( 
      gv!i := Undefined.Global
   $)             
$)                                     
//
// this procedure is defined as global in H/libhdr
//
AND Undefined.global() BE $( G.sc.beep() ; Abort(5) $)

//
// Initialise display, mouse and sprite space
//
//
AND setup.screen() BE
$(
   LET pb = VEC 7

   // N.B. these two lines must occur before Mode change
   OSByte(144,0,0)   // Set display position and interlace - mod for A500 PAC
   OSByte(114,1,0)   // Set non shadow modes at next mode change

   G.sc.mode(1)                  // mode 1, join cursors, default palette
   G.sc.initialise.mouse()       // new mouse init

// shd do something about this !!!
// RUNPROG("**TMAX 1280, %n",m.sd.disY0) // Set Icon switchover point

   // get user sprite space from the system heap
   //
   G.sc.sprite.area := GETVEC( m.sd.sprite.ws.size/bytesperword )

   IF G.sc.sprite.area = 0 THEN G.ut.abort( m.ut.init.abort+1 )

   //
   // N.B. the values used below are obtained by trial and error
   // using a BASIC program. The Acorn documentation is insufficient.
   // The really dodgy value is the 100, which is the offset to first
   // sprite. See the reference manual for details of control block
   //

   G.sc.sprite.area!0 := m.sd.sprite.ws.size  // set up header info
   G.sc.sprite.area!1 := 1                    // so that the SNEW
   G.sc.sprite.area!2 := 100                  // command will initialise
   G.sc.sprite.area   := G.sc.sprite.area * bytesperword // m/c address

   pb!0 := G.sc.sprite.area        // R1 = sprite workspace 

   UNLESS OsSprite( m.sd.clear.sprite.area, pb ) // initialise sprite area
   DO G.ut.abort( m.ut.init.abort+2 )

   // earliest point for messages - screen has been initialised now
   G.sc.mess(" Logica Turbo Domesday starting; please wait")
$)

//
// Disable the player front panel switches, etc.
//
AND setup.player() BE
$(
    g.vh.send.fcode("I0")  // Disable local controls
    g.vh.send.fcode("J0")  // Disable handset
    g.vh.send.fcode("$0")  // Disable replay switch

    // front panel and handset enabled for debugging purposes
    $<floppy
    g.vh.send.fcode("I1")  // Enable local controls
    g.vh.send.fcode("J1")  // Enable handset
    $>floppy
$)

//
// Set function keys to give codes, etc.
//
AND setup.keyboard() BE
$(
    OSByte(4,2)                  // Set cursor keys to give characters
    OSByte(229,1)                // set Escape key to give character
    OSByte(225,m.kd.keybase,0)   // Set function keys to give ASCII
    OSByte(226,m.kd.shiftbase,0) // Set shift+func key to give ASCII
    OSByte(227,1,0)              // Set cntrl+func key to give strings
    OSByte(228,1,0)              // Set shift+cntrl+func to give strings
    OSByte(200,2,0)              // Clear memory on BREAK (inits BASIC)
$)

//
// new stuff for A500 default font - modify the zero, pound & N/A chars
//
AND setup.font() BE 
$(
   LET ft = TABLE

   #x30, #x663C, #x6666, #x6666, #x003C, // character #x30 ( zero )
   #x60, #x361C, #x7C30, #x3030, #x007E, // character #x60 ( pound )   
   #x86, #x7000, #x5750, #x5755, #x0505  // character #x86 ( N/A )

   FOR i = 0 TO 10 BY 5 DO
   VDU( "23,%,%;%;%;%;", ft!i, ft!(i+1), ft!(i+2), ft!(i+3), ft!(i+4) )
$)
.
