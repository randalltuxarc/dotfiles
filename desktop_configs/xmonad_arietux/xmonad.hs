------------------------------------------------------------------------
-- Imports --
------------------------------------------------------------------------
import System.Exit
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (manageDocks, avoidStruts)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.MultiToggle
import XMonad.Layout.SimplestFloat
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.StackTile
import XMonad.Util.Run (spawnPipe, hPutStrLn)
import qualified Data.Map                 as M
import qualified GHC.IO.Handle.Types      as H
import qualified XMonad.Layout.Fullscreen as FS
import qualified XMonad.StackSet          as W

------------------------------------------------------------------------
-- Layout names and quick access keys
------------------------------------------------------------------------
myWorkspaces :: [String]
myWorkspaces        = clickable . (map dzenEscape) $ ["satu","dua","tiga","empat","lima","enam","tujuh"] 
  where clickable l = [ "^ca(1,xdotool key super+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
                            (i,ws) <- zip [1..] l,
                            let n = i ]

------------------------------------------------------------------------
-- Key bindings --
------------------------------------------------------------------------
myKeys ::  XConfig l -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
    -- jalanken dmenu
      ((modm,xK_p), spawn dmenuCall)
    -- Sistem Xmonad
    , ((modShift, xK_Escape), spawn "killall udiskie dzen2 compton urxvtd mpd" >> io (exitWith ExitSuccess))
    , ((modShift,xK_q), kill)
    , ((modShift,xK_r) , spawn "killall dzen2; xmonad --recompile; xmonad --restart")
     -- Ganti Layout
    , ((modm,xK_space), sendMessage NextLayout)
     -- Pindah Wokspaces
    , ((modm,xK_Right), nextWS)
    , ((modm,xK_Left) , prevWS)
    -- Tukar Fokus window
    , ((modm,xK_Tab), windows W.focusDown )
    , ((modm,xK_j) , windows W.focusDown )
    , ((modm,xK_k)  , windows W.focusUp    )
    , ((modm,xK_m)  , windows W.focusMaster)
    -- Urgency Hook
    , ((modm, xK_x), focusUrgent)
    , ((modShift, xK_x), focusUrgent)
    -- Geser Fokus Window
    , ((modShift,xK_Return), windows W.swapMaster)
    , ((modShift,xK_j)     , windows W.swapDown  )
    , ((modShift,xK_k)     , windows W.swapUp    )
    -- Susutkan ukuran window
    , ((modm,xK_h), sendMessage Shrink)
    , ((modm,xK_l), sendMessage Expand)
    -- ngatur window biar ke tilling mode
    , ((modm,xK_t), withFocused $ windows . W.sink)
    -- Increment and decrement the number of windows in the master area
    , ((modm,xK_comma) , sendMessage (IncMasterN 1)   )
    , ((modm,xK_period), sendMessage (IncMasterN (-1)))
    -- fulscreen window
    , ((modm,xK_f), sendMessage $ Toggle FULL)
    -- Aplikasi 
    , ((mod1cont,xK_g) , spawn "gimp")
    , ((mod1cont,xK_t) , spawn "/opt/pt/packettracer")
    , ((mod1cont,xK_v) , spawn "virtualbox")
    , ((modShift,xK_p) , spawn "gmrun")
    , ((0, xK_Print)   , spawn "xfce4-screenshooter")
    , ((modm,xK_Return), spawn $ XMonad.terminal conf)
    , ((mod1cont,xK_f) , spawn "firefox")
    , ((mod1cont,xK_c) , spawn "google-chrome-stable")
    , ((mod1cont,xK_l) , spawn "libreoffice")
    , ((mod1cont,xK_e) , spawn "thunar")
    , ((mod1cont,xK_z) , spawn "zekr.sh")
    -- Pengaturan Alsa
    , ((0, 0x1008ff11), spawn "/home/randalltux/.xmonad/Scripts/volctl down"  )
    , ((0, 0x1008ff13), spawn "/home/randalltux/.xmonad/Scripts/volctl up"    )
    , ((0, 0x1008ff12), spawn "/home/randalltux/.xmonad/Scripts/volctl toggle")
    -- Pengaturan Cahaya
    , ((0, 0x1008ff03), spawn "xbacklight -dec 5")
    , ((0, 0x1008ff02), spawn "xbacklight -inc 5")
    , ((0, 0x1008ff14), spawn "mpc toggle")
    , ((0, 0x1008ff16), spawn "mpc prev")
    , ((0, 0x1008ff17), spawn "mpc next")
    , ((0, 0x1008ff15), spawn "mpc stop")
    -- , ((0, XF86AudioLowerVolume  ), spawn "amixer -q sset Master 3- unmute")
    -- , ((0, XF86AudioRaiseVolume  ), spawn "amixer -q sset Master 3+ unmute")
    -- , ((0, ), spawn "amixer -q sset Master toggle")

    ]
    ++
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_4,xK_5,xK_6,xK_7]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

    where modShift  = modm .|. shiftMask
          mod1cont  = mod1Mask .|. controlMask
          dmenuCall = "dmenu_run -i"
                      ++ " -fn 'termsyn-8' "
                      ++ " -sb '" ++ colLook Cyan 0 ++ "'"
                      ++ " -nb '#000000'"

