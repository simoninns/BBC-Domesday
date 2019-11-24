// /**
//       WMHDR - WINDOW MANAGER HEADER
//       -----------------------------
//
//       Created specially for the A500 system
//       Contains SWI definitions, etc. for the
//       Arthur window manager interfaces.
//      
//       REVISION HISTORY:
//
//       DATE     VERSION  AUTHOR  DETAILS OF CHANGE
//       18.8.87  1        PAC     Initial version
// **/

MANIFEST 
$(

// swi numbers used in the window system
m.wm.swibase = #x400C0

// Use OSWimpG( swi.number, block ) for MOST of these.
// use OSWimpS for those marked with asterisks (***)

m.wm.Initialise         = m.wm.swibase + 0
m.wm.Create.Window      = m.wm.swibase + 1 
m.wm.Create.Icon        = m.wm.swibase + 2 
m.wm.Delete.Window      = m.wm.swibase + 3 
m.wm.Delete.Icon        = m.wm.swibase + 4 
m.wm.Open.Window        = m.wm.swibase + 5 
m.wm.Close.Window       = m.wm.swibase + 6 
m.wm.Poll               = m.wm.swibase + 7 
m.wm.Redraw.Window      = m.wm.swibase + 8 
m.wm.Update.Window      = m.wm.swibase + 9 
m.wm.Get.Rectangle      = m.wm.swibase + 10
m.wm.Get.Window.State   = m.wm.swibase + 11
m.wm.Get.Window.Info    = m.wm.swibase + 12
m.wm.Set.Icon.State     = m.wm.swibase + 13
m.wm.Get.Icon.State     = m.wm.swibase + 14
m.wm.Get.Pointer.Info   = m.wm.swibase + 15
m.wm.Drag.Box           = m.wm.swibase + 16
m.wm.Force.Redraw       = m.wm.swibase + 17 // ***
m.wm.Set.Caret.Position = m.wm.swibase + 18 // ***
m.wm.Get.Caret.Position = m.wm.swibase + 19
m.wm.Create.Menu        = m.wm.swibase + 20 // ***
m.wm.Decode.Menu        = m.wm.swibase + 21 // ***
m.wm.Which.Icon         = m.wm.swibase + 22 // ***
m.wm.Set.Extent         = m.wm.swibase + 23
m.wm.Set.Pointer.Shape  = m.wm.swibase + 24 // ***
m.wm.Open.Template      = m.wm.swibase + 25
m.wm.Close.Template     = m.wm.swibase + 26
m.wm.Load.Template      = m.wm.swibase + 27 // ***


// manifests for the Poll operation
//
// reason codes
//
m.wm.Null.Reason.Code        = 0
m.wm.Redraw.Window.Request   = 1
m.wm.Open.Window.Request     = 2
m.wm.Close.Window.Request    = 3
m.wm.Pointer.Leaving.Window  = 4
m.wm.Pointer.Entering.Window = 5
m.wm.Mouse.Button.Change     = 6
m.wm.User.Drag.Box           = 7
m.wm.Key.Pressed             = 8
m.wm.Menu.Select             = 9
m.wm.Scroll.Request          = 10

// masks - only the ones it's possible to mask are here
//
m.wm.Disallow.Null.Reason.Code        = 1 << 0
m.wm.Disallow.Redraw.Window.Request   = 1 << 1
m.wm.Disallow.Pointer.Leaving.Window  = 1 << 4
m.wm.Disallow.Pointer.Entering.Window = 1 << 5
m.wm.Disallow.Mouse.Button.Change     = 1 << 6
m.wm.Disallow.Key.Pressed             = 1 << 8

$)
