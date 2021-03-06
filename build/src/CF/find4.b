//  AES SOURCE  4.87

/**
         CF.FIND4 - READS GRID REF IN TEXT FORM
         --------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2             "      New 'get' directives
         22.5.86  3        PAC         Get SDHDR
         2.6.86   4        MFP         'A <= x <= B' to 'A <= x < Y'
                                       etc in g.cf.checkgr(x,y)
         19.6.86  5        NY          Add gl5hd
         30.6.86  6        MFP         5000 to 3000 in cases 'G','H','J' below
         14.7.86  7        MFP         More '<=' to '<' as marked
         16.9.86  8        MFP         'G' for 'W' in country code
         ********************************************
         8.6.87   9        MFP         ADOPTED FOR UNI
**/



section "find4"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/sdhd.h"
get "H/cfhd.h"

static $( easting = 0; northing = 0 $)
manifest $( topbit = 1 << 15 $)

/**
         g.cf.checkgr(x,y) checks to see if the the grid ref
         easting=x, northing=y lies within the Domesday area.
**/

let g.cf.checkgr(x,y) =
   800 <= x < 6800 & 0 <= y < 4800 |                   // south britain
   400 <= x < 5600 & 4500 <= y < 9900 |                // north britain
   2800 <= x < 4800 & 9600 <= y < 12300 |              // orkney & shetland
   1600+topbit <= x < 4000+topbit & 3000 <= y < 4800 | // northern ireland
   5100+topbit <= x < 5900+topbit & 54400 <= y < 55300 -> // channel islands
   true, false

/**
         irishsystem.(a) puts into easting, northing the grid ref
         for the letter a. The result is 0 if OK, 4 if an invalid
         letter.
**/

let irishsystem.(a) = valof
$(  switchon a into
    $(  case 'C': easting := 2000; northing := 4000; endcase
        case 'D': easting := 3000; northing := 4000; endcase
        case 'G': easting := 1000; northing := 3000; endcase
                                          // bug fix of 30.6.86
        case 'H': easting := 2000; northing := 3000; endcase
        case 'J': easting := 3000; northing := 3000; endcase
        default: resultis 4
    $)
    easting := easting+topbit; resultis 0
$)

/**
         lettercode.(a) is used by UKsystem.(..) below.
**/

let lettercode.(a) = valof for i = 1 to 25 if
    a = "VWXYZQRSTULMNOPFGHJKABCDE"%i resultis i-1

/**
         UKsystem(a,b) puts into easting, northing the grid ref
         for the letter combination a,b. The result is 0 if OK, 5
         if invalid letter pair.
**/

let UKsystem.(a,b) = valof
$(  unless (a = 'S' | a = 'T' | a = 'N' | a = 'O' | a = 'H') & b ~= 'I'
       resultis 5
    // the next 3 lines are very tightly coded
    a := lettercode.(a); b := lettercode.(b)
    easting := (a-2) rem 5 * 5000 + b rem 5 * 1000
    northing := (a-5) / 5 * 5000 + b/5 * 1000
    resultis 0
$)

/**
         trannumbers.(...) adds into easting, northing the value
         of the numeric part of the grid ref.

         The arguments of trannumbers.(...) are as follows:

         s        is the address of the string
         k        is the byte offset to the first digit in s
         halfsize is the number of digits in each of the easting
                  and northing parts
         width    is the number of digits that will give an
                  accuracy in the grid ref down to 1 Hm (3 if
                  letters are used, 5 otherwise).
         units    is the number of Hm represented by a '1' in the
                  first digit position
**/


let trannumbers.(s,k,halfsize,width,units) be
$(  let digits = halfsize > width -> width, halfsize
    for i = 0 to digits-1 do
    $(  easting := easting + (s%(k+i)-'0') * units
        northing := northing + (s%(k+i+halfsize)-'0') * units
        units := units/10
    $)
$)

