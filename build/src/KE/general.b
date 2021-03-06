//  AES SOURCE  4.87

/**
         GENERAL - STATE SETTING AND SPECIAL EXITS
         -----------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         s.kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         5.5.87      1     DNH      CREATED FROM ROOT1
                                    boot -> G.ov.boot
                                    general -> G.ov.general
                                    setup.sram -> G.ov.set...
                                    s.overbay -> G.overbay
         27.7.87     2     PAC      Area setup frig under debug
         11.12.87    3     MH       Change to state for clearing the
                                    virtual keyboard.
         21.12.87    4     MH       G.context!m.video.mode initialised to OFF
                                    in G.ov.boot.
**/

SECTION "general"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/sthd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/dhhd.h"
get "H/ovhd.h"
get "H/uthd.h"
get "H/vhhd.h"


/**
         G.OV.GENERAL - HANDLE GENERAL ACTIONS
         -------------------------------------

         This routine copes with the state changes

         INPUTS: state of global G.key

         OUTPUTS: none

         GLOBALS MODIFIED:

         G.dy.action, g.dy.init, g.dy.free, etc.

         PROGRAM DESIGN LANGUAGE:

         G.ov.general []
         ---------------
         IF redraw flag is true & not pending state change
         THEN redraw default menu bar (all boxes ON)

         UNLESS G.key equal to no action request DO

            IF G.key is function key 1-6
            THEN do menu bar transition state change
            ELSE IF G.key is negative
                 THEN do 'pending state change', pushing current
                      state onto the exit stack in G.context
                 ELSE IF  screen pointer is in message area and
                          key is 'action' or 'change'
                      THEN make a beep
                      ENDIF
                 ENDIF
            ENDIF
**/

global $( setstate:1000 $)

LET G.ov.general() BE
$(
    LET var, initr = ?,?
    LET menu.params = TABLE m.sd.act, m.sd.act, m.sd.act,
                            m.sd.act, m.sd.act, m.sd.act

    IF G.redraw & (G.key >= 0)
      THEN G.sc.menu ( menu.params ) // catch undrawn menu

    IF G.key ~= m.kd.noact
    THEN
    $(
        TEST (G.key > m.kd.keybase) & (G.key <= (m.kd.keybase+m.st.barlen))
        THEN     // menu bar transition
        $(
            var := (G.Context!m.state-1)*(m.st.barlen)+(G.key-m.kd.keybase)
            g.context!m.laststate := g.context!m.state
            g.context!m.state := G.sttran!var
            setstate(m.ov.no.frame)
            initr := !( G.stinit!var + @G.dummy )
            initr()
        $)
        ELSE
        $(
            TEST G.key < 0
            THEN // pending state changes set by specific action routine
            $(
                G.UT.TRAP("OV",1,TRUE,2,G.key,-G.context!m.maxstates,0)
                G.context!(G.context!m.stackptr+m.exitstack):=G.context!m.state
                G.context!m.stackptr := G.context!m.stackptr+1
                IF G.context!m.stackptr > m.constack THEN ABORT(98)
                                                     // stack overflow !!
                G.context!m.laststate := G.context!m.state
                G.context!m.state := -G.key
                G.Context!m.justselected := TRUE  //mark for action routines
                setstate(m.ov.no.frame)
            $)
            // this test modified by PAC 19.9.86
            ELSE IF ((G.screen = m.sd.message) | (G.screen = m.sd.none  )) &
                    ((G.key    = m.kd.action ) | (G.key    = m.kd.change))
                 THEN G.sc.beep()
        $)
    $)
$)


/**

         G.OV.EXIT - EXIT FROM STATE BACK TO PREVIOUS STATE
         --------------------------------------------------

         This routine is responsible for finding the correct
         state to return into after an excursion into help

         INPUTS: None

         OUTPUTS: None

         GLOBALS MODIFIED:
         G.Context

         SPECIAL NOTES FOR CALLERS:

         As no correct initialisation routine can be called in
         this state the overlay load routine must handle
         sufficient general initialisation that any of the states
         in that overlay can start up. Typically this will
         involve setting a static to indicate 'just loaded' and
         allowing each state to take the appropriate action.

         PROGRAM DESIGN LANGUAGE:

         Retrieve exit status
         Free up overlay
         Load new state explicitly (Normally the state routine
         does this for you)
**/

AND G.ov.exit() BE
$(
      //  Exit for special state transition, needs special handling
    TEST g.context!m.stackptr > 0
    THEN
    $(
        g.context!m.stackptr := g.context!m.stackptr - 1
        g.context!m.state := g.context!(g.context!m.stackptr+m.exitstack)
        setstate(m.ov.no.frame)
      //  No initalization state available;
      //  must return to wherever you came from
    $)
    ELSE
        G.ut.abort(710)  // stack underflow !!
$)