------------------------------------------------------------------------
-- Pengaturan Tetikus --
------------------------------------------------------------------------
myMouseBindings :: XConfig t -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                      >> windows W.shiftMaster)
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                      >> windows W.shiftMaster)
    ]

------------------------------------------------------------------------
-- Aturan untuk Window --
------------------------------------------------------------------------
-- Catatan: Untuk menemukan nama spesial dari aplikasi, pake ini :
-- > xprop | grep WM_CLASS
-- Terus klik window yang ingin didapatkan nama specialnya :D
------------------------------------------------------------------------
myManageHook :: ManageHook
myManageHook = composeAll . concat $
     [ [ className =? c --> doShift    	        (myWorkspaces !! 0) | c <- utama]
     , [ className =? c --> doShift     	(myWorkspaces !! 3) | c <- desain]
     , [ className =? c --> doShift		(myWorkspaces !! 4) | c <- multimedia]
     , [ className =? c --> doShift		(myWorkspaces !! 5) | c <- kantor]
     , [ className =? c --> doShift		(myWorkspaces !! 6) | c <- utilitis]
     , [ className =? c --> doCenterFloat			    | c <- terminal]
     , [ className =? c --> doCenterFloat			    | c <- ngambang]
     , [ name      =? n --> doCenterFloat			    | n <- popUp]
     , [ resource  =? r --> doIgnore				    | r <- doIgnores]
     , [ isFullscreen   --> doFullFloat ]
     ] where
          name          = stringProperty "WM_NAME"
          utama 	= [ "Firefox", "Google-chrome"]
          desain	= [ "Gimp"]
          multimedia	= [ "Totem", "MPlayer"]
          kantor	= [ "libreoffice-calc", "libreoffice-writter", "libreoffice-impress", "libreoffice-startcenter", "libreoffice-draw", "Thunar", "Nautilus", "SWT"]
          utilitis	= [ "Vidalia"]
          terminal	= [ "URxvt"]
          ngambang	= [ "MPlayer", "Xmessage", "Xfce4-screenshooter", "Gedit", "Lxappearance"
			  , "Gcolor3", "DTA"]
	  popUp		= [ "Add media", "Choose a file", "Open Image", "File Operation Progress", "Firefox Preferences", "Preferences", "Search Engines"
                          , "Set up sync", "Passwords and Exceptions", "Autofill Options", "Rename File", "Copying files", "Moving files", "File Properties", "Replace"
                          , "libreoffice-startcenter", "libreoffice-writer", "libreoffice-calc", "libreoffice-impress", "libreoffice-draw", "libreoffice-base", "libreoffice-math"
			  , "DownThemAll"]
          doIgnores	= [ "stalonetray", "kdesktop", "desktop_window"]

------------------------------------------------------------------------
-- Status bars and logging --
------------------------------------------------------------------------
myLogHook ::  H.Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor (colLook White 0)
                                          (colLook Cyan  0) . pad
      , ppVisible           =   dzenColor (colLook Cyan  0)
                                          (colLook Black 0) . pad
      , ppHidden            =   dzenColor (colLook Cyan  0)
                                          (colLook BG    0) . pad
      , ppHiddenNoWindows   =   dzenColor (colLook White 1)
                                          (colLook BG    0) . pad
      , ppUrgent            =   dzenColor (colLook Red   0)
                                          (colLook BG    0) . pad
      , ppWsSep             =   ""
      , ppSep               =   " | "
      , ppLayout            =   dzenColor (colLook Cyan 0) "#000000" .
            (\x -> case x of
                "Spacing 20 Tall"        -> clickInLayout ++ icon1
                "Tall"                   -> clickInLayout ++ icon2
                "Mirror Spacing 20 Tall" -> clickInLayout ++ icon3
                "Full"                   -> clickInLayout ++ icon4
		"StackTile"		 -> clickInLayout ++ icon5
		"SimplestFloat"		 -> clickInLayout ++ icon6
                _                        -> x
            )
      , ppTitle             =   (" " ++) . dzenColor "#A3A3A3" "#000000" . dzenEscape
      , ppOutput            =   hPutStrLn h
    }
    where icon1 = "^i(/home/randalltux/.xmonad/dzen/icons/stlarch/tile.xbm)^ca()"
          icon2 = "^i(/home/randalltux/.xmonad/dzen/icons/stlarch/monocle.xbm)^ca()"
          icon3 = "^i(/home/randalltux/.xmonad/dzen/icons/stlarch/bstack.xbm)^ca()"
          icon4 = "^i(/home/randalltux/.xmonad/dzen/icons/stlarch/monocle2.xbm)^ca()"
	  icon5 = "^i(/home/randalltux/.xmonad/dzen/icons/stlarch/bstack2.xbm)^ca()"
	  icon6 = "^i(/home/randalltux/.xmonad/dzen/icons/stlarch/float.xbm)^ca()"

