// /**
//       GLHDR - GLOBALS HEADER
//       ----------------------
//
//       This is the master system Global definition file
//       Every module should "get " this header file to ensure no
//       clashes of global variables. No globals may be declared
//       anywhere else in the system, apart from the overlay
//       globals files glCMhdr, glNFhdr etc.
//
//       Changes made for the UNIfied code system 24.4.87
//
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR   DETAILS OF CHANGE
//       23.4.87           PAC      ADOPTED FOR UNI SYSTEM
//       30.4.87     2     DNH      add g.ut.diag etc
//       1.5.87      3     DNH      g.he.exit -> g.ov.helpexit
//       27.5.87     4     PAC      De-overlay globals for AES
//        9.6.87     5     PAC      Updates from UNI
//       11.6.87     6     PAC      Update package globals
//       17.6.87     7     PAC      Update NP globals
//       23.7.87     8     PAC      New mouse global
//       03.12.87    9     MH       3 new globals added to glCMhd
//
//       04.12.87   10     MH       G.nw.showframe. added
//       15.12.87   11     MH       G.context increased in size for 
//                                  m.itemh.level
//       16.12.87   12     MH       m.hie.ptr added for type and hierarchy
//                                  records
//       21.12.87   13     MH       m.video.mode added to G.context at postion
//                                  61 which was unused at the time.
// **/

$$DEBUG    // SYSTEM WIDE DEBUG FLAG FOR CONDITIONAL COMPILATION
$$FLOPPY   // THIS TAG CONTROLS THE LOAD OF 'WORDS' & OVERLAYS FROM ADFS

MANIFEST $(
FG=FIRSTFREEGLOBAL

//  OFFSETs for G.Context

m.state     = 0  // Current state
m.laststate = 1  // Previous state
m.discid    = 2  // Videodisc identifier
m.stackptr  = 3  // stack pointer for exit stack
m.leveltype = 4  // level and type, see On Disc Data Structures
m.grbleast  = 5  // grid ref, bottom left Easting
m.grblnorth = 6  // grid ref, bottom left Northing
m.grtreast  = 7  // grid ref, top right Easting
m.grtrnorth = 8  // grid ref, top right Northing
m.frame.no  = 9  // video disc frame number
m.page.no   =10  // page number for essays
m.picture.no=11  // picture number for picture sets
m.areal.unit=12  // current areal unit, 0 implies grid square data
m.resolution=13  // 1-10km resolution of dataset,
// gap where itemname used to be...

m.itemrecord=16  // current record from item names file
                 // 36 bytes long: 1st 31 bytes = item name string;
                 // %31 is item type; %32-%35 is itemaddress
                 // hierarchy pointer is %36-%39
m.itemtypeoff = m.itemrecord*bytesperword + 31    // byte offset
m.itemaddress = m.itemrecord + 32/bytesperword    // word offset
m.itemh.level = m.itemrecord + 36/bytesperword    
                                      // hierarchy pointer 15.12.87 MH

m.flags      =36 // flags for general use, esp. menu bar config for CFind
m.underlay.frame.no= 37 // Current Underlay map frame number
// gap where hierarchy stuff was...   (36,37,38)
m.maxstates  =41 // number of states in state table
m.justselected=42// flag if pending state change used
m.maprecord  =43 // map record for community disc
m.exitstack  =44 // Stack of exits from special state changes
                 // i.e HELP, Forced AREA and ITEM examination
m.constack   = 4 // Size of context exit stack - n.b. no extra space now

// gap where hierarchy stuff was...  (48, 49)
m.itemselected=50 // item examination entry flag

m.xpos = 51      // used by G.SC.INPUT - xpos of box start
m.curpos = 52    // ditto - pos of cursor along string
m.map.no = 53    // Frame number of current map
m.name.AOI = 54  // Code from Gazetteer
m.type.AOI = 55  // ditto

m.itemadd2   = 56 // item addresses for chained essays
m.itemadd3   = 58
m.hie.ptr    = 60 //vector pointer for hierarchy and type records 16.12.87 MH
m.video.mode = 61
m.contextsize= 61 // Size of this area at getvec parameter

// offsets from g.menubar
// these contain the box status (active,inactive,clear,etc.)
m.box1 =0  // menu bar box1...
m.box2 =1
m.box3 =2
m.box4 =3
m.box5 =4
m.box6 =5
m.menubarsize = 5 // Size of this area as getvec parameter

// results from g.ut.cmp32
// BEWARE ***  these are duplicated in UT.a.calc32 and
// in NN assembler somewhere
m.lt = -1   // a < b
m.eq =  0   // a = b
m.gt =  1   // a > b

$)

