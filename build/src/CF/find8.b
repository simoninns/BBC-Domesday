//  AES SOURCE  4.87

/**
         CF.FIND8 - MAIN ACTION ROUTINE Part II
         --------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         10.6.86  1        M.F.Porter  Initial version, split off from
                                       find0
         19.6.86  2        NY          Add gl5hd
         1.7.86   3        MFP         m.vh.video.off in g.cf.rinit
                                       - item selection 1 out cured
                                       - g.sc.clear removed from init
         18.7.86  4        MFP         $<debug removed
                                       clear message added as marked
                                       fix item selection problems
         20.7.86  5        MFP         c.keepmess used
         23.7.86  6        NRY         Move keepmess code to g.cf.rinit
         26.9.86  7        MFP         Addition as marked
        15.10.86  8        PAC         Speculative fix to printtitles, etc.
        16.10.86  9        PAC         Confirm fix, and bugfix g.cf.rinit
        21.10.86  10       PAC         Reverse above change
        *****************************************
         8.6.87   11       MFP         CHANGES FOR UNI
**/

section "find8"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/vhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/iohd.h"
get "H/cfhd.h"

let trap.(n,val,low,high) be g.ut.trap("CF",80+n,true,3,val,low,high)

/**
         printtitles.() prints the current page of item names
         ('titles') on the screen
**/

let printtitles.() be
$(  let w = g.cf.p!c.ws  // workspace area
    g.sc.pointer(m.sd.off)
    g.sc.clear(m.sd.display)
    g.sc.high(0,0,false,100)  // switch off any outstanding highlighting
    g.sc.selcol(m.sd.cyan)
    g.sc.movea(m.sd.display, m.sd.disXtex, m.sd.disYtex-m.sd.linw)
    for i = 1 to g.cf.p!c.titles do
    $(  let s = g.cf.p+p.t+(i-1)*m.tsize  // s gives i-th title
        trap.(0,s%0,0,30)
        for i = 1 to s%0 do w%(i+5) := s%i   // w is s plus 5 extra chars
        $(  let u = (s%31 >> 7) ~= 0 -> "Pic. ", "Text "
            for i = 1 to 5 do w%i := u%i     // put item type at front of w
        $)
        w%0 := s%0+5                         // complete length
        g.sc.oplist(g.cf.p!c.titlenumber+i, w)  // and output
    $)
    g.sc.pointer(m.sd.on)
$)

/**
         g.cf.rinit() is the initialisation routine for FIND's
         'review' state. It essentially prints the current page
         full of item names ('titles').
**/

let g.cf.rinit() be
$(
    g.context!m.stackptr := 0
    g.context!m.page.no := 0
    g.context!m.picture.no := 1
    g.context!m.itemaddress := g.cf.p!c.itemaddress
    g.vh.video(m.vh.video.off)   // added 1.7.86
    // g.sc.clear(m.sd.message)     removed 1.7.86
    test g.cf.p!c.keepmess then g.cf.p!c.keepmess := false or
        g.sc.clear(m.sd.message)
    /* the above fix dates from 20.7.86. The message area will be cleared
       unless the message 'These items have been found' has just been
       written in the Main state */
    unless (g.cf.p!c.state = s.inn)
    do $( printtitles.()               // changed 21.10.86 PAC
          g.cf.p!c.state := s.review   // added PAC 16.10.86
       $)
$)

/**
         g.cf.raction() is the action routine for FIND's 'review'
         state. This deals with page changing and item selection
         selection in the FIND hit list, and also in the
         gazetteer.
**/

