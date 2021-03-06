//  AES SOURCE  4.87

/**
         ROOT - ROOT OF ALL OVERLAYS
         ---------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         s.kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         23.4.87  1        PAC      ADOPTED FOR AES SYSTEM
         29.4.87  2        DNH      dy.init -> initialise
         1.5.87      3     DNH      Fixes for tables offset from
                                    g.dummy, & fix setup.sram.
                                    G.he.exit -> G.ov.helpexit
         5.5.87      4     DNH      SPLIT GENERAL AND SRAM FILES
         26.5.87     5     PAC      Remove overlays
         12.6.87     6     PAC      Add diagnostics
         26.7.87     7     PAC      Remove very old debug call
         30.7.87     8     PAC      Fix startup film code
         10.12.87    9     MH       Getvec for virtual keyboard added
         15.12.87   10     MH       Update to RESTART.QUERY for VK
         16.12.87   11     MH       New module load.hie.recs added for reading
                                    TYPE and HIERARCHY data
**/

SECTION "root"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/gldyhd.h"
get "H/sthd.h"
get "H/st2hd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/vhhd.h"
get "H/dhhd.h"
get "H/ovhd.h"
get "H/uthd.h"  
get "H/iophd.h"


/**
         MAIN.INIT - GENERAL INITIALISATION ROUTINE
         ------------------------------------------

         Responsible for all Domesday initialisations,
         especially GETVECs for system areas.

         GLOBALS MODIFIED:

         GETVECs are performed for the following globals:

         G.stover
         G.stactr
         G.sttran
         G.stinit
         G.stmenu
         G.Context
         G.menuwords  
         G.ComCache
         G.NatCache

         SPECIAL NOTES FOR CALLERS:

         Unlike all other overlays this one has no G.dy.free()
         routine. This is because this overlay is never unloaded.

         PROGRAM DESIGN LANGUAGE:

         main.init[]
         -----------

         GETVEC for all global areas permanently resident
         Load menu and filename words
         Load state tables
         Load and call machine specific initialisation
         RETURN

**/

manifest $( m.vk.area.size = 5 $) //added for virtual keyboard 10.12.87 MH

LET main.init() BE
$(
   LET p = ?

   G.menuwords := load.file("WORDS") + 2 // adjust for FILETOVEC extras

   p := load.file("STATES")

   G.stover := p + m.st.over.offset
   G.stactr := p + m.st.actr.offset
   G.sttran := p + m.st.tran.offset
   G.stinit := p + m.st.init.offset
   G.stmenu := p + m.st.menu.offset

   G.context := GETVEC( m.contextsize )
   G.menubar := GETVEC( m.st.barlen )    
   G.sc.vk.area := GETVEC( m.vk.area.size )  
         // added for virtual keyboard 10.12.87 MH
             
   // set up the cache vector
   G.CacheVec := GETVEC( m.io.cachesize/bytesperword )   

   // G.overbay := G.ov.load("init",0) - out now !!

   G.IN.dy.init()  // this does all the work for init    
   G.dy.init := G.dummy  // set these to a safe value
   G.dy.free := G.dummy  // before boot gets started
$)


/*
         load.file() returns a pointer to the vector allocated
         for the file name specified. Aborts if file is not
         found. It is used for loading tables, but NOT code.
         Has ADFS checking under $$floppy tag.
*/

AND load.file( name ) = VALOF
$(
   LET v = 0

$<floppy
   LET buf = VEC 20/BYTESPERWORD
   v := FILETOVEC( concat.("-adfs-", name, buf) )
$>floppy

   IF v = 0 THEN
      v := FILETOVEC( name )

   IF v = 0 THEN
   $( G.sc.mess("Failed to load %S, reason %N", name, RESULT2 )
      G.ut.abort( m.ut.root.abort )
   $)
   RESULTIS v
$)

$<floppy
AND concat.( s1, s2, buf ) = VALOF
$(
   g.ut.movebytes (s1, 1, buf, 1,      s1%0)
   g.ut.movebytes (s2, 1, buf, s1%0+1, s2%0)
   buf%0 := s1%0 + s2%0
   resultis buf
$)
$>floppy

/* this routine reads in all the type and hierarchy data into a vector
   added 16.12.87 MH
*/
and load.hie.recs() be
$( let name = "-adfs-HTRECS"
   G.context!m.hie.ptr := FILETOVEC(name)
   IF G.context!m.hie.ptr = 0 THEN
   $( G.sc.mess("Failed to load %s, reason %N", name, RESULT2 )
      G.ut.abort( m.ut.root.abort )
   $)
   G.context!m.hie.ptr := G.context!m.hie.ptr + 2 //point to start of data
$)
   

