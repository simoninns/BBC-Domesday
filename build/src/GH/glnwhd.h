// /**
//       GLNWHDR - GLOBALS HEADER for National Walk
//       ------------------------------------------
//
//       This is a master system Global definition file
//       Reserved for state, routine and data globals
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       23.4.87  1        PAC      ADOPTED FOR UNI SYSTEM
//       10.12.87 2        MH       G.nw.showframe. added
// **/

GLOBAL
$(

G.nw.action      :FGNW+0  // walk/gallery
G.nw.action1     :FGNW+1  // 'plan' state
G.nw.init0       :FGNW+2  // from elsewhere
G.nw.init        :FGNW+3  // internal init
G.nw.init2       :FGNW+4  // walk ini routine
G.nw.action2     :FGNW+5  // action routine for walk (plan function)

G.nw.goleft      :FGNW+6  // walk utilities
G.nw.goright     :FGNW+7
G.nw.goforward   :FGNW+8
G.nw.goback      :FGNW+9
G.nw             :FGNW+10 // walk/gallery data area
G.nw.showframe.  :FGNW+11

$)

