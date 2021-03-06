//  AES SOURCE  4.87

/**
         ERRTEXT - GET ERROR TEXT ROUTINE
         --------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         l.errtext

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         09.06.86 1        PAC      Initial version
         12.5.87  2        PAC      Adopted for AES system
         12.6.87  3        PAC      Revert to old way of doing it
**/
SECTION "errtext"

get "H/libhdr.h"
get "GH/glHD.h"
get "H/SDPHD.h"

/**
         G.UT.GET.ERMESS - FIND SYSTEM ERROR MESSAGE
         -------------------------------------------

         This routine can be called after a fault condition has
         been detected, to find the text of the operating system
         error message.

         INPUTS:

         pointer to free memory area for string
         maximum number of chars allowed for message

         OUTPUTS:

         length of string found

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:


         An example of this routine's use is given below :

         LET error.str = GETVEC( 40 )

         G.ut.get.ermess( error.str, 78 )  // find the error message
         G.sc.beep()                       // indicate fault by beeping
         G.sc.ofstr("*n%s*n",error.str )   // print error string

         FREEVEC( error.str )


         PROGRAM DESIGN LANGUAGE:

         Find address of error text in IO processor
         using stringadd = (#x00FD) {lo byte = FD, hi byte = FE}

         REPEAT Get character from this address
                Increment address

         UNTIL  character = 0 OR max chars is reached

         Set up string length

         RETURN string length
**/
LET G.ut.get.ermess( string, maxchars ) = VALOF

$(
   TKRErr( string, maxchars ) // lousy Acorn routine doesn't work
   RESULTIS string%0
$)
 /* ******************************* 

$(
   LET block   = VEC 2
   LET lo.addr = ?
   LET addr    = ?
   LET ptr     = 0
  
                             // I/O processor address
   block!0 := #xFFFF00FD     // point parameter block to #x00FD
  
   Osword( 5, block )        // get low byte of string address
  
   lo.addr := block%4
   block%0 := block%0 + 1    // point parameter block to #x00FE
  
   Osword( 5, block )        // get high byte of string address
                               
   addr := (lo.addr | (block%4 << 8)) + 1  // this is where the string is

   block%0 := addr & #xFF    // point block at string 
   block%1 := addr >> 8

   $(loop  // read the string character by character
  
      Osword( 5, block )              // get next character
  
      block!0    := block!0 + 1       // increment address
      ptr        := ptr + 1           // increment string pointer
      string%ptr := block%4           // add character to string
  
   $)loop REPEATUNTIL (string%ptr = 0) | (ptr >= maxchars)
  
   string%0 := ptr-1
  
   RESULTIS string%0
$)

****************************************************** */                       .
