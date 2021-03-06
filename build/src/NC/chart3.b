//  PUK SOURCE  6.87

/**
         CHART GRAPHICS ROUTINES - 1
         ---------------------------

         NAME OF FILE CONTAINING RUNNABLE CODE:

         r.chart

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
          3.11.86 13       SRY         Another scale fix
          7.11.86 14       SRY         Another animation fix
*******************************************************************************
          2.06.87 15       SRY         Changes for UNI
         12.08.87 16       SRY         Modified for DataMerge
         14.08.87 17       SRY         Changed g.nc.clear calls
                                       and narrow chars
         25.08.87 18       SRY         Abb calc. tuned
         21.09.87 19       SRY         Floating point
**/

section "chart3"

get "H/libhdr.h"
get "GH/glhd.h"
get "GH/glNChd.h"
get "GH/glNMhd.h"
get "H/sdhd.h"
get "H/nchd.h"

static
$( sv=? cv=? cc=? gcts=? vals=? d=? c.g=? bw=? vp=? b=? nb=? a=? sy=? abb=?
   xk=? yk=? vps=? sgnd=? buff=? o.nm=?
$)

/**
         g.nc.draw.chart
         ---------------

         Draw any chart
**/

let g.nc.draw.chart(g.f) be
$( let a1 = vec 4*m.nc.values.words // enough for 4 datasets
   a := a1
   cc := G.nc.area!m.nc.cc
   sv,cv := G.nc.area!m.nc.sv,G.nc.area!m.nc.cv
   gcts := G.nc.area+m.nc.gcats
   vp,vps := gcts+cv*m.nc.gpwords,gcts+sv*m.nc.gpwords
   vals := G.nc.area+m.nc.values
   buff := g.nc.area!m.nc.name.buff
   sgnd := ((g.nc.area%m.nc.dsize) & #x80) ~= 0
   g.sc.pointer(m.sd.off)
   unless cc=m.nc.mtslg
   $( move(vals, a, m.nc.values.words)
      unless g.f=0
      $( g.nc.getdata()
         if g.nc.area!m.nc.l.s=m.nc.error goto exit
         if cc=m.nc.looping
         $( g.nc.varkey()
            g.sc.pointer(m.sd.off)
         $)
      $)
   $)
   nb := g.nc.area!m.nc.nb
   switchon cc into
   $( case m.nc.pie:
         pie()
      endcase
      case m.nc.stslg:
         g.nc.area!m.nc.lc := m.nc.unknown
         bhead()
         lgraph(vals,1,false)
         bend()
      endcase
      case m.nc.mtslg:
         unless mlineg() goto exit
      endcase
      case m.nc.btob:
         btob()
      endcase
      default: // bar chart
      $( let an=bhead()
         for n=1 to nb bar(n,(n-1)*bw,n.gr(cv),((n & 1) << 3)+2,an)
         bend()
      $)
   $)
   g.sc.selcol(m.sd.cyan)
   tab(m.nc.tx,m.nc.ty)
   g.sc.rect(m.sd.clear,m.nc.tw,m.nc.td)
   tab(m.nc.tx,m.nc.ty+m.nc.td-12)
   g.sc.mover(484-(g.sc.width(g.nc.area+m.nc.labels.b/bytesperword) >> 1),0)
   g.sc.oprop(g.nc.area+m.nc.labels.b/bytesperword)
   g.nc.area!m.nc.lc := d -> cc,m.nc.unknown
exit:
   G.sc.pointer(m.sd.on)
$)

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//           Utility Routines used by Chart drawing only                    //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

and btob() be
$( let x,bn,s,an=0,0,0,0
   let sinc,cinc=vps!m.nc.incg,vp!m.nc.incg
   let save=!vps
   bw := (m.nc.cw << 1)/((nb << 1)+cinc-1)
   g.nc.area!m.nc.bw := bw
   bw := (((bw*sinc) << 1)+bw) >> 1 // work out abb's on clusterwidth
   an := bhead()
   bw := g.nc.area!m.nc.bw
   box(0,m.nc.xay,m.nc.xaw,m.nc.xad-84)
   for n=1 to cinc  // each group of current variable
   $( s := n.gr(cv)
      !vps := m.nc.all
      for m=1 to sinc  // each group of sec. variable
      $( bn := bn+1
         bar(bn,x,s,m*3,an) // if you change m*3,change end of bar!
         if (n=1) & ~an // put in key once only
         $( go.key(m,0)
            g.sc.blob()
            g.sc.selcol(m.sd.cyan)
            g.sc.mover(m.sd.charwidth,0)
            g.nc.pr(n.gr(sv),24) // 14.8
         $)
         x := x+bw
      $)
      x := x+(bw >> 1)
   $)
   !vps := save
   bend()
$)

and bar(n,x,str,c,an) be
$( let xpos=x+m.nc.origx+4
   let ypos=m.nc.origy+sy
   let new=scale(vals,n)
   let b4=bw-4
   g.sc.ecf(c)
   test an // animate bar
   then $( let s,flat=4,?
           let old=scale(a,n)
           let maxh=580-sy
           // Both bars too big and same sign
           if abs(new) > maxh & abs(old) > maxh &
              abs(new)*abs(old) >= 0 return
           if ((old >= 0) & (new < 0)) | ((old < 0) & (new >= 0))
           $( tab(xpos,ypos) // clear bar from opposite side of zero
              g.sc.rect(m.sd.clear,b4,maxh*sgn(old))
              old := 0
           $)
           flat := abs(new)=maxh
           if abs(new) > maxh new := maxh*sgn(new) // truncate at maxh
           if abs(old) > maxh old := maxh*sgn(old)
           test abs(old) > abs(new) // shrink bar towards zero
           then $( g.sc.selcol(m.sd.black)
                   if new >= 0 s := -s
                $)
           else if new < 0 s := -s  // grow bar
           while abs(old-new) >= 4 // same sign now
           $( tab(xpos,old+ypos) // do the animation
              g.sc.rect(m.sd.plot,b4,s)
              old := old+s
           $)
           if (abs(new) >= maxh) & (~flat)  // triangle at top of bar
           $( let dir=sgn(new)
              tab(xpos,ypos+(maxh-24)*dir)
              g.sc.selcol(m.sd.black)
              g.sc.rect(m.sd.plot,b4,24*dir)
              tab(xpos,ypos+(maxh-24)*dir)
              g.sc.ecf(c)
              g.sc.triangle(m.sd.plot,b4,0,-(bw>>1),20*dir)
           $)
           g.ut.wait(m.nc.aw)
        $)
   else $( tab(xpos,ypos)
           g.sc.rect(m.sd.plot,b4,new)
           if cc ~= m.nc.btob | c = 3 blab(xpos,str)
           g.sc.ecf(c) // reset for blob
        $)
$)

and pie() be
$( let sx,sy,sa=0,m.nc.radius,-31416 // init. angle - pi
   let nosec=false
   let fp = vec FP.LEN
   d := false
   g.nc.clear(m.sd.clear,m.nc.chart)
   box(0,m.nc.cy,952,m.nc.cd)
   box(0,m.nc.xay,m.nc.xaw,m.nc.xad)
   for n = vals to vals+(nb-1)*3 by 3
   $( g.nm.int48.to.fp(n, fp)
      if FSGN(fp) = -1
      $( g.sc.ermess("Negative values")
         return
      $)
   $)
   if FSGN(g.nc.area+m.nc.sampsiz) = 0
   $( g.sc.ermess("All values in this chart are zero")
      return
   $)
   bw := 256
   g.nc.area!m.nc.bw := 256
   c.g := !vp
   test vp!m.nc.incg <= 4
   then $( abb := false
           g.nc.area!m.nc.abbrevs := false
        $)
   else a.n()
   !vp := m.nc.all
   for n=1 to nb // draw sectors and key
   $( g.sc.ecf(n)
      unless nosec
      $( let x,y = -4,m.nc.radius-4
         nosec := rest.zero(n)
         sa := sa + piscale(n)
         unless nosec // close up last non-zero sector!
            x,y := muldiv(-sin(sa),m.nc.radius,10000),
                   muldiv(-cos(sa),m.nc.radius,10000)
         tab(m.nc.centrex,m.nc.centrey)
         g.sc.sec(m.sd.plot,x,y,sx-x,sy-y)
         sx,sy := x,y
      $)
      tab( ((n-1) >> 2)*320+8,200-((n-1) rem 4)*40 )
      g.sc.blob()
      plab(n.gr(cv))
   $)
   xlab(232)
   !vp := c.g
   d := true
$)

and mlineg()=valof
$( let save,sinc=!vps,vps!m.nc.incg
   g.nc.area!m.nc.lc := m.nc.unknown
   !vps := m.nc.all
   for i=m.nc.values.words*2 to m.nc.values.words*4 a!i := 0
   for i=1 to sinc // read up to four charts into store
   $( n.gr(sv)
      g.nc.getdata()
      if g.nc.area!m.nc.l.s=m.nc.error resultis false
      move(vals, a+(i-1)*m.nc.values.words, m.nc.values.words)
   $)
   nb := g.nc.area!m.nc.nb
   bhead() // this scales the whole thing
   box(0,m.nc.xay,m.nc.xaw,120)
   !vps := m.nc.all
   for i=1 to sinc // plot the charts
   $( let s=n.gr(sv)
      lgraph(a+(i-1)*m.nc.values.words,i,i~=1)
      go.key(i,16)
      g.sc.dot(xk,yk-20,xk+32,yk,i)
      g.sc.selcol(m.sd.cyan)
      g.nc.pr(s,24) // 14.8
   $)
   bend()
   !vps := save
   resultis true
$)

and lgraph(vr,col,k.d) be // draw a line graph
$( let oldx,oldy=0,0
   for n=1 to nb
   $( let x=n*bw-(bw >> 1)+4+m.nc.origx
      let y=scale(vr,n)+m.nc.origy+sy
      let s=n.gr(cv)
      unless k.d blab(x-(bw >> 1),s)
      unless oldx=0
      $( g.sc.selcol((col & 1)+1)
         g.sc.dot(oldx,oldy,x,y,col)
      $)
      oldx,oldy := x,y
   $)
$)

AND Xlab(y) BE // Print xaxis
$( LET w=vptr(cv)
   let s=G.ut.align(G.nc.area,w,buff,m.nc.lsize.b)
   w := G.sc.n.width(s) // 14.8
   IF w > 960 w := 960
   g.sc.selcol(m.sd.cyan)
   tab((952-w)/2,y)
   g.nc.Pr(s,60) // 14.8
$)

and bhead()=valof // y-axis and x-axis
$( c.g := !vp
   unless cc=m.nc.btob
   $( bw := 768/nb
      g.nc.area!m.nc.bw := bw
   $)
   if cc=g.nc.area!m.nc.lc
   $( let an=true
      let fp = vec FP.LEN
      if sy > 0 resultis true // can animate if axis in middle
      for n=vals to vals+(nb-1)*3 by 3
      $( g.nm.int48.to.fp(n, fp)
         if FSGN(fp) = -1
         $( an := false
            break // negative data with axis at bottom
         $)
      $)
      if an resultis true
   $)
   d := false
   g.nc.clear(m.sd.clear,m.nc.chart)
   g.nc.vertical(cc=m.nc.mtslg -> a,vals)
   sy := g.nc.area!m.nc.sy
   xlab(192)
   a.n()
   !vp := m.nc.all
   resultis false
$)

and bend() be // tidy up
$( g.sc.selcol(m.sd.cyan)
   !vp := c.g
   line(m.nc.origx,m.nc.origy+sy,952,m.nc.origy+sy)
   d := true
$)

and blab(x,str) be // label for bar-abb. or name
$( let w=abb -> m.sd.charwidth,g.sc.n.width(str)
   tab(x+(bw-w)/2,240)
   plab(str)
$)

and plab(s) be // print label or abbreviation
$( g.sc.selcol(m.sd.cyan)
   test abb
   then $( let s1="  = "
           let ab=s%(o.nm -> m.nc.oaoff,m.nc.aoff)
           g.sc.ofstr("%c",ab)
           if d return
           g.nc.clear(m.sd.clear,m.nc.ab.key)
           s1%1 := ab
           g.sc.oprop(s1)
           d := true
           g.nc.area!m.nc.ca := b
           g.sc.oprop(s)
        $)
   else g.sc.narrow(s)
$)

and scale(ptr,n)=valof // scaled value of 'bar'
$( let res = ?
   let t = vec 2
   let fp1 = vec FP.LEN
   let fp2 = vec FP.LEN
   let zero = vec 1
   let temp. = vec 0

   G.ut.set32(0, 0, zero)
   g.nm.int48.to.fp(ptr+(n-1)*3, fp1)
   G.ut.movebytes(g.nc.area+m.nc.sf, 0, t, 0, 4)
   !temp. := g.ut.cmp32(t, zero) = m.lt -> #xffff, 0
   G.ut.movebytes(temp., 0, t, 4, 2)
   g.nm.int48.to.fp(t, fp2)
   FMULT(fp1, fp2, fp1)
   FFLOAT(g.nc.area!m.nc.int, fp2)
   FDIV(fp1, fp2, fp1)
   FDIV(fp1, g.nc.area+m.nc.soc, fp1)
   FFLOAT(-30000, fp2)
   test FCOMP(fp1, fp2) = -1
   then FFLOAT(-30000, fp1)
   else $( FFLOAT(30000, fp2)
           if FCOMP(fp1, fp2) = 1 FFLOAT(30000, fp1)
        $)
   res := FFIX(fp1)
   if (g.nc.area!m.nc.sy = 0) & (res < 0) res := 0
   resultis (res >> 2) << 2 // Mult of 4.
$)

and piscale(n) = valof // scaled value of pi seg angle
$( let fp1 = vec FP.LEN
   let fp2 = vec FP.LEN
   FFLOAT(31416, fp2)
   g.nm.int48.to.fp(vals+(n-1)*3, fp1)
   FMULT(fp1, fp2, fp1)
   FDIV(fp1, g.nc.area+m.nc.sampsiz, fp1)
   resultis 2*FFIX(fp1)  // angle in radians (* 10000)
$)

and rest.zero(n) = valof
$( for i = n + 1 to nb unless 0 <= piscale(i) <= 100 resultis false
   resultis true                            // approx 1/2 degree
$)

and a.n() be // abbs nec ?
$( g.nc.area!m.nc.abbrevs := false
   g.nc.area!m.nc.ca := m.nc.unknown
   !vp := m.nc.all
   for n=1 to nb
      if (n.gr(cv))%0 > ((bw-4) >> 4) // was >> 5; 14.8.87. -4 added 25.8
      $( g.nc.area!m.nc.abbrevs := true
         abb := true
         return
      $)
   abb := false
$)

and go.key(m,x) be
$( xk := 8+(1-(m & 1))*476+x
   yk := 144-((m-1) >> 1)*40
   tab(xk,yk)
$)

AND vptr(v)=valof // Byte offset to variable name
$( let l=1
   for i=1 to v-1 l := l+g.nc.cats(i)+1
   resultis m.nc.labels.b+l*m.nc.lsize.b
$)

and n.gr(v)=valof // Byte offset to name of next group of variable
$( let vp=gcts+v*m.nc.gpwords
   let r=?
   b := g.nc.next.group(v)
   test (b & #xff00)=0
   then for i=1 to g.nc.cats(v)
           if vp!i=b
           $( r := vptr(v)+i*m.nc.lsize.b
              o.nm := false
              break
           $)
   else $( o.nm := true
           r := m.nc.gname*bytesperword+(b >> 8)*m.nc.olsize.b
        $)
   resultis G.ut.align(G.nc.area,r,buff,m.nc.lsize.b)
$)

and line(sx,sy,ex,ey) be
$( tab(sx,sy)
   g.sc.linea(m.sd.plot,m.sd.display,ex,ey)
$)

and box(x,y,w,d) be
$( let xm=x+w
   let ym=y+d
   g.sc.selcol(m.sd.blue)
   line(x,y+4,x,ym-4)
   line(x+4,ym,xm-4,ym)
   line(xm,ym-4,xm,y+4)
   line(xm-4,y,x+4,y)
$)

and sgn(n)=n < 0 -> -1,(n=0 -> 0,1)

and tab(x,y) be g.sc.movea(m.sd.display,x,y)
.

