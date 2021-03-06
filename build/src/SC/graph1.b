//  $MSC
//  AES SOURCE  4.87

/**
         SC.GRAPH1 - GRAPHICS PACKAGE FIRST PART
         ---------------------------------------

         The graphics package uses the file SDHDR to define
         various manifest constants for calling graphics
         primitives. Notable ones are :

         Those used for 'system' in calls :

         m.sd.menu, m.sd.display, m.sd.message, m.sd.none

         Those used for 'type' in calls :

         m.sd.plot, m.sd.clear, m.sd.invert

         These determine whether the object is plotted, cleared
         or inverted (i.e. plotted in graphics foreground,
         background or logical inverse colours). Different rules
         apply for the block copy/move operation; see the note
         below.

         Procedures in GRAPH1 are:

         G.sc.movea       - move absolute
         G.sc.linea       - line absolute
         G.sc.mover       - move relative
         G.sc.liner       - line relative
         G.sc.triangle    - draw a triangle
         G.sc.rect        - draw a rectangle
         G.sc.sec         - draw a sector
         G.sc.parallel    - draw a parallelogram

         ***********************************************
         the following procedures removed 28.5.86
         G.sc.circ        - draw a circle filled
         G.sc.cout        - draw a circle outline
         G.sc.elips       - draw an ellipse filled
         G.sc.ellout      - draw an ellipse outline
         G.sc.arc         - draw an arc
         G.sc.seg         - draw a segment
         G.sc.movcop      - move/copy block
         G.sc.floodnbg    - flood fill to non background
         G.sc.floodfg     - flood fill to foreground
         ***********************************************

         NAME OF FILE CONTAINING RUNNABLE CODE:

         kernel

         REVISION HISTORY:

         DATE     VERSION  AUTHOR      DETAILS OF CHANGE
         30.04.87 1        PAC         ADOPTED FOR AES SYSTEM
         24.07.87 2        PAC         Remove mouse pointer calls
**/

section "sc.graph1" // graphics package first chunk

get "H/libhdr.h"
get "H/syshdr.h"
get "GH/glhd.h"
get "H/sdhd.h"   // manifests header
get "H/sdphd.h"  // private manifests

// private routine plot takes all the graphics output
// and switches off the mouse pointer before any o/p
let plot ( p1,p2,p3 ) be
$( // let oldstate = g.sc.pointer( m.sd.off )
   vdu ("25,%,%;%;",p1,p2,p3)
   // g.sc.pointer ( oldstate )
$)

/**
         The procedures given below are all very short, as they
         consist mainly of a translation from a BCPL routine to a
         BBC VDU driver command. For this reason, a separate
         procedure banner is not used for each one. The routines
         make use of the GXR facilities, which are documented in
         the GXR user manual, and BBC MASTER manual part 1.

         G.SC.MOVEA - MOVE TO ABSOLUTE POSITION
         G.SC.LINEA - DRAW LINE TO ABSOLUTE POSITION
         -------------------------------------------

         G.SC.MOVEA moves to an absolute position in Domesday
                    coordinates

         G.SC.LINEA draws a line from the current position to the
                    Domesday point specified

         INPUTS:

         g.sc.movea ( co-ord system, absolute position X,
                                     absolute position Y )

         g.sc.linea ( plot type, co-ord system, absolute end X,
                                                absolute end Y )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         G.SC.MOVEA requires the Domesday coodinate system, and
         two points, which are OFFSETS from that system's origin,
         to define the screen position to which the cursor will
         be moved.

         G.SC.LINEA has an additional parameter, plot type, which
         defines whether the plot is in foreground or background
         colour. Manifests to use are :
               m.sd.plot, m.sd.clear, m.sd.invert.

**/

// g.sc.movea moves cursor to given absolute position
let g.sc.movea ( sys,posX,posY ) be
$( $<debug
      G.ut.trap ("SC",1,false,3,posX,0,1280 )
      G.ut.trap ("SC",2,false,3,g.sc.dtob(sys,posY),0,1024)
   $>debug

   VDU ("25,%,%;%;",m.sd.movA, posX, g.sc.dtob( sys,posY ))
$)

// g.sc.linea draws a line from present position to absolute end X,Y
and g.sc.linea ( type,sys,endX,endY ) be
$( $<debug
      G.ut.trap ("SC",3,false,3,endX,0,1280 )
      G.ut.trap ("SC",4,false,3,g.sc.dtob(sys,endY),0,1024)
   $>debug

   plot ( type+4, endX, g.sc.dtob (sys,endY))
$)

