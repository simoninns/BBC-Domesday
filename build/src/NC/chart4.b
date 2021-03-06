//  PUK SOURCE  6.87

/**
         CHART WRITE and VALUES
         ----------------------

         This section contains :

            G.nc.write
            G.nc.value
            g.nc.fpout

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
       11.03.87   8        SRY         Potential bug in Write
*******************************************************************************
        2.06.87   9        SRY         Changes for UNI
       13.08.87  10        SRY         Modified for DataMerge
       21.09.87  11        SRY         Floating point
       23.09.87  12        SRY         Download bug
       05.01.88  13        MH          Update to flush to stop writing extra
                                       space when last char is <CR>
**/

section "chart4"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nchd.h"
get "H/uthd.h"

static $( bcount=? byteinset=? dataset=? size=? signed=? offset=? buffer=?
          datasize=? small.length=? lsize=? read.cell=? value=? buff=?
          r.err=?
       $)

/**
         G.NC.VALUE
         ----------

         Display value of part of chart
**/

let g.nc.value() be
$( let cc = g.nc.area!m.nc.cc
   buff := G.nc.area!m.nc.name.buff
   g.sc.pointer(m.sd.off)
   test cc = m.nc.stslg | cc = m.nc.mtslg
   then get.y.value()
   else bar.value()
   g.sc.pointer(m.sd.on)
$)

and bar.value() be
$( let barno = g.nc.area!m.nc.bn
   unless barno = m.nc.unknown
   $( let fp = vec FP.LEN
      g.nm.int48.to.fp(g.nc.area+m.nc.values+(barno-1)*3, fp)
      num.out(fp)
   $)
$)

and get.y.value() be
$( let yval = vec FP.LEN
   let maxval = vec FP.LEN
   let maxy = vec FP.LEN
   let two = vec FP.LEN
   FFLOAT(2, two)
   FFLOAT(G.nc.area!m.nc.int, maxY)
   move(G.nc.area+m.nc.soc, maxval, FP.LEN)
   FMULT(maxval, maxy, maxy) // Max y-value on screen
   FFLOAT(m.nc.cd+m.nc.cy-m.nc.origy, maxval)
   FFLOAT(G.ypoint-m.nc.origy, yval)
   UNLESS G.nc.area!m.nc.sy = 0
   $( FDIV(maxval, two, maxval)
      FMINUS(yval, maxval, yval)
   $)
   FMULT(maxy, yval, maxy)
   FDIV(maxy, maxval, maxy)
   num.out(maxy)
$)

and num.out(num) be
$( let s = G.ut.align(G.nc.area, m.nc.labels.b+m.nc.lsize.b,
                      buff, m.nc.lsize.b)
   let l = s%0
   if l > 30 s%0 := 30
   G.sc.mess("")
   G.sc.movea(m.sd.message, m.sd.mesXtex, m.sd.mesYtex)
   G.sc.selcol(m.sd.blue)
   G.nc.fpout(num, 8)
   G.sc.oprop(" ")
   G.sc.oprop(s)
   s%0 := l
$)

