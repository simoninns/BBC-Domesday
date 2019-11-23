// /**
//       UTHDR - UILITIES HEADER
//       -----------------------
//
//       manifests for UT:
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       17.01.86 1        DNH         Initial version
//       05.03.86 2        PAC         Added PRINT constants
//       25.03.86 3        PAC         Added WRITE + WAIT consts
//       08.04.86 4        PAC         Mod PRINT timeout const.
//       15.04.86 5        DRF         Added copy screen consts
//       07.05.86 6        PAC         Mod PRINT timeout const.
//       25.06.86 7        DNH         Abort codes added
//       30.06.86 8        PAC         Add stuff for open.file
//        1.07.86 9        SRY         Add abort code
//       04.07.86 10       PAC         Add load/save bookmark stuff
//        1.9.86  11       PAC         Extended timeout for print
//       13.10.86 12       PAC         Add init.abort code
//       14.5.87    13     PAC         Removed unused AES manifests
//       10.6.87    14     PAC         Removed cmp32 manifests
//       31.7.87    15     PAC         New print manifest
//       07.01.88   16     MH          m.ut.words.per.line changed from 20
//                                     to 40/bytesperword
// **/

manifest
$(
//       manifests results for G.ut.cmp32: signed 32 bit compare
//       now in glhdr because of RCP compiler blowing up

// manifests for G.ut.print
m.ut.maxtime  = 300  // timeout for printer - 3 seconds with nothing happening
m.ut.maxchars =  55  // 55 chars per line of print
m.ut.emptybuff = 63  // buffer size of an empty buffer

// manifests for G.ut.write
m.ut.success    = 0
m.ut.CR         = #x0D
m.ut.osfind     = #xFFCE
m.ut.osfile     = #xFFDD
m.ut.osgbpb     = #xFFD1
m.ut.osword     = #xFFF1
m.ut.write.op   = 2    // OSGBPB - append bytes to file
m.ut.read.op    = 4    // OSGBPB - read from current pos in file
m.ut.close      = 0    // OSFIND - close file
m.ut.open.read  = #x40 // OSFIND - open file to read
m.ut.open.write = #x80 // OSFIND - open file to write
m.ut.delete.file= 6    // OSFILE - delete file
m.ut.min.error  = #x80
m.ut.text       = 1
m.ut.dump16bit  = 2
m.ut.dump32bit  = 3

// for SRAM commands
m.ut.from.SRAM = #x40
m.ut.to.SRAM   = #xC0

// for bookmark save/load
m.ut.new.mark   = 1
m.ut.old.mark   = 2
m.ut.Community  = 3
m.ut.National   = 4

m.ut.16bit.nos.per.line = 5
m.ut.32bit.nos.per.line = 3

m.ut.linewidth      = 40   // 40 chars (max) in one line
m.ut.chars.per.line = 40
m.ut.words.per.line = 40/bytesperword // words in one line Updated 07.01.88 MH

m.ut.chars16 = 7  // chars in a 16 bit number
m.ut.chars32 = 12 // chars in a 32 bit number

// manifests for g.ut.copy.screen
m.ut.main   =  0
m.ut.shadow =  1

//  abort codes
m.ut.kernel.abort = 700
m.ut.root.abort = 710
m.ut.help.abort = 720
m.ut.videodisc.abort = 730
m.ut.trap.abort = 740
m.ut.map.abort  = 750
m.ut.area.abort = 760
m.ut.init.abort = 770 // dud SRAM
$)

