//  AES SOURCE  4.87

section "utgrid2"
// needs the 32 bit calculations package

/**
         UT.B.GRID2 - Grid References Manipulation 2
         -------------------------------------------

         Primitive conversion routines for grid ref conversion.
         Called by main routines in section utgrid1 but also
         global and may be called directly by overlays,
         especially g.ut.grid.trim.
         This module is now Machine, Wordsize, Byteorder
         Independent.

         NAME OF FILE CONTAINING RUNNABLE CODE: L.grid

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         29.9.86  1        DNH         Split from grid1
                                       Range check E,N separate-
                                       ly in letter.code

         29.4.87     2     DNH         AES CHANGES

         Globals:
            g.ut.grid.letter.code
            g.ut.grid.to.string
            g.ut.grid.trim
**/

get "H/libhdr.h"
get "GH/glhd.h"
get "H/grhd.h"

/**
         G.UT.GRID.LETTER.CODE - Obtain Letter Code from GR
         --------------------------------------------------

         Obtains the letter pair code for the 100 * 100 km square
         containing the point specified by the Domesday Format
         easting and northing.

         INPUTS: easting, northing, string for return

         OUTPUTS: the string is filled in with the letters

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:
         It should not be called for Channel Islands since square
         codes are not defined; spaces are returned.
         For Northern Ireland the first letter is and ASCII
         space.
         The string should be declared as a vector of 3 bytes or
         more.
         Range checking will reject GR's outside table range to
         the East and North.
         This is for National Mappable and Area which are the
         ones likely to cause trouble.

         PROGRAM DESIGN LANGUAGE:

         g.ut.grid.letter.code [easting, northing, string]
            get region from grid ref
            initialise string to spaces
            if region is invalid or channel islands
            then return
            trim easting and northing
            if region is northern ireland
            then
               look up second letter in NI table
               return
            else
               if within limits of table
                  look up first letter in GB table
                  look up second letter in second GB table
               endif
            endif
         end
**/

let g.ut.grid.letter.code (e, n, str) be
$(                                // e, n must be untrimmed !!!
   let region = g.ut.grid.region (e, n)
   str%0, str%1, str%2 := 2, '*S', '*S'

   if region = m.grid.invalid |
      region = m.grid.is.Channel return      // no codes

   e := g.ut.grid.trim (e)
   n := g.ut.grid.trim (n)

   test region = m.grid.is.NI then
   $(       // first letter (str%1) is already a space
      str%2 := "GHJKBCDE" % (1 + (n-3000)/1000*4 + (e-1000)/1000)
   $)
   else        // on GB grid
   $( let e.index, n.index = e/5000, n/5000
      let codes = "STNOHJ"       // first letter: 500km code
      if e.index <= 1 & n.index <= 2 then
      $( str%1 := codes % (1 + e.index + n.index*2)
                                 // second letter: 100km code
         str%2 := "VWXYZ*
                  *QRSTU*
                  *LMNOP*
                  *FGHJK*
                  *ABCDE" % (1 + (n rem 5000)/1000*5 + (e rem 5000)/1000)
      $)    // otherwise outside range so leave blank
   $)
$)


/**
         G.UT.GRID.TO.STRING - Convert Value to String
         ---------------------------------------------

         Converts a 16 bit grid reference or residual into a
         string of ascii digits with leading zeros in the field
         width specified.

         INPUTS: 16 bit value, string for return, number of
                                                         digits

         OUTPUTS: 'number of digits' digits are placed in the
         string.

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:
         Value must be trimmed if the top bit is set
         artificially (eg. N.Ireland easting).
         Value must be divided down to the units required by the
         caller, eg. to output 02345 04567 to 10km first divide
         each by 100, then obtain the easting string by calling
         this routine with parameters "23, <str.addr>, 3" to get
         023, then "45, <str.addr>, 3" to get 045.  Obviously, no
         dividing down is required for hectometre output.

         String should be declared as a vector of as many
         bytes as 'number of digits', plus one.

         PROGRAM DESIGN LANGUAGE:

         g.ut.grid.to.string [value, string, number of digits]
            for count = number of digits to 1
               divide value by 10
               put remainder, in ascii, into string%count
            endfor
            set string length to number of digits
         end
**/

let g.ut.grid.to.string (value, str, digits) be
$(
   let a = vec 1
   let b = vec 1
   let c = vec 1
   let junk = ?

   g.ut.set32 (10, 0, a)      // divide by 10 each time
   g.ut.set32 (value, 0, b)

   for j = digits to 1 by -1 do
   $(
      g.ut.div32 (a, b, c)    // effectively "b := b / 10"
      str%j := g.ut.get32 (c, @junk) + '0'      // remainder as next digit
   $)
   str%0 := digits
$)


/**
         G.UT.GRID.TRIM - Trim the top bit off a word
         --------------------------------------------

         Ands a word with #X7fff to nobble top bit

         INPUTS: value

         OUTPUTS: trimmed value

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS:

         PROGRAM DESIGN LANGUAGE:

         g.ut.grid.trim (value) returns value with the top bit
         trimmed.  This is for use on grid refs for internal Map
         use (since BCPL is happier with signed quantities) and
         for stripping off the artificially set top bits that are
         used to distinguish grid systems in the Domesday Format
         GR's.
**/

let g.ut.grid.trim (value) = value & #X7fff    // kill top bit
.
