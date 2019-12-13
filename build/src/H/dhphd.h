// /**
//       dh.h.dhphdr - Private manifests for Data Handler
//       ------------------------------------------------
//
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       14.11.85 1        D.Hepper    Initial version.
//       21.11.85 1.01     D.Hepper    correction to sectors
//                                     per frame - 24.
//       27.1.86  2        DNH         Various defin's to
//                                       'h.dhhdr' instead.
//        3.2.86   3       DNH         Osbyte added.
//       12.2.86   4       DNH         m.vfs.osword.read.write
//       18.3.86   5                   m.osgbpb.gb.csd.op
//       25.6.86   6       DNH         m.name.size.words 25 -> 10
//                                     m.ascii.cr gone
//                                     m./vfs/adfs/.osword.get.error
//       27.6.86   7       DNH         ...fcode.read -> ...read
//                                     ...fcode.get.. ->
//                                           ...get.fcode..
//        8.5.87   8       PAC         Fix block sizes
//       25.7.87   9       PAC         Add SCSI control manifest
// **/

// most of these values relate to the VFS manual

manifest
$(
m.osargs = #Xffda
m.osargs.fstype.op = 0
m.osargs.flength.op = 2

m.osbyte = #Xfff4
m.osbyte.read.ram = #Xa1

m.osfind = #Xffce
m.osfind.open.read.op = #X40
m.osfind.close.op     = #X00

m.osgbpb = #Xffd1
m.osgbpb.gb.newptr.op = 3
m.osgbpb.gb.csd.op    = 8
m.osgbpb.rcb.size.words = 14/BYTESPERWORD
// ( use %1 to %13 for read control block )

m.osword = #Xfff1
m.osword.read  = #X08               // value for SCSI function code
m.osword.get.fcode.result = #Xc8    // ditto
m.adfs.osword.read.write = #X72
m.vfs.osword.read.write  = #X62     // prevents clashes with ADFS
m.adfs.osword.get.error = #X73
m.vfs.osword.get.error  = #X63

m.SCSI.Control.word = 0     // used by readframes 

m.name.size.words = 20/BYTESPERWORD // length and 19 chars (plenty)
m.carry.flag = #X01           // flag bit mask in status (flag) register
m.fs.error = #X80             // lowest possible filing system error
m.dh.zpage = 112              // zero page byte address of 4 bytes for dh

m.cbsw = 20/BYTESPERWORD      // control block size words
$)



