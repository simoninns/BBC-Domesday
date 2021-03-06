//  AES SOURCE  6.87

/**
         HE.HELP1 - HELP OVERLAY
         -----------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR  DETAILS OF CHANGE
         30.04.86 1        PAC     Initial version
         24.05.86 2        JIBC    Fix menu bar, reduce messages
         29.05.86 3        PAC     Fix status page display
         26.06.86 4        PAC     Split for new code
         01.07.86 5        PAC     Remove paging into help text
         02.07.86 6        PAC     Bugfix status page
         15.07.86 7        PAC     Add more status page stuff
         16.07.86 8        PAC     Use GL7HDR
         31.07.86 9        PAC     Don't show demo if flag set
           6.8.86 10       PAC     Fix show demo bug
   ***************************************************************
         16.6.87  11       PAC     ADOPTED FOR UNI
**/

SECTION "b.help1"

get "H/libhdr.h"

get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/kdhd.h"
get "H/hehd.h"

/**
         G.HE.HELP - ACTION ROUTINE FOR HELP
         -----------------------------------

         main action routine in help

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         none - this routine does very little

         PROGRAM DESIGN LANGUAGE:

         IF key is "?" THEN show system status page

         IF help was entered from FILM
         THEN don't show "Demo" in menu

         UNLESS help was entered from MAPPROC or AREA
         don't show "Areal" in menu
**/

LET G.he.Help() BE
$( LET status = TABLE m.sd.act,m.sd.act,m.sd.act,
                      m.sd.act,m.sd.act,m.sd.act

   TEST G.he.work!m.he.show.demo // added 31.7.86 PAC
   THEN status!2 := m.sd.act     // fixed 6.8.86 PAC
   ELSE status!2 := m.sd.wBlank  // used to be !3

   TEST G.he.work!m.he.show.areal
   THEN status!5 := m.sd.act
   ELSE status!5 := m.sd.wBlank

   IF G.key = '?' THEN sys.status.page()

   IF G.redraw | check.menu( status ) THEN G.sc.menu( status )
$)

/**
         sys.status.page [] - display the system status page for HELP
         ---------------

         This is the system status page, and appears on the final
         version for debugging purposes and advanced user
         information.

         It can be made to appear by typing "?" in the normal top
         level HELP state.

         It can be removed by taking a sub-option (e.g. SYSTEM),
         and then returning to the MAIN state. This redisplays
         the normal status page.
**/

AND sys.status.page() BE
$(
   LET CX = G.he.save+m.he.context.start
   LET MB = G.he.save+m.he.menubar.start
   LET oldlen = (CX+m.itemrecord)%0

   G.sc.pointer( m.sd.off )
   G.sc.clear( m.sd.display )
   G.sc.clear( m.sd.message )
   G.sc.mess("Help Status Page - Context Globals are:")
   G.sc.selcol( m.sd.cyan )
   G.sc.movea ( m.sd.display,0,m.sd.disYtex )

   WRITEF(" Laststate, Disc id___ %n,%n",CX!m.laststate,CX!m.discid)
   WRITEF("*n Level, Type__________ %n,%n",(CX!m.leveltype>>8),(CX!m.leveltype & #xFF))

   WRITES("*n GridRef BotL E, N____ ")

   WRITEU.( CX!m.grbleast, 1 ) ; WRCH(',')
   WRITEU.( CX!m.grblnorth,1 )

   WRITES("*n GridRef TopR E, N____ ")

   WRITEU.( CX!m.grtreast, 1 ) ; WRCH(',')
   WRITEU.( CX!m.grtrnorth,1 )

   WRITES("*n Frame no_____________ ")
   WRITEU.( CX!m.frame.no,1 )

   WRITES("*n Underlay frame_______ ")
   WRITEU.( CX!m.underlay.frame.no,1 )

   WRITEF("*n Page.no, Picture.no__ %n,%n",CX!m.page.no,CX!m.picture.no)
   WRITEF("*n Areal.U, resolution__ %n,%n",CX!m.areal.unit,CX!m.resolution)
   WRITEF("*n AOI.type, AOI.name___ %n,%n",CX!m.type.AOI,CX!m.name.AOI)

   IF oldlen > 32 THEN (CX+m.itemrecord)%0 := 32
   WRITEF("*n Itemrec : %n ",CX%m.itemtypeoff); G.sc.oprop(CX+m.itemrecord)
   (CX+m.itemrecord)%0  := oldlen

   WRITES("*n Itemaddress_(16bit)__ ") ; WRITEU.( CX!m.itemaddress,1 )

   WRITEF("*n Itemaddress_(32bit)__ ") ; WRITE32( CX + m.itemaddress )
   WRITEF("*n Itemadd 2____________ ") ; WRITE32( CX + m.itemadd2 )
   WRITEF("*n Itemadd 3____________ ") ; WRITE32( CX + m.itemadd3 )

   WRITEF("*n Maprec,Flags,Mapno___ %n, %n, ",CX!m.maprecord,CX!m.flags)
   WRITEU.( CX!m.map.no,1 )

   WRITEF("*n Itemselected_________ %n",CX!m.itemselected)
   WRITEF("*n Xpos,Curpos__________ %n, %n",CX!m.xpos,CX!m.curpos)

   WRITEF("*n Exit stack___________ %n %n %n %n",CX!42,CX!43,CX!44,CX!45 )
   WRITEF("*n Exit stack pointer___ %n",CX!m.stackptr )
   WRITEF("*n G.menubar____________ %n %n %n %n %n %n",MB!0,MB!1,MB!2,MB!3,MB!4,MB!5)
   WRITEF("*n Last video mode______ %c",G.he.save!m.he.oldvideo & #x7F)
   WRITEF("*n Help's MAXVEC size___ %n",G.he.work!m.he.worksize)

   G.sc.pointer( m.sd.on )
$)

AND check.menu( boxvec ) = VALOF
$( FOR i = 0 TO 5 DO
   UNLESS G.menubar!i = boxvec!i RESULTIS TRUE
   RESULTIS FALSE
$)          

AND WRITEU.( number ) BE
$(
   LET buf = VEC 6 / bytesperword
   LET ptr = 1
   G.vh.word.asc( number, buf )

   WHILE buf%ptr = '0' DO // strip leading zeroes
   $( buf%ptr := '*S'
      ptr := ptr + 1
   $)    

   WRITES( buf ) // print it
$)

AND WRITE32( nptr ) BE
$(
   WRITEHEX( G.ut.unpack16( nptr,2 ) , 4)
   WRITEHEX( G.ut.unpack16( nptr,0 ) , 4)
$)
.
