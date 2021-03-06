//  AES SOURCE  4.87


/**
14.      COMMUNITY FIND
         --------------

         CF.FIND0 - MAIN ACTION ROUTINE
         ------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2            "       'g.cf.p' introduced; proper headers
         20.5.86  3            "       Yellow on blue headings
         22.5.86  4        PAC         Move code to find7, manifests
                                       to CFHDR
         2.6.86   5        MFP         trap.() for trap()
         10.6.86  6        MFP         split in half - see find8
         19.6.86  7        NY          Add gl5hd
         22.6.86  8        MFP         bug fix in g.cf.minit
         1.7.86   9        MFP         "m.vh.superimpose" & other bugs
                                       + scope of search test
         18.7.86  10       MFP         $<debug removed
                                       'Photo' 'Text' words suppression
         28.7.86  11       MFP         'c.vrestore' test introduced
         8.9.86   12       MFP         fix as marked
         11.9.86  13       MFP         fixes as marked
         16.9.86  14       MFP         'G' for 'W' in country code
         17.9.86  15       MFP         adjustments as marked
         25.9.86  16       MFP         menu.() defined
        15.10.86  17       PAC         Fixes as marked
        16.10.86  18       PAC         Bugfixes for states problem
        21.10.86  19       PAC         Remove titles change.
        ************************************
         88.6.87  20       MFP         ADOPTED FOR UNI
**/

section "find0"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/vhhd.h"
get "H/kdhd.h"
get "H/sdhd.h"
get "H/sthd.h"
get "H/iohd.h"
get "H/grhd.h"
get "H/dhhd.h"
get "H/cfhd.h"

static $( boxtables = 0; box.n = 0 $)


let trap.(n,val,low,high) be g.ut.trap("CF",n,true,3,val,low,high)

/**
         'Boxes' are defined in CF.FIND1. setboxtables.() sets
         the static boxtables so that boxtabes, boxtables+6,
         boxtables+12 and boxtables+18 define the four boxes for
         the main FIND screen (namely: the grid ref, place name,
         query and previous query boxes).
**/

let setboxtables.() be
    boxtables := table
    29*m.sd.charwidth, m.sd.disYtex-m.sd.linw+4, 11, 1, m.sd.blue, m.sd.cyan,
                    0, m.sd.disYtex-4*m.sd.linw, 40, 2, m.sd.blue, m.sd.cyan,
                    0, m.sd.disYtex-8*m.sd.linw, 40, 3, m.sd.blue, m.sd.cyan,
                    0,m.sd.disYtex-13*m.sd.linw, 40, 3, m.sd.cyan, m.sd.blue

/**
         ws.(n,s) writes string s on the screen proportionally
         spaced in yellow on blue at the nth line down in the
         display area.
**/

let ws.(line,s) be
$(  let  y = m.sd.disYtex-(line-1)*m.sd.linw
    g.sc.movea(m.sd.display,0,y+4); g.sc.selcol(m.sd.blue)
    g.sc.rect(m.sd.plot,g.sc.width(s)+8,-m.sd.linw-4)
    g.sc.movea(m.sd.display,m.sd.disXtex,y-4); g.sc.selcol(m.sd.yellow)
    g.sc.oprop(s)                     // ^ this -4 added 16.10.86 PAC
$)

/**
         fillold.() fills in the previous query (with box) on the
         screen
**/

let fillold.() be
$(  setboxtables.()
    $(  let b = boxtables+18             // b is previous query box
        g.cf.boxinput('f',b,m.sd.blue)   // fill with blue
        g.cf.boxinput('i',b,g.cf.p+p.q)  // initialise for input

        // now input the previous query. It is copied into the
        // current query space as a side effect, but this is harmless.

        g.cf.boxinput('s',g.cf.p+p.oldq); g.cf.boxinput('-')
        g.cf.highlight()                 // highlight keywords
    $)
$)

/**
         g.cf.writerest(s) writes the previous query beneath the
         string s, and the headings for the count boxes.
**/

let g.cf.writerest(s) be
$(  ws.(13, s)
    fillold.()
    ws.(18,"Percentage through search:")
    ws.(20,"'Perfect matches' found:")
$)

