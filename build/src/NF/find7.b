/**
         NF.FIND7 - OUTPUTS FIND'S RUNNING COUNTS ON THE SCREEN
         ------------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         13.5.86  1        M.F.Porter  Initial working version
         19.6.86  2        MFP         "gl4hd" & remove g.sc.pointer
        20.10.86  3        PAC         adjust wrn. display position
         ***********************************************
         9.6.87   4        MFP         RELEASED FOR UNI
         ***********************************************
         24.7.87  5        MH          RELEASED FOR PUK
**/


section "find7"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNFhd.h"
get "H/sdhd.h"

/**
          See CF.FIND7 for comments
**/

manifest $( c = m.sd.charwidth; h = m.sd.linw
            c2 = c*2; c3 = c*3; c4 = c*4
            x1 = m.sd.disXtex+24*c
            y1 = m.sd.disYtex-17*h
            x2 = m.sd.disXtex+24*c
            y2 = m.sd.disYtex-19*h
         $)

let wrn.(n, x, y, xi, eta, s) be
$(  // g.sc.pointer(m.sd.off)  - removed 19.6.86
    g.sc.movea(m.sd.display, x, y+4)
    g.sc.selcol(m.sd.cyan); g.sc.rect(m.sd.plot, xi, -eta)
    g.sc.movea(m.sd.display, x, y-4) // changed 20.10.86 PAC
    g.sc.selcol(m.sd.blue); g.sc.ofstr(s, n)
    // g.sc.pointer(m.sd.on)
$)

let g.nf.writepc(n) be
$(
    static $( oldn = 0 $)
    test n > 0 & n/10 = oldn/10 then wrn.(n rem 10, x1+c2, y1, c, h, "%N")
                                  or wrn.(n, x1, y1, c4, h, "%I3%%")
    oldn := n
$)

let g.nf.writepm(n) be
$(
    static $( oldn = 0 $)
    if n = 101 do n := 100
    test n > 0 & n/10 = oldn/10 then wrn.(n rem 10, x2+c2, y2, c, h, "%N")
                                  or wrn.(n, x2, y2, c4, h, "%I3")
    oldn := n
$)





