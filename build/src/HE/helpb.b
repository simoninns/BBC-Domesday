//  PUK SOURCE  6.87

/**
         HE.HELPB - HELP BOOKMARK
         ------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         16.6.87  14       PAC     ADOPTED FOR UNI
         2.7.87   15       PAC     Better pointer handling
        20.8.87   16       SRY     Changed for PUK
        21.8.87   17       SRY     Numbered marks
         7.9.87   18       MH      Update to G.he.loadmark to move pointer off
                                   the meu bar area
**/

SECTION "HELPB"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/kdhd.h"
// get "H/dhhd.h"
get "H/hehd.h"
get "H/uthd.h"

STATIC $( s.i = 0 // counter for line. routine
          s.string = ?
          s.fmess = ?
       $)

/**
         G.HE.BOOKINI - INITIALISE FOR BOOKMARK
         --------------------------------------

         Init routine to enter BOOKMARK

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         Set up static pointer to floppy disc message
         Display help text page on display
**/
LET G.he.bookini() BE
$(
   LET line.(string) BE
   $( g.sc.movea(m.sd.display,m.sd.propXtex,m.sd.disYtex-m.sd.linw*s.i)
      g.sc.oprop(string)
      s.i := s.i+1
   $)

   s.i := 0
   s.fmess := "Insert floppy disc; type R (ready) or Q (quit):"

   G.he.work!m.he.gotmark :=
      G.ut.restore(g.he.work+m.he.bm,m.he.savesize,m.io.context.cache)
//   G.he.work!m.he.gopend   := FALSE
   G.he.work!m.he.discpend := m.he.none
   G.sc.pointer(m.sd.off)
   G.sc.mess( "Help Bookmark" )
   G.sc.clear( m.sd.display )

   G.sc.selcol(m.sd.cyan)

   line.("")
   line.("You may SET a MARK to remember the last")
   line.("item you were looking at.  This will")
   line.("include all the information on how you")
   line.("found the item and how far you got in")
   line.("examining it.  This MARK is kept in the")
   line.("micro's memory and so will be lost if")
   line.("you switch off.")
   line.("")
   line.("If you already have a MARK you may GO")
   line.("to it.  This will leave the system")
   line.("exactly as if you had done nothing")
   line.("since SET MARK.  Anything else you have")
   line.("done will be lost.")
   line.("")
   line.("If you have a floppy disc you may SAVE")
   line.("your MARK to a file called DOMARK.")
   line.("If the disc already has a DOMARK on it")
   line.("it will be lost.  You may LOAD a MARK")
   line.("from a floppy disc back into the micro.")
   line.("When you LOAD or SET a MARK any other")
   line.("MARK will be lost.")

   G.sc.pointer(m.sd.on)
$)

/**
         G.HE.BOOK - ACTION ROUTINE FOR BOOKMARK
         ---------------------------------------

         .......

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.HE.Save is set up from bookmark to reflect status help was
                   in when bookmark was previously set

         SPECIAL NOTES FOR CALLERS:

         Traps keypress for GO MARK and sets up everything so that
         when General() in ROOT detects keypress and calls STATE routine
         G.OV.EXIT() is called exactly as if Help had called it for a
         normal Exit.
         N.B. must do a turnover function if Marked disc is not the same
              as current disc.

         PROGRAM DESIGN LANGUAGE:

         IF a floppy disc access is pending
         THEN IF key is not noact
              THEN save or load bookmark

         IF About to go to a bookmark
         THEN
            This could easily set current state as the bookmark first
            IF new disc not same as old disc
            THEN do turnover here to change disc sides
            IF new disc = old disc IGNORING diff between Community sides
            THEN
               TEST national disc
               THEN copy community cache area to national cache
               ELSE copy national cache area to community cache
            TEST new disc = national
            THEN restore national cache status flags
            ELSE restore community cache status flags
            restore screen
            restore G.Context and G.menubar by putting them in
            help's saved area then using G.OV.EXIT to 'return'
            from help
**/

