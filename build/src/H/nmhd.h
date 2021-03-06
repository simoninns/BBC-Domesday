// /**
//       nm.h.NMHDR - MANIFESTS FOR NATIONAL MAPPABLE
//       --------------------------------------------
//
//       Manifests for national mappable data display routines.
//       Globals are in glhdr, glCMhdr
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       10.01.86 1        DRF      Initial version
//       17.02.86 2        DRF      g.nm.s extended,
//                                  new constants,
//                                  g.nm.s manifests expanded
//                                     to reflect national scope
//       05.03.86 3        DRF         local average -> g.nm.s
//                                  scope -> g.nm.s
//                                  current child -> g.nm.s
//                                  m.nm.child.ovly.size added
//                                  m.nm.file.name.length added
//                                  m.nm.max.num.areas reduced
//                                        to free up NOSA store
//                                  nmdihdr included
//                                  logical colour allocations
//                                  general purpose area added
//                                  to g.nm.s
//
//       14.04.86 4        DRF      m.nm.absolute.type added
//                                  m.nm.categorised.type,
//                                     m.hiword added
//                                  grid system -> g.nm.s
//                                  raster gr. sys. -> g.nm.s
//                                  names.offset -> g.nm.s
//                                  gaz.handle -> g.nm.s
//                                  window.set -> g.nm.s
//                                  raster index record &
//                                     offset -> g.nm.s
//                                  m.nm.child.ovly.size
//                                     changed
//                                  m.menubarsize adjustment
//       09.07.86 5        DRF      g.nm.s reorganised to
//                                     remove coarse index
//                                  m.nm.y.pixel.adjustment to
//                                  centre maps in display area
//                                  item address -> g.nm.s
//                                  m.nm.gone.to.text-> g.nm.s
//                                  m.nm.NA.char redefined
//                                  m.nm.max.num.areas
//                                     increased
//                                  areal data record &
//                                     offset -> g.nm.s
//                                  m.dh.bytes.per.frame
//                                     duplicated here to
//                                     enable compilations
//                                     in various modules
//                                  national min,max,ave
//                                     removed from g.nm.s
//                                  pix.per.grid.sq renamed
//                                     graph.per.grid.sq in
//                                     g.nm.s
//                                  x,y graphics start ->
//                                     g.nm.s
//                                  areal.data.size -> g.nm.s
//       *****************************
//       18.6.87     6     DNH      CHANGES FOR UNI
//                                     see marked-up listings
//       30.7.87     7     PAC      Fix resolution for A500 
//                                  Set child o'ly size to 0
//       4.8.87      8     PAC      Change vert res for mode 9
//       14.1.88     9     PAC      Fix vert res properly !!!
//       19.01.88   10     MH       m.nm.global.static.size increased from
//                                  47 to 55 for RANK
//       *****************************
//       06.06.88   11     SA       CHANGES FOR COUNTRYSIDE
//                                  'total' function
// **/