GLOBAL $(

//******* state tables *********

G.stover        :FG+0    // name of overlay
G.stactr        :FG+1    // action routine for current state
G.sttran        :FG+2    // 'next state' table
G.stinit        :FG+3    // initialisation routine to call
G.stmenu        :FG+4    // menu bar words and box sizes
G.stDYinit      :FG+5    // spare vector - use in the ARM
G.stDYfree      :FG+6    //           ditto

//******* system data areas *********

G.menuwords     :FG+7    // array of menu words
G.menubar       :FG+8    // pointer to menu bar box data
G.menuon        :FG+9    // menu bar status (true=on/false=off)
G.redraw        :FG+10   // redraw menu bar flag (true=redraw)
G.screen        :FG+11   // co-ord system (menu,display or message)
G.key           :FG+12   // last keypress
G.Xpoint        :FG+13   // last X position
G.Ypoint        :FG+14   // last Y position
G.Context       :FG+15   // pointer to context data area

//******* top level control *********

G.dy.Init       :FG+16   // Dynamic routines, redefine for specific states
G.dy.Free       :FG+17
G.dy.action     :FG+18

G.ov.helpexit   :FG+19
G.ov.unload     :FG+20
G.ov.load       :FG+21
G.ov.exit       :FG+22   // Exit routine for special exits,
                         // must be in Root

//******* primitives *********

G.dh.close           :FG+23
G.dh.length          :FG+24
G.dh.fstype          :FG+25
G.dh.open            :FG+26
G.dh.read            :FG+27
G.dh.readframes      :FG+28
G.dh.reset           :FG+29
G.dh.discid          :FG+30   // Disc side detect
G.dh.SCSI.error      :FG+31   // get last SCSI error from LV-DOS
G.dh.select.disc     :FG+32   // eject disc and initialise another

G.sc.spacing         :FG+33  // pointer to proportional spacing lookup table
G.sc.addspace        :FG+34  // flag for opage. THIS IS DATA !

G.sc.getact          :FG+35 // get user's action
G.sc.mouse           :FG+36 // mouse handler
G.sc.moveptr         :FG+37 // move mouse pointer
G.sc.pointer         :FG+38 // turn mouse pointer on/off

G.sc.btod            :FG+39  // BBC->Domesday co-ords
G.sc.dtob            :FG+40  // Domesday->BBC co-ords
G.sc.mode            :FG+41  // set screen mode
G.sc.findmode        :FG+42     // inquire screen mode
G.sc.movea           :FG+43 // move absolute
G.sc.mover           :FG+44 // move relative
G.sc.linea           :FG+45 // draw line absolute
G.sc.liner           :FG+46 // draw line relative
G.sc.rect            :FG+47 // filled rectangle
G.sc.clear           :FG+48 // clear selected screen area
G.sc.sec             :FG+49 // sector (pie slice)
G.sc.triangle        :FG+50 // draw a filled triangle
G.sc.parallel        :FG+51 // draw a parallelogram
G.sc.savcur          :FG+52 // save cursor position
G.sc.rescur          :FG+53 // restore cursor position
G.sc.oprop           :FG+54 // output string proportionally spaced
G.sc.width           :FG+55 // inquire width of PS string
G.sc.ofstr           :FG+56 // output string with formatting
G.sc.odrop           :FG+57 // output text with drop shadow
G.sc.pixcol          :FG+58 // inquire pixel colour (POINT)
G.sc.palette         :FG+59 // change a single palette colour
G.sc.setpal          :FG+60 // set palette to a predefined mix
G.sc.selcol          :FG+61 // select a colour
G.sc.XOR.selcol      :FG+62 // select colour in XOR mode
G.sc.physical.colour :FG+63
G.sc.complement.colour:FG+64
G.sc.next.colour     :FG+65
G.sc.opage           :FG+66 // output text page with highlighting
G.sc.menu            :FG+67 // draw a menu bar
G.sc.input           :FG+68 // text input primitive
G.sc.opnum           :FG+69 // output a real number
G.sc.oplist          :FG+70 // output list item
G.sc.high            :FG+71 // highlight item number
G.sc.2high           :FG+72 // extra highlight for CT
G.sc.setfont         :FG+73 // special font for community text
G.sc.mess            :FG+74 // output a message
G.sc.ermess          :FG+75 // output an error message
G.sc.cachemess       :FG+76 // cache/restore message area
G.sc.icon            :FG+77 // display icon
G.sc.beep            :FG+78 // make a beep
G.sc.defwin          :FG+79 // select default graphics window
G.sc.setwin          :FG+80 // set a graphics window
G.sc.keyboard.flush  :FG+81 // flush the keyboard buffer

// n.b. for the ARM, these globals can be anywhere
//
G.ut.add32           :FG+82  // 32 bit addition
G.ut.sub32           :FG+83  // 32 bit subtraction
G.ut.mul32           :FG+84  // multiply
G.ut.div32           :FG+85  // divide
G.ut.cmp32           :FG+86  // compare

G.ut.sequence.no     :FG+87  // file sequence no. for WRITE - data
G.ut.stream          :FG+88  // file handle for WRITE       - data

G.ut.get.ermess      :FG+89  // get error message text from IO processor
G.ut.save.mark       :FG+90  // load and ...
G.ut.load.mark       :FG+91  // ... save bookmark.
G.ut.videodisc.error :FG+92  // handle fatal error from disc
G.ut.abort           :FG+93  // file handle for trap to write to
G.ut.trap            :FG+94  // trap invalid parameter
G.ut.cache           :FG+95  // save and restore data to IO processor
G.ut.restore         :FG+96  // sideways RAM
// G.ut.srmove          :FG+97  // SRAM move block operation
G.ut.copy.screen     :FG+98  // shadow screen copying
G.ut.print           :FG+99  // print a line
G.ut.wait            :FG+100 // delay routine
G.ut.printingchar    :FG+101 // test for printable char
G.ut.write           :FG+102 // used for the WRITE primitive
G.ut.open.file       :FG+103 // ditto
G.ut.close.file      :FG+104 // ditto
G.ut.do.32.line      :FG+105 // special access to Write conversion
                             // routine for NM
G.ut.grid.region      :FG+106
G.ut.grid.eight.digits:FG+107
G.ut.grid.mixed       :FG+108
G.ut.grid.letter.code :FG+109
G.ut.grid.to.string   :FG+110
G.ut.grid.trim        :FG+111

G.ut.set32           :FG+112  // new utilities for UNI system
G.ut.get32           :FG+113
G.ut.mov32           :FG+114
G.ut.align           :FG+115
G.ut.movebytes       :FG+116
G.ut.unpack16        :FG+117
G.ut.unpack16.signed :FG+118
G.ut.diag            :FG+119
G.ut.send.to.OS      :FG+120
G.ut.set.text.window :FG+121
G.ut.unpack32        :FG+122

// specially for NM: separate link
G.ut.set48           :FG+123
G.ut.get48           :FG+124
G.ut.mov48           :FG+125


G.vh.frame           :FG+131
G.vh.video           :FG+132
G.vh.play            :FG+133
G.vh.goto            :FG+134
G.vh.reset           :FG+135
G.vh.audio           :FG+136
G.vh.send.fcode      :FG+137
G.vh.word.asc        :FG+138 // conversion routine
G.vh.step            :FG+139 // *STEP command - pause player
G.vh.call.oscli      :FG+140 // send a command to operating system
G.vh.poll            :FG+141 // player status poll


// THESE SHOULD NOT BE HERE !!!!  ****
G.overbay            :FG+142
G.CacheVec           :FG+143
// spare             :FG+144
G.ov.general         :FG+145
G.ov.boot            :FG+146
G.ov.setup.sram      :FG+147

// NOR SHOULD THESE  ****
G.sc.ecf             :FG+148
G.sc.blob            :FG+149
G.sc.dot             :FG+150
G.sc.char90          :FG+151
G.sc.initialise.mouse:FG+152
G.sc.sprite.area     :FG+153

// spare globals area - up to 160 at present (change FOG)
$)

