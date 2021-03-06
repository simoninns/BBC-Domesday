//  AES SOURCE  4.87

section "utgrid1"
// needs the 32 bit calculations package

/**
         UT.B.GRID1 - Grid References Manipulation
         -----------------------------------------

         Handles conversion of grid references to strings of
         various formats.
         This module is now Machine, Wordsize, Byteorder
         Independent.

         NAME OF FILE CONTAINING RUNNABLE CODE: L.grid

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         26.3.86  1        D.Hepper    Initial version
         27.6.86  2        DNH         Fix domesday wall
          1.7.86  3        DNH         Fix fix of domesday wall
          1.8.86  4        DNH         Fix NI letter codes
         12.9.86  5        DNH         Fiddle Orkneys for L1
                                       invalid gr's -> spaces
         29.9.86  6        DNH         B.GRID2 CREATED BY SPLIT

         Limitations: Works on Domesday format Grid References
         and now handles Channel Isles grid ref's correctly.
         Be VERY careful of overlaps between L1 maps.

         Orkney overlap problem:
         The orkneys overlap slightly with Scotland at all
         levels.  The bottom left corner of the L1 Orkneys map is
         actually in Scotland.  Com. Text needs to get back
         'm.grid.is.Shet' from g.ut.grid.region when this GR is
         submitted.  So we frig things by returning this for the
         whole of the overlap.

         Globals:
            g.ut.grid.region
            g.ut.grid.eight.digits
            g.ut.grid.mixed
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "H/grhd.h"

/**
         G.UT.GRID.REGION - Obtains the Level 1 map region
         -------------------------------------------------

         Returns the Domesday region, ie. the Level 1 map name,
         containing the grid ref specified by the easting and
         northing.

         INPUTS:  easting, northing

         OUTPUTS:  word value manifest from h.grhdr

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         The grid ref specified by the easting and northing
         must be make up Domesday Format grid ref.
         The top bit pattern is decoded as follows:

                      easting        northing
         top bit:       1               1           channel
                        1               0           N.Ireland
                        0               1           INVALID
                        0               0           Great Britain

         Great Britain GR's are further subdivided into the 4
         regions defined by the Level 1 maps: South Britain,
         North Britain, Isle of Man and Orkneys and Shetlands.

         PROGRAM DESIGN LANGUAGE:

         rc := g.ut.grid.region [easting, northing]
            if easting top bit set
            then
               if northing top bit set
               then return 'channel'
               else return 'northern ireland'
            endif
            if northing top bit set
            then return 'invalid'
            if inside Isle of Man GR's
            then return 'isle of man'
            if within Domesday wall northing limits
            then
               if easting is west of South map return 'north'
               if easting is east of North map return 'south'
               return 'domesday wall'
            endif
            if northing less than min. northing for 'north'
            then return 'south britain'
            if northing GE min. northing for 'shet' and
                easting GE min. easting for 'shet'
            then return 'orkneys and shetlands'
            return 'north britain'
         end
**/

