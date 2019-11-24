// /**
//       nm.h.NMREHDR - PRIVATE MANIFESTS FOR NM cnmRETR MODULE
//       ------------------------------------------------------
//
//       Manifests used privately by national mappable retrieve
//       routines.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       21.04.86 1        D.R.Freed   Initial version
//       *******************************
//       18.6.87     2     DNH      CHANGES FOR UNI
//                                   m.write.ok: use bytesperword
//       19.01.88    3     MH       Update for RANK
// **/

manifest
$(
   m.gaz.record.length  =  48 // in  bytes

      // offsets into g.nm.s for context variables

   m.local.state = m.nm.gen.purp    // local state within Retrieve
   m.saved = m.nm.gen.purp + 1    // screen saved flag
   m.restore = m.nm.gen.purp + 2  // screen restore flag
   m.sum.total = m.nm.gen.purp + 3  // sum of retrieved values
   m.missing = m.nm.gen.purp + 6 // missing data flag for values function
   m.area.no = m.nm.gen.purp + 12
   m.gaz.record = m.nm.gen.purp + 13  // gazetteer record buffer
   m.write.ok = m.gaz.record + m.gaz.record.length / BYTESPERWORD
                                    // disc error status

   // flashing square information
   // if m.flash.colour = m.nm.flash.white then there is no flashing square

   m.flash.colour = m.nm.gen.purp + 7 // original colour of flashing square
   m.flash.e = m.nm.gen.purp + 8 // easting of flashing square
   m.flash.n = m.nm.gen.purp + 9 // northing of flashing square
   m.flash.sq.e = m.nm.gen.purp + 10 // grid square reference of square
   m.flash.sq.n = m.nm.gen.purp + 11

// RANK section

   m.nm.rpage        = m.write.ok + 1  // current page of RANK list
   m.nm.num.values   = m.write.ok + 2  // number of non-missing values
   m.nm.grand.total  = m.write.ok + 3  // 3 words: total of data values
   m.nm.help.visit   = m.write.ok + 6  // help visited flag
   m.nm.prev.mode    = m.write.ok + 7  // previous video mode
   m.nm.pal          = m.write.ok + 8  // nm.class.init words for palette
   m.nm.cum          = m.write.ok + 13 // Display cumlative totals ?
   m.nm.reload       = m.write.ok + 14 // Help reload flag
   m.nm.rank.pages   = m.write.ok + 15 // number of pages in RANK list

// end of list

   m.nm.ritems.page  = 8
   m.nm.rpage.top    = 688 // m.sd.disH - 5 * m.sd.linW
$)
