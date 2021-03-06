//  AES SOURCE  6.87

/**
         HE.HELPC - CONFIGURE
         --------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         13.05.86 1        PAC     Initial version
         09.06.86 2        PAC     exclude 'get error text'
                                   primitive to UT
         30.06.86 3        PAC     Bounce up mouse pointer
         01.07.86 4        PAC     Fix get error SA bug
         09.07.86 5        PAC     Home text cursor at start
         16.07.86 6        PAC     Use GL7HDR
         22.07.86 7        PAC     Help text page on initialise
           7.8.86 8        PAC     Exclude M/C specific stuff
         17.10.86 9        PAC     Cure extra beep bug
    *****************************************************************
         16.6.87  6        PAC     ADOPTED FOR UNI
**/

SECTION "helpC"

STATIC $( s.i = 0 $)

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/sdphd.h"
get "H/kdhd.h"
get "H/hehd.h"

/**
         G.HE.CONFIGINI - INITIALISE FOR CONFIGURE
         -----------------------------------------

         Init routine to enter CONFIGURE

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         Clear screen
         Display help text page on SYSTEM
         Setup the help text window
         Setup the input routine, and display
         text cursor.
**/
LET G.he.configini() BE
$(
   LET line.(string) BE
   $( g.sc.movea(m.sd.display,m.sd.propXtex,m.sd.disYtex-m.sd.linw*s.i)
      g.sc.oprop(string)
      s.i := s.i+1
   $)

   s.i := 0

   G.sc.pointer( m.sd.off )
   G.sc.clear( m.sd.message )
   G.sc.clear( m.sd.display )
   G.sc.selcol( m.sd.cyan )

   line.("")
   line.("   Help with operating system commands")
   line.("")
   line.("This function allows you to enter operating")
   line.("system (star) commands - for example: **TIME.")
   line.("")
   line.("Type in the command you want executed and")
   line.("then press <ACTION> ( <RETURN> on the")
   line.("keyboard ). The cursor keys and <DELETE>")
   line.("are available for correction. You do not")
   line.("have to type in the initial '**': it is")
   line.("provided for you.")
   line.("")
   line.("Beware of any commands that can affect the")
   line.("running of the system. If you change filing")
   line.("systems, corrupt memory, or load a new")
   line.("language, then the Domesday system will have")
   line.("to be restarted with <SHIFT> / <BREAK>.")
   line.("")
   line.("")
   line.("")
   line.("")

   g.ut.set.text.window()
   setup.input()

   IF G.screen = m.sd.menu
   THEN
   G.sc.moveptr( G.xpoint, G.sc.dtob(m.sd.display,4) )

   G.sc.pointer(m.sd.on)

   s.i := 0
$)
/**
         G.HE.CONFIG - ACTION ROUTINE FOR CONFIGURE
         ------------------------------------------

         Handles operating system commands

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         IF G.key ~= m.kd.noact AND string length < 39 chars
         THEN call INPUT to add char to string

         IF G.key = m.kd.return
         THEN send command to operating system


**/
AND G.he.config() BE
$( LET status = TABLE m.sd.act,m.sd.act,m.sd.act,
                      m.sd.act,m.sd.act,m.sd.act

   IF G.key ~= m.kd.noact
      THEN G.sc.input( G.he.work+m.he.string, m.sd.blue, m.sd.cyan, 38 )

   IF G.key = m.kd.return
      THEN
           $(
              G.sc.pointer( m.sd.off )

              IF s.i = 0  // clear display on first command
              THEN $( g.sc.clear( m.sd.display ) ; s.i := 1 $)

              g.ut.send.to.OS( G.he.work+m.he.string )
              setup.input() // ready for next string

              G.sc.pointer( m.sd.on )
           $)

   IF G.redraw THEN G.sc.menu( status )
$)

AND setup.input() BE
$(
   G.sc.selcol( m.sd.cyan )
   G.sc.movea ( m.sd.message, 0, 0 )
   G.sc.rect  ( m.sd.plot, m.sd.mesW-1, m.sd.mesh-1 )
   G.sc.selcol( m.sd.blue )
   G.sc.movea ( m.sd.message,m.sd.mesXtex, m.sd.mesYtex )
   G.sc.oprop ( "**" )

   (G.he.work+m.he.string)%0 := 0

   G.key := m.kd.noact
   G.sc.input( G.he.work+m.he.string, m.sd.blue, m.sd.cyan, 2 )
$)
.
