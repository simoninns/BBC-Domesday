//  AES SOURCE  6.87

/**
         HE.HTEXT7 - SEVENTH MODULE FOR HELP TEXT
         --------------------------------------

         This file contains only G.he.set.first.essay

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.help

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         23.07.86 1        PAC         Initial version
         25.07.86 2        PAC         Add manifests for essays
           6.8.86 3        PAC         Update addresses
           2.9.86 4        PAC         Update addresses (finally!)
          23.9.86 5        PAC         Update addresses (yet again)
          6.11.86 6        PAC         Update addresses for MP01C

         ********************************************************

         WARNING: FOLLOWING ABOVE CHANGE, THE HELP OVERLAY FOR
         MP01C HAS BECOME INCONSISTENT WITH THAT ON MP01A/B.

         The only addresses changed are the National ones, so
         Help overlays built with code following this latest
         revision will work with any of the Domesday discs.

         The only danger is that someone will use a Help overlay
         downloaded from MP01A/B with the Helptext file on MP01C.

         ********************************************************

         12.11.86 7        PAC         Update yet again.
         12.11.86 8        NRY         ... and one more time.
         7.7.87   9        PAC         ADOPTED FOR UNI
**/
SECTION "HelpText7"

STATIC $( s.addresses = 0 $)

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glHEhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/hehd.h"

MANIFEST
$(
// addresses for help essays

m.he.HI1  = 0
m.he.LO1  = 0       // chgen

m.he.HI2  = 0
m.he.LO2  = #x1800  // chmap

m.he.HI3  = 0
m.he.LO3  = #x3800  // chmapopt

m.he.HI4  = 0
m.he.LO4  = #x4800  // chmapscl

m.he.HI5  = 0
m.he.LO5  = #x6000  // chphoto

m.he.HI6  = 0
m.he.LO6  = #x8800  // chphopt

m.he.HI7  = 0
m.he.LO7  = #x9800  // chtext

m.he.HI8  = 0
m.he.LO8  = #xB800  // chteopt

m.he.HI9  = 0
m.he.LO9  = #xC800  // chfind

m.he.HI10 = 1
m.he.LO10 = #x0800  // chindex

m.he.HI11 = 1
m.he.LO11 = #x1000  // nhgen

m.he.HI12 = 1
m.he.LO12 = #x2800  // nhfind

m.he.HI13 = 1
m.he.LO13 = #x5800  // nhindex

m.he.HI14 = 1
m.he.LO14 = #x6000  // nhphoto

m.he.HI15 = 1
m.he.LO15 = #x8000  // nhtext

m.he.HI16 = 1
m.he.LO16 = #x9800  // nhwalk

m.he.HI17 = 1
m.he.LO17 = #xC000  // nhgall

m.he.HI18 = 1
m.he.LO18 = #xF800  // nhfilm

m.he.HI19 = 2
m.he.LO19 = #x1000  // nhmaps

m.he.HI20 = 2
m.he.LO20 = #x6800  // nharea

m.he.HI21 = 2
m.he.LO21 = #xA800  // nhcmpre

m.he.HI22 = 2
m.he.LO22 = #xD800  // nhanlys

m.he.HI23 = 3
m.he.LO23 = #x6000  // nhchart

m.he.HI24 = 4
m.he.LO24 = #x0800  // nhconts

// essay numbers

m.he.chgen    = 1
m.he.chmap    = 2
m.he.chmapopt = 3
m.he.chmapscl = 4
m.he.chphoto  = 5
m.he.chphopt  = 6
m.he.chtext   = 7
m.he.chteopt  = 8
m.he.chfind   = 9
m.he.chindex  = 10

m.he.nhgen    = 11
m.he.nhfind   = 12
m.he.nhindex  = 13
m.he.nhphoto  = 14
m.he.nhtext   = 15
m.he.nhwalk   = 16
m.he.nhgall   = 17
m.he.nhfilm   = 18
m.he.nhmaps   = 19
m.he.nharea   = 20
m.he.nhcmpre  = 21
m.he.nhanlys  = 22
m.he.nhchart  = 23
m.he.nhconts  = 24

$)

/**
         G.HE.SET.FIRST.ESSAY - SETUP FIRST ESSAY
         ----------------------------------------

         This routine decides which essay to show on entry to
         help text.

         INPUTS:

         none

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         G.context!m.itemaddrLO
         G.context!m.itemaddrHI

         SPECIAL NOTES FOR CALLERS:

         none

         PROGRAM DESIGN LANGUAGE:

         initialise essay address lookup table
         initialise essay number lookup table
         pick appropriate essay for previous state
         set up G.context!m.itemaddress with
                   address from lookup table
**/

