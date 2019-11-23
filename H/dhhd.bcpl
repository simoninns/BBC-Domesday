// /**
//       DH.H.DHHDR - MANIFESTS FOR DATA HANDLER
//       ---------------------------------------
//
//       Manifests for data handler routines.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       14.11.85 1        DNH         Initial version
//       02.12.85 1.01                 include VFS type
//       27. 1.86 2                    changes to names and
//                                     definitions moved from
//                                        dhphdr
//       14. 3.86 3                    New values for discid.
//       17. 6.86 4                    Add m.dh.natB
//        5. 8.86 5                    non.data -> not.domesday
//        1.10.86 6                    Add comment; cross-ref to
//                                        NMHDR
//       29.4.87     7    DNH       m.dh.not... from -1 to 0
// **/


manifest
$(
   //  useful values for g.dh.read etc.
   //  NB: THE FOLLOWING 3 MANIFESTS ARE DUPLICATED IN NMHDR - ANY
   //      CHANGES MUST BE MADE TO BOTH FILES
m.dh.bytes.per.sector = 256
m.dh.sectors.per.frame = 24
m.dh.bytes.per.frame = m.dh.bytes.per.sector * m.dh.sectors.per.frame

   // filing system types returned by g.dh.fstype()
m.dh.none = 0
m.dh.adfs = 8
m.dh.vfs  = 10

// values for g.dh.discid; not.domesday should never appear in
// g.context!m.discid since g.dh.seldisc will reject any unknown disc.
m.dh.south        =  2
m.dh.north        =  4
m.dh.natA         =  8
m.dh.natB         = 16
m.dh.not.domesday =  0        // UNI. Used to be -1
$)