// Output floating point number
and g.nc.fpout(num, places) be
$( let neg = false
   let lo16, hi16 = ?, ?
   let exp = g.nc.area!(m.nc.norm/bytesperword)
   let fp = vec FP.LEN
   let max.32 = vec FP.LEN
   let two.to.16 = vec FP.LEN
   let t = vec 2
   g.ut.set48(#xffff, #x7fff, 0, t)
   g.nm.int48.to.fp(t, max.32)
   g.ut.set48(0, 1, 0, t)
   g.nm.int48.to.fp(t, two.to.16)

   // Deal with non-exponent norm. factor
   unless (g.nc.area%m.nc.sfe = 'E') | (exp = 0)
   $( FFLOAT(exp, fp)
      test g.nc.area%m.nc.s.f = 'D'
      then FDIV(num, fp, num)
      else FMULT(num, fp, num)
      exp := 0
   $)
   if FSGN(num) = -1
   $( neg := true
      FNEG(num, num)
   $)

   // Get fp smaller than 32 bits
   FFLOAT(10, fp)
   until FCOMP(num, max.32) = -1
   $( exp := exp + 1
      FDIV(num, fp, num)
   $)

   // Convert fp to 32-bit
   FDIV(num, two.to.16, fp)
   hi16 := un.int(fp)
   un.float(hi16, fp)
   FMULT(fp, two.to.16, fp)
   FMINUS(num, fp, fp)      // subtract from num to get remainder
   lo16 := un.int(fp)
   g.ut.set32(lo16, hi16, t)

   // Output 32-bit number
   if neg  // reverse sign
   $( !t := !t NEQV #xffff
      t!1 := t!1 NEQV #xffff
      g.ut.add32((table 1, 0), t)
   $)
   G.sc.opnum(t, exp, places)
$)

and un.int(fp) = valof // return unsigned 16-bit value of fp num in range
                       // 0 to 65535
$( let max.16 = vec FP.LEN
   FFLOAT(32767, max.16)
   test FCOMP(fp, max.16) = 1
   then $( let fp1 = vec FP.LEN
           FFLOAT(1, fp1)
           FPLUS(fp1, max.16, fp1)
           FMINUS(fp, fp1, fp)
           resultis FINT(fp) + 32768
        $)
   else resultis FINT(fp)
$)

// Float an UNSIGNED 16-bit number
and un.float(u, fp) be
   test 0 <= u <= 32767 // ok for FFLOAT
   then FFLOAT(u, fp)
   else $( let fp1 = vec FP.LEN
           FFLOAT(32767, fp1)
           FFLOAT(1, fp)
           FPLUS(fp1, fp, fp1)
           u := u - 32768
           FFLOAT(u, fp)
           FPLUS(fp, fp1, fp)
        $)


/**
         G.NC.WRITE
         ----------

         Download chart data to disc
**/

and G.nc.write() BE // Download chart data to disc
$( LET vars = G.nc.area%m.nc.vars
   LET is.exp = G.nc.area%m.nc.sfe = 'E'
   LET mult = G.nc.area%m.nc.s.f = 'M'
   LET i = m.nc.dm
   LET l = 0
   LET n = g.nc.area!(m.nc.norm/bytesperword)
   LET lptrb = m.nc.labels.b + 3 * m.nc.lsize.b
   LET max.labels = ?

   size := (((maxvec())/3) & #XFFFE) - 20 // 1/3 for reading, 1/3 for writing.
                                          // 1/3 for g.ud.write buffer.
                                          // Even no. of words.
   max.labels := size/(m.nc.lsize.b*bytesperword)
   G.sc.pointer(m.sd.off)
   signed := ((G.nc.area%m.nc.dsize) & #X80) ~= 0
   datasize := (G.nc.area%m.nc.dsize) & #X7F
   buffer := GETVEC(size)
   bcount := 0

   // Header

   do.char('T') // header
   do.char(m.ut.CR)
   lwrite(m.nc.labels.b) // title
   lwrite(m.nc.labels.b + m.nc.lsize.b) // Dependent variable name
   for v = 2 to vars
   $( let add = G.nc.area%m.nc.add = 2 -> 'N', 'A'
      let c = G.nc.area%v
      if c > 24
      $( c := G.nc.cats(v)
         add := 'N'
      $)
      two.char.num(c)
      do.char(add)
      do.char(' ')
   $)
   do.char(m.ut.CR)

   if is.exp // Norm. factor (NB - if 'D' & 'E' exp is negative.
             // See Chart0.)
      $( do.char('E')
         unless mult
         $( n := abs(n)
            do.char('-')
         $)
      $)
   two.char.num(n)
   do.char(' ')

   do.char('=')
   do.char('0' + datasize)
   unless signed do.char('U')
   do.char(m.ut.CR)

   UNTIL G.nc.area%i = 0 // Display methods
   $( two.char.num(G.nc.area%i)
      do.char(' ')
      i := i + 1
      IF i > m.nc.dm + 9 BREAK
   $)
   do.char(m.ut.CR)

   two.char.num(G.nc.area%m.nc.defdis) // Default display
   do.char(m.ut.CR)

   FOR i = 0 TO 2
   $( two.char.num(G.nc.area%(m.nc.colset+i)) // Palette
      do.char(' ')
   $)
   flush()
   IF r.err goto exit

   // Labels

   FOR v = 2 TO vars
   $( FOR c = 1 TO G.nc.cats(v) + 1 // extra one for var. name
      $( do.char(g.nc.area%(lptrb+m.nc.aoff))
         g.ut.movebytes(g.nc.area, lptrb+1, buffer, bcount, g.nc.area%lptrb)
         bcount := bcount + g.nc.area%lptrb
         do.char(m.ut.CR)
         lptrb := lptrb + m.nc.lsize.b
         l := l + 1
         IF l = max.labels
         $( flush() // deals with extra CR
            IF r.err goto exit
            l := 0
         $)
      $)
   $)
   UNLESS l = 0 flush()

   // Data
   UNLESS r.err write.data()

exit:
   FREEVEC(buffer)
   G.sc.pointer(m.sd.on)
$)

and do.char(char) be
$( buffer%bcount := char
   bcount := bcount + 1
$)

AND flush() BE  // Write out part of dataset processed so far. Reset pointer
$( IF buffer%(bcount-1) = m.ut.CR
      bcount := bcount - 1  // updated 05.01.87 MH
//      buffer%(bcount-1) := ' '  // deal with double CR
   unless g.ud.write(buffer*bytesperword, bcount, m.ut.text) = m.ut.success
      r.err := TRUE
   bcount := 0
$)

and two.char.num(number) be
   test number >= 10
   then $( do.char('0' + number/10)
           do.char('0' + number rem 10)
        $)
   else do.char('0' + number)

and lwrite(byte.p) be
$( let l = g.nc.area%byte.p > 40 -> 40, g.nc.area%byte.p
   G.ut.movebytes(g.nc.area, byte.p+1, buffer, bcount, l)
   bcount := bcount + l
   do.char(m.ut.CR)
$)

// The following routines for reading and writing the dataset are based
// on G.nc.getdata in module Chart7.

and write.data() be
$( let cells = vec 1  // there could just be more than 32k
   let dim = vec 1
   let c = vec 1      // cell count
   let one = vec 1

   g.ut.set32(1, 0, one)
   env(1)
   if r.err goto error

   g.ut.mov32(one, cells)
   for v = 2 to g.nc.area%m.nc.vars // cell count = product of all dimensions
   $( g.ut.set32(g.nc.cats(v), 0, dim)
      g.ut.mul32(dim, cells)
   $)

   g.ut.set32(0, 0, c)
   $( g.ut.add32(one, c)
      if g.ut.cmp32(c, cells) = m.gt break // (for c = 1 to cells)

      // Pad to 4 bytes with spaces for benefit of do.32.line
      unless (bcount & 3) = 0 for i = 1 to 4 - (bcount & 3) do.char(' ')

      // Write out number to buffer
      g.ud.do.32.line(buffer+bcount/bytesperword, read.cell(), 1)
      bcount := bcount + 12
      do.char(((!c) & 3) = 0 -> m.ut.CR, ' ') // CR every 4th

      // Size is now bytes: leave 1 line (40 chars) for next 32.line
      if bcount >= size - 40 flush()
      if r.err goto error
      inc.pointer()
      if r.err goto error
   $) repeat
   flush()

error:
   env(2)
$)

and env(start.finish) be
   test start.finish = 1
   then $( let size.needed = vec 1
           offset := getvec(1) // byte offset in data file of chunk of dataset
           small.length := getvec(1) // | data1 | minus maxvec size - in bytes
           lsize := getvec(1)        // size in 32 bits
           value := getvec(1)
           read.cell := valof switchon datasize into
           $( case 1: resultis read.cell1
              case 2: resultis read.cell2
              case 4: resultis read.cell4
           $)

           dataset := getvec(size)
           size := size * bytesperword // Now bytes
           G.ut.set32(size & #XFFFF, size >> 16, lsize)

           // Work out size needed and truncate buffer if nec.
           G.ut.set32(datasize, 0, size.needed)
           for i = 1 to G.nc.area%m.nc.vars
           $( let t = vec 1
              G.ut.set32(G.nc.cats(i), 0, t)
              G.ut.mul32(t, size.needed)
           $)
           if G.ut.cmp32(size.needed, lsize) = m.lt
              G.ut.mov32(size.needed, lsize)
           G.ut.mov32(G.nc.area+m.nc.dataptr, offset)

           g.dh.length(g.nc.area!m.nc.handle, small.length)
           g.ut.sub32(lsize, small.length)
           g.ut.sub32(lsize, offset)
           read.data()
        $)
   else $( freevec(dataset)
           freevec(offset)
           freevec(small.length)
           freevec(lsize)
           freevec(value)
        $)

and inc.pointer() be  // increment pointer, reading data if necessary
$( byteinset := byteinset + datasize
   if byteinset >= size read.data()
$)

and read.data() be
$( g.ut.add32(lsize, offset)
   if g.ut.cmp32(offset, small.length) = m.gt
   $( g.ut.add32(lsize, small.length)
      g.ut.sub32(offset, small.length)
      g.ut.mov32(small.length, lsize)
   $)
   if g.ud.read(g.nc.area!m.nc.handle, offset, dataset, !lsize) = 0
   $( r.err := true
      g.nc.area!m.nc.l.s := m.nc.error
   $)
   byteinset := 0
$)

and read.cell1() = valof  // get value of 1-byte cell
$( let v = dataset%byteinset
   test (~signed) | (v < #x80)
   then G.ut.set32(v, 0, value)
   else G.ut.set32(v | #Xff00, #Xffff, value)
   resultis value
$)

and read.cell2() = valof  // get value of 2-byte cell
$( let v = signed -> G.ut.unpack16.signed(dataset, byteinset),
                     G.ut.unpack16(dataset, byteinset)
   !value := v
   value!1 := ((v >= 0) | (~signed)) -> 0, #XFFFF
   resultis value
$)

and read.cell4() = valof  // get value of 4-byte cell
$( g.ut.unpack32(dataset, byteinset, value)
   resultis value
$)
.
