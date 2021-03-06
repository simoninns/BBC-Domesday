// /**
//       H.CM2HDR - COMMUNITY MAP 2ND HEADER
//       -----------------------------------
//
//       Definitions for: direction interpretation of screen
//       positions; menu bar offsets; move & zoom graphics;
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//        6. 3.86    1      DNH        Initial version
//       11. 3.86    2      DNH        move & zoom graphics
//  ***************************************
//       30.4.87   15      DNH      UNI version
// **/

manifest
$(
         // display interpretation stuff for mapwalking
// directions
m.invalid = -1
m.beep = 0
m.n = 1
m.s = 2
m.e = 4
m.w = 8
m.ne = m.n | m.e
m.nw = m.n | m.w
m.se = m.s | m.e
m.sw = m.s | m.w
m.up   = 16
m.down = 32

// more directions for photo sequences of the Map Key
m.first = 1
m.previous = 2
m.next = 3

// coordinates and screen values
m.tope = m.sd.disw - 1     // max display position to right
m.topn = m.sd.dish - 1     // ...and to top of screen
m.mide = m.tope / 2
m.midn = m.topn / 2
m.dve  = m.tope / 3        // ADJUST
m.dvn  = m.topn / 5        //       THESE
m.dse  = m.tope / 5        //            LATER
m.dsn  = m.topn / 3        //                 (if necessary)

         // useful values for mapwalking Graphics
m.cm.frame.steps = 8
m.cm.frame.pause = 5          // centiseconds
//  m.cm.frame.end.pause = 200      DEFUNCT
m.cm.arrow.steps = 6       // six for each half of the move
m.cm.arrow.pause = 6
$)