/**
         START - START OF SOFTWARE
         -------------------------

         This is the top level control loop of the Domesday
         retrieval software.

         INPUTS: None

         OUTPUTS: None

         GLOBALS MODIFIED:

         G.Context -- the current context of the state machine
         G.redraw  -- menu redraw flag
         G.key     -- last keypress
         G.xpoint  -- screen x position
         G.ypoint  -- screen y position


         SPECIAL NOTES FOR CALLERS:

         Only returns if switch off requested by user

         PROGRAM DESIGN LANGUAGE:

         START []
         --------

         Load initial overlay
         Play startup film
         Set initial state
         WHILE stop request not confirmed
           WHILE keypress NOT EQUAL stop request
             get action request
             handle state specific actions
             handle general action (e.g. state transition
                                          requests)
           ENDWHILE
        ENDWHILE
**/

AND START () BE
$(
    main.init ()        // set up vectors and do machine-specific init

//  Call boot before film to get overlay into store
    g.ov.boot()
    load.hie.recs() //read in type and hierarchy data
    g.sc.pointer(m.sd.off)    // defensive programming, ensure...
    IF G.dh.fstype() = m.dh.vfs THEN
        startup.film()
    g.sc.pointer(m.sd.on)  // ...mouse pointer initialised


// ******************************************************* //
//                                                         //
//       MAIN LOOP OF DOMESDAY RETRIEVAL SOFTWARE          //
//                                                         //
// ******************************************************* //

   $(
      $(
         $(
            G.sc.getact()
            G.dy.action()
            G.ov.general()
$<debug
            IF G.key = 4 debug(0) // on ctrl-d
$>debug       

         $) REPEATUNTIL G.key=m.kd.stop

      $) REPEATUNTIL restart.query() = 'R'

      g.ov.boot()  // reset G.Context and get initial overlay

   $) REPEAT  // forever...
$)



// ask the user if he wants to restart the system
// procedure result is 'R' only if R or r is pressed
// in response to the question.

AND restart.query() = VALOF
$(
   LET question  = "Type R to restart or C to continue:"
   LET width     = G.sc.width( question ) + m.sd.charwidth
   LET ch = ?

   // a few dummy reads to clear out the keyboard buffer
      G.sc.getact()    //G.sc.getact used 15.12.87 MH
   REPEATUNTIL G.key = m.kd.noact

   G.sc.cachemess(m.sd.save)
   G.sc.mess( question )

      G.sc.getact()        // get the response G.sc.getact used 15.12.87 MH
   REPEATUNTIL G.key ~= m.kd.noact
   TEST G.key = 'R'
   THEN
   $(  G.sc.movea(m.sd.message, width, m.sd.mesYtex)
       G.sc.ofstr("R")
   $)
   ELSE G.sc.cachemess(m.sd.restore)

   RESULTIS G.key   //G.key returned 15.12.87 MH
$)


// play startup film
// N.B. This code assumes a cold boot has just occurred
// and that video mode is hence VP 3 (dy.init of startup state
// must not alter this).

AND startup.film() BE
$(
   LET db1 = ?
   LET key = m.kd.noact
   LET discid    = G.context!m.discid
   LET reply.buf = VEC m.vh.poll.buf.words

   G.sc.clear(m.sd.message)        // clear 'starting' message 26.9.86 PAC  

   // a few dummy reads to clear out the keyboard buffer

   $<debug IF FALSE DO $>debug
   UNTIL read.ch() = m.kd.noact LOOP

   $<debug IF read.ch() = m.kd.stop RETURN $>debug

   G.vh.audio(m.vh.both.channels)  // switch on both audio channels

   TEST discid = m.dh.NatA
   THEN G.vh.play( m.ov.nfilmS, m.ov.nfilmE )      // play national film
   ELSE IF (discid = m.dh.south) | (discid = m.dh.north)
        THEN G.vh.play( m.ov.cfilmS, m.ov.cfilmE ) // play community film

   $(wait

      key := read.ch()
      db1 := G.vh.poll(m.vh.read.reply,reply.buf)

   $)wait REPEATUNTIL (key = m.kd.stop) |
                  (db1 = m.vh.finished) $<debug | (CAPCH(key)='Q') $>debug

   IF db1 ~= m.vh.finished THEN G.vh.send.fcode("X")

   G.vh.audio( m.vh.no.channel )
$)


// minor tidying up for AES system
// watch out for wordsize here !!!

AND read.ch() = VALOF
$(
   LET mouse.buf = VEC 3
   G.sc.mouse(mouse.buf)
   RESULTIS mouse.buf!2
$)
.
