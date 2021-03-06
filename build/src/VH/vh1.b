//  $MSC
//  AES SOURCE  4.87

section "vh1"
/**
         VH.VH1 - VIDEO HANDLER PRIMITIVES
         ---------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         12.11.85 1        D.Hepper    Initial version
         26.11.85 1.01                 only comments, for PDL
         17.1.86  2        DNH         Trap call added
         11.2.86  3        DNH         No mode for 'g.vh.play'.
                                       Altered 'g.vh.video
         13.3.86  4        DNH         g.vh.frame uses *search
         25.4.86  5        DNH         video on/off modes
         01.05.86 6        PAC         Add VPX to G.vh.video
                                       Remove runprogs
         06.05.86 7        PAC         Update m.frame.no
                                       in G.vh.frame
         29.05.86 8        PAC         G.vh.play mod, and add
                                       G.vh.step
         20.06.86   9      DNH         g.vh.call.oscli
                                       g.vh.send.fcode replaces
                                        g.vh.chapter
                                       "00000" -> vec 2
         25.06.86  10      DNH         tidying
           9.7.86  11      DNH         bugfix call.oscli
         29.4.87     12    DNH      Use BYTESPERWORD
                                    Use fcodes, not VFS commands
         8.5.87      13    PAC      Adopted for AES system
                                    Modified G.vh.call.oscli
         21.7.87     14    PAC      Remove get of vhphdr
         24.7.87     15    PAC      New 'write fcode' 
         21.12.87    16    MH       G.vh.video updated.

         g.vh.call.oscli
         g.vh.frame
         g.vh.video
         g.vh.play
         g.vh.step
         g.vh.reset
         g.vh.audio
         g.vh.send.fcode

         No indication of success is returned by any of these
         procedures.
**/


get "H/libhdr.h"
get "GH/glhd.h"
get "H/vhhd.h"

/**
         g.vh.call.oscli (command string) = valof
         ----------------------------------------
         Takes a BCPL string and passes it to OSCLI, the
         operating system command line interpreter.
         The string must be terminated by a carriage return, or
         whatever the call requires. If call fails the result
         is set to #xFF, else the result is 0.

         Thus 0 => OK, non-0 => error.
**/

