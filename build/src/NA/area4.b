//  PUK SOURCE  6.87

/**
         AREA4 - READS GRID REF IN TEXT FORM
         -----------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.area

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial version (FIND)
         8.5.86   2        S.R.Young   Appropriated for AREA
        19.5.86   3        SRY         Changed range check
         1.7.86   4        SRY         Changed NI 5000 to 3000
        16.7.86   5        NY          Fix bug in trangridref.
         7.8.86   6        SRY         Change limits of GRs
*******************************************************************************
         8.7.87   7        SRY         Changes for UNI
**/

section "Area4"

get "H/libhdr.h"
get "H/syshdr.h"
get "GH/glhd.h"
get "GH/glNAhd.h"

static $( easting = ? northing = ? $)
manifest $( topbit = 1 << 15 $)

let checkgr(x,y) =
   0 <= x <= 7000 & 0 <= y <= 12300 |                   // Britain
   1600+topbit <= x <= 4000+topbit & 3000 <= y <= 4800 | // Northern Ireland
   5000+topbit <= x <= 6000+topbit & 54000 <= y <= 55300 -> // Channel Islands
   true, false

let irishsystem.(a) = valof
$( switchon a into
   $( case 'C': easting := 2000; northing := 4000; endcase
      case 'D': easting := 3000; northing := 4000; endcase
      case 'G': easting := 1000; northing := 3000; endcase
      case 'H': easting := 2000; northing := 3000; endcase
      case 'J': easting := 3000; northing := 3000; endcase
      default: resultis 4
   $)
   easting := easting+topbit
   resultis 0
$)

let lettercode.(a) = valof for i = 1 to 25 if
    a = "VWXYZQRSTULMNOPFGHJKABCDE"%i resultis i-1

let UKsystem.(a,b) = valof
$(  unless (a = 'S' | a = 'T' | a = 'N' | a = 'O' | a = 'H') & b ~= 'I'
       resultis 5
    a := lettercode.(a); b := lettercode.(b)
    easting := (a-2) rem 5 * 5000 + b rem 5 * 1000
    northing := (a-5) / 5 * 5000 + b/5 * 1000
    resultis 0
$)

let trannumbers.(s,k,halfsize,width,units) be
$(  let digits = halfsize > width -> width, halfsize
    for i = 0 to digits-1 do
    $(  easting := easting + (s%(k+i)-'0') * units
        northing := northing + (s%(k+i+halfsize)-'0') * units
        units := units/10
    $)
$)

let trangridref.(s0, country) = valof
$(  let l = s0%0
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
    or
    $(  unless s%1 = '0' resultis 6
        $(  let ch = s%(l/2+1)
            unless ch = '0' | ch = '1' | ch = '5' resultis 7
        $)
        easting, northing := 0,0
        trannumbers.(s,1,l/2,5,10000)
        // the next line deals with the channel islands
        if (northing & topbit) ~= 0 do easting := easting+topbit
        // now resolve the Wales/Northern Ireland ambiguity:
        if 1600 <= easting <= 4000 & 3000 <= northing <= 4800 do
        $(  if country = 'W' resultis 0
            if country = 'N' do $( easting := easting+topbit; resultis 0 $)
            resultis -1  // ambiguous
        $)
    $)
    unless checkgr(easting, northing) resultis 9
    resultis 0
$)

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

let G.na.gridref(s, v, country) = valof
$(  let n = trangridref.(s, country)
    if n > 0 do $( errormessage.(n); resultis 2 $)
    v!0, v!1 := easting, northing
    if n < 0 resultis 1  // ambiguous
    resultis 0
$)
.
