//  AES SOURCE  6.87

/**
         NATPHO1 - NATIONAL PHOTO
         -------------------------

         Action routine for National Photo

         NAME OF FILE CONTAINING RUNNABLE CODE:
         r.photo

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
          1.7.86  9        SRY      Fix to #7
          7.8.86 10        SRY      Print warning fix
         18.9.86 11        SRY      Index page bug/video on @print
*******************************************************************************
      All changes after this point are not on the Domesday Discs
*******************************************************************************
         24.3.87 12        SRY      Fix highlight going into index when
                                    cursor hasn't moved
         10.6.87     13    DNH      CHANGES FOR UNI
         31.7.87     14    PAC      Fix initial caption bug
                                    and blank box bug
         04.12.87    15    MH       Arcimedes update for photo sets
**/

SECTION "Natpho1"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNPhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/vhhd.h"
get "H/nphd.h"

/**
         proc G.NP.PHOTO ()
              ----------

         Specific action routine for photo

         PROGRAM DESIGN LANGUAGE:

         g.np.photo []
         -------------

         <Handle initial case>

         if state just selected
         then call initialise routine
         else if just back from help
              then Strip top bit from local.state
                   if state not index then switch video on ENDIF
              ENDIF
         ENDIF

         <Handle forward/backwards move>

         local key := g.key

         if local key = change and g.screen = display
          then if g.Xpoint < display width/3
                then local key = Function 7
                else if g.xpoint > 2/3 * display width
                      then local key = Function 8
                      else beep
                     ENDIF
               ENDIF
         ENDIF

         <Handle index selection>

         if local state = index then
            highlight current index entry if valid
            if local key = ACTION and g.screen = display
            then if valid selection
                 then Fill in boxes 3, 4, 5 from default menubar for photo
                      if <= 100 photos
                      then Put 'Index' in box 6
                      ENDIF
                      Clear screen
                      Enable video output
                      Select yellow
                      Display picture selected
                      Display short caption if not first picture
                      local state = photo
                 ENDIF
            ENDIF
         ENDIF

         <Take action depending on keypress>

         CASE OF local key
            Function 3 : if long caption displayed
                           then clear long caption
                                "Description" -> box 3
                           else display long caption
                                "Clear" -> box 3
                                "Caption" -> box 4
                         ENDIF
            Function 4 : if short caption displayed
                           then clear short caption
                                "Caption" -> box 4
                           else display caption
                                "Clear" -> box 4
                                "Description" -> box 3
                         ENDIF
            Function 5 : Print the screen
            Function 6 : Blank boxes 3, 4, 5, 6
                         Clear screen
                         Disable video
                         Select cyan
                         Display first page of index
                         local state = index
            Function 7 : page backwards
                         if short caption displayed
                         then if picture not first
                              then display (new) short caption
                              else clear caption
            Function 8 : page forwards
                         if short caption displayed
                         then display (new) short caption
         ENDCASE

         if menu bar needs redrawing
            then redraw menu bar
         ENDIF
**/

let g.np.photo () be
$(
   let b.s = g.np.s + m.np.box1

   unless g.key = m.kd.noact do
      g.sc.pointer (m.sd.off)

   if g.context!m.justselected do   // catch this before unmute test
   $(
      g.np.phoini ()
      find.picture ()
      unless g.context!m.picture.no = 1 do
         s.c (m.np.screen)     // fix 31.7.87 PAC
   $)

   if g.np.s!m.np.vrestore do       // unmute video after Help
      G.np.show.picture ()

   // map Change to Previous/Next
   if g.key = m.kd.change & g.screen = m.sd.display then
      test g.Xpoint < m.np.LHS then
         g.key := m.kd.Fkey7
      else
         test g.xpoint > m.np.RHS then
            g.key := m.kd.Fkey8
         else
            g.sc.beep ()

   if g.np.s!m.np.local.state = m.np.index do
   $(
      g.context!m.picture.no := highlight ()

      if g.key = m.kd.action & g.screen = m.sd.display &
         g.context!m.picture.no ~= m.sd.hinvalid do
      $(
         g.sc.clear (m.sd.display)
         g.sc.selcol (m.sd.yellow)
         g.np.s!m.np.local.state := m.np.photo

         find.picture ()

         test g.context!m.picture.no = 1 then
            G.np.show.picture ()
         else
         $( G.np.show.picture()
            b.s!m.box3 := m.sd.act     // Descr.
            b.s!m.box4 := m.sd.wClear  // Caption - fixed: was Blank !!
            b.s!m.box5 := m.sd.act     // Print      PAC 31.7.87
            s.c (m.np.screen)
         $)

         if g.np.s!m.np.npics <= m.np.max.shorts do
            b.s!m.box6 := m.sd.act

         g.vh.video (m.vh.superimpose)    // enable the video
      $)
   $)

   SWITCHON g.key INTO
   $(
      CASE m.kd.Fkey3 :          // Description/Clear
         c.c ()
         test g.menubar!m.box3 = m.sd.wClear then
            b.s!m.box3 := m.sd.act
         else
         $(
            l.c (m.np.screen)
            b.s!m.box3 := m.sd.wClear
            b.s!m.box4 := m.sd.act
         $)
      ENDCASE

      CASE m.kd.Fkey4 :          // Caption/Clear
         c.c ()
         test g.menubar!m.box4 = m.sd.wClear then
            b.s!m.box4 := m.sd.act
         else
         $( 
            s.c (m.np.screen)
            b.s!m.box3 := m.sd.act
            b.s!m.box4 := m.sd.wClear
         $)
      ENDCASE

      CASE m.kd.Fkey5 :          // Print
         test g.menubar!m.box4 = m.sd.wClear then
            s.c (m.np.print)
         else
            if g.menubar!m.box3 = m.sd.wClear do
               l.c (m.np.print)
      ENDCASE

      CASE m.kd.Fkey6 :          // Index
         $(
            for j = m.box3 to m.box6 do
               b.s!j := m.sd.wBlank
            g.np.s!m.np.local.state := m.np.index
            g.vh.video (m.vh.micro.only)
            g.sc.high (0, 0, false, 100)
            display.index (1)
         $)
      ENDCASE

      CASE m.kd.Fkey7:
         if p.b () do
            do.screen (b.s)
      ENDCASE

      CASE m.kd.Fkey8:
         if p.f () do
            do.screen (b.s)
   $)

   if g.redraw | check.menu (b.s) do
      g.sc.menu (b.s)

   g.sc.pointer (m.sd.on)
$)


