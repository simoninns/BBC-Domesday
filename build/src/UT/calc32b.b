//  AES SOURCE  4.87

/**
         UT.B.CALC32B - 32 Bit calculations: BCPL
         ----------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         17.1.86  1        DNH         Initial version
         12.5.87    2      PAC         Adopted for AES 32 bit system
                                       no return value for add32 
         10.6.87    3      PAC         change m.ut.lt, etc.
         31.7.87    4      PAC         Make add32 return value

         globals:    

         g.ut.add32     unsigned 32 bit addition
         g.ut.sub32     unsigned 32 bit subtraction
         g.ut.mul32     unsigned 32 bit multiplication
         g.ut.div32     unsigned 32 bit division

         g.ut.cmp32     signed compare of 32 bit numbers
**/

section "calc32b"

get "H/libhdr.h"
get "GH/glhd.h"
get "H/uthd.h"

/**
         G.UT.ADD32 - Add 2 32-bit numbers
         ---------------------------------

         INPUTS:

         a32adr, b32adr - addresses of 32-bit numbers

         OUTPUTS:

         Returns TRUE for carry, FALSE otherwise

         32 bit sum stored in b32adr

         PROGRAM DESIGN LANGUAGE:

         g.ut.add32 (a32adr, b32adr)
         ---------------------------
         BCPL:  b32 := b32 + a32
**/

// signed version  no good ++++++++
// LET G.ut.add32( a32adr, b32adr ) BE !b32adr := !b32adr + !a32adr

LET G.ut.add32 (a32adr, b32adr) = VALOF
$(
   let carry = FALSE       // unless set later on...
   let a = !a32adr >> 2    // avoid problems with top bits: unsigned add
   let b = !b32adr >> 2
   let ex = (!a32adr & #X03) + (!b32adr & #X03)  // bottom 2 bits

   if ex > #X03 do
   $(
      b := b + 1   // add in carry from mini-add 
      ex := ex & #X03
   $)

   b := b + a

   if b > #X3fffffff do      // next-to-top bit set by add
   $(
      carry := TRUE
      b := b & #X3fffffff
   $)

   !b32adr := (b << 2) + ex    // shift back left again; add in bottom 2 bits
   RESULTIS carry
$)

/**
         G.UT.SUB32 - Subtract 2 32-bit numbers
         --------------------------------------

         +++++++++++++++++++  THIS IS NOT UNSIGNED YET  ++++++++++++++++

         INPUTS:

         a32adr, b32adr - addresses of 32-bit numbers

         OUTPUTS:

         32 bit difference stored in b32adr

         PROGRAM DESIGN LANGUAGE:

         g.ut.sub32 (a32adr, b32adr)
         ---------------------------
         BCPL:      !b32 := !b32 - !a32
**/          

AND G.ut.sub32( a32adr, b32adr ) BE !b32adr := !b32adr - !a32adr
                                             
/**
         G.UT.MUL32 - Multiply 2 32-bit numbers
         --------------------------------------

         INPUTS:

         a32adr, b32adr - addresses of 32-bit numbers

         OUTPUTS:

         32 bit product stored in b32adr, 
         result FALSE if overflow

         PROGRAM DESIGN LANGUAGE:

         g.ut.mul32 (a32adr, b32adr)
         ---------------------------
         BCPL:   b32 := b32 * a32
     
         Called from as:
          ok := g.ut.mul32 (a32adr, b32adr)
 
         so that on return a32 is unaltered and b32adr
         points to (b32 * a32).
         Inputs: word addresses of two 32 bit numbers.
         Outputs: 32 bit product of the two numbers stored in the
         32 bits pointed to by the word address in parameter 2.
         FALSE (0) is returned to BCPL calling procedure and b32
         is unaltered if overflow occurs.  a32 is never altered. 

         This procedure uses MULDIV to evaluate the 64 bit result
          a32 * b32 / #x40000000 - in other words, the 64 bit 
         product of a & b, shifted right 30 so as to fit into the 
         procedure result, and the global Result2. The final return
         value is obtained by ORing the remainder (i.e. the low 30
         bits of the product) with the bottom two bits of the result.

         A picture may help:
                          -------------------------------- 
         a32 * b32  -->  |  64 bit intermediate product   |
                          --------------------------------

         shift right 30 puts it into result & result2 like this:

                          ---------------------------------                                              | |    Result    | |   Result2    |
                          ---------------------------------
                          ^ 2 bits      ^   ^ low 30 bits
                         of result lost | top 2 bits

         Note that the top two bits of the 64 bit product are lost,
         so there is an area of uncertainty in the result.

**/

AND G.ut.mul32( a32adr, b32adr ) = VALOF
$(
   Let a,b,r = !a32adr, !b32adr, ?

   r := MULDIV( a, b, #x40000000 ) // divide by 2^30 i.e. shift R 30 bits

   if r >> 2 ~= 0 resultis false   // N.B. doesn't check top 2 bits 
                                   // of 64 bit result
 
   !b32adr := result2 | r << 30    // put number back together   
   
   resultis TRUE
$)
                                             
/**
         G.UT.DIV32 - Divide 2 32-bit numbers
         ------------------------------------

         INPUTS:

         a32adr, b32adr, c32adr - addresses of 32-bit numbers

         OUTPUTS:

         32 bit quotient  stored in b32adr,
         32 bit remainder stored in c32adr
         result FALSE if divide by zero

         PROGRAM DESIGN LANGUAGE:

         g.ut.div32 (a32adr, b32adr, c32adr)
         -----------------------------------
         Called from Cintcode as:
            ok := g.ut.div32 (a32adr, b32adr, c32adr)
         so that on return a32 is unaltered and b32
         contains (b32 / a32), c32 contains (b32 rem a32).
         Effectively:  c32 := b32 rem a32
                       b32 := b32 / a32
 
         Outputs: 32 bit quotient in b32, and 32 bit
         remainder in c32.
         FALSE (0) is returned to BCPL calling procedure and b32
         and c32 are unaltered if divide by zero occurs.  a32 is
         never altered.
**/
AND G.ut.div32( a32adr, b32adr, c32adr ) = VALOF
$(         
   LET a,b,q,r = !a32adr, !b32adr, ?,?

   if a = 0 resultis false

   !b32adr := muldiv( 1, b, a ) ; !c32adr := Result2
  
   resultis true
$)

/**
         G.UT.CMP32 - Compare two 32 Bit Signed numbers
         ----------------------------------------------

         rc := g.ut.cmp32 (a32s.adr, b32s.adr)

         INPUTS:
         a32s.adr, b32s.adr: address of 32 bit parameters

         OUTPUTS:
         rc: set to one of the manifests in 'uthdr':
            m.lt <=> a32 < b32
            m.eq <=> a32 = b32
            m.gt <=> a32 > b32
            Both numbers are unchanged by the function.

         GLOBALS MODIFIED: none

         SPECIAL NOTES FOR CALLERS: this is a SIGNED compare, cf.
         the other calc32 procedures. The result manifests are 
         declared in glhdr, so you don't have to get "UTHDR". 

         PROGRAM DESIGN LANGUAGE:

         g.ut.cmp32 (a32s.adr, b32s.adr) = value  

         if a2 < b2 = m.lt
         if a2 > b2 = m.gt
               else = m.eq
**/

let g.ut.cmp32 (a32s.adr, b32s.adr) = valof
$(
   let a2 = a32s.adr!0
   let b2 = b32s.adr!0
   
   resultis a2 < b2 -> m.lt,
            a2 > b2 -> m.gt, m.eq
$)
.