let g.ut.grid.region (e, n) = valof
$(
   if (e & #X8000) ~= 0 then
      resultis (n & #X8000) ~= 0 -> m.grid.is.channel, m.grid.is.NI
   if (n & #X8000) ~= 0 resultis m.grid.invalid

      // all the rest are on GB grid.  Now decode the region.
      // must do Isle of Man before Domesday Wall...
   if (m.gr.man.L1.mine <= e < m.gr.man.L1.maxe) &
      (m.gr.man.L1.minn <= n < m.gr.man.L1.maxn) resultis m.grid.is.IOM

      // the overlap between South and North along the Domesday Wall is not
      // complete so we must exclude the ends into exclusively one or other
      // of the regions.
   if m.gr.north.L1.minn <= n < m.gr.south.L1.maxn then
   $( if e <  m.gr.south.L1.mine resultis m.grid.is.North
      if e >= m.gr.north.L1.maxe resultis m.grid.is.South
      resultis m.grid.is.Domesday.wall
   $)

   if n < m.gr.north.L1.minn resultis m.grid.is.South

   if e >= m.gr.shet.L1.mine &
      n >= m.gr.shet.L1.minn resultis m.grid.is.Shet

   resultis m.grid.is.North
$)


/**
         G.UT.GRID.EIGHT.DIGITS - Convert GR to String
         ---------------------------------------------

         Converts a Domesday Format grid reference to an eight
         digit number format (accurate to the nearest km) string
         in a vector provided by the caller.

         INPUTS: easting and northing; string/vec for return

         OUTPUTS: the output string is filled with 9 chars.
         eg. "0377 0866".

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:
         Only works when provided with a true Domesday Format
         grid ref.  This should be checked by calling
         g.ut.grid.region first.
         The string provided for the reply should be declared as
         a vector of 10 or more bytes.

         PROGRAM DESIGN LANGUAGE:

         g.ut.grid.eight.digits [easting, northing, dest.string]
            get grid region from easting and northing
            trim easting
            if region is not 'Channel Isles'
            then trim northing
            divide easting by 10
         end
**/

let g.ut.grid.eight.digits (e, n, str) be
$(
   let temp = vec 5/BYTESPERWORD   // for a temporary string
   let a = vec 1
   let b = vec 1
   let c = vec 1
   let region = g.ut.grid.region (e, n)
   let junk = ?

   e := g.ut.grid.trim (e)                   // kill top bit
   unless region = m.grid.is.Channel do
      n := g.ut.grid.trim (n)                // trim N only if not real
   e := e/10                                 // (no top bit problem)
   g.ut.grid.to.string (e, str, 4)           // convert to string
   g.ut.set32 (10, 0, a)                     // divide n by 10
   g.ut.set32  (n, 0, b)                     // preserving 16 bit
   g.ut.div32  (a, b, c)
   n := g.ut.get32 (b, @junk)
   g.ut.grid.to.string (n, temp, 4)
   str%5 := '*S'                             // set middle space
   for i = 1 to 4 do str%(i+5) := temp%i     // copy 4 digits
   str%0 := 9                                // length byte
$)


/**
         G.UT.GRID.MIXED - Convert GR to Mixed Format String
         ---------------------------------------------------

         Converts a Domesday Format grid reference to a mixed
         letter-code and digits format string in the vector
         provided.

         INPUTS: easting, northing, string for return

         OUTPUTS: string is filled in with 8 chars:
         The format of the string is:
            %0 1 2 3 4 5 6 7 8
             l c c   n n   n n
         where 'l' is the single byte length; 'c' is a letter;
         'n' is a digit.

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:
         Only works when provided with a true Domesday Format
         grid ref. EXCLUDING the Channel Islands, for which mixed
         format grid ref's are not defined; spaces are returned
         This can be checked by calling g.ut.grid.region
         first.
         The string provided for the reply should be declared as
         a vector of 5 or more words.

         PROGRAM DESIGN LANGUAGE:
         g.ut.grid.mixed [easting, northing, destination.string]
            get region code
            initialise string to spaces
            if region is invalid or channel islands return
            get letter code and put into string
            if grid reference within range then
               trim easting
               trim northing
               convert easting to string at km accuracy and copy
               convert northing to string at km accuracy and copy
            endif
            set string length
         end
**/

let g.ut.grid.mixed (e, n, str) be
$(
   let temp = vec 3/BYTESPERWORD
   let region = g.ut.grid.region (e, n)
   for j = 1 to 8 do str%j := '*S'
   str%0 := 8

   if region = m.grid.invalid |
      region = m.grid.is.Channel return

   g.ut.grid.letter.code (e, n, str)      // top bits intact; get letter codes
   unless str%2 = '*S' do                 // a space here implies out of range
   $(
      e := g.ut.grid.trim (e) rem 1000    // remainder after letter codes
      n := g.ut.grid.trim (n) rem 1000

      g.ut.grid.to.string (e/10, temp, 2) // easting
      str%4 := temp%1                     // copy to final string
      str%5 := temp%2
      g.ut.grid.to.string (n/10, temp, 2)
      str%7 := temp%1
      str%8 := temp%2
   $)
   str%0 := 8                          // at end since letter.code overwrites
$)
.