AND G.he.book() BE
$(
   LET status = TABLE m.sd.act,m.sd.act,m.sd.act,
                      m.sd.act,m.sd.act,m.sd.act
//   LET go.side = ?
   LET oldp    = ?
   LET switched = FALSE
   IF G.key ~= m.kd.noact $( oldp := G.sc.pointer( m.sd.off )
                             switched := TRUE $)

// A SAVE MARK or LOAD MARK is pending if G.he.work!m.he.discpend
// is not equal to m.he.none.
   unless g.key = m.kd.noact
      test G.he.work!m.he.discpend = m.he.load
      then $( if '0' <= g.key <= '9' | g.key = m.kd.delete | 
                 g.key = m.kd.return then
              $( if G.key = m.kd.return & s.string%0 = 0 G.key := m.kd.noact
                 g.sc.input(s.string, m.sd.blue, m.sd.cyan, 2)
              $)
              // here we want to get the mark number ...
              IF (G.key = m.kd.Return) & (s.string%0 > 0) then
              $(
                 g.sc.mess(s.fmess)
                 g.he.work!m.he.discpend := m.he.loadpend

              $)
           $)
      else if g.he.work!m.he.discpend = m.he.loadpend |
              g.he.work!m.he.discpend = m.he.save
           then save.load()


// A Go MARK is pending if the user has to turn the disc over
// to satisfy the Go mark. We are pending until the user confirms his
// wish to eject the disc, or presses any other key

/*
   IF G.he.work!m.he.gopend
   THEN IF G.key ~= m.kd.noact
        THEN
        $( G.he.work!m.he.gopend := FALSE // X position fixed by PAC 17.12.86
           G.sc.movea(m.sd.message,m.he.EOS-4*m.sd.charwidth,m.sd.mesYtex)
           TEST CAPCH(G.key) = 'Y'
           THEN
           $( LET old.disc = G.context!m.discid
              G.sc.ofstr("Y")             // was lowercase 17.12.86 PAC
              IF g.dh.select.disc(G.he.work!(m.he.bm+m.discid))
              THEN
              $(
                 G.context!m.discid := old.disc // let gomark know that the
                 gomark()                       // disc has turned over
              $)
           $)
           ELSE
           $( G.sc.ofstr("N")             // was lowercase 17.12.86 PAC
              G.ut.wait(50)
           $)
           G.sc.mess( "Help Bookmark" )
        $)
*/

   TEST G.he.work!m.he.gotmark
   THEN
   $( status!3 := m.sd.act
      status!4 := m.sd.act
   $)
   ELSE
   $( status!3 := m.sd.wBlank
      status!4 := m.sd.wBlank
   $)

   IF G.redraw THEN G.sc.menu( status )

   IF G.key = m.kd.Fkey5 THEN
   $(

     // About to go to a bookmark....
     // IF new disc not same as old disc
     // THEN set pending and wait for confirmation

/*
     go.side := G.he.work!(m.he.bm+m.discid)

     TEST G.Context!m.discid ~= go.side
     THEN     // Turnover
     $( G.sc.ermess("Turn disc over to goto Mark")
        TEST go.side = m.dh.NatA
        THEN G.sc.mess("Mark is on National disc, eject (y/n)?")
        ELSE TEST go.side = m.dh.South
             THEN G.sc.mess("Mark is on Community South, eject (y/n)?")
             ELSE G.sc.mess("Mark is on Community North, eject (y/n)?")
        G.he.work!m.he.gopend := TRUE
        G.key := m.kd.noact
      $)
      ELSE
*/
      gomark()
   $)
// returns us in a state to allow G.HE.EXIT to be called

IF switched G.sc.pointer( oldp )
$)

/**
         GOMARK() - SUBROUTINE TO GOTO A BOOKMARK
         ----------------------------------------

         not a global routine, but it requires documenting.

         PROGRAM DESIGN LANGUAGE:

         Gomark []
         ------
         IF new disc = old disc IGNORING diff between Community sides
         THEN TEST national disc
              THEN copy community cache area to national cache
              ELSE copy national cache area to community cache

         ELSE TEST national disc
              THEN copy national cache area to community cache
              ELSE copy community cache area to national cache

         TEST new disc = national
         THEN restore national cache status flags
         ELSE restore community cache status flags

         Restore the bookmarked screen

         Move the bookmark save area into the last overlay
         save area.

         Restore G.context and G.menubar from this area.

         The next thing to happen is that 'General' will detect a
         funtion key from Help (from the G.Context we have just
         restored !) and so will call the transition routine. We
         wish this to be G.OV.EXIT in ROOT. Because state is HELP
         this setstate call will use HELPs menu bar. The desired
         menu bar is BOOKMARKs. We can fix the effect of this
         either by patching state to BOOK, or by patching G.key
         to Fkey1 (which causes G.OV.EXIT to be called). I have
         choosen to do the latter, because it makes Bookmark
         exits appear identical to HELP exits.
**/