let g.cf.raction() be
$(  // call the init routine if entry is from a pending state change
    if g.context!m.justselected do
    $( g.cf.rinit()
       g.context!m.justselected := false
    $)
    // turn 'tab' in the screen margings into function keys 7 & 8:
    if g.key = m.kd.tab & g.screen = m.sd.display
        test g.xpoint <= thirdwidth then g.key := m.kd.fkey7 or
        test g.xpoint >= 2*thirdwidth then g.key := m.kd.fkey8 or
        g.sc.beep()

    // the s.inn state correspond to gazetteer handling

    test g.cf.p!c.state = s.inn then switchon g.key into
    $(  case m.kd.noact:
            g.sc.high(1, g.cf.p!c.gaztitles, false, 1); return
        case m.kd.fkey7:
            g.cf.changegazpage(g.cf.p, -1); endcase  // prev page
        case m.kd.fkey8:
            g.cf.changegazpage(g.cf.p, 1); endcase   // next page
        case m.kd.return:
        // gazetteer name selection:
        $(  let n = g.sc.high(1, g.cf.p!c.gaztitles, false, 1)
            if n < 0 endcase        // nothing selected
            unless g.cf.selectgazitem(n, g.context+m.grbleast) endcase
            g.key := -m.st.mapwal   // prepare to change states
            g.context!m.leveltype := 2
            g.cf.p!c.state := s.outsidebox  // so we don't pick this state up
                                       // after reentering the 'review' state
            return
        $)
    $)
    or switchon g.key into
    $(  case m.kd.noact:
            g.sc.high(g.cf.p!c.titlenumber+1,
                      g.cf.p!c.titlenumber+g.cf.p!c.titles, false, 1)
            return
        case m.kd.fkey7:
            if g.cf.p!c.m = 0 do $( g.sc.beep(); endcase $)  // on 1st page
            g.cf.p!c.m := g.cf.p!c.m-m.titlespp*m.misize  // move back a page
            g.cf.p!c.titlenumber := g.cf.p!c.titlenumber-m.titlespp
            g.cf.extracttitles(g.cf.p)     // extract new page of titles
            printtitles.() // replaced 21.10.86 PAC (REMOVED PAC 15.10.86)
            endcase
        case m.kd.fkey8:
            $(  let m = g.cf.p!c.m+m.titlespp*m.misize

              //  let tn = g.cf.p+c.titlenumber // added by PAC 15.10.86
              //  !tn := !tn+m.titlespp         // removed PAC 21.10.86

                /* m is the offset in the best match vector of the first
                   item of the next page full. If this is off the end the
                   query must be rerun to get the next storeful of best
                   matches. But if the vector is undersize we are at the
                   end of the query list, and so merely beep.
                */

                test m+m.misize >= g.cf.p!c.mend then
                $(  if g.cf.p!c.mend < m.msize  // titles fix - PAC 16.10.86
                    do $( g.sc.beep(); endcase $)
                    g.sc.clear(m.sd.display)
                    g.cf.writerest("Query:")
                    g.cf.runquery(g.cf.p)      // rerun the query
                $)
                or $( g.cf.p!c.m := m ; g.cf.extracttitles(g.cf.p) $)
                g.cf.p!c.titlenumber := g.cf.p!c.titlenumber+m.titlespp
            $)
            printtitles.() // resplaced 21.10.86 PAC
            endcase
        case m.kd.return:
            // item selection
            $(  let n = g.sc.high(g.cf.p!c.titlenumber+1,
                                  g.cf.p!c.titlenumber+g.cf.p!c.titles, false,
                                  1)-g.cf.p!c.titlenumber-1

                let q, type = ?, ?
                if n < 0 endcase            // nothing selected
                q := g.cf.p+p.t+n*m.tsize   // q points to the item name
                g.context!m.itemaddress := g.ut.unpack16(q,m.tbsize-4)
                type := q%31                // 'type' gives its type
                test (type >> 7) ~= 0 then
                $(  g.context!m.picture.no := type & 127
                    g.key := -m.st.cphoto   // change state into photo
                $) or
                $(  g.context!m.page.no := type
                    g.key := -m.st.ctext    // change state into text
                $)
                g.ut.movebytes(q,0,g.context+m.itemrecord,0,m.tbsize-4)
                    // addition of 26.9.86
                return
            $)
    $)
$)

and g.cf.compstring(s,i,t,j) = valof
$(  let m,n = s%i, t%j
    for o = 1 to m < n -> m, n do
    $(  let diff = CAPCH(s%(i+o))-CAPCH(t%(j+o))
        if diff ~= 0 resultis diff
    $)
    resultis m-n
$)


