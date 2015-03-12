module System.Taffybar.Volume (volumeW) where

import Control.Monad (liftM, void)
import Control.Monad.IO.Class (liftIO, MonadIO)
import Control.Exception (try, SomeException)
import Graphics.UI.Gtk (eventBoxNew, scrollEvent, on, tryEvent, eventScrollDirection, ScrollDirection(..), containerAdd, widgetShowAll, toWidget)
import XMonad.Actions.Volume (getVolumeMute, raiseVolume, lowerVolume)
import System.Taffybar.Widgets.PollingBar

volumeW = do
  ebox <- eventBoxNew

  void $ (ebox `on` scrollEvent) $ tryEvent $ do
    dir <- eventScrollDirection
    void $ liftIO
      (try $
        case dir of
          ScrollUp -> raiseVolume 5
          ScrollDown -> lowerVolume 5
      :: IO (Either SomeException Double))

  wd <- pollingBarNew barConfig 1 readVolBar
  containerAdd ebox wd
  widgetShowAll ebox
  return $ toWidget ebox

readVolBar :: IO Double
readVolBar = do
  (vol, mute) <- getVolumeMute
  return $ if mute then 0 else vol / 100.0

barConfig = (defaultBarConfig $ const (0,1,0))
  { barBackgroundColor = \v -> if v == 0 then gray else black
  , barColor = \v -> if v == 0 then gray else green
  }


black  = (0.0, 0.0, 0.0)
white  = (1.0, 1.0, 1.0)
gray   = (0.5, 0.5, 0.5)
red    = (1.0, 0.0, 0.0)
green  = (0.0, 1.0, 0.0)
blue   = (0.0, 0.0, 1.0)
yellow = (1.0, 1.0, 0.0)
purple = (1.0, 0.0, 1.0)
cyan   = (0.0, 1.0, 1.0)
orange = (1.0, 0.5, 0.0)