let g.vh.call.oscli( string ) = (Oscli( string ) -> 0, #xFF)


/**
         g.vh.frame (frame.number)
         -------------------------
         Inputs: 16 bit frame number.
         Outputs: none.

         Globals Modified: sets g.context!m.frame.no

         Uses fcode FxxxxxR.  Converts the frame number to an
         ascii string using a separately-defined procedure.  Only
         returns when the frame has been found - this avoids
         losing fcodes if they are sent while the search is in
         progress, but doesn't return control to the micro so
         fast.  In theory a global could be used to hold a 'reply
         expected' flag for the next command to inspect but this
         adds greatly to the complexity of the routine.
**/

AND g.vh.frame (frame.no) be
$(
   let cs = vec 8/BYTESPERWORD      // command string
   let ns = vec 6/BYTESPERWORD      // number string
   let buf = vec m.vh.poll.buf.words

   g.context!m.frame.no := frame.no       // update context

// word   0   1   2   3
// byte   0 1 2 3 4 5 6 7
// cs     l F x x x x x R

   cs%0, cs%1, cs%7 := 7, 'F', 'R'
   g.vh.word.asc (frame.no, ns)    // convert to ascii digit string
   g.ut.movebytes (ns, 1, cs, 2, 5)
   g.vh.send.fcode (cs)
   while g.vh.poll (m.vh.read.reply, buf) = m.vh.unfinished loop
$)


/**
         g.vh.video (mode)
         -----------------
         Inputs: manifest mode from h.vhhdr
         Outputs: none.
         Uses one of the VP commands via oscli to change the
         video mode OR uses E1, E0 to switch the video on or off
         OR sends "*VPX" to enquire the current mode.
**/

AND G.vh.video (mode) BE
$(
   LET cs = ?

   G.ut.trap ("VH", 1, false, 3, mode, m.vh.min.lv.mode, m.vh.max.lv.mode)
 
// if mode = on and video player is already on then do nothing
   UNLESS mode = G.context!m.video.mode = m.vh.video.on  //21.12.87 MH
   $(
      SWITCHON mode INTO
      $(
         CASE m.vh.video.on:   cs := "E1"; endcase
         CASE m.vh.video.off:  cs := "E0"; endcase
         DEFAULT:
            cs := "VP1"
            cs%3 := mode         // VP 1,2,3,4,5 or X
            endcase
      $)
      g.vh.send.fcode( cs )    // equiv. to typing "*fcode vp3", for example
      G.context!m.video.mode := mode
   $)
$)


/**
         g.vh.play (start.frame.number, end.frame.number)
         ------------------------------------------------------
         Inputs: 16 bit frame numbers for start and end frame
         numbers.
         Outputs: none.
         Uses fcodes 'FxxxxxS', 'E1' and 'N'.

         PDL:

            switch off video
            until at start frame do
               go to start frame
            set auto stop register
            switch on video
            play forwards

         The caller should poll for m.vh.finished when this call
         returns.  NO OTHER FCODES SHOULD BE SENT BEFORE THE ACK
         IS RECEIVED OR IT MAY BE LOST.
         On return the video is left on.
**/

AND g.vh.play (start.frame.no, end.frame.no) BE
$(
   let cs = vec 8/BYTESPERWORD      // command string
   let ns = vec 6/BYTESPERWORD      // number string
   let buf = vec m.vh.poll.buf.words

// word   0   1   2   3
// byte   0 1 2 3 4 5 6 7
// cs     l F x x x x x S   -   set auto stop

   g.vh.video (m.vh.video.off)         // switch off first

         // Repeated test because of obscure Philips bug: going
         // to Gallery from Find goes wrong.  Player returns ACK but goes
         // to the end frame instead of the start frame first time.

   until g.vh.poll (m.vh.frame.poll, buf) = start.frame.no do
      g.vh.frame (start.frame.no)

   cs%0, cs%1 := 7, 'F'
   g.vh.word.asc (end.frame.no, ns)
   g.ut.movebytes (ns, 1, cs, 2, 5)
   cs%7 := 'S'
   g.vh.send.fcode (cs)               // set stop register

   g.vh.video (m.vh.video.on)          // video on
   g.vh.send.fcode ("N")              // play from here to stop reg.

   // player is now playing.  Caller should poll for second ACK.
$)


/**
         g.vh.step (command)
         --------------------
         Inputs : command (16 bit integer)
         Outputs: none.
         Uses fcode '*' = halt.

         You can ONLY use:
         m.vh.stop - freeze video at current frame

         THIS ROUTINE USED TO DO A STEP, BUT NOBODY USED IT...
**/

AND g.vh.step (command) BE
$(
   if command = m.vh.stop do
      g.vh.send.fcode ("**")
$)


/**
         g.vh.reset ()
         -------------
         Inputs: none.
         Outputs: 0 => OK, non-zero => failed
         Uses *RESET (Start Unit) command via oscli to return
         the player to its power-up state.
**/

AND g.vh.reset () = g.vh.call.oscli ("RESET*C")


/**
         g.vh.audio (mode)
         -----------------
         Inputs: manifest mode from h.vhhdr.
         Outputs: none.
         Uses fcode commands to switch the sound on
         (left channel, right channel or both) or off.
         Uses fcodes 'Ax' and 'Bx'.
**/

AND g.vh.audio (channels) BE
$(
   g.vh.send.fcode ( (channels = m.vh.left.channel |
                       channels = m.vh.both.channels) -> "A1", "A0" )
   g.vh.send.fcode ( (channels = m.vh.right.channel |
                       channels = m.vh.both.channels) -> "B1", "B0" )
$)


/**
         g.vh.send.fcode (command.string)
         --------------------------------
         Inputs: bcpl string fcode command
            eg. "?P", "F02345R"
         Outputs: returns 0 => success
                  returns non-0 => error
         Uses *FCODE command via oscli to send the specified
         string to LV-DOS Fcode interpreter.  Reply should be
         read using g.vh.poll (m.vh.read.reply, buf).
         Parameter command.string must not be longer than
         9 bytes.
**/

AND g.vh.send.fcode (str) = valof
$(
   let rc = ?
   let cs = VEC 12/bytesperword

   g.ut.movebytes (str, 1, cs, 1, str%0)     // copy parameter part
   cs%(str%0+1) := '*C'                      // CR terminator
   
$<debug show.delay() $>debug
                       
   rc := OsWriteFcode( cs )    // send to VFS    

$<debug show.delay() $>debug     

   resultis rc -> 0,1         // result is 0 if ok
$)
    
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
