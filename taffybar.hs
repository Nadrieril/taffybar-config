import System.Taffybar

import System.Taffybar.TaffyPager
import System.Taffybar.Pager
import System.Taffybar.WindowSwitcher
import System.Taffybar.WorkspaceSwitcher

import System.Taffybar.Battery
import System.Taffybar.SimpleClock
import System.Taffybar.Systray
import System.Taffybar.MPRIS2

import System.Taffybar.Widgets.PollingBar
import System.Taffybar.Widgets.PollingGraph

import System.Information.Memory
import System.Information.CPU


pagerCfg = defaultPagerConfig
    { emptyWorkspace = colorize "#6b6b6b" "" . escape
    , activeWorkspace  = colorize "#429942" "" . escape . wrap "<" ">"
    }

main = do
    pager <- pagerNew pagerCfg

    let wss = wspaceSwitcherNew pager
        wnd = windowSwitcherNew pager

        clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
        mpris = mpris2New
        battery = textBatteryNew "$percentage$%/$time$" 60
        tray = systrayNew
      
        mem = pollingGraphNew memCfg 1 memCallback
            where
                memCallback = do
                    mi <- parseMeminfo
                    return [memoryUsedRatio mi]
                memCfg = defaultGraphConfig
                    { graphDataColors = [(1, 0, 0, 1)]
                    , graphLabel = Nothing
                    , graphDirection = RIGHT_TO_LEFT
                    }

        cpu = pollingGraphNew cpuCfg 1 cpuCallback
            where
                cpuCallback = do
                    (_, _, totalLoad) <- cpuLoad
                    return [totalLoad]
                cpuCfg = defaultGraphConfig
                    { graphDataColors = [(0, 1, 0, 1)]
                    , graphLabel = Nothing
                    , graphDirection = RIGHT_TO_LEFT
                    }

    defaultTaffybar defaultTaffybarConfig
        { barHeight = 20
        , startWidgets = [wss, wnd]
        , endWidgets = reverse [mpris, cpu, mem, battery, clock, tray]
        }
