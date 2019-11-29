// /**
//       IOPHDR - PRIVATE I/O WORKSPACE HEADER
//       -------------------------------------
//
//       This file defines the addresses in the I/O processor
//       for the CACHE/RESTORE operation.
//
//       N.B. ensure that the area numbers in this file tie up
//       with the manifests in IOHDR.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//        27.5.87 1        PAC         ADOPTED FOR AES SYSTEM
//         1.6.87 2        PAC         Modified community areas
//        12.6.87 3        PAC         Modified national areas
//        18.6.87 4        PAC         Upped bookmark cache
//        23.7.87    5     DNH         Up NP cacheto 52 bytes
//        03.12.87   6     MH          updated m.io.a23add from 436 to 868
//        23.12.87   7     MH          m.io.booksize increased from 448 to 464
//        24.12.87   8     MH          m.ioa13add increased from 3436 to 3544
//        06.06.88   9     SA          m.ioa10add increased from 2048 to 2060
//                                     for countryside development of NM
// **/

 MANIFEST
 $(

//
//  All addresses are BYTE offsets within the cache vector 'G.cachevec'
//  G.cachevec is obtained from  the heap on system startup, and is a
//  getvec of size m.io.cachesize.
//
//  The screen is not held within the cache area, but remains within
//  sideways RAM. The whole screen is now saved, including the menu bar.
//
//  To address an area of the cache, we use the current tables set up in
//  the UTILS2 module. As before, each cache area has a number associated
//  with it, which is used as an index to look up in the tables.
//

// these values refer to the SRAM locations for the screen
// and message bar, and also the size of a display screen.

 m.io.messadd   = 0      // sram start of message bar cache
 m.io.screenadd = #x500  // sram start of place to save screen
 m.io.scrsize   = #x5000 // = 20k (i.e. all the screen)
                         // ...was 19199 which left out the menu bar
 m.io.second.screen = #x5500 // spare screen areaused for copy.screen

// m.io.maxram   = #xFFBF  // top address in sideways ram

 // ******** these need checking out / chucking out ************
 //
 // manifests used by bookmark (cache/restore/load/save) stuff only
 // m.io.end.add = m.io.screenadd + m.io.scrsize + 300
 // m.io.halfram = (m.io.maxram - m.io.end.add) >> 1 // half the available RAM
 // m.io.total.size = m.io.scrsize + (m.io.a2add-m.io.a1add)

//
// these values define BYTE offsets within G.Cachevec.
// they do NOT refer to SRAM any more.
//

 m.io.cachesize = #x10000          // just have 64k for starters
 m.io.booksize  = 464              // size of bookmark cache
                                   //increaesed from 448 to 464 23.12.87 MH
 m.io.halfram   = (m.io.cachesize-m.io.booksize)/2 // half of available RAM

 m.io.a0add =   0 // area 0 WAS where we put the screen but it's not used now
 m.io.a1add =   m.io.a0add + 0
 m.io.a2add =   m.io.a1add + m.io.booksize  // bookmark's cache of G.he.save

 m.io.NatStart= m.io.a2add          // NATIONAL areas
 m.io.a3add  =  m.io.a2add  +  52   // photo
 m.io.a4add  =  m.io.a3add  +  4128 // find
 m.io.a5add  =  m.io.a4add  +  8192 // mapproc - areal vector
 m.io.a6add  =  m.io.a5add  +  244  // mapproc - areal map
 m.io.a7add  =  m.io.a6add  +  28   // mapproc - class intervals
 m.io.a8add  =  m.io.a7add  +  24   // mapproc - class colours
 m.io.a9add  =  m.io.a8add  +  2070 // mapproc - statics
 m.io.a10add =  m.io.a9add  +  2692 // contents - thesdata
 m.io.a11add =  m.io.a10add +  804  // contents - itemdata
 m.io.a12add =  m.io.a11add +  28   // contents - statics
 m.io.a13add =  m.io.a12add +  3544 // chart updated from 3436 24.12.87 MH
 m.io.a14add =  m.io.a13add +  0    // film
 m.io.a15add =  m.io.a14add +  100  // walk
 m.io.a16add =  m.io.a15add +  324  // area
 m.io.NatTop =  m.io.a16add +  808  // essay

 m.io.NatEnd =  m.io.NatTop -  1

 m.io.ComStart = m.io.natstart + m.io.halfram

 m.io.a17add =  m.io.Comstart       // COMMUNITY areas
 m.io.a18add =  m.io.Comstart + 984 // phtx context
 m.io.a19add =  m.io.a18add +  4020 // find
 m.io.a20add =  m.io.a19add +  184  // map - statics
 m.io.a21add =  m.io.a20add + 20004 // map - cache
 m.io.a22add =  m.io.a21add +  84   // map - keep vec
 m.io.a23add =  m.io.a22add +  868  // map - map opt cache
                                    //updated from 436 to 868 03.12.87 MH
 m.io.a24add =  m.io.a23add +  6148 // phtx - frame buffer

 m.io.ComEnd =  m.io.a24add - 1
$)