and do.screen (b.s) be
$(
   find.picture ()

   G.np.show.picture ()
   test b.s!m.box4 = m.sd.wClear then
      s.c (m.np.screen)
   else
      if b.s!m.box3 = m.sd.wClear then
         l.c (m.np.screen)
$)

       
and check.menu (b.s) = valof   // See if menu needs redrawing
$(
   for j = m.box1 to m.box6 do
      unless b.s!j = g.menubar!j RESULTIS TRUE
   RESULTIS FALSE
$)


and c.c () be   // Clear caption
$(
   g.sc.movea (m.sd.display, 0, 0)
   g.sc.rect (m.sd.clear, m.sd.disw, m.sd.linw*8)
$)


and s.c (type) be   // Display or print short caption
$(
   test g.context!m.picture.no <= m.np.max.shorts then
   $(
      let st = m.np.sclength * (g.context!m.picture.no-1)
      g.ut.movebytes (g.np.short.buff, st, g.np.tbuff, 1, m.np.sclength)
   $)
   else
   $(          // not got caption: do a special read
//      let fptr32 = vec 1

//      g.ut.set32 ( (g.context!m.picture.no-1) * m.np.sclength, 0, fptr32)
//      g.ut.add32 (g.np.s + m.np.short.start32, fptr32)

//      g.dh.read (g.np.s!m.np.file.handle, fptr32, g.np.rbuff, m.np.sclength)
      g.np.read.cap(g.np.rbuff, g.context!m.picture.no)
      g.ut.movebytes (g.np.rbuff, 0, g.np.tbuff, 1, m.np.sclength)
   $)

//   G.np.show.picture ()         // (no more reads to do)   not needed

   test type = m.np.screen then
   $(                      // string length is set up by 'centreit'
      g.sc.movea (m.sd.display, centreit (), m.np.scYpos)
      g.sc.odrop (g.np.tbuff)
   $)
   else
      if g.ut.print (TABLE 0) do
      $(
         g.np.tbuff%0 := m.np.sclength
         g.ut.print (g.np.tbuff)
      $)
$)


and centreit () = valof
$(
   let len = m.np.sclength
   while ( g.np.tbuff%len = 0 |              // discount trailing non-sig's
           g.np.tbuff%len = '*S' ) &
         ( len > 0 ) do                      // but with limit of 0 chars
      len := len - 1
   g.np.tbuff%0 := len
   RESULTIS ( m.sd.disW - g.sc.width (g.np.tbuff) ) / 2
$)


and l.c (type) be   // Display or print long caption
$(
   let fptr32 = vec 1
   let len32 = vec 1
   let bytes.per.lc = g.np.s!m.np.descr.siz * m.np.lclength

   // if printing, the long caption will already be in 'rbuff', so don't
   // reread it.  If the printer isn't there, give up now.

   test type = m.np.print then
      unless g.ut.print (TABLE 0) do
         RETURN
   else              // must read the caption into 'rbuff'
   $(
//      g.ut.set32 ( (g.context!m.picture.no-1), 0, fptr32)
//      g.ut.set32 (bytes.per.lc, 0, len32)
//      g.ut.mul32 (len32, fptr32)
//      g.ut.add32 (g.np.s + m.np.long.start32, fptr32)
//      g.dh.read (g.np.s!m.np.file.handle, fptr32, g.np.rbuff, bytes.per.lc)
        g.np.read.descr(g.np.rbuff, g.context!m.picture.no) 

//      G.np.show.picture ()      // data read: show picture now  not needed
      g.np.tbuff%0 := m.np.lclength
   $)

   for line = 0 to g.np.s!m.np.descr.siz - 1    // for each line
   $(
      g.ut.movebytes (g.np.rbuff, line * m.np.lclength, g.np.tbuff, 1,
                                                            m.np.lclength)
      test type = m.np.screen then
      $(
         g.sc.movea ( m.sd.display, m.sd.propXtex,
                                 (g.np.s!m.np.descr.siz - line) * m.sd.linW )
         g.sc.odrop (g.np.tbuff)
      $)
      else
         unless g.ut.print (g.np.tbuff)  BREAK
   $)
$)


