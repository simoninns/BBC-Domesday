//  AES SOURCE  4.87

/**
         CF.FIND5 - SUFFIX STRIPPER
         --------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         R.FIND

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         7.5.86   1        M.F.Porter  Initial working version
         13.5.86  2             "      New 'get' directives
         22.5.86  3        PAC         Get SDHDR
         19.6.86  4        NY          Get gl5hd
         25.9.86  5        MFP         Comments added, & adjustments as
                                       marked
         *********************************************
         8.6.87   6        MFP         ADOPTED FOR UNI
**/



section "find5"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glCFhd.h"
get "H/sdhd.h"
get "H/cfhd.h"

static $( p = 0; k = 0; k0 = 0; j = 0 $)

/**
         The stemming algorithm used in the Domesday Project is
         fully described in M.F. Porter, 1980, 'An algorithm for
         suffix stripping' in 'Program', 14(3), 130-137.
**/

/**
         c.(i) is true <=> p%i is a consonant.
**/

let c.(i) = valof
$(  let ch = p%i
    if ch = 'a' | ch = 'e' | ch = 'i' | ch = 'o' | ch = 'u' resultis false
    if ch = 'y' resultis i = 0 -> true, ~c.(i-1)
    resultis true
$)

/**
         m.() measures the number of consonant sequences between
         k0 and j. if c is a consonant sequence and v a vowel
         sequence, and <..> indicates arbitrary presence,

           <c><v>       gives 0
           <c>vc<v>     gives 1
           <c>vcvc<v>   gives 2
           <c>vcvcvc<v> gives 3
           ....
**/

and m.() = valof
$(  let n = 0
    let i = k0
    $(  if i > j resultis n
        unless c.(i) break
        i := i+1
    $) repeat
    i := i+1
    $(
        $(  if i > j resultis n
            if c.(i) break
            i := i+1
        $) repeat
        i := i+1
        n := n+1
        $(  if i > j resultis n
            unless c.(i) break
            i := i+1
        $) repeat
        i := i+1
    $) repeat
$)

/**
         vowelinstem.() is true <=> k0,...j contains a vowel
**/

and vowelinstem.() = valof
$(  for i = k0 to j do unless c.(i) resultis true
    resultis false
$)

/**
         doublec.(j) is true <=> j,(j-1) contain a double
         consonant.
**/

and doublec.(j) = j < k0+1 -> false, valof
$(  let ch, ch1 = p%j, p%(j-1)
    if ch ~= ch1 resultis false
    resultis c.(j)
$)

/**
         cvc.(i) is true <=> i-2,i-1,i has the form consonant -
         vowel - consonant and also if the second c is not w,x or
         y. this is used when trying to resore an e at the end of
         a short word. e.g.

           cav(e), lov(e), hop(e), crim(e), but
           snow, box, tray.

**/

and cvc.(i) = valof
$(  if i < k0+2 | ~c.(i) | c.(i-1) | ~c.(i-2) resultis false
    $(  let ch = p%i
        if ch = 'w' | ch = 'x' | ch = 'y' resultis false
    $)
    resultis true
$)

/**
         ends.(s) is true <=> k0,...k ends with the string s.
**/

and ends.(s) = valof
$(  let length = s%0
    j := k
    if length > k resultis false
    for i = 1 to length if p%(k-length+i) ~= s%i resultis false
    j := k-length
    resultis true
$)

/**
         setto.(s) sets (j+1),...k to the characters in the
         string s, readjusting k.
**/

and setto.(s) be
$(  let length = s%0
    for i = 1 to length do p%(j+i) := s%i
    k := j+length
$)

/**
         r.(s) is used below.
**/

and r.(s) be if m.() > 0 do setto.(s)

/**
         step1.() gets rid of plurals and -ed or -ing. e.g.

           caresses  ->  caress
           ponies    ->  poni
           ties      ->  ti
           caress    ->  caress
           cats      ->  cat

           feed      ->  feed
           agreed    ->  agree
           disabled  ->  disable

           matting   ->  mat
           mating    ->  mate
           meeting   ->  meet
           milling   ->  mill
           messing   ->  mess

           meetings  ->  meet

**/

and step1.() be
$(  if p%k = 's' do
    test ends.("sses") then k := k-2 or
    test ends.("ies") then setto.("i") or
    unless p%(k-1) = 's' do k := k-1

    test ends.("eed") then if m.() > 0 do k := k-1 or
    if (ends.("ed") | ends.("ing")) & vowelinstem.() do
    $(  k := j
        test ends.("at") then setto.("ate") or
        test ends.("bl") then setto.("ble") or
        test ends.("iz") then setto.("ize") or
        test doublec.(k) then
        $(  k := k-1
            $(  let ch = p%k
                if ch = 'l' | ch = 's' | ch = 'z' do k := k+1
            $)
        $)
        or if m.() = 1 & cvc.(k) do setto.("e")
    $)
$)