/**
         G.OV.HELPEXIT - EXIT FROM HELP
         ------------------------------

         This routine called on exit from HELP.
         It does the same as G.OV.EXIT (see above), but also
         restores the video frame to G.context!m.frame.no. It
         does NOT unmute video though.

         INPUTS: none

         OUTPUTS: none

         GLOBALS MODIFIED: G.context

         SPECIAL NOTES FOR CALLERS:
         see g.ov.exit

         PROGRAM DESIGN LANGUAGE:

         G.ov.helpexit []
         ----------------
         Retrieve exit status
         Free up overlay  (call dy.free)
         Load new state explicitly
         Restore video frame
         Initialise new overlay (call dy.init)
**/

AND G.ov.helpexit() BE
$(
      // Exit from help - does the same as ov.exit (above),
      // but also restores video frame.

   TEST g.context!m.stackptr > 0
   THEN
   $(
      g.context!m.stackptr := g.context!m.stackptr - 1
      g.context!m.state    := g.context!(g.context!m.stackptr+m.exitstack)
      setstate( m.ov.set.frame )
   $)
   ELSE G.ut.abort(710)  // stack underflow !!
$)


/**
         G.OV.BOOT
         ---------

         *************

**/

AND g.ov.boot() BE
$(
   G.sc.addspace := FALSE
   G.redraw      := TRUE
   G.menuon      := TRUE
   G.key         := m.kd.noact

   // next 4 statements changed 4.9.86 PAC

   G.key := m.kd.stop        // signal that Help must switch screens
   G.dy.free()               // Get rid of current overlay
   G.key := m.kd.noact       // reset G.key

   // clear menu bar, as Help will have mucked it up
   G.sc.clear( m.sd.menu )

   G.context!0 := 0
   MOVE (G.context, G.context+1, m.contextsize)

$<debug
   G.Context!m.state := G.dh.reset()  // return CMOS location 30, use as
                                      // starting state for time being
$>debug
   G.Context!m.laststate := m.st.startstop
   G.Context!m.maxstates := m.st.nostates

$<debug
   // test for video player before issue call to VFS
   TEST G.dh.fstype() = m.dh.vfs
   THEN
$>debug
       G.Context!m.discid := G.dh.discid()
$<debug
   ELSE G.Context!m.discid := m.dh.NATA
$>debug
   G.Context!m.grblnorth := -1
   G.Context!m.grtrnorth := -1
   G.Context!m.areal.unit := -1
   G.Context!m.resolution := -1
   G.Context!m.name.AOI := -1
   G.Context!m.type.AOI := -1
   G.context!m.video.mode := m.vh.video.off

$<debug
   IF G.context!m.discid = m.dh.NatA DO
   $(
   G.Context!m.grblnorth := 930
   G.Context!m.grbleast  := 5120
   G.Context!m.grtrnorth := 2030
   G.Context!m.grtreast  := 6720
   G.Context!m.areal.unit := -1
   G.Context!m.resolution := -1
   G.Context!m.name.AOI := 29
   G.Context!m.type.AOI := 14
   $)
$>debug

   G.Context!m.justselected := TRUE   // Start is like a pending state change
$<debug
   IF (G.Context!m.state < 1) | (G.Context!m.state > G.Context!m.maxstates)
   THEN
$>debug
       TEST G.Context!m.discid = m.dh.NatA
       THEN G.Context!m.state := m.st.gallery
       ELSE G.Context!m.state := m.st.mapwal

   G.sc.setpal(m.sd.defpal) // added 4.9.86  PAC

   G.ov.setup.sram()  // initialise sideways RAM and reset the cache flags

   G.overbay := G.ov.load(@G.menuwords!(G.stover!(G.Context!m.state)),G.overbay)
   G.dy.init()
   G.dy.action := !( G.stactr!(g.Context!m.state) + @G.dummy )

// dnh   G.vh.video( m.vh.superimpose ) // default mode 12.8.86 PAC
$)


// set up the new state, possibly loading a new overlay
// the parameter is used solely by G.ov.helpexit to restore frame
// it saves duplication of code

AND setstate( type ) BE
$(
   LET st = G.context!m.state

   // handle new overlay for this state

   IF G.stover!(st) ~= G.stover!(G.context!m.laststate)
   THEN
   $(
      G.dy.free()
      G.overbay := G.ov.load( @G.menuwords!(G.stover!st), G.overbay)

      G.dy.init()

      IF type = m.ov.set.frame              // used only by help exit
      THEN G.vh.frame(G.context!m.frame.no)
   $)

   G.dy.action := !( G.stactr!st + @G.dummy )
   IF st ~= g.context!m.laststate
   THEN
   $( G.redraw := TRUE                // menu bar gets redrawn
      UNLESS G.menuon THEN
      $( G.menuon := true             //set menubar to on  11.12.87 MH
         G.sc.TMAX := 76  //pointer to change in menubar
         G.sc.clear(m.sd.menu)        //clear virtual keyboard
      $)
   $)
$)
.
