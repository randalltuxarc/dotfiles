import XMonad
import Control.Monad
import System.IO
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.SpawnOnce
import XMonad.Util.Loggers

import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS (prevWS, nextWS)

import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified GHC.IO.Handle.Types as H

import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile

ic = " ^i(/home/randalltux/.xmonad/symbol/"

ruangKerja :: [String]
ruangKerja = clickable $ [ ic ++ "diskette.xbm) "
			 , ic ++ "fox.xbm) "
			 , ic ++ "half.xbm) "
			 , ic ++ "info_03.xbm) "
			 , ic ++ "mail.xbm) "
			 , ic ++ "mouse_01.xbm) "
			 ]
	   where clickable l = [ "^ca(1,xdotool key super+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
	   			 (i,ws) <- zip [1..] l,
				 let n = i ]

startup = do
	  spawnOnce "xsetroot -cursor_name left_ptr &"

bg = "#2d2d2d"
fg = "#ffffff"
sg = "#444444"
eg = "#b1b1b1"

logBar h = do
	dynamicLogWithPP $ tryPP h
tryPP :: Handle -> PP
tryPP h = defaultPP
	{ ppOutput		= hPutStrLn h
	, ppCurrent		= dzenColor fg sg . pad
	, ppVisible		= dzenColor eg bg . pad
	, ppHidden		= dzenColor eg bg . pad
	, ppHiddenNoWindows	= dzenColor eg bg . pad
	, ppWsSep		= ""
	, ppSep			= "   |   "
	, ppLayout		= dzenColor fg bg . pad
	}

gsconfig2 colorizer = (buildDefaultGSConfig colorizer) { gs_cellheight = 30, gs_cellwidth = 100 }

greenColorizer = colorRangeFromClassName
			black 
			(0x70,0xFF,0x70)
			black
			white
			white
   where black = minBound
   	 white = maxBound

tombol = [ ((mod4Mask, xK_r), spawn "dmenu_run -b")
	 , ((mod4Mask, xK_m), sendMessage MirrorShrink)
	 , ((mod4Mask, xK_u), sendMessage MirrorExpand)
	 , ((mod4Mask, xK_g), goToSelected $ gsconfig2 greenColorizer )
	 ]

main = do
	panel <- spawnPipe top
	info <- spawnPipe sys
	xmonad $ defaultConfig
		{ manageHook = manageDocks <+> manageHook defaultConfig
		, layoutHook = avoidStruts $ ResizableTall 1 (2/300) (1/2) []
		, modMask = mod4Mask
		, workspaces = ruangKerja
		, terminal = "urxvt"
		, focusedBorderColor = "#444444"
		, normalBorderColor = "#2d2d2d"
		, borderWidth = 4
		, logHook = logBar panel
		} `additionalKeys` tombol
		where top = "dzen2 -p -ta l -e 'button3=' -fn 'Ubuntu-8' -fg '#ffffff' -bg '#2d2d2d' -h 24 -w 700"
		      sys = "sh /home/randalltux/.xmonad/script/sysinfo.sh"
