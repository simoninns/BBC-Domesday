//  AES SOURCE  6.87

/**
         HE.HELPD - DEMOS
         ----------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         13.05.86 1        PAC     Initial version
         24.05.86 2        JIBC    Fix so compiles
         24.06.86 3        PAC     Fix for new states
         15.07.86 4        PAC     Exit properly (FCODE "X")
         16.07.86 5        PAC     Use GL7HDR
         22.07.86 6        PAC     Add 'sound sequence'
           6.8.86 7        PAC     Reset player on exit
          11.8.86 8        PAC     Use real demo addresses,
                                   Scrap DEHDR.
          2.10.86 9        DNH     Change to frame poll, new
                                   statics for start & end
                                   fixes run-on bug
         9.10.86  10       DNH     New addresses for demos
        20.10.86  11       PAC     Fix compare bug of DNH
        21.10 86  12       DNH     REMOVE FIX FIX OF V.11
    *****************************************************************
         16.6.87  6        PAC     ADOPTED FOR UNI
                                   Fix play restart
         31.7.87  7        PAC     Fix play for A500 poll
**/

SECTION "HELPD"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/hehd.h"
get "H/vhhd.h"
get "H/dhhd.h"
get "H/sthd.h"
get "H/sihd.h"

MANIFEST
$(
// community South film start addresses

   m.cfindS   = 44997 // find
   m.mapwalS  = 47158 // mapwalk
   m.mapoptS  = 49229 // mapopt
   m.cphotoS  = 51699 // photo
   m.ctextS   = 52949 // text

// community North film start addresses

   m.cfindN   = 44372 // find
   m.mapwalN  = 46677 // mapwalk
   m.mapoptN  = 48912 // mapopt
   m.cphotoN  = 51244 // photo
   m.ctextN   = 52683 // text

// national disc table

   m.nphoto   = 40848 // photo
   m.ntext    = 42153 // text
   m.walk     = 43186 // walk
   m.chart    = 45220 // chart
   m.content  = 47268 // contents
   m.mapproc  = 48658 // mapproc
   m.area     = 50797 // area
   m.nfind    = 51816 // find
   m.gallery  = 52696 // gallery

// end for all discs
   m.END      = 53993

// offsets into demo tables
// community demos
   m.de.cfind    = 0
   m.de.mapwalk  = 1
   m.de.mapopt   = 2
   m.de.cphoto   = 3
   m.de.ctext    = 4

// national demos
   m.de.nphoto   = 0
   m.de.ntext    = 1
   m.de.walk     = 2
   m.de.chart    = 3
   m.de.contents = 4
   m.de.mapproc  = 5
   m.de.area     = 6
   m.de.nfind    = 7
   m.de.gallery  = 8
$)

STATIC $( s.paused = FALSE    // flag for paused/not paused
          s.film.start = ?    // film start frame number
          s.film.end = ?      // film end frame number
       $)

/**
         G.HE.DEMOINI - INITIALISE FOR DEMO
         ----------------------------------

         Init routine to enter DEMO

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         configure menu bar

         work out frame numbers for start and end of film

         start film playing

         do an error message - "Sound Sequence"

**/
LET G.he.demoini() BE
$(
   G.sc.clear( m.sd.display )
   G.sc.clear( m.sd.message )

   // set up the menu bar
   FOR i = m.he.box1 TO m.he.box6 DO
      G.he.work!i := m.sd.act

   G.he.work!m.he.box3 := m.wPause

   find.demo ()

   $<debug
   IF G.ut.diag() THEN
   G.sc.mess("Demo: start %n %x4 end %n %x4", s.film.start, s.film.start,
                                              s.film.end,   s.film.end )
   $>debug

   // start film playing

   s.paused := FALSE

   IF G.dh.fstype() = m.dh.vfs
   THEN
   $(
      G.vh.frame( s.film.start )          // get to correct frame before
      G.vh.audio( m.vh.both.channels )  // turning audio on
      G.vh.video( m.vh.superimpose )    // and video on
      G.vh.video( m.vh.video.on )
      G.vh.play( s.film.start, s.film.end ) // off it goes...
   $)

   G.sc.ermess("Sound sequence")

$)

/**
         G.HE.DEMO - ACTION ROUTINE FOR DEMO
         -----------------------------------

         Handles display of demo films

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         IF film is running
         THEN poll player for current frame number
              IF current frame is > end of film
              THEN fake up a retrun to HELP main state

         CASE G.key OF

         Function 1 or Function 2 :  (EXIT or MAIN)

         Clear player registers with fcode "X"
         Switch off audio
         Select micro only video mode

         ENDCASE

         Function 3 : (PAUSE/CONTINUE)

         IF film is paused
         THEN
            restart film playing
            set up menu bar

         ELSE
            pause film
            set up menu bar

         ENDCASE

**/
AND G.he.demo() BE
$( LET rbuff = VEC m.vh.poll.buf.words

   UNLESS s.paused
   DO
   $(
      TEST G.vh.poll (m.vh.frame.poll, rbuff) >= s.film.end
      THEN G.key := m.kd.Fkey2            // frig a return to main
      ELSE G.ut.wait(50)                  // fix - allow the user a look in!
   $)

   SWITCHON G.key INTO
   $(
      CASE m.kd.Fkey1 :  // reset player ready for exit (added 6.8.86 PAC)
      CASE m.kd.Fkey2 :  // go back to main
      $(
         IF G.dh.fstype() = m.dh.vfs
         THEN
         $(
           G.vh.send.fcode("X")             // reset player registers
           G.vh.video( m.vh.micro.only )    // turn video
           G.vh.audio( m.vh.no.channel )    // and audio off
         $)
      $)
      ENDCASE

      CASE m.kd.Fkey3 :
      $(
         TEST s.paused
         THEN
            $( G.vh.send.fcode("N") // restart film playing
               s.paused := FALSE
               G.he.work!m.he.box3 := m.wPause
            $)
         ELSE
            $( G.vh.step( m.vh.stop )  // pause film
               s.paused := TRUE
               G.he.work!m.he.box3 := m.wContinue
            $)
      $)
      ENDCASE
   $)

   IF G.redraw | check.menu( G.he.work+m.he.box1 )
      THEN G.sc.menu( G.he.work+m.he.box1 )
$)

