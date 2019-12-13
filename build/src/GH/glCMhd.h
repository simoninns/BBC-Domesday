// /**
//       GLCMHDR - GLOBALS HEADER for Community Map
//       ------------------------------------------
//
//       This is a master system Global definition file
//       Reserved for state, routine and data globals
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       23.4.87  1        PAC      ADOPTED FOR UNI SYSTEM
//       03.12.87 2        MH       CO globals updated for map measure opertion
// **/


GLOBAL
$(

G.cm.Mapwal                :FGCM+0
G.cm.Mapini                :FGCM+1
G.cm.Mapopt                :FGCM+2
G.cm.Optini                :FGCM+3
G.cm.Mapsca                :FGCM+4
G.cm.Scaini                :FGCM+5
G.cm.Mapkey                :FGCM+6
G.cm.Keyini                :FGCM+7
G.cm.unitsini              :FGCM+8

G.cm.mapini2               :FGCM+9
G.cm.mapini.special        :FGCM+10

// private globals for mapwalking

G.cm.turn.over.setup       :FGCM+11
G.cm.turn.over.reply       :FGCM+12
G.cm.clear.cache           :FGCM+13
G.cm.highlight.level0      :FGCM+14
G.cm.direction             :FGCM+15
G.cm.a.of                  :FGCM+16
G.cm.b.of                  :FGCM+17
G.cm.testbit               :FGCM+18
G.cm.intof                 :FGCM+19
G.cm.wordsfor              :FGCM+20
G.cm.findmaprec            :FGCM+21
G.cm.showframe             :FGCM+22
G.cm.showmap               :FGCM+23
G.cm.debugmess             :FGCM+24
G.cm.collapse              :FGCM+25
G.cm.drawboxes             :FGCM+26
G.cm.drawbox               :FGCM+27
G.cm.box                   :FGCM+28
G.cm.moving.arrow          :FGCM+29
G.cm.sel.fs                :FGCM+30
G.cm.parentof              :FGCM+31
G.cm.otherpars             :FGCM+32
G.cm.mapinfo               :FGCM+33
G.cm.submapinfo            :FGCM+34
G.cm.submap                :FGCM+35
G.cm.subi                  :FGCM+36
G.cm.mof                   :FGCM+37
G.cm.nof                   :FGCM+38
G.cm.transmapno            :FGCM+39
G.cm.go                    :FGCM+40
G.cm.up                    :FGCM+41
G.cm.down                  :FGCM+42
G.cm.update.globals        :FGCM+43
G.cm.grid.system           :FGCM+44
G.cm.expand.frame.from     :FGCM+45
G.cm.shrink.frame.to       :FGCM+46
G.cm.clear.yellow.border   :FGCM+47
G.cm.mwidth                :FGCM+48
G.cm.mheight               :FGCM+49
G.cm.pwidth                :FGCM+50
G.cm.cmpw                  :FGCM+51
G.cm.show.grid.banner      :FGCM+52
G.cm.show.grid.ref         :FGCM+53

// statics for Map

G.cm.s                     :FGCM+54

// routines in map options

G.co.show.value            :FGCM+55
G.co.show.units            :FGCM+56
G.co.fx.to.32              :FGCM+57
G.co.store.point           :FGCM+58
G.co.unstore.point         :FGCM+59
G.co.calculate.distance    :FGCM+60
G.co.calculate.area        :FGCM+61
G.co.area.complete         :FGCM+62
G.co.options.clear         :FGCM+63
//Added 03.12.87 for update to map measure MH
G.co.draw.lines            :FGCM+64
G.co.band.line.to          :FGCM+65
G.co.clip.line             :FGCM+66

$)

