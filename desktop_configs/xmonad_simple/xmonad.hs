import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import System.IO
import Keys(myKeys)
  
main = do
xmproc <- spawnPipe "xmobar"
mulai  <- spawnPipe "/home/randalltux/.xmonad/autostart.sh"
xmonad $ defaultConfig
        { borderWidth        = 2
        , normalBorderColor  = "#161616"
        , focusedBorderColor = "#0f0f0f"
        , workspaces = ["1:WEB", "2:MUSIC", "3:CODING", "4:IRC", "5", "6", "7", "8", "9"]
        , layoutHook = avoidStruts $
        onWorkspace "2:MUSIC" (mailLayout ||| Full) $
        onWorkspace "4:IRC" (tiled ||| Mirror tiled) $
        smartBorders (tiled ||| Mirror tiled ||| Full )
        , logHook = dynamicLogWithPP $ xmobarPP
        { ppOutput = hPutStrLn xmproc
         , ppTitle = xmobarColor "#665c64" "" . shorten 50
          , ppCurrent = xmobarColor "#e5505f" ""
          , ppSep = " <fc=#2e3436>|</fc> "
        }

        , modMask = mod4Mask
        , terminal = "urxvt"
        , manageHook = myManageHook

        } `additionalKeys` myKeys

where
    mailLayout = Tall nmaster delta mailRatio
    tiled      = Tall nmaster delta ratio

    -- default number of windows in the master pane
    nmaster     = 1
  
    -- default propoertion of screen occupied by master pane
    ratio       = toRational (2/(1+sqrt(5)::Double)) -- golden ratio
    mailRatio  = 0.8                                 -- Pareto ratio, mutt:pidgin
 
   -- Percent of screen to increment by when resizing panes
    delta =0.05

   -- How to handle various windows

myManageHook = composeAll
   [ className =? "Firefox"              --> doF (W.shift "3:WEB")
         , className =? "Gimp"           --> doFloat
         , className =? "Gnubg"          --> doFloat
         , title     =? "mutt"           --> doF (W.shift "2:MAIL")
         , className =? "Pidgin"         --> doF (W.shift "2:MAIL")
         , title     =? "qiv"            --> doFloat
         , className =? "Emacs"          --> doF (W.shift "4:TEX")
         , manageDocks
         ] <+> manageHook defaultConfig