manifest
$(

BITSPERWORD = BYTESPERWORD * 8      // (avoid needing H/syshdr)

// NB: THIS MANIFEST IS DUPLICATED FROM DHHDR TO CUT DOWN ON SYMBOLS
//     DURING COMPILATION - ANY CHANGES MUST BE MADE IN BOTH FILES
m.dh.bytes.per.frame = 6144  // 24 sectors of 256 bytes = 6kb


//  LOGICAL COLOUR ALLOCATIONS FOR MODE 2

// m.sd.black2 is always black, throughout the system
// colours below m.nm.white are used by the kernel and are not to be redefined
//
m.nm.white        =  4  // NB =  m.sd.ff.col2 in SDHDR
m.nm.flash.white  =  5
m.nm.fg.col.base  =  6  // base number for foreground colours in key display
m.nm.bg.col.base  =  11 // base number for background colours in key display;
                        // these are the colours used for map displays

//  SCREEN DEFINITIONS

// NB: m.sd.disw = 1280, m.sd.dish = 888 in SDHDR ;
//     mappable data displays only use 220 of the 222 pixels available
//     in the display area; this area is centred within the full area
//
m.nm.pixel.width  = 320 // was 160
m.nm.pixel.height = 220 // was 220 // NB: if this changes, NAHDR must be changed

m.nm.x.pixels.to.graphics = 1280 / m.nm.pixel.width
m.nm.y.pixels.to.graphics = 880 / m.nm.pixel.height

m.nm.y.pixel.adjustment = 1


// USEFUL VALUES AND VECTOR SIZES

// aspect ratios for maps
m.nm.width.aspect  = 80
m.nm.height.aspect = 55


m.nm.coarse.blocksize   =  32
m.nm.fine.blocksize     =  8  // assumed to be m.nm.coarse.blocksize / 4

m.nm.coarse.index.size  =  1363  // maximum index size
                                 // NOSA = 350

m.nm.max.data.size      =  4 / BYTESPERWORD
            // NB: check NN.a.classify
            //     and in some optimised modules where
            //     an equivalent shift manifest is
            //     declared; any change must be made
            //     to all files   ****

m.nm.frame.size         =  m.dh.bytes.per.frame / BYTESPERWORD // in words

m.nm.child.ovly.size    =  0 // 3064 // nearly 6k bytes for child overlays
                                // this is the most that will fit in the
                                // non-stand-alone system

m.nm.file.name.length   =  8  // length of child overlay filename,
                              // in bytes, including length byte

m.nm.max.num.areas      =  1935  // NOSA value = 99

m.nm.areal.vector.size  =  (m.nm.max.num.areas + 1) * m.nm.max.data.size - 1
m.nm.areal.cache.size   =  m.nm.frame.size - 1
                                 // NOSA value = m.nm.areal.vector.size
m.nm.areal.map.size     =  m.nm.max.num.areas / BITSPERWORD

m.nm.max.neg.high    =  #X8000   // (used to be ...max.negative.value)
m.nm.uniform.missing =  #X8000   // (new one ****)
m.nm.max.pos.low     =  #Xffff
m.nm.max.pos.high    =  #X7fff

m.nm.NA.char = 134   // special mode 2 character for the "NA" symbol

m.nm.grid.mappable.data    =  1
m.nm.areal.boundary.data   =  2
m.nm.areal.mappable.data   =  3

m.nm.absolute.type                  = 0
m.nm.ratio.and.numerator.type       = 1
m.nm.percentage.and.numerator.type  = 4
m.nm.incidence.type                 = 5
m.nm.categorised.type               = 6

m.nm.num.of.class.intervals = 5  // NB: duplicated in NN.a.classify; any
                                 //     changes must be made to both files

m.nm.units.string.length = 40    // in BYTES



//   ++++  GLOBAL STATIC AREA g.nm.s STARTS HERE  ++++

// WORD OFFSETS INTO GLOBAL STATIC AREA g.nm.s


m.nm.num.auto.cut.points = 0  // controls quantiles and equal intervals


// AREA OF INTEREST, SCOPE OF RASTERIZED DATA AND SCREEN MAPPING

m.nm.km.low.e = 1    // in kilometres
m.nm.km.top.e = 2
m.nm.km.low.n = 3
m.nm.km.top.n = 4

m.nm.grid.sq.low.e = 5  // in grid squares
m.nm.grid.sq.top.e = 6
m.nm.grid.sq.low.n = 7
m.nm.grid.sq.top.n = 8

m.nm.grid.sq.start.e = 9   // compressed data easting start in grid squares
m.nm.grid.sq.start.n = 10  // compressed data northing start in grid squares
m.nm.grid.sq.end.e = 11    // compressed data easting end in grid squares
m.nm.grid.sq.end.n = 12    // compressed data northing end in grid squares

m.nm.blk.low.e = 13   // in coarse blocks
m.nm.blk.top.e = 14
m.nm.blk.low.n = 15
m.nm.blk.top.n = 16

m.nm.blk.start.e = 17
m.nm.blk.start.n = 18
m.nm.blk.end.e   = 19
m.nm.blk.end.n   = 20

m.nm.x.graph.per.grid.sq = 21   // graphics coordinates per
m.nm.y.graph.per.grid.sq = 22   //           grid square mappings

m.nm.x.min = 23   // display window in graphics coordinates
m.nm.x.max = 24
m.nm.y.min = 25
m.nm.y.max = 26

m.nm.x.graph.start = 49    // graphics coordinates for bottom left
m.nm.y.graph.start = 50    //                            grid square


// HEADER INFORMATION FOR DATASET

m.nm.dataset.record.number = 27  // absolute record number of dataset start
m.nm.dataset.type = 28

// NOTE: the following three text addresses must be contiguous and in
//       the order: private, descriptive, technical
m.nm.private.text.address = 29
m.nm.descriptive.text.address = 31
m.nm.technical.text.address = 33

m.nm.value.data.type = 35
m.nm.raster.data.type = 36


// HEADER INFORMATION FOR SUB-DATASET

m.nm.sub.dataset.index.record.number = 37 // absolute location of index
m.nm.sub.dataset.index.offset = 38
m.nm.data.record.number = 39  // absolute location of rasterised data
m.nm.data.offset = 40
m.nm.gr.start.e = 41    // compressed data starts at this grid reference
m.nm.gr.start.n = 42
m.nm.gr.end.e = 43      //                 and ends at this grid reference
m.nm.gr.end.n = 44
m.nm.primary.norm.factor = 45
m.nm.secondary.norm.factor = 46
m.nm.nat.num.areas = 47     // only meaningful for areal mappable datasets
                            // number of areas in areal vector
m.nm.data.size = 48     // in bytes
// (NB  49,50 defined above)

m.nm.areal.data.size = 51 // data size of areal data in bytes
m.nm.file.system = 52 // ADFS or VFS file


// (NB  53,54 are unused)


// SUMMARY DATA FOR SUB-DATASET

m.nm.equal.classes = 55    // equal class intervals over whole dataset
m.nm.nested.means.classes = m.nm.equal.classes +
                              (m.nm.num.of.class.intervals + 1) *
                                                         m.nm.max.data.size
m.nm.quantile.classes = m.nm.nested.means.classes + 4 * m.nm.max.data.size

                           // number of coarse blocks west to east
m.nm.num.we.blocks =
      m.nm.quantile.classes +
            (m.nm.num.of.class.intervals + 1) * m.nm.max.data.size

                           // number south to north - product of this and
                           // m.nm.num.we.blocks gives actual size of index
m.nm.num.sn.blocks = m.nm.num.we.blocks + 1

// current fine block index for coarse block within a sub-dataset -
// assume 4*4 fine blocks in a coarse block

m.nm.fine.index.record.number = m.nm.num.sn.blocks + 1
m.nm.fine.index.offset = m.nm.fine.index.record.number + 16


// HEADER INFORMATION FOR SUB-DATASET

m.nm.primary.units.string = m.nm.fine.index.offset + 16
m.nm.secondary.units.string = m.nm.primary.units.string +
                                 m.nm.units.string.length/BYTESPERWORD + 1


// CONTEXT VARIABLES

m.nm.windowed = m.nm.secondary.units.string +
                   m.nm.units.string.length/BYTESPERWORD + 1
     
      // window operation performed flag
m.nm.message.area = m.nm.windowed + 1
m.nm.overlay.mode = m.nm.message.area + 1
m.nm.num.areas = m.nm.overlay.mode + 1 // number of grid squares or areal
                                       // units within area of interest
m.nm.local.data.unpacked = m.nm.num.areas + 1
m.nm.local.min.data.value = m.nm.local.data.unpacked + 1
m.nm.local.max.data.value = m.nm.local.min.data.value + 2
m.nm.local.average = m.nm.local.max.data.value + 2
m.nm.scope = m.nm.local.average + 3
m.nm.intervals.changed = m.nm.scope + 1
m.nm.entry.mode = m.nm.intervals.changed + 1
m.nm.boundary.address = m.nm.entry.mode + 1

m.nm.menu = m.nm.boundary.address + 2  // local menu bar requirements

   // key sizes

m.nm.box.position = m.nm.menu+m.menubarsize + 1 // vector of graphics x coords,
                                                // 0 -> no. class intervals
m.nm.number.width = m.nm.box.position + m.nm.num.of.class.intervals + 1


   // current child overlay
m.nm.curr.child   =  m.nm.number.width + 1

   // grid system that area of interest is based on
m.nm.grid.system  = m.nm.curr.child +
                       m.nm.file.name.length / BYTESPERWORD + 1

   // offset of area names records in Gazetteer
m.nm.names.offset = m.nm.grid.system + 1

   // file handle for Gazetteer
m.nm.gaz.handle = m.nm.names.offset + 2

   // plot window flag
m.nm.window.set = m.nm.gaz.handle + 1

   // grid system that rasterized data is based on
m.nm.raster.grid.system = m.nm.window.set + 1

   // location of rasterised data subset index
m.nm.raster.index.record = m.nm.raster.grid.system + 1
m.nm.raster.index.offset = m.nm.raster.index.record + 1

   // item address of current dataset
m.nm.item.address = m.nm.raster.index.offset + 1

   // text function invoked flag
m.nm.gone.to.text = m.nm.item.address + 2

   // location of areal data values
m.nm.areal.data.record = m.nm.gone.to.text + 1
m.nm.areal.data.offset = m.nm.areal.data.record + 1

   // total   SA 06.06.88
m.nm.total.displayed = m.nm.areal.data.offset + 1   //flag
m.nm.total           = m.nm.total.displayed + 1     //value  3 words
m.nm.mask.black.sqrs = m.nm.total + 3     //flag for masking out grid squares
                                          //plotted in black.  SA 09.06.88


// GENERAL PURPOSE WORK AREA FOR USE BY ONE OPERATION AT A TIME

m.nm.gen.purp = m.nm.mask.black.sqrs + 1

   // size of global static area g.nm.s
m.nm.global.statics.size = m.nm.gen.purp + 55  //increased for RANK 19.01.88 MH

$)