AND check.menu( boxes ) = VALOF
$( FOR i = 0 TO 5
   UNLESS boxes!i = G.menubar!i RESULTIS TRUE
   RESULTIS FALSE
$)

AND find.demo() BE
$(
   LET discid     =  G.context!m.discid
   LET demo.state = (G.he.save+m.he.context.start)!m.laststate
   LET demo.table =  ?
   LET demo       =  ? // offset into selected demo table

   // community South table
   LET cstab = TABLE m.cfindS, m.mapwalS, m.mapoptS,
                     m.cphotoS, m.ctextS, m.END

   // community North table
   LET cntab = TABLE m.cfindN, m.mapwalN, m.mapoptN,
                     m.cphotoN, m.ctextN, m.END

   // national disc table
   LET natab = TABLE m.nphoto, m.ntext, m.walk, m.chart, m.content,
                     m.mapproc, m.area, m.nfind, m.gallery, m.END

   $<debug
   IF G.ut.diag() THEN
   $(
   G.sc.moveA( m.sd.message, m.sd.mesXtex, m.sd.mesYtex )
   G.sc.selcol( m.sd.yellow )
   G.sc.ofstr("state  <%n>? ",demo.state)
   demo.state := READN()
   G.sc.ofstr("discid <%n>? ",discid)
   discid := READN()
   $)
   $>debug

   SWITCHON discid INTO
   $(
      // N.B. this should never happen - just use a safe demo area
      DEFAULT         : $( demo.table := cstab ; demo := m.de.mapwalk $)
      ENDCASE

      CASE m.dh.South :
      CASE m.dh.North :
      $(
         // select demo addresses table
         demo.table := (discid = m.dh.South) -> cstab, cntab

         SWITCHON demo.state INTO
         $(
            DEFAULT           : demo := m.de.mapwalk // shouldn't happen
            ENDCASE

            CASE m.st.cfinde  :
            CASE m.st.cfindm  :
            CASE m.st.cfindr  : demo := m.de.cfind
            ENDCASE

            CASE m.st.mapwal  : demo := m.de.mapwalk
            ENDCASE

            CASE m.st.mapopt  :
            CASE m.st.mapsca  :
            CASE m.st.mapkey  : demo := m.de.mapopt
            ENDCASE

            CASE m.st.cphoto  :
            CASE m.st.picopt  : demo := m.de.cphoto
            ENDCASE

            CASE m.st.ctext   :
            CASE m.st.ctexopt : demo := m.de.ctext
            ENDCASE
         $)
      $)
      ENDCASE

      CASE m.dh.natA :
      $(
         demo.table := natab   // select demo addresses table

         SWITCHON demo.state INTO
         $(
            DEFAULT           : demo := m.de.gallery // shouldn't happen
            ENDCASE

            CASE m.st.conten  : demo := m.de.contents
            ENDCASE

            CASE m.st.nfinde  :
            CASE m.st.nfindm  :
            CASE m.st.nfindr  : demo := m.de.nfind
            ENDCASE

            CASE m.st.uarea   :
            CASE m.st.area    : demo := m.de.area
            ENDCASE

            CASE m.st.Gallery :
            CASE m.st.Galmove :
            CASE m.st.Gplan1  :
            CASE m.st.Gplan2  : demo := m.de.gallery
            ENDCASE

            CASE m.st.nphoto  : demo := m.de.nphoto
            ENDCASE

            CASE m.st.ntext   : demo := m.de.ntext
            ENDCASE

            CASE m.st.walk    :
            CASE m.st.walmove :
            CASE m.st.wplan1  :
            CASE m.st.wplan2  :
            CASE m.st.detail  : demo := m.de.walk
            ENDCASE

            CASE m.st.chart   :
            CASE m.st.rchart  : demo := m.de.chart
            ENDCASE

            CASE m.st.datmap  :
            CASE m.st.manal   :
            CASE m.st.mdetail :
            CASE m.st.resol   :
            CASE m.st.mareas  :
            CASE m.st.mclass  :
            CASE m.st.manual  :
            CASE m.st.autom   :
            CASE m.st.equal   :
            CASE m.st.nested  :
            CASE m.st.quant   :
            CASE m.st.retri   :
            CASE m.st.compare : demo := m.de.mapproc
            ENDCASE
         $)
      $)
      ENDCASE
   $) // end of top switchon

   s.film.start := demo.table!demo
   s.film.end   := demo.table!(demo+1)
$)
.