/**
         step2.() turns terminal y to i when there is another
         vowel in the stem.
**/

and step2.() be if ends.("y") & vowelinstem.() do p%k := 'i'

/**
         step3.() maps double suffices to single ones. so
         -ization ( =  -ize plus -ation) maps to -ize etc. note
         that the string before the suffix must give m.() > 0.
**/

and step3.() be switchon p%(k-1) into
$(
    case 'a': if ends.("ational") do $( r.("ate"); endcase $)
              if ends.("tional") do $( r.("tion"); endcase $)
              endcase
    case 'c': if ends.("enci") do $( r.("ence"); endcase $)
              if ends.("anci") do $( r.("ance"); endcase $)
              endcase
    case 'e': if ends.("izer") do $( r.("ize"); endcase $)
              endcase
    case 'l': if ends.("bli") do $( r.("ble"); endcase $)
              if ends.("alli") do $( r.("al"); endcase $)
              if ends.("entli") do $( r.("ent"); endcase $)
              if ends.("eli") do $( r.("e"); endcase $)
              if ends.("ousli") do $( r.("ous"); endcase $)
              endcase
    case 'o': if ends.("ization") do $( r.("ize"); endcase $)
              if ends.("ation") do $( r.("ate"); endcase $)
              if ends.("ator") do $( r.("ate"); endcase $)
              endcase
    case 's': if ends.("alism") do $( r.("al"); endcase $)
              if ends.("iveness") do $( r.("ive"); endcase $)
              if ends.("fulness") do $( r.("ful"); endcase $)
              if ends.("ousness") do $( r.("ous"); endcase $)
              endcase
    case 't': if ends.("aliti") do $( r.("al"); endcase $)
              if ends.("iviti") do $( r.("ive"); endcase $)
              if ends.("biliti") do $( r.("ble"); endcase $)
              endcase
//  next line removed 25.9.86 for compatibility with pre-mastering
//  stemming program
//  case 'g': if ends.("logi") do $( r.("log"); endcase $)
$)

/**
         step4.() deals with -ic-, -full, -ness etc. similar
         strategy to step3.
**/

and step4.() be switchon p%k into
$(
    case 'e': if ends.("icate") do $( r.("ic"); endcase $)
              if ends.("ative") do $( r.(""); endcase $)
              if ends.("alize") do $( r.("al"); endcase $)
              endcase
    case 'i': if ends.("iciti") do $( r.("ic"); endcase $)
              endcase
    case 'l': if ends.("ical") do $( r.("ic"); endcase $)
              if ends.("ful") do $( r.(""); endcase $)
              endcase
    case 's': if ends.("ness") do $( r.(""); endcase $)
              endcase
$)

/**
         step5.() takes off -ant, -ence etc., in context
         <c>vcvc<v>.
**/

and step5.() be
$(  switchon p%(k-1) into
    $(  case 'a':  if ends.("al") endcase; return
        case 'c':  if ends.("ance") endcase
                   if ends.("ence") endcase; return
        case 'e':  if ends.("er") endcase; return
        case 'i':  if ends.("ic") endcase; return
        case 'l':  if ends.("able") endcase
                   if ends.("ible") endcase; return
        case 'n':  if ends.("ant") endcase

        // next two lines adjuseted slightly 25.9.86 for compatibility
        // with pre-mastering stemming

                   if ends.("ement") & m.() > 1 endcase
                   if ends.("ment") & m.() > 1 endcase
                        // element etc. not stripped before the m
                   if ends.("ent") endcase; return
        case 'o':  if ends.("ion") & (p%j = 's' | p%j = 't') endcase
                   if ends.("ou") endcase; return      // takes care of -ous
        case 's':  if ends.("ism") endcase; return
        case 't':  if ends.("ate") endcase
                   if ends.("iti") endcase; return
        case 'u':  if ends.("ous") endcase; return
        case 'v':  if ends.("ive") endcase; return
        case 'z':  if ends.("ize") endcase; return
        default: return
    $)
    if m.() > 1 do k := j
$)

/**
         step6.() removes a final -e if m.() > 1.
**/

and step6.() be
$(  j := k
    if p%k = 'e' do
    $(  let a = m.()
        if a > 1 | a = 1 & ~cvc.(k-1) do k := k-1
    $)
    if p%k = 'l' & doublec.(k) & m.() > 1 do k := k-1
$)

and g.cf.stem(s) be
$(  k := s%0
    if k <= 2 return  // no stemming on strings of length 1 or 2
    p := s; k0 := 1   // the string goes from p%k0 to p%k
    step1.(); step2.(); step3.(); step4.(); step5.(); step6.()
    s%0 := k  // reset the length
$)

