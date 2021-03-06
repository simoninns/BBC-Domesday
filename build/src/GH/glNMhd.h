// /**
//       GLNMHDR - GLOBALS HEADER for NM
//       -------------------------------
//
//       This is the master system Global definition file
//       Reserved for mappable routine globals
//       and data areas
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       29/09/86 7        DRF         FG+364-399 grabbed,
//                                     FG+54, 66, 67 grabbed from
//                                        glst2hdr;
//                                     G.nm.goto.text,
//                                     G.nm.return.from.text,
//                                     G.nm.check.summary.data,
//                                     G.nm.auto.ermess,
//                                     G.nm.plot.fine.block,
//                                     G.nm.square.colour
//                                        added
//                                     G.nm.get.areal.unit
//                                        replaced by
//                                        g.nm.build.areal.units
//                                     G.nm.calc.correlation
//                                        added
//                                     G.nm.running.status added
//       ********************************
//       25.6.87     8     DNH      CHANGES FOR UNI
//       3.7.87      9     DNH      ...int3... -> g.nm.int48.to.fp
//       ********************************
//       07.06.88    10    SA       CHANGES FOR COUNTRYSIDE
//                                  added total function
// **/

      //   STATE MACHINE GLOBALS

GLOBAL $(

G.nm.map       :FGNM+1   // start of mappable action routines
G.nm.analyse   :FGNM+2
G.nm.to.detail :FGNM+3   // ini routine
G.nm.resolution:FGNM+4
G.nm.areas     :FGNM+5
G.nm.class     :FGNM+6
G.nm.manual    :FGNM+7
G.nm.comp.to.map.ini :FGNM+8 // ini routine
G.nm.auto.opt    :FGNM+9
G.nm.retrieve    :FGNM+10
G.nm.compare     :FGNM+11
G.nm.map.to.com  :FGNM+12  // mappable data initialisation routines
G.nm.anal.to.clas:FGNM+13
G.nm.anal.to.ret :FGNM+14
G.nm.to.anal     :FGNM+15
G.nm.to.res      :FGNM+16
G.nm.to.areas    :FGNM+17
G.nm.to.map      :FGNM+18
G.nm.clas.to.man :FGNM+19
G.nm.to.auto     :FGNM+20
G.nm.up.to.class :FGNM+21
G.nm.man.to.man  :FGNM+22
G.nm.to.equal    :FGNM+23
G.nm.to.nested   :FGNM+24
G.nm.to.quantile :FGNM+25
G.nm.man.to.auto :FGNM+26
G.nm.ret.to.write:FGNM+27
G.nm.to.link.ini  :FGNM+28
G.nm.to.correl.ini:FGNM+29
G.nm.to.name.ini  :FGNM+30

      //    data areas

G.nm.child.ovly  :FGNM+31 // NM child overlay bay
G.nm.areal.map   :FGNM+32 // areal vector bitmap

G.nm.s           :FGNM+33 // national map statics area

// NB: the following two global definitions are duplicated in NN.a.classify,
//     the assembler module; any changes must be made to both files
G.nm.class.colour:FGNM+34 // vector of class colours (words)
G.nm.class.upb   :FGNM+35 // vector of upper bounds for classes (double words)

G.nm.values      :FGNM+36 // unpacked values for fine block (double words)
G.nm.areal       :FGNM+37 // areal unit values (double words)
G.nm.frame       :FGNM+38 // buffer for frame of packed data

G.nm.coarse.index.record   :FGNM+39 // index of coarse record numbers
G.nm.coarse.index.offset   :FGNM+40 // index of coarse offsets


      //    private routines


      // NM.MAP

g.nm.restore.message.area  :FGNM+41
g.nm.map.ini               :FGNM+42
g.nm.toggle.video.mode     :FGNM+43
g.nm.top.menu              :FGNM+44
g.nm.goto.text             :FGNM+45
g.nm.return.from.text      :FGNM+46

      // NM.DISPLAY1

g.nm.init.display          :FGNM+47
g.nm.pick.initial.subset   :FGNM+48

      // NM.DISPLAY2

g.nm.display.variable   :FGNM+49


      // NM.PROCESS

g.nm.init.processor     :FGNM+50
g.nm.process.variable   :FGNM+51
g.nm.convert.refs.to.km :FGNM+52


      // NM.UNPACK

g.nm.init.values.buffer :FGNM+53
g.nm.unpack.fine.block  :FGNM+54
g.nm.unpack32           :FGNM+55



      // NM.LOAD1

g.nm.load.dataset.header:FGNM+56
g.nm.load.coarse.index  :FGNM+57
g.nm.load.fine.index    :FGNM+58
g.nm.get.size4.value    :FGNM+59
g.nm.skip.fields        :FGNM+60

      // NM.LOAD2

g.nm.load.raster.sub.dataset  :FGNM+61
g.nm.load.areal.sub.dataset   :FGNM+62
g.nm.load.areal.data          :FGNM+63

// (some spares)

      // NM.FRAME

g.nm.init.frame.buffer     :FGNM+70
g.nm.current.frame.number  :FGNM+71
g.nm.inc.frame.ptr         :FGNM+72
g.nm.read.frame            :FGNM+73


      // NM.UTILS

g.nm.dual.data.type     :FGNM+74
g.nm.widen              :FGNM+75
g.nm.min                :FGNM+76
g.nm.max                :FGNM+77
g.nm.set.map.entry      :FGNM+78
g.nm.apply.areal.map    :FGNM+79
g.nm.map.hit            :FGNM+80
g.nm.bad.data           :FGNM+81
g.nm.set.plot.window    :FGNM+82
g.nm.unset.plot.window  :FGNM+83
g.nm.position.videodisc :FGNM+84
g.nm.load.child         :FGNM+85

      // NM.UTILS2

g.nm.load.dataset       :FGNM+86
g.nm.replot             :FGNM+87
g.nm.restore.areal.vector :FGNM+88
g.nm.save.screen        :FGNM+89
g.nm.restore.screen     :FGNM+90
g.nm.id.grid.pos        :FGNM+91
g.nm.running.status     :FGNM+92

      // NM.KEY

g.nm.check.class.intervals :FGNM+93
g.nm.shuffle.key           :FGNM+94
g.nm.init.classes          :FGNM+95
g.nm.init.class.colours    :FGNM+96
g.nm.display.key           :FGNM+97
g.nm.display.box           :FGNM+98
g.nm.display.link.key      :FGNM+99


      // NM.SUBSETS

g.nm.num.of.subsets        :FGNM+100
g.nm.look.for.subset       :FGNM+101
g.nm.find.subset           :FGNM+102

// (some spares)

      // cnmMANU

g.nm.string.to.num         :FGNM+110
g.nm.disable.entry.mode    :FGNM+111


      // cnmAUTO

g.nm.check.summary.data    :FGNM+112
g.nm.auto.ermess           :FGNM+113
g.nm.nested.colours        :FGNM+114


      // cnmRETR

g.nm.unit                  :FGNM+115
g.nm.gridref               :FGNM+116
g.nm.sum                   :FGNM+117
g.nm.value.func            :FGNM+118
g.nm.to.write              :FGNM+119
g.nm.write                 :FGNM+120
g.nm.retrieve.values       :FGNM+121
g.nm.write.data            :FGNM+122


      // cnmWIND

g.nm.window.variable       :FGNM+123


      // cnmCOMP

g.nm.compare.sub.op        :FGNM+124
g.nm.check.compare.options :FGNM+125
g.nm.link.handler          :FGNM+126
g.nm.correlate.handler     :FGNM+127
g.nm.calc.correlation      :FGNM+128
g.nm.name.handler          :FGNM+129
g.nm.save.context          :FGNM+130
g.nm.restore.context       :FGNM+131

// (some spares)

      // LIBRARY ROUTINES

g.nm.sort               :FGNM+140
g.nm.plot.block         :FGNM+141
g.nm.plot.fine.block    :FGNM+142

g.nm.square.colour      :FGNM+143 // NB: assembler routine; global is
                                  //     duplicated in NN.a.classify and
                                  //     any change must be made to both
                                  //     files

g.nm.mpadd              :FGNM+144
g.nm.mpdiv              :FGNM+145
g.nm.mpdisp             :FGNM+146
g.nm.calc.mapping       :FGNM+147
g.nm.au.usable          :FGNM+148
g.nm.build.areal.units  :FGNM+149
g.nm.res.usable         :FGNM+150
g.nm.get.area.name         :FGNM+151
g.nm.rank.data             :FGNM+152
g.nm.sort.rank             :FGNM+153
g.nm.calc.tie.correction   :FGNM+154
g.nm.int48.to.fp           :FGNM+155
g.nm.fpwrite               :FGNM+156


      // ROUTINES FOR DEVELOPMENT ONLY

g.nm.debug.set.data.fs     :FGNM+157
g.nm.debug.restore.fs      :FGNM+158

g.nm.total                 :FGNM+159   //total function in cnmWIND  SA 07.06.88
$)

//  +++  The End  +++