AND gomark() BE
$(
   LET bufsize     = G.he.work!m.he.worksize - m.he.buf
//   LET old.disc    = G.context!m.discid
   LET cache.flags = G.he.work+m.he.bm+m.he.cacheflags
//   LET new.disc    = G.he.work!(m.he.bm+m.discid)

//    TEST ((old.disc ~= m.dh.NatA) & (new.disc ~= m.dh.NatA)) |
//          (old.disc = new.disc)

//    THEN TEST old.disc = m.dh.NatA THEN
           G.ut.Cache( G.he.work+m.he.buf,bufsize,m.io.ComtoNat )
//         ELSE G.ut.Cache( G.he.work+m.he.buf,bufsize,m.io.NattoCom )

//    ELSE TEST new.disc = m.dh.NatA  // added 1.12.86 PAC - turnover bug fix
//         THEN G.ut.Cache( G.he.work+m.he.buf,bufsize,m.io.NattoCom )
//         ELSE G.ut.Cache( G.he.work+m.he.buf,bufsize,m.io.ComtoNat )

//    TEST new.disc = m.dh.NatA THEN
      G.ut.restore( cache.flags, m.io.max.natflag,m.io.ComtoNat)
//   ELSE G.ut.restore( cache.flags, m.io.max.natflag,m.io.NattoCom)

   G.ut.restore( 0,0,m.io.screen ) // Restore the bookmarked screen

   // Set the SAVE area of the last overlay to be the MARK
   // N.B. bookini has restored this area from SRAM
   //
   MOVE(G.he.work+m.he.bm,G.he.save,m.he.savesize+1)

   // Restore G.Context and G.menubar to their bookmarked state
   MOVE(G.he.save+m.he.context.start,G.Context,m.contextsize+1)
   MOVE(G.he.save+m.he.menubar.start,G.menubar,m.menubarsize+1)

   G.key := m.kd.Fkey1           // frig a press of EXIT from help
   G.he.work!m.he.redraw := TRUE // set private redraw flag
                                 // so that new menu bar is drawn
                                 // after a Go Mark
   G.sc.keyboard.flush()         // added 26.9.86 PAC - kill typeahead
$)

// save or load a bookmark
// G.he.work!m.he.discpend is set FALSE at the end of this
// routine.
// Loads or saves the sideways RAM contents OPPOSITE to the
// current disc side. ( i.e. the bookmark ram )
//
AND save.load() BE
$(
   LET mark.mess = "Help Bookmark"
   LET buffer  = G.he.work+m.he.buf  // fixed 6.8.86 PAC - was !, now +
   LET bufsize = G.he.work!m.he.worksize - m.he.buf
   LET type    =
// (G.context!m.discid = m.dh.NatA) ->
   m.ut.Community
// , m.ut.National
   G.sc.movea(m.sd.message, m.sd.mesXtex + g.sc.width(s.fmess), m.sd.mesYtex)
   TEST CAPCH(G.key) = 'R'
   THEN                 // o.k. to save or load
   $(
      G.sc.ofstr("R")

      TEST G.he.work!m.he.discpend = m.he.save

      THEN TEST G.ut.save.mark( buffer, bufsize, type )
           THEN G.sc.mess("Bookmark %n saved", G.ut.mark.w-1) 
                                                // '.' out - PAC 16.10.86
           ELSE G.sc.mess( mark.mess )

      ELSE $( test s.string%0 = 2
              then g.ut.mark.r := (s.string%1 - '0') * 10 +
                                   s.string%2 - '0'
              else g.ut.mark.r := s.string%1 - '0'
              TEST G.ut.load.mark( buffer, bufsize, type )
              THEN $( G.sc.mess("Bookmark %n loaded", G.ut.mark.r) 
                                                       // '.' - PAC 16.10.86

                      // pick up bookmark vector from SRAM
                      G.ut.restore(G.he.work+m.he.bm,m.he.savesize,
                                   m.io.context.cache)
                      // and ensure that the cache flag for bookmark is set up
                      G.ut.cache(G.he.work+m.he.bm,m.he.savesize,
                                   m.io.context.cache)

                      G.he.work!m.he.gotmark := TRUE
                      G.redraw := TRUE
                   $)
              ELSE G.sc.mess( mark.mess )
           $)
   $)
   ELSE
   $( G.sc.ofstr("Q")
      G.ut.wait(50)
      G.sc.mess( mark.mess )
   $)

   G.sc.keyboard.flush() // added 26.9.86 PAC - kill typeahead
   G.he.work!m.he.discpend := m.he.none
$)

