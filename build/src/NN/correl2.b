//  PUK SOURCE  6.87


/**
         NM.CORREL2 - CORRELATE OPERATION FOR MAPPABLE DATA
         --------------------------------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         cnmCORR

         REVISION HISTORY:

         DATE     VERSION  AUTHOR   DETAILS OF CHANGE
         16.06.86 1        D.R.Freed   Created from CORREL
                                          to compile
         *****************************
         21.7.87     2     DNH      CHANGES FOR UNI

         g.nm.calc.correlation
**/

section "nmcorrel2"

$<RCP
needs "FLAR1"
needs "FLAR2"
needs "FLCONV"
needs "FLSQRT"
$>RCP

get "H/libhdr.h"
$<RCP
get "H/fphdr.h"
$>RCP
get "GH/glhd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nmhd.h"


/*
      g.nm.calc.correlation

         calculates the Spearman's Rank correlation coefficient and
         displays the results, given two sets of adjusted ranks each
         with a tie correction factor
*/

let g.nm.calc.correlation (num.ranks, ranks.a, fp.tie.factor.a,
                                       ranks.b, fp.tie.factor.b) be
$(
   let diff32     = vec 1
   and diff.sqr32 = vec 1
   and ssd48 = vec 2    // for accumulating the Sum of the Squares of the
                        //                      Differences
   and fp.ssd = vec FP.LEN
   and fp.correlation = vec FP.LEN
   and fp.significance = vec FP.LEN
   and fp.n = vec FP.LEN
   and fp.n.cubed.minus.n = vec FP.LEN
   and fp.constant = vec FP.LEN
   and fp.npwr = vec FP.LEN
   and fp.temp = vec FP.LEN

   // initialise sum

   g.ut.set48 (0, 0, 0, ssd48)

   // calculate the sum of the squares of the differences between the two
   // sets of ranks. Note that since each rank was multiplied by two (to
   // handle ties), the sum of the squares of differences needs dividing
   // by 2*2 = 4, to derive the final result

   for i = 0 to (num.ranks - 1) do
      $(
         g.ut.set32 (ABS (ranks.a!i - ranks.b!i), 0, diff32)
         g.ut.mov32 (diff32, diff.sqr32)     // copy it
         g.ut.mul32 (diff32, diff.sqr32)
    // square it
         g.nm.mpadd (diff.sqr32, ssd48)
     // add in the square
      $)

   // convert the sum to FP for further calculations
   g.nm.int48.to.fp (ssd48, fp.ssd)

   // divide by 4 to correct for shifted ranks
   FDIV (fp.ssd, FFLOAT (4, fp.temp), fp.ssd)

   // calculate the corrected correlation coefficient

   FFLOAT (num.ranks, fp.n)

   // (n^3 - n) is used repeatedly in the calculations
   FMINUS (
           FMULT (FMULT (fp.n, fp.n, fp.npwr),
                  fp.n,
                  fp.npwr),
           fp.n,
           fp.n.cubed.minus.n)

   // calculate X and Y which are functions of the tie correction factors
   // for variables A and B

   FMINUS (
           FDIV (fp.n.cubed.minus.n, FFLOAT (12, fp.constant), fp.temp),
           fp.tie.factor.a,
           fp.tie.factor.a)
   FMINUS (fp.temp, fp.tie.factor.b, fp.tie.factor.b)

   FPEXCEP := 0

   // the corrected correlation coefficient
   FDIV (
         FMINUS (
                 FPLUS (fp.tie.factor.a, fp.tie.factor.b, fp.temp),
                 fp.ssd,
                 fp.temp),
         FMULT (
                FFLOAT (2, fp.constant),
                FSQRT (FMULT (fp.tie.factor.a, fp.tie.factor.b, fp.npwr),
                       fp.npwr),
                fp.npwr),
         fp.correlation)

   // check for special case where one (or both) datasets are entirely
   // uniform; this results in a coefficient = 0/0 which generates an
   // illegal value. the correct statistical answer in these cases is 0
   // which will fail the significance test
   if FPEXCEP ~= 0 then
      FFLOAT (0, fp.correlation)

   // calculate the F-statistic to see if the correlation is significant

   FFLOAT (num.ranks - 2, fp.n)

   FABS (
         FMULT (
                fp.correlation,
                FSQRT (
                       FDIV (
                             fp.n,
                             FMINUS (FFLOAT (1, fp.constant),
                                     FMULT (
                                            fp.correlation,
                                            fp.correlation,
                                            fp.ssd),
                                     fp.temp),
                             fp.significance),
                       fp.npwr),
               fp.significance),
         fp.significance)

$<debug
if g.ut.diag () then
$(
g.sc.mess ("")
g.sc.movea (m.sd.message, m.sd.mesxtex, m.sd.mesytex)
g.sc.oprop ("F: ")
g.nm.fpwrite (WRITEFP, fp.significance, 20, 3)
g.ut.wait (300)
$)
$>debug

   test FCOMP (fp.significance, FFLOAT (2, fp.temp)) < 0 then
      g.sc.mess ("Correlation is not significant")
   else
      $(
         g.sc.mess ("")
         g.sc.movea (m.sd.message, m.sd.mesxtex, m.sd.mesytex)
         g.sc.oprop ("Correlation:")
         g.nm.fpwrite (WRITEFP, fp.correlation, 6, 3)
// WRITEFP(fp.correlation, 6, 3)
         g.sc.ofstr (" %c%n %s", '(', num.ranks, "data points)")
      $)
$)

.
