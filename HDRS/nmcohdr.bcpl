// /**
//       nm.h.NMCOHDR - CONFIGURATION MANIFESTS FOR MAPPABLE DATA
//       --------------------------------------------------------
//
//       Manifests used for configuration of mappable data
//       operation.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       02.05.86 1        D.R.Freed   Initial version
//       07.11.86 2        DRF         Default display
//                                        parameters tuned
// **/

manifest
$(
   m.nm.conf.num.of.cut.points = 4     // number of cut-points to use
                                       // for automatic classing

   m.nm.target.num.of.squares =  1700  // target number of grid squares
                                       // for initial display
                                       // NB: must be >= 33 on a 16-bit word
                                       //     machine, since
                                       //       surface area in sq.km
                                       //       divided by the constant must
                                       //       always fit in a word

   m.nm.target.num.of.areas   =  70    // best number
   m.nm.lo.num.of.areas       =  30    // minimum desirable number
   m.nm.hi.num.of.areas       =  500   // maximum desirable number

   // land surface area of GB = 240,000 sq.km = 3a980 (hex)
   // used to calculate average area sizes for areal units
   m.nm.land.surface.area.lo  =  #xa980
   m.nm.land.surface.area.hi  =  #x0003
$)