LET G.he.set.first.essay() BE
$(
   LET state    = (G.he.save+m.he.context.start)!m.laststate
   LET essay.no = init.essay.tables(state)   
   LET lo.addr, hi.addr = ?,?   

   essay.no := (essay.no-1) * 2  // because the table is 2 word entries

   lo.addr := s.addresses!essay.no
   hi.addr := s.addresses!(essay.no+1)

// G.sc.ermess("Set addr %n %n  lo %n hi %n",state, essay.no, lo.addr, hi.addr )
   G.ut.set32( lo.addr, hi.addr, G.context+m.itemaddress )
$)

AND init.essay.tables( state.number ) = VALOF
$( 
   LET essay.no  = ?
 
   LET addresses = TABLE
   m.he.LO1,  m.he.HI1,  m.he.LO2,  m.he.HI2,
   m.he.LO3,  m.he.HI3,  m.he.LO4,  m.he.HI4,
   m.he.LO5,  m.he.HI5,  m.he.LO6,  m.he.HI6,
   m.he.LO7,  m.he.HI7,  m.he.LO8,  m.he.HI8,
   m.he.LO9,  m.he.HI9,  m.he.LO10, m.he.HI10,
   m.he.LO11, m.he.HI11, m.he.LO12, m.he.HI12,
   m.he.LO13, m.he.HI13, m.he.LO14, m.he.HI14,
   m.he.LO15, m.he.HI15, m.he.LO16, m.he.HI16,
   m.he.LO17, m.he.HI17, m.he.LO18, m.he.HI18,
   m.he.LO19, m.he.HI19, m.he.LO20, m.he.HI20,
   m.he.LO21, m.he.HI21, m.he.LO22, m.he.HI22,
   m.he.LO23, m.he.HI23, m.he.LO24, m.he.HI24

   s.addresses := addresses

   //
   //  m.st.startstop (=0) has no essay
   //
   RESULTIS VALOF SWITCHON state.number INTO
   $(
      DEFAULT          : RESULTIS 0
      CASE m.st.mapwal : RESULTIS m.he.chmap
      CASE m.st.mapsca : RESULTIS m.he.chmapscl

      CASE m.st.mapopt :
      CASE m.st.mapkey : RESULTIS m.he.chmapopt

      CASE m.st.cphoto : RESULTIS m.he.chphoto
      CASE m.st.picopt : RESULTIS m.he.chphopt
      CASE m.st.ctext  : RESULTIS m.he.chtext
      CASE m.st.ctexopt : RESULTIS m.he.chteopt

      CASE m.st.cfinde  : RESULTIS m.he.chgen  // never gets here !!
      CASE m.st.cfindm  : RESULTIS m.he.chfind
      CASE m.st.cfindr  : RESULTIS m.he.chindex

      CASE m.st.conten : RESULTIS m.he.nhconts

      CASE m.st.uarea  :
      CASE m.st.area   : RESULTIS m.he.nharea

      CASE m.st.datmap : RESULTIS m.he.nhmaps

      CASE m.st.manal  :
      CASE m.st.mdetail:
      CASE m.st.resol  :
      CASE m.st.mareas :
      CASE m.st.mclass :
      CASE m.st.manual :
      CASE m.st.autom  :
      CASE m.st.equal  :
      CASE m.st.nested :
      CASE m.st.quant  :
      CASE m.st.retri  : RESULTIS m.he.nhanlys

      CASE m.st.compare: RESULTIS m.he.nhcmpre

      CASE m.st.chart  :
      CASE m.st.rchart : RESULTIS m.he.nhchart

      CASE m.st.nfinde : RESULTIS m.he.nhgen  // never gets here !!
      CASE m.st.nfindm : RESULTIS m.he.nhfind
      CASE m.st.nfindr : RESULTIS m.he.nhindex

      CASE m.st.Gallery :
      CASE m.st.Galmove :
      CASE m.st.Gplan1  :
      CASE m.st.Gplan2  : RESULTIS m.he.nhgall

      CASE m.st.walk    :
      CASE m.st.walmove :
      CASE m.st.wplan1  : 
      CASE m.st.wplan2  :
      CASE m.st.detail  : RESULTIS m.he.nhwalk

      CASE m.st.film   : RESULTIS m.he.nhfilm

      CASE m.st.ntext  : RESULTIS m.he.nhtext

      CASE m.st.nphoto : RESULTIS m.he.nhphoto

      CASE m.st.AAtext   :
      CASE m.st.AAtexopt : RESULTIS m.he.chtext
  $)                 
$)
.
