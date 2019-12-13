// /**
//       UT.H.GRHDR - Grid Reference Manipulation Header
//       -----------------------------------------------
//
//       For calls to GR library of UT package.
//       Not part of the kernel.
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       24.3.86   1       DNH         Initial version
//       27.6.86   2       DNH         fix domesday wall area
//       12.9.86   3       DNH         fix orkney wall area
// **/

manifest
$(
m.grid.invalid  = 0         // Grid Ref of invalid format or magnitude
m.grid.is.GB    = 8         // the Great Britain grid System
m.grid.is.South = 8+1       // Regions for Southern Britain...
m.grid.is.North = 8+2
m.grid.is.Domesday.wall = 8+3
m.grid.is.IOM   = 8+4
m.grid.is.Shet  = 8+5
m.grid.is.NI      = 16       // Northern Ireland System and Region
m.grid.is.Channel = 32       // Channel Isles System and Region

// various hectometre values for L1 maps: used to match an L1 map to a
// GB grid reference.  Of internal use to GR library.
// Values from Helen Mounsey for grid limits.
// NB!!! Values for top right for IOM are for the top right of the level 1
// itself, not the grid.  This is because there are many points not on the
// level 1 map which are on the level 2 due to duff photographing.
// If these are requested by Community Find they result in a small cross in
// the sea off Scotland.

m.gr.man.L1.mine = 2140
m.gr.man.L1.maxe = 2540
m.gr.man.L1.minn = 4640
m.gr.man.L1.maxn = 5070

m.gr.south.L1.mine =  800
m.gr.south.L1.maxn = 4800

m.gr.north.L1.minn = 4500
m.gr.north.L1.maxe = 5600

m.gr.shet.L1.mine = 2800
m.gr.shet.L1.minn = 9600
$)