/**
         G.HE.SETMARK - INITIALISE FOR BOOKMARK
         --------------------------------------

         Init routine to enter BOOKMARK

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         .......

         SPECIAL NOTES FOR CALLERS:

         .......

         PROGRAM DESIGN LANGUAGE:

         Save old screen into IO processor cache for marked
         screen

         TEST national disc

         THEN copy national cache area to community cache,
              getting national cache status flags

         ELSE copy community cache area to national cache,
              getting community cache status flags

         ADD to the context in SAVEd area the status of Cache's flags

         MOVE help's saved area into work vector where bookmark
              context is kept

         CACHE SAVE area to IO Processor

         SET bookmark as present in system, and force menu redraw

**/

AND G.he.setmark() BE
$(
   LET bufsize = G.he.work!m.he.worksize - m.he.buf
   LET flags   = G.he.work+m.he.bm+m.he.cacheflags

   //   Save screen into IO processor cache
   G.ut.cache(0,0,m.io.screen)

//   TEST G.Context!m.discid = m.dh.NatA THEN
          G.ut.cache( flags, bufsize, m.io.NattoCom)
//   ELSE G.ut.cache( flags, bufsize, m.io.ComtoNat)

   // save the cache flags in G.he.save to make this a full bookmark
   MOVE(flags, G.he.save+m.he.cacheflags, m.he.savesize-m.he.cacheflags+1)

   // copy this information into the work area, where bookmarks are stored
   MOVE(G.he.save, G.he.work+m.he.bm, m.he.savesize+1)

   // Save G.Context, G.menubar and cache flags from help's saved area to
   // IO processor cache for bookmark

   G.ut.cache(G.he.save,m.he.savesize,m.io.context.cache)

   G.he.work!m.he.gotmark := TRUE
   G.redraw := TRUE
   G.sc.mess("Bookmark set")
$)

/**
         G.HE.LOADMARK - INITIALISE FOR BOOKMARK
         ---------------------------------------

         Init routine from BOOKMARK to BOOKMARK on LOAD

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.redraw set TRUE so new menu bar with SAVE and GOMARK
         can be drawn

         SPECIAL NOTES FOR CALLERS:

         See save mark, needs new primitive G.ut.read

         PROGRAM DESIGN LANGUAGE:

         .......
**/

AND G.he.loadmark() BE
$( let mess = "Enter mark number: "
   s.string := "*S*S"
   G.sc.pointer(m.sd.off)
   if G.screen = m.sd.menu then   // added 7.9.87 MH
   $( G.screen := m.sd.display   // kick pointer off the menu bar area
      G.ypoint := m.sd.disY0
      G.sc.moveptr(G.xpoint, G.ypoint)
   $)
   g.sc.mess(mess)
   g.sc.movea(m.sd.message, m.sd.mesXtex + g.sc.width(mess), m.sd.mesYtex)
   s.string%0 := 0
   g.key := m.kd.noact
   g.sc.input(s.string, m.sd.blue, m.sd.cyan, 2)
   G.he.work!m.he.discpend := m.he.load
   G.sc.pointer(m.sd.on)
$)

/**
         G.HE.SAVEMARK - INIT ROUTINE IN BOOKMARK
         ----------------------------------------

         Init routine from BOOKMARK to BOOKMARK, saving
         current bookmark on disc

         INPUTS:

         none

         OUTPUTS:

         Writes to file DOMARK on disc
         This should be under 50K bytes, made up of
         20K screen image
         22K half of remaining sideways RAM
         <1K G.context, G.menubar, help restore status

         GLOBALS MODIFIED:

         None

         SPECIAL NOTES FOR CALLERS:

         Note: G.ut.open needs redefinition, currently opens
                        files only for SAVE function
               G.ut.write needs mods to write sideways ram

         PROGRAM DESIGN LANGUAGE:

         .......
**/

AND G.he.savemark() BE
$( g.sc.mess(s.fmess)
   G.he.work!m.he.discpend := m.he.save
$)
.