/**
         trangridref.(s0,country) puts into easting, northing the
         grid ref value of the string s0.

         Three basic forms are dealt with:

         Single letter + numbers, e.g. "H7468" (Irish system)
         Two letters + numbers, e.g.   "NT2134" (UK system)
         Numbers only: e.g.            "03210634"

         Misplaced spaces are regarded as errors (e.g. "032
         10634"). Spaces may occur at the beginning, before the
         first digit, and midway in the digit sequence (there
         must be an even number of digits).

         If letters are used, the digits may be entirely absent.
**/

let trangridref.(s0, country) = valof
$(  let l = s0%0     // string length
    let lastspace = 0 // will be the position of the last space in s
    let k = 1  // k will be the offset of the first digit in s
    let a, b = ?, ? // 1st & 2nd letters
    let s = vec 20/bytesperword  // enough
    // first remove spaces:
    $(  let j = 0
        for i = 1 to l test s0%i = ' ' then lastspace := j+1
                                       or $( j := j+1; s%j := s0%i $)
        l := j
    $)
    if l = 0 resultis 8
    a := CAPCH(s%1)
    if 'A' <= a <= 'Z' do
    $(  k := 2
        b := CAPCH(s%2)
        if l > 1 & 'A' <= b <= 'Z' do k := 3
    $)
    for i = k to l unless '0' <= s%i <= '9' resultis 2
    if (l-k+1) rem 2 = 1 resultis 3
    if lastspace > k & 2*(l-lastspace+1) ~= l-k+1 resultis 1
    test k > 1 then
    $(  let result = (k = 2 -> irishsystem., UKsystem.)(a,b)
        if result ~= 0 resultis result
        trannumbers.(s,k,(l-k+1)/2,3,100)
    $)
    or    // numbers only
    $(  unless s%1 = '0' resultis 6
        $(  let ch = s%(l/2+1)
            unless ch = '0' | ch = '1' | ch = '5' resultis 7
        $)
        easting, northing := 0,0
        trannumbers.(s,1,l/2,5,10000)
        // the next line deals with the channel islands
        if (northing & topbit) ~= 0 do easting := easting+topbit
        // now resolve the Great Britain/Northern Ireland ambiguity:
        if 1600 <= easting < 4000 & 3000 <= northing < 4800 do
        $(  if country = 'G' resultis 0
            if country = 'N' do $( easting := easting+topbit; resultis 0 $)
            resultis -1  // ambiguous
        $)
    $)
    unless g.cf.checkgr(easting, northing) resultis 9
    resultis 0
$)

/**
         errormessage.(n) generates error message number n in the
         message area.

         Here are some examples:

        error 1 : "NX 1 213"
        error 2 : "XTR", "017/019" etc.
        error 3 : "NX121"
        error 4 : "Z2134"
        error 5 : "AS214 319"
        error 6 : "2109"
        error 7 : "015 416"
        error 8 : ""
        error 9 : "HL0000"
**/

let errormessage.(n) be g.sc.ermess(valof switchon n into
   $( case 1: resultis "Grid reference has the wrong spacing"
      case 2: resultis "Grid reference cannot have this form"
      case 3: resultis "Number of digits must be even"
      case 4: resultis "Invalid single letter"
      case 5: resultis "Invalid letter pair"
      case 6: resultis "Easting should begin with '0'"
      case 7: resultis "Northing should begin '0', '1' or '5'"
      case 8: resultis "Grid reference is blank"
      case 9: resultis "Grid reference outside Domesday area"
   $)
)

/**
         g.cf.gridref(s,v,country) converts the grid reference in
         the string s into standard Domesday form, putting the
         result into v!0 (easting) and v!1 (northing). Northern
         Ireland grid refs in numeric form have the same form as
         certain UK grid refs. To resolve this ambiguity,
         'country' may be set to 'N' (Northern Ireland) or 'G'
         (Great Britain). Any other value of country is regarded
         as ambiguous.

         The result of the call is:

         0 : grid ref OK
         1 : grid ref ambiguous
         2 : grid ref invalid

         In the last case, one of nine errors is reported in the
         message area.
**/

let g.cf.gridref(s, v, country) = valof
$(  let n = trangridref.(s, country)
    if n > 0 do $( errormessage.(n); resultis 2 $)
    if n < 0 resultis 1  // ambiguous
    v!0, v!1 := easting, northing
    resultis 0
$)


