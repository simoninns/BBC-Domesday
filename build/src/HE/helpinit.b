//  AES SOURCE  6.87

/**
         HE.HELPINIT - HELP OVERLAY INITIALISE
         -------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         30.04.86 1        PAC     Initial version
         22/05/86 2        JIBC    Add bookmark stuff
         18/06/86 3        JIBC    Bugfix during release
         21/06/86 4        PAC     Add help text stuff
                                   & graphics cursor save
         25/06/86 5        PAC     Open Gazetteer if NAT
         16.07.86 6        PAC     Use GL7HDR
         30.07.86 7        PAC     Don't ask for discid
           5.8.86 8        PAC     Add video mute on exit
           4.9.86 9        PAC     Switch screen for restart
          16.9.86 10       PAC     Fix restart MODE bug
                                   Rmove GET of STHDR
         14.10.86 11       PAC     Kick pointer on exit
         16.10.86 12       PAC     Video mode on restart fix

        POST RELEASE BUGFIXES HAVE BEEN MADE AFTER THIS DATE

         25.3.87  13       PAC     Chart restart transient
    *****************************************************************
         16.6.87  14       PAC     ADOPTED FOR UNI
         31.7.87  15       PAC     Remove copy.screen and 
                                   fix mode for restart

**/

SECTION "helpinit"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/gldyhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/uthd.h"
get "H/hehd.h"
get "H/dhhd.h"
get "H/vhhd.h"
get "H/nehd.h"  
get "H/iohd.h"
get "H/iophd.h"
get "H/kdhd.h"

/**
         G.HE.DY.INIT - INITIALISE HELP OVERLAY
         --------------------------------------

         does GETVECs for HELP, and screen switch

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.context!m.exitsatck, etc.

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         get work area vectors

         save screen palette definitions

         switch screens
         set up default palette

         inquire video mode, and save it
         set video mode to micro only

         save g.context

         set up fake exit stack

**/

LET G.HE.dy.init() BE
$(
   LET text.statics = ?
   LET page.buffer  = ?
   LET worksize     = ?
   LET discid       = ?
   LET maxpages     = 0

   G.he.save := GETVEC( m.he.savesize ) // space for saving stuff

   text.statics := GETVEC( m.ne.statics.size )
   page.buffer  := GETVEC( m.sd.opage.buffsize )

   worksize     := MAXVEC()
   G.he.work    := GETVEC( worksize )
   G.he.work!m.he.worksize := worksize  // record of how much free memory


   G.he.work!m.he.tstats    := text.statics
   G.he.work!m.he.page.buff := page.buffer
   G.he.work!m.he.dirtybuff := TRUE  // so text must initialise buffer
   G.he.work!m.he.redraw    := FALSE // dont redraw menu when leaving

   set.text.globals()

   switch.screens()

   TEST G.dh.fstype() = m.dh.vfs
      THEN setup.video()
      ELSE G.he.save!m.he.oldvideo := m.he.mode.invalid

//  Set up fake exit stack to allow us to use G.OV.EXIT to return to
//  where we came. Note that this is not totally transparent at present
//  but should be near enough for initial testing. To make transparent see
//  notes in listings of OV package -- JIBC
//  N.B. must be done before context vector is saved

   G.Context!(G.context!m.stackptr+m.exitstack) := G.Context!m.laststate
   G.Context!m.stackptr := G.Context!m.stackptr + 1
   IF G.Context!m.stackptr > m.constack THEN ABORT(98) // stack overflow !!

   // save G.context vector
   MOVE( G.context, G.he.save+m.he.context.start, m.contextsize + 1 )

   // save G.menubar vector
   MOVE( G.menubar, G.he.save+m.he.menubar.start, m.menubarsize + 1 )

   discid := (G.he.save+m.he.context.start)!m.discid

   $<debug
   IF G.ut.diag() THEN
   $(
   G.sc.mess("In Help: worksize= %n next= %n",worksize,m.he.next.entry)
//   G.sc.movea(m.sd.display,m.sd.disXtex, m.sd.disYtex )
//   WRITEF("Discid  <%n> ? ",discid); discid := READN()
// WRITEF("Ar.Unit <%n> ? ",G.context!m.areal.unit)
// (G.he.save+m.he.context.start)!m.areal.unit := READN()
//   (G.he.save+m.he.context.start)!m.discid := discid
   $)
   $>debug

   G.he.work!m.he.gazhandle := 0 // set 'gazetter not open' state

   // open the gazetteer IFF we're doing a national operation
   IF (discid = m.dh.natA)
   THEN G.he.work!m.he.gazhandle := G.dh.open("gazetteer")
$)

// set up the globals for text's buffers
// N.B. HELP has responsibility to free these vectors
// - the text subroutines can only USE them
//
AND set.text.globals() BE
$(
   LET maxpages = (G.he.work!m.he.worksize -
                           m.he.next.entry -
                           m.ne.photo.data.size)/ 
                           (m.sd.pagelength/bytesperword) -1

   G.he.s       := G.he.work!m.he.tstats
   G.he.buff    := G.he.work+m.he.next.entry
   G.he.s!m.ne.pagebuff  := G.he.work!m.he.page.buff
   G.he.s!m.ne.max.pages := maxpages
   G.he.s!m.ne.gone.to.help := FALSE // show that text must initialise fully

   G.he.s!m.ne.D1.handle := 0   // show that the text file not opened

$)

