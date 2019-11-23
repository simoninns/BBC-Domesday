// /**
//       CO.CM3HDR - Map Options Header
//       ------------------------------
//
//       Useful values for Scale, Distance, Area, Units
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//        1.5.86    1      DNH      Initial version
//       14.5.86    2      DNH      bugfix values
//       16.5.86    3      DNH      values for band.line.to
//       20.5.86    4      DNH      overflow renamed full
//        9.6.86    5      DNH      conversion factors; 3sf
//       10.6.86    6      DNH      real g.sc.xor.selcol
//        8.7.86    7      DNH      m.v.second.last.x/y added
//                                  limit upped to 50 points
//       30.9.87    8      MH       update to size of measure
// **/

manifest
$(

//  values for Units
m.metric = 0
m.imperial = ~m.metric

//  values for Distance and Area op's:
m.metres.to.yards = 10940     // * 1.094     (must mult by this, div by 10,000)
m.km.to.miles     = 6214      // * 0.6214
m.scale.sig.digits = 3              // output to 3sf

//  message area text positions for Scale output etc.
//  note that 'writesg' of the FP package writes a leading space
//  in front of all positive numbers
m.distance.value.X.pos =                       m.sd.mesXtex
m.distance.units.X.pos =  8 * m.sd.charwidth + m.sd.mesXtex
m.distance.value.field =  7           // 6 digits worth
m.area.value.X.pos     =  2 * m.sd.charwidth + m.sd.mesXtex
m.area.units.X.pos     = 11 * m.sd.charwidth + m.sd.mesXtex
m.area.value.field     =  8           // 7 digits worth

//  offsets down the 'measure' vector
m.v.value          = 0     // cumulative distance in Distance op.
                           //     (a fixed point value)
                           // OR total area value in Area op.
m.v.next.point.ptr = 4     // pointer to next coordinate pair
                           //  (allow 4 words for the preceding FX value)
m.v.full           = 5     // true if screen coord storage vec full up
m.v.units          = 6     // current units (m.metric/m.imperial)
m.v.second.last.x  = 7     // storage for second last in case it has to be
m.v.second.last.y  = 8     // restored due to overflow
m.v.first.point    = 9     // offset to 1st coord pair
m.v.last.point     = 107   // offset to last: enough for 50 points
m.v.co.xdir        = 209   // direction from last point
m.v.co.ydir        = 210   //
m.v.co.xco         = 211   // map coordinates of 1st map
m.v.co.yco         = 212   //
m.v.co.oldx        = 213   // temporary store for old.xpoint
m.v.co.oldy        = 214   // temporary store for old.ypoint
m.v.co.relx        = 215   // direction from 1st position
m.v.co.rely        = 216   //
   // m.cm.measure.size = 216   size of whole vec in cmhdr
m.v.to.x.y       = 100     // offset for X and Y squares

//  values for 'band.line.to' routine
m.band.line = 0
m.fix.line  = 1
$)
