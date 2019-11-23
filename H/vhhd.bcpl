// /**
//       vh.h.vhhdr - Global Manifests for Video Handler
//       -----------------------------------------------
//
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR      DETAILS OF CHANGE
//       14.11.85 1        D.Hepper    Initial version
//       17.1.86  2        DNH         trap limits in
//       12.2.86  3        DNH         modes for play gone;
//                                     video values changed
//       10.3.86  4        DNH         disc side values in
//       20.3.86  5        DNH         values for g.vh.poll
//       24/04/86 6        JIBC        mod to g.vh.poll after PHILIPS
//       25.4.86  7        DNH         video on/off modes in
//       01.05.86 8        PAC         add VH.VIDEO "VPX" command
//       30.05.86 9        PAC         add G.VH.STEP stopcode
//       27.6.86  10       DNH         min.lv.mode to '1'
//       ********************************
//       29.4.87  11       DNH      UNI CHANGES
//                                  poll.buf.words defin.
// **/


manifest
$(

// for g.vh.video       there may be more of these
m.vh.lv.only     = '1'  // VP1
m.vh.micro.only  = '2'  // VP2
m.vh.superimpose = '3'  // VP3
m.vh.transparent = '4'  // VP4
m.vh.highlight   = '5'  // VP5
m.vh.inquire     = 'X'  // VPX

m.vh.video.off   = '8'  // FCODE E0
m.vh.video.on    = '9'  // FCODE E1

m.vh.min.lv.mode = '1'        // these must be kept up to date,
m.vh.max.lv.mode = 'X'        //  they are trap limits.

// for g.vh.step
m.vh.stop = 0  // freeze current video during a play

// for g.vh.audio
m.vh.no.channel    = '0'        // ie. switch sound off
m.vh.right.channel = '1'
m.vh.left.channel  = '2'
m.vh.both.channels = '3'

// for g.vh.poll
m.vh.poll.buf.words = 10/BYTESPERWORD+1  // necessary for ALL calls to poll

// modes for g.vh.poll  (the actual characters for the fcode string)
m.vh.frame.poll = 'F'
m.vh.chapter.poll = 'C'
m.vh.player.status.poll = 'P'
m.vh.read.reply = '@'

// general results from g.vh.poll
m.vh.finished   = 1        // Ax or AN (posative or negative acknowledge)

m.vh.bad.filing.system = -1
m.vh.bad.mode   = -2
m.vh.bad.result = -3
m.vh.missing    = -4       // frame or chapter not found: 'X' was returned
m.vh.lid.open   = -5
m.vh.unfinished = -6       // reply from player null (e.g. still playing)

// result codes from g.vh.poll (m.vh.player.status.poll)
m.vh.not.ready = #X00       // neither bit set
m.vh.CAV       = #X01       // active play disc
m.vh.CLV       = #X02       // long play disc

// bit for testing whether disc ready. Never returned by g.vh.poll.
m.vh.N.mode    = #X20

// If people wish to test other bits in the actual returned
// bytes they should put manifests in below here.
$)