/**
         G.SC.MOVER - MOVE RELATIVE
         G.SC.LINER - DRAW LINE RELATIVE
         -------------------------------

         G.SC.MOVER moves the cursor relative to the current
                    point by the given displacement.
         G.SC.LINER draws a line relative to the current point,
                    with plot type specified as m.sd.plot,
                    m.sd.clear or m.sd.invert

         INPUTS:

         g.sc.mover ( relative displacement X,
                      relative displacement Y )
         g.sc.liner ( type, relative end X, relative end Y )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         The units for the parameters are BBC graphics units.
         ( 4 graphics units = 1 pixel ONLY in mode 1 )
**/
// g.sc.mover moves cursor to given relative position
and g.sc.mover ( posX,posY ) be
$( VDU("25,%,%;%;",m.sd.movR, posX, posY ) $)

// g.sc.liner draws a line from present position to relative end X,Y
and g.sc.liner ( type,endX,endY ) be
$( plot ( type, endX, endY )  $)

/**
         NB In the procedures given below, the parameter 'type'
         -- may be foreground, background or inverse, which are
            defined in sdhdr as m.sd.plot, m.sd.clear and
            m.sd.invert respectively. All the drawing primitives
            may be used to clear, or plot in inverse colour, as
            well as plot in foreground ( the normal case )

         G.SC.TRIANGLE - DRAW A FILLED TRIANGLE
         --------------------------------------

         A filled triangle is drawn, using the supplied
         coordinates for the two undefined vertices. (The first
         vertex is taken to be the present cursor position)

         INPUTS:

         plot type,
         relative coords of second vertex, (XY)
         relative coords of third vertex ( from second )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         move to the position of the first vertex before calling
         this routine.

         PROGRAM DESIGN LANGUAGE:

         G.sc.triangle [ type, pos2X, pos2Y, pos3X, pos3Y ]
         -------------
         move to second vertex of triangle
         plot a triangle using plot type
**/
and G.sc.triangle ( type,pos2X,pos2Y,pos3X,pos3Y ) be
$( plot ( 0,pos2X,pos2Y ) // move relative to second vertex
   plot ( m.sd.triplt+type ,pos3X,pos3Y ) // plot triangle
$)

/**
         G.SC.PARALLEL - DRAW A FILLED PARALLELOGRAM
         -------------------------------------------

         A filled parallelogram is drawn, using the supplied
         coordinates for the two undefined vertices. (The first
         vertex is taken to be the present cursor position)

         INPUTS:

         plot type,
         relative coords of second vertex, (XY)
         relative coords of third vertex ( from second )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         move to the position of the first vertex before calling
         this routine.

         PROGRAM DESIGN LANGUAGE:

         G.sc.parallel [ type, pos2X, pos2Y, pos3X, pos3Y ]
         -------------
         move to second vertex of parallelogram
         plot a parallelogram using plot type
**/
AND G.sc.parallel ( type,pos2X,pos2Y,pos3X,pos3Y ) BE
$( plot ( 0,pos2X,pos2Y ) // move relative to second vertex
   plot ( m.sd.parplt+type ,pos3X,pos3Y ) // plot parallelogram
$)


/**
         G.SC.RECT - DRAW A FILLED RECTANGLE
         -----------------------------------

         The parameters size X and size Y define the size of the
         rectangle in graphics units, relative to the present
         position. (The start position is the present cursor
         position)

         INPUTS:

         g.sc.rect  ( type, size X, size Y )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

         The rectangle is plotted in the current colour, so use
         G.SC.SELCOL to choose the correct one. This routine may
         be used to clear a selected area, by using plot type
         m.sd.clear.

         The cursor will be left at the opposite corner of the
         rectangle.
**/
and g.sc.rect ( type,posX,posY ) be
$( $<debug
     G.ut.trap ("SC",5,false,3,posX,-1280,1280 )
     G.ut.trap ("SC",6,false,3,posY,-1024,1024 )
   $>debug

   plot ( m.sd.recplt+(type & 3), posX, posY )
$)
/**
         G.SC.SEC - DRAW A SECTOR
         -------------------------

         The sector primitive moves relative to the start
         position, then plots relative to the end.

         INPUTS:

         g.sc.sec   ( type, startX, startY, endpX, endpY )

         OUTPUTS:

         none

         GLOBALS MODIFIED:

         none

         SPECIAL NOTES FOR CALLERS:

**/
and g.sc.sec ( type, startX, startY, endpX, endpY ) be
$( $<debug
      LET id = "SC"
      G.ut.trap (id,19,false,1,startX,0,1280)
      G.ut.trap (id,20,false,1,startY,0,1024)
      G.ut.trap (id,21,false,1,endpX, 0,1280)
      G.ut.trap (id,22,false,1,endpY, 0,1024)
   $>debug

   plot ( 0, startX, startY )
   plot ( m.sd.secplt+(type & 3), endpX, endpY )
$)
// end of first section of graph
.