// inquires and saves the old video mode
// then sets up 'micro only' mode for HELP
//
AND setup.video() BE
$(
   LET reply.buffer = VEC m.vh.poll.buf.words
   LET j = 0

   G.vh.video(m.vh.inquire) // inquire video mode

   // looping added 21.10.86 PAC
   G.vh.poll(m.vh.read.reply, reply.buffer) REPEATWHILE reply.buffer%0 = '*C'

   // examine reply buffer
   // the character before the C/R is the (ascii) mode number
   j := j+1 REPEATUNTIL reply.buffer%(j+1) = m.ut.CR

   G.he.save!m.he.oldvideo := reply.buffer%j

   G.vh.video( m.vh.micro.only ) // default mode for HELP
$)

// save the display status and contents
// including palette definitions and last two
// graphics cursor positions, then
// switch to shadow display screen
//
AND switch.screens() BE
$(
   LET oldptr = ?

   // read the palette definitions
   FOR i = 0 TO m.he.ncolours DO
   G.he.save!(m.he.palette+i) := m.sd.white2 - G.sc.complement.colour(i)

   // read current graphics cursor position
   G.sc.savcur( G.he.save+m.he.cursor )

   // switch the screens
   oldptr := G.sc.pointer( m.sd.off )
   G.he.save!m.he.oldptr  := oldptr // save initial pointer status
   G.he.save!m.he.oldmode := G.sc.findmode()

   G.sc.mode(129)  // change to mode 1, clearing (shadow) screen
                   // this also selects default palette
   G.sc.pointer( oldptr )
$)

/**
         G.HE.DY.FREE - FREE HELP OVERLAY
         --------------------------------

         Called by setstate() as a pending state change, this
         routine restores things to what they were before help
         was called.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         restores G.context
         restores G.menubar

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         special case handling for restart only.

         IF pointer is in the menu bar
         THEN move it up a bit

         IF G.key is m.kd.stop  i.e. doing a restart
         THEN copy shadow screen onto main screen
              set 'old screen mode' to mode 1
              set 'old video mode'  to superimpose

         switch screens
         reset saved palette

         set video mode to old mode

         restore g.context

         restore g.menubar

         close files

         free work area vectors

**/

AND G.HE.dy.free() BE
$(
/* Dy.free called with G.Context!m.state = new state
   see code for SETSTATE and G.ov.exit in ROOT1  */

   LET new.state =  G.context!m.state
   LET discid    = (G.he.save+m.he.context.start)!m.discid
   LET area.no   = (discid = m.dh.NatA) -> m.io.min.Natflag, m.io.min.Comflag
   LET size.wds  = m.io.halfram / bytesperword
   LET oldvid    = G.he.save + m.he.oldvideo

   // switch the screens
   G.sc.pointer( m.sd.off )            // leave pointer off for screen switch

   // kick the pointer out of the menu bar - PAC 14.10.86
   // moved here from ROOT
   IF G.screen = m.sd.menu
   THEN G.sc.moveptr( G.xpoint, G.sc.dtob(m.sd.display,4) )

   //
   // special case handling for restart only.
   // we always go back to mode 1, video superimpose
   //
   IF G.key = m.kd.stop                // we're doing a restart
   THEN $( // G.ut.copy.screen( area.no, size.wds, m.ut.shadow )
           G.he.save!m.he.oldmode := 1 // always back to mode 1 PAC 16.9.86
           UNLESS !oldvid = m.he.mode.invalid // added 16.10.86 PAC
           DO !oldvid := m.vh.superimpose     // always this mode
        $)                                    // (unless there's no player)

   G.sc.mode( G.he.save!m.he.oldmode ) // reselect old mode

   // special fix for palette reset on restart after
   // we've gone into Help from chart PAC 25.3.87
   //
   TEST G.key = m.kd.stop THEN
   $( G.sc.clear( m.sd.display )
      G.sc.clear( m.sd.menu )
      G.sc.clear( m.sd.message ) 
   $)
   ELSE
   $(
      FOR i = m.he.ncolours TO 0 BY -1    // restore palette
         G.sc.palette( i, G.he.save!(m.he.palette+i) )
   $)

   G.sc.rescur(G.he.save+m.he.cursor)  // restore graphics cursor positions
   G.sc.pointer(G.he.save!m.he.oldptr) // restore old pointer state

   // restore G.Context and G.menubar vectors
   MOVE(G.he.save+m.he.context.start,G.Context,m.contextsize+1)
   MOVE(G.he.save+m.he.menubar.start,G.menubar,m.menubarsize+1)

   TEST G.Context!m.stackptr > 0
   THEN G.Context!m.stackptr := G.Context!m.stackptr - 1
   ELSE ABORT(97) // stack underflow !!

   G.context!m.state     := new.state // set last state = this state
   G.context!m.laststate := new.state // so that g.redraw is not true

   // restore the menu bar itself if coming from bookmark
   IF G.he.work!m.he.redraw THEN G.sc.menu(G.menubar)

   // get back old video mode

   // ********* N.B. restore of frame occurs in G.he.exit *********

   IF !oldvid ~= m.he.mode.invalid
   THEN $( G.vh.video( m.vh.video.off )           // mute added 5.8.86 PAC
           G.vh.video( !oldvid )
        $)
      
   // close the helptext file if it has been opened
   IF G.he.s!m.ne.D1.handle  ~= 0
   THEN G.dh.close( G.he.s!m.ne.D1.handle )

   // close the gazetteer file if it has been opened
   IF G.he.work!m.he.gazhandle  ~= 0
   THEN G.dh.close( G.he.work!m.he.gazhandle )

   // free up the 'save' and 'work' vectors
   FREEVEC( G.he.save )
   FREEVEC( G.he.work!m.he.tstats )    // free text statics
   FREEVEC( G.he.work!m.he.page.buff ) // free text page buffer
   FREEVEC( G.he.work )
$)
.