clickInLayout :: String
clickInLayout = "^ca(1, xdotool key super+space)"
 
------------------------------------------------------------------------
-- Definisi Warna --
------------------------------------------------------------------------
type Hex = String
type ColorCode = (Hex,Hex)
type ColorMap = M.Map Colors ColorCode

data Colors = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White | BG
    deriving (Ord,Show,Eq)

colLook :: Colors -> Int -> Hex
colLook color n =
    case M.lookup color colors of
        Nothing -> "#000000"
        Just (c1,c2) -> if n == 0
                        then c1
                        else c2

colors :: ColorMap
colors = M.fromList
    [ (Black   , ("#393939",
                  "#121212"))
    , (Red     , ("#e60926",
                  "#df2821"))
    , (Green   , ("#219e74",
                  "#219579"))
    , (Yellow  , ("#218c7e",
                  "#218383"))
    , (Blue    , ("#217a88",
                  "#21728d"))
    , (Magenta , ("#216992",
                  "#216097"))
    , (Cyan    , ("#21579c",
                  "#214ea1"))
    , (White   , ("#D6D6D6",
                  "#A3A3A3"))
    , (BG      , ("#000000",
                  "#444444"))
    ]

------------------------------------------------------------------------
-- Jalanken Xmonad --
------------------------------------------------------------------------
main :: IO ()
main = do
    d <- spawnPipe callDzen1
    spawn callDzen2
    mulai <- spawnPipe "/home/randalltux/.xmonad/autostart.sh"
    xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig {
        terminal                  = "urxvtc",
        focusFollowsMouse         = True,
        borderWidth               = 3,
        modMask                   = mod4Mask,
        normalBorderColor         = colLook White 1,
        focusedBorderColor        = colLook Cyan 0,
        workspaces                = myWorkspaces,
        keys                      = myKeys,
        mouseBindings             = myMouseBindings,
        logHook                   = myLogHook d,
        layoutHook                = smartBorders myLayout,
        manageHook                = myManageHook <+> manageDocks,
        handleEventHook           = FS.fullscreenEventHook,
        startupHook               = setWMName "LG3D"
    }
    where callDzen1 = "dzen2 -ta l -fn '"
                      ++ dzenFont
                      ++ "' -bg '#000000' -w 500 -h 18 -e 'button3='"
          callDzen2 = "conky -c ~/.xmonad/.conkyrc | dzen2 -x 500 -ta r -fn '"
                      ++ dzenFont
                      ++ "' -bg '#000000' -h 18 -e 'onnewinput=;button3='"
          -- dzenFont  = "Inconsolata-8"
          dzenFont  = "Ubuntumono-8"
          -- | Layouts --
          myLayout = mkToggle (NOBORDERS ?? FULL ?? EOT) $ avoidStruts $ webLayout $ desainLayout $ standardLayout 
              where
                  standardLayout = float
                                   ||| tiled
                                   ||| fullTiled
				   ||| mirrorTiled
				   ||| hozTile
				   ||| focused
                  webLayout      = onWorkspace (myWorkspaces !! 0) $ fullTiled
                                   ||| tiled
                  desainLayout   = onWorkspace (myWorkspaces !! 3) $ fullTiled
                                   ||| tiled
                  fullTiled      = Tall nmaster delta (1/4)
                  mirrorTiled    = Mirror . spacing 20 $ Tall nmaster delta ratio
                  focused        = gaps [(L,385), (R,385),(U,10),(D,10)]
                                   $ noBorders (FS.fullscreenFull Full)
                  tiled          = spacing 20 $ Tall nmaster delta ratio
		  hozTile	 = StackTile 1 (3/100) (1/2)
		  float		 = simplestFloat
		  -- The default number of windows in the master pane
                  nmaster = 1
                  -- Percent of screen to increment by when resizing panes
                  delta   = 5/100
                  -- Default proportion of screen occupied by master pane
                  ratio   = 1/2