/**
         showmap.() shows the frame of the current background
         map, turning video on, and setting the video-restore
         flag to false.
**/

let showmap.() be $( g.vh.frame(g.context!m.map.no)
                     g.vh.video(m.vh.superimpose) // added 1.7.86
                     g.vh.video(m.vh.video.on)
                     g.cf.p!c.vrestore := false $)  // 28.7.86

/**
         err.reset.(s) resets the main FIND screen after an
         error. This involves outputting s as an error message
         (if s ~= 0) reshowing the current map background, and
         turning the cursor back on in the currently selected
         box.
**/

let err.reset.(s) be
$(  if s ~= 0 do g.sc.ermess(s)
    showmap.()
    g.cf.boxinput('+')     // cursor back on
    // next line added 11.9.86. Note that g.key = m.kd.return at this point.
    // It suppresses an unwanted beep.
    if g.screen = m.sd.message do g.key := m.kd.noact
$)

/**
         menu.() (re)draws the menu bar. 'Old', 'Text' and
         'Photos' are suppressed if necessary.
**/

let menu.() be
// menu bar drawing elaborated 18.7.86
$(  let v = vec 5
    for i = 0 to 5 do v!i := m.sd.act
    if g.cf.p!c.state = s.unset |
       g.cf.p!c.mend = 0   // new test for no-hit-list 17.9.86
    do v!5 := m.sd.wblank
    if (g.context!m.flags & #X1) = 0 do v!4 := m.sd.wblank // no text
    if (g.context!m.flags & #X2) = 0 do v!3 := m.sd.wblank // no photos
    g.sc.menu(v)
$)

/**
         g.cf.minit() is the initialisation routine for the MAIN
         state.
**/

let g.cf.minit() be
$(  // first some fiddling in g.context:
    g.context!m.stackptr := 0
    g.context!m.page.no := 0
    g.context!m.picture.no := 1

    g.cf.p!c.itemaddress := g.context!m.itemaddress
    g.sc.pointer(m.sd.off)     // pointer off during screen writing
    showmap.()  // 22.6.86     - show the current map background
    g.sc.clear(m.sd.message)
    g.sc.clear(m.sd.display)   // clear the screen

    // now output the boxes with headings
    setboxtables.()
    ws.(2,"Map by Grid Reference:")
    g.cf.boxinput('f', boxtables, m.sd.blue)
    ws.(4,"Map by Place Name:")
    g.cf.boxinput('f', boxtables+6, m.sd.blue)
    ws.(8,"Text and Photos by Topic:")
    g.cf.boxinput('f', boxtables+12, m.sd.blue)
    g.cf.writerest("Previous Query:")

    // addition of 1.7.86:
    /* the next bit works out the condition for the "Scope .. limited .."
       message. If the level is 0 or above 2 the message is never required.
       If the 'area' of the background map is the Domesday wall it is
       not required. Otherwise if the 'area' does not correspond to the
       current side of disc it is required. */

    if g.context!m.leveltype < 3 do  // levs 0,1,2
    $(  let area = g.ut.grid.region(g.context!m.grbleast,
                                    g.context!m.grblnorth)
        unless area = m.grid.is.domesday.wall do
            if g.context!m.leveltype = 0 |
            ((area = m.grid.is.south | area = m.grid.is.channel) neqv
             g.context!m.discid = m.dh.south) do
                g.sc.mess("Scope of topic search limited on this side")
    $)
    menu.()                        // draw the menu bar
    g.cf.p!c.state := s.outsidebox   // set the initial state
    g.sc.pointer(m.sd.on)            // pointer back on
$)

/**
         boxatcursor() determines the box at which the mouse
         pointer is pointing. The result is i (i  = 0, 6 or 12),
         so that boxtables+i is the box. If the pointer is not at
         any box the result is -1.
**/

let boxatcursor() = g.screen ~= m.sd.display -> -1, valof
$(  setboxtables.()
    for i = 0 to 12 by 6 do
    $(  let d = boxtables!(i+1) - g.ypoint
        if 0 <= d <= boxtables!(i+3) * m.sd.linw + 8 &  // '8' determined by
                                                        // inspection
           g.xpoint >= boxtables!i resultis i
    $)
    resultis -1
$)

/**
         addch.() adds g.key to the currently selected box,
         changing the state to 'atbox' if this results in the
         contents of the box being deleted.
**/

let addch.() be if g.cf.boxinput('c',g.key) = 0 do 
   g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1

/**
         g.cf.maction() is the action routine for the MAIN state
         of FIND. Within the MAIN state there a set of subsidiary
         states as follows:

         'outsidebox': no box is currently selected.

         'atbox': a box is selected and is empty (apart from the
         cursor). From this state cursor movement can take us to
         the 'outsidebox' state. The box selected (0,6 or 12) is
         in g.cf.p!c.box

         'ing', 'inn', 'inq': text is being input to the grid
         ref, name, or query box respectively. Deleting all text
         in the box takes us to the 'atbox' state again, from
         which another box may be selected.

         'gr.ambig': a valid grid ref has been input, but the
         system is waiting on the resolution of the
         Ireland/Britain ambiguity.

         This state is held in g.cf.p!c.state.
**/

let g.cf.maction() be
$(  let v = g.cf.p+p.s+10 // to hold grid ref - adjusted 17.9.86

    // g.cf.minit() must be called explicitly if the entry was via a
    // pending state change
    if g.context!m.justselected do
    $(  g.cf.minit()
        g.context!m.justselected := false
    $)
    // restore video if necessary
    if g.cf.p!c.vrestore do        // added 28.7.86
    $(  g.vh.video(m.vh.video.on)
        g.cf.p!c.vrestore := false
    $)
    switchon g.cf.p!c.state into
    $(
        case s.outsidebox:
        $(  let n = boxatcursor()       // find currently selected box
            if n >= 0 do                // change state if it exists
            $(  g.cf.p!c.state, g.cf.p!c.box := s.atbox, n
                g.cf.boxinput('f', boxtables+n, m.sd.cyan) // fill with cyan
                (g.cf.p+p.q)%0 := 0     // empty the input string
                g.cf.boxinput('i', boxtables+n, g.cf.p+p.q) // initialise box
                box.n := n 
                loop
            $)
        $); endcase
        case s.atbox: if G.key = m.kd.action & G.menuon = false &
                         (0 <= G.cf.p!c.box <= 12) then
                      $(
                         G.cf.p!c.state := s.atbox1
                         endcase
                      $)
        case s.atbox1:
        $(  let n = boxatcursor()       // find currently selected box
            if G.cf.p!c.state = s.atbox1 & g.menuon G.cf.p!c.state := s.atbox
              // change if different
            if n ~= g.cf.p!c.box  & (g.cf.p!c.state = s.atbox |
                (g.cf.p!c.state = s.atbox1 & G.key = m.kd.action)) do
            $(  g.cf.p!c.state := s.outsidebox
                g.cf.boxinput('f', boxtables+g.cf.p!c.box, m.sd.blue)
                loop                   // fill with blue
            $)
            if g.key = m.kd.noact endcase     // continue if no character
            g.cf.p!c.state := s.ing+box.n/6; loop // otherwise enter the box
            unless g.cf.p!c.state = s.ing | g.cf.p!c.state = s.inn |
                   g.cf.p!c.state = s.inq | g.cf.p!c.state = s.gr.ambig do
                endcase   // continue if no character
        $)
        case s.ing:
            // add the character to the box
            addch.()
            unless g.key = m.kd.return 
            $( if (g.cf.p+p.s)!2 = 0 then
                  g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1
               endcase
            $)
            // if the character is RETURN, process the grid ref
            $(  let res = g.cf.gridref(g.cf.p+p.q,v,-1)
                if res = 1 do  // grid ref ambiguous
                $(             // ask the question:
                    g.sc.clear(m.sd.message)
                    g.sc.mess("Do you mean GB or N Ireland (G/N)?")
                    g.sc.movea(m.sd.message, 59*m.sd.charwidth/2,
                               m.sd.mesYtex) // adjusted 17.9.86
                    v%0 := 0   // prepare to receive answer in v
                    g.key := m.kd.noact
                    g.sc.input(v, m.sd.blue, m.sd.cyan, 1)
                    g.cf.p!c.state := s.gr.ambig // change states
                    endcase
                $)
                if res = 2 do  // grid ref faulty
                $(  g.cf.boxinput('+')   // turn cursor back on
                    // next line added 11.9.86
                    if g.screen = m.sd.message do g.key := m.kd.noact
                    endcase
                $)
            $); goto lab0  // the successful exit
        case s.gr.ambig:
            if g.key ~= m.kd.noact &
               g.key ~= m.kd.fkey1 // added 8.9.86
            do g.sc.input(v, m.sd.blue, m.sd.cyan, 1)            
            unless g.key = m.kd.return 
            $( if (g.cf.p+p.s)!2 = 0 then
                  g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1
               endcase
            $)
            $(  let ch = CAPCH(v%1)
                if v%0 ~= 1 | ch ~= 'N' & ch ~= 'G' do
                $(  g.cf.p!c.state := s.ing // bad answer - try again
                    // next line added 11.9.86
                    if g.screen = m.sd.message do g.key := m.kd.noact
                    loop
                $)
                g.cf.gridref(g.cf.p+p.q,v,ch) // recompute properly
                g.sc.clear(m.sd.message)
            $)
        lab0:   // selection by grid ref - change state into map walking
            g.context!m.grbleast := v!0
            g.context!m.grblnorth := v!1
            g.key := -m.st.mapwal
            g.context!m.leveltype := 1
            return
        case s.inn:
            // similarly for place names:   
            addch.()
            unless g.key = m.kd.return 
            $( if (g.cf.p+p.s)!2 = 0 then
                  g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1
              endcase
            $)
            $(  let s = g.cf.p+p.q       // s is the place name
                if s%0 = 0 do
                $(  err.reset.("Place name is blank")
                    g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1
                    endcase
                $)
                /* look up s in the gazetteer, entering map walking by a
                   pending state change if it's uniquely found, otherwise
                   switching into the REVIEW state where the user will
                   see a gazetteer page. */

                test g.cf.lookupgaz(g.cf.p, s, g.context+m.grbleast)
                then $( g.key := -m.st.mapwal; g.context!m.leveltype := 2 $)
                or g.key := -m.st.cfindr
            $)
            return
        case s.inq:
            // add the character, copying previous query if character is COPY
            test g.key = m.kd.copy then g.cf.boxinput('s',g.cf.p+p.oldq)
                                     or addch.()
            unless g.key = m.kd.return 
            $( if (g.cf.p+p.s)!2 = 0 then
                  g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1
               endcase
            $)
            if (g.cf.p+p.q)%0 = 0 do
            $(  err.reset.("Query is blank")
                g.cf.p!c.state := G.menuon -> s.atbox, s.atbox1
                endcase
            $)
            unless g.cf.makequery(g.cf.p) do $( err.reset.(0); endcase $)
            // bug fix 1.7.86
            unless g.cf.runquery(g.cf.p) do
            $(  g.sc.clear(m.sd.message)
                showmap.()
                fillold.()
                $(  manifest $( c4 = m.sd.charwidth*4
                                h = m.sd.linw
                                x = m.sd.disXtex+24*m.sd.charwidth
                                y1 = m.sd.disYtex-17*h
                                y2 = m.sd.disYtex-19*h $)
                    g.sc.movea(m.sd.display,x,y1+4)
                    g.sc.rect(m.sd.clear,c4,-h)
                    g.sc.movea(m.sd.display,x,y2+4)
                    g.sc.rect(m.sd.clear,c4,-h)
                $)
                menu.()
                g.cf.p!c.state := s.outsidebox; endcase
            $)
            g.cf.p!c.titlenumber := 0  // replaced by PAC 21.10.86
            g.cf.p!c.keepmess := TRUE  // added 16.10.86 PAC - runquery
            g.cf.p!c.state := s.review // no longer sets it up.
            g.key := -m.st.cfindr
            return
        default: trap.(2,g.cf.p!c.state,1,s.gr.ambig)
    $)
    return
$) repeat