MANIFEST
$(
   // UN-overlaid globals start here
   // to OVERLAY these globals, simply change the offsets
   // to zero.

   FOG  = FG + 160
   FGDY = FOG         // dy.inits   - size is 27 words + 3 spare
   FGCF = FOG  + 30   // CF globals - size is 23
   FGCM = FGCF + 23   // CM globals - size is 67
   FGCP = FGCM + 67   // CP globals - size is 42
   FGNA = FGCP + 42   // NA globals - size is 8
   FGNC = FGNA + 8    // NC globals - size is 25
   FGNE = FGNC + 25   // NE globals - size is 9
   FGNF = FGNE + 9    // NF globals - size is 16
   FGNM = FGNF + 16   // NM globals - size is 170
   FGNP = FGNM + 170  // NP globals - size is 13
   FGNT = FGNP + 13   // NT globals - size is 21
   FGNV = FGNT + 21   // NV globals - size is 5
   FGNW = FGNV + 5    // NW globals - size is 12
   FGHE = FGNW + 12   // HE globals - size is 27
   last.of.the.globals = FGHE + 27
   // ...that makes a total of 394 globals here
$)

GLOBAL $( G.Dummy   :last.of.the.globals 
          // virtual keyboard - SC
          G.sc.virtual.key     :last.of.the.globals+1
          G.sc.setup.vk        :last.of.the.globals+2
          G.sc.vkey.board      :last.of.the.globals+3
          G.sc.vk.area         :last.of.the.globals+4
          G.nf.writerest.      :last.of.the.globals+5
          G.nf.selectitem.     :last.of.the.globals+6
          G.dh.read.names.rec  :last.of.the.globals+7
          G.dh.read.type       :last.of.the.globals+8
          G.dh.read.thes.rec   :last.of.the.globals+9
          G.nf.extractfiles    :last.of.the.globals+10
          G.ut.mark.r          :last.of.the.globals+11
          G.ut.mark.w          :last.of.the.globals+12
          G.ud.open            :last.of.the.globals+13
          G.ud.read            :last.of.the.globals+14
          G.ud.open.file       :last.of.the.globals+15
          G.ud.close.file      :last.of.the.globals+16
          G.ud.write           :last.of.the.globals+17
          G.ud.do.32.line      :last.of.the.globals+18
          G.dh.delete.file     :last.of.the.globals+19
          G.sc.narrow          :last.of.the.globals+20
          G.sc.n.width         :last.of.the.globals+21
          G.nc.cats            :last.of.the.globals+22
          G.nc.pr              :last.of.the.globals+23
          G.nc.fpout           :last.of.the.globals+24
          G.nm.check.download  :last.of.the.globals+25
          G.ud.readframes      :last.of.the.globals+26
          G.nm.detail          :last.of.the.globals+27
          G.nm.automatic       :last.of.the.globals+28
          G.nm.rank            :last.of.the.globals+29
          G.nm.init.rank       :last.of.the.globals+30
          G.sc.TMAX            :last.of.the.globals+31
          G.nm.hinit.rank      :last.of.the.globals+32
          G.nm.sort.rankop     :last.of.the.globals+33
          G.nm.rank.page       :last.of.the.globals+34
       $)
//  Note must be highest global number
//  since is referenced in Kernel, and
//  so defines size of GLOBAL vector
//  If this global is changed, then a relink of
//  Kernel is necessary.

//   ***  The End  ***
