pc		RN	15
r14		RN	14
rb		RN	8
rl		RN	12
rts		RN	11
rp		RN	10
rg		RN	9
rgb		RN	7
w1		RN	4
w2		RN	5
nil		RN	13
nilbase 	RN	6
r0		RN	0
a1		RN	1
a2		RN	2
a3		RN	3
a4		RN	4

; SWI calls
KWrch		*	0
KWrite0 	*	2
KNewline	*	3
KRdch		*	4
KCLI		*	5
KByte		*	6
KWord		*	7
KFile		*	8
KArgs		*	9
KBget		*	&a
KBput		*	&b
Kgbpb		*	&c
KFind		*	&d
KControl	*	&f
KReadEnv	*	&10
KExit		*	&11
KSetEnv 	*	&12
KCallBack	*	&15

PSRBits 	*	&fc000000
OverflowBit	*	&10000000

; 3rd argument (what to do) for SetEventHandler
ev_ignore	*	0
ev_set_flag	*	1
ev_call_proc	*	2
ev_buffer	*	3

	GBLA	xxrelocs
	GBLA	xxglobs
	GBLA	xxtopglobal
	GBLA	tempa
	GBLS	temps
xxrelocs SETA	0
xxglobs SETA	0
UserGlobals * 150

xxtopglobal SETA  UserGlobals

	MACRO
	Module $name,$date
Start
	=	"BCPL"
	&	globinits-Start
	=	("$name":CC:"        "):LEFT:8
 [ "$date"=""
	=	"<unset> <unset>",0,0,0,0,0
  |
	=	"$date",0,0
 ]
	&	0
	MEND

	MACRO
$name	GlobNo $no
G_$name *	($no)*4
 [ $no>xxtopglobal
xxtopglobal SETA $no
 ]
	MEND

	MACRO
	GlobDef $no,$name
	&	-1
	=	7,("$name":CC:"       "):LEFT:7
G_$name *	($no)*4
 [ $no>xxtopglobal
xxtopglobal SETA $no
 ]
temps	SETS	"xxgname":CC:"$xxglobs"
	GBLS	$temps
$temps	SETS	"$name"
xxglobs SETA	xxglobs+1
$name
	MEND

	MACRO
	GlobInits
globinits
tempa	SETA	0
     WHILE tempa<xxglobs
temps	SETS	"xxgname":CC:"$tempa"
temps	SETS	$temps
	GlobInit $temps
tempa	SETA	tempa+1
     WEND
	MEND

	MACRO
$lab	Address $value
 [ "$lab"<>""
$lab
 ]
temps	SETS	"rx":CC:"$xxrelocs"
$temps
	&	$value-Start
xxrelocs SETA	xxrelocs+1
	MEND

	MACRO
	GlobInit $name
	&	G_$name/4
temps	SETS	"rx":CC:"$xxrelocs"
$temps
	&	$name-Start
xxrelocs SETA	xxrelocs+1
	MEND

	MACRO
	EndModule
globinits
tempa	SETA	0
     WHILE tempa<xxglobs
temps	SETS	"xxgname":CC:"$tempa"
temps	SETS	$temps
	GlobInit $temps
tempa	SETA	tempa+1
     WEND
	&	&$xxtopglobal
	&	0

	&	&12345678
tempa	SETA	0
     WHILE tempa<>xxrelocs
temps	SETS	"rx":CC:"$tempa"
tempa	SETA	tempa+1
	&	$temps-Start
     WEND
	&	&87654321
	MEND

	END
