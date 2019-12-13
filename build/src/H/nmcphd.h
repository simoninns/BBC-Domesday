// /**
//       nm.h.NMCPHDR - PRIVATE MANIFESTS FOR NM cnmCOMP MODULE
//       ------------------------------------------------------
//
//       Manifests used privately by national mappable compare
//       routines and display key module.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       16.06.86 1        D.R.Freed   Initial version
//       31.07.86 2        DRF      correlate statics
//       *******************************
//       18.6.87     2     DNH      CHANGES FOR UNI
// **/

manifest
$(
      // logical colours for use in the Link sub-operation
      // NOTE these are the same colours used for foregrounds
      // in the normal key - so the other keys must never be
      // displayed whilst there is a linked display on show;
      // display key reassigns these colours when it is next
      // called

   m.bg.nodata    =  m.nm.fg.col.base      //  "No data" box
   m.fg.nodata    =  m.nm.fg.col.base + 1
   m.bg.coinc     =  m.nm.fg.col.base + 2  // "Coincident data" box
   m.fg.coinc     =  m.nm.fg.col.base + 3


      // NAMES file record and field lengths

   m.itemrecord.length = 36 // length of NAMES file record in bytes
   m.namelength        = 30 // length of item name in bytes


      // byte offsets into NAMES record

   m.type      = 31     // item type    ( 8 bit)
   m.address   = 32     // item address (32 bit)


      // minimum number of points on which Correlate can be performed
   m.min.num.correl.points = 25

      // maximum number of points on which the fast Correlate method
      // can be performed; the frame buffer needs to be split into 2
      // for this method
   m.max.num.fast.correl.points = m.nm.frame.size / 2

      // offsets into g.nm.s for context variables

   m.linked.display = m.nm.gen.purp // current display linked flag
   m.help.visited = m.nm.gen.purp + 1 // help been visited flag
   m.itemname = m.nm.gen.purp + 2 // item name string as entered by user
      // pointer into areal vector for unpacking grid square data
   m.next = m.itemname + m.namelength / BYTESPERWORD + 1
   m.old.itemrecord = m.next + 1 // save area for current dataset's
                                 // item record
$)