// p.b  =  page.back

and p.b () = valof   // Display previous page of index or previous picture
$(
   test g.np.s!m.np.local.state = m.np.photo then
      if g.context!m.picture.no > 1
      $(
         g.context!m.picture.no := g.context!m.picture.no - 1
         if g.context!m.picture.no = 1
            for j = m.np.box3 to m.np.box5 do
               g.np.s!j := m.sd.wBlank
         c.c ()
         RESULTIS TRUE
      $)
   else
      if g.np.s!m.np.index.page > 1
      $(
         display.index (g.np.s!m.np.index.page - 1)
         RESULTIS FALSE
      $)
   g.sc.beep ()
   RESULTIS FALSE
$)


// p.f =  page.forward

and p.f () = valof   // Display next page of index or next picture
$(
   test g.np.s!m.np.local.state = m.np.photo then
      if g.context!m.picture.no < g.np.s!m.np.npics
      $(
         g.context!m.picture.no := g.context!m.picture.no + 1
         if g.context!m.picture.no = 2
         $(
            g.np.s!m.np.box3 := m.sd.act
            g.np.s!m.np.box4 := m.sd.wClear
            g.np.s!m.np.box5 := m.sd.act
         $)
         c.c ()
         RESULTIS TRUE
      $)
   else
      if g.np.s!m.np.index.page < g.np.s!m.np.lastpage
      $(
         display.index (g.np.s!m.np.index.page + 1)
         RESULTIS FALSE
      $)
   g.sc.beep ()
   RESULTIS FALSE
$)


and find.picture () be   // Display picture from videodisc
$(
   let frame = ?
//   let fptr32 = vec 1

//   g.ut.set32 (m.np.num.pics.off + g.context!m.picture.no * 2, 0, fptr32)
//   g.ut.add32 (g.np.s + m.np.itemaddr32, fptr32)
//   g.dh.read (g.np.s!m.np.file.handle, fptr32, @frame, 2)
     g.np.read.frame(@frame, g.context!m.picture.no)
   g.context!m.frame.no := g.ut.unpack16 (@frame, 0)
   g.np.s!m.np.vrestore := TRUE
$)


and G.np.show.picture () be
$(
   g.vh.frame (g.context!m.frame.no)
   g.vh.video (m.vh.video.on)
   g.np.s!m.np.vrestore := FALSE
$)


and highlight () = valof   // Highlight relevant item number
$(
   let first = (g.np.s!m.np.index.page-1) * m.sd.displines + 1
   let second = first + m.sd.displines - 1

   unless second <= g.np.s!m.np.npics do
      second := g.np.s!m.np.npics
   RESULTIS g.sc.high (first, second, FALSE, 0)
$)


and display.index (page) be   // Display a page of the index
$(
   let maxl = m.sd.displines

   g.sc.selcol (m.sd.cyan)
   g.sc.clear (m.sd.display)
   g.sc.movea (m.sd.display, m.sd.disXtex, m.sd.disYtex)

   if page = g.np.s!m.np.lastpage do
   $(
      maxl := g.np.s!m.np.npics REM m.sd.displines
      if maxl = 0 do
         maxl := m.sd.displines
   $)

   g.np.tbuff%0 := m.np.sclength

   for line = 1 to maxl do       // for each line
   $(
      let item = (page - 1) * m.sd.displines + line
      let st   = (item - 1) * m.np.sclength
      g.ut.movebytes (g.np.short.buff, st, g.np.tbuff, 1, m.np.sclength)
test blank.line(g.np.tbuff, item) then
   g.sc.oplist(item, G.np.tbuff)
else     
      g.sc.oplist (item, g.np.tbuff)
   $)

   g.np.s!m.np.index.page := page
   g.context!m.picture.no := highlight ()
$)

and blank.line(s, i) = valof
$( let string = "Photo*s*s*s*s"
   let digit = ?
   string%6, string%7, string%8 := '*s', '*s', '*s'
   for i = 1 to s%0 do
     if s%i ~= 32 
        resultis false
   digit := (i rem 10) + '0'
   string%8 := digit
   digit := i / 10
   if digit ~= 0 then
   $(  digit := (digit rem 10) + '0'
       string%7 := digit
       if i >= 100 string%6 := (i / 100) + '0'
   $)  
   G.ut.movebytes(string, 1, s, 1, string%0)
   resultis true
$)
.
