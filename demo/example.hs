import Control.Monad
import Data.IORef
import Data.Monoid
import Graphics.DrawingCombinators ((%%))
import qualified Graphics.DrawingCombinators             as Draw
import qualified Graphics.UI.GLFW                        as GLFW
import           Graphics.Rendering.OpenGL.GL.StateVar
import qualified Graphics.Rendering.OpenGL.GL.CoordTrans as GL(Size(..))

import System.Environment(getArgs)

resX, resY :: Int
resX = 640
resY = 480

initScreen :: IO ()
initScreen = do
  True <- GLFW.initialize
  True <- GLFW.openWindow (GL.Size (fromIntegral resX) (fromIntegral resY))
                          [GLFW.DisplayRGBBits 8 8 8,
                           GLFW.DisplayDepthBits 8]
                          GLFW.Window

  return ()

unitText :: Draw.Font -> String -> Draw.Image Any
unitText font str = (Draw.translate (-1,0) %% Draw.scale (2/w) (2/w) %% Draw.text font str)
                        `mappend`
                    Draw.tint (Draw.Color 1 0 0 1) (Draw.line (-1,0) (1,0))
    where
    w = Draw.textWidth font str

quadrants :: (Monoid a) => Draw.Image a -> Draw.Image a
quadrants img = mconcat [
    (Draw.translate (-0.5,0.5) %%),
    (Draw.translate (0.5,0.5)   `Draw.compose` Draw.rotate (-pi/2) %%),
    (Draw.translate (0.5,-0.5)  `Draw.compose` Draw.rotate pi %%),
    (Draw.translate (-0.5,-0.5) `Draw.compose` Draw.rotate (pi/2) %%)] (Draw.scale 0.5 0.5 %% img)

circleText :: Draw.Font -> String -> Draw.Image Any
circleText font str = unitText font str `mappend` Draw.tint (Draw.Color 0 0 1 0.5) Draw.circle

main :: IO ()
main = do
    initScreen
    args <- getArgs
    font <- case args of
        [fontName] -> do
            font <- Draw.openFont fontName
            return font
        _ -> error "Usage: drawingcombinators-example some_font.ttf"


    doneRef <- newIORef False
    GLFW.windowCloseCallback $= do
      writeIORef doneRef True
      return True
    waitClose font doneRef 0
    GLFW.terminate
    return ()
    where

    waitClose font doneRef rotation = do
      isDone <- readIORef doneRef
      unless isDone $ do
        Draw.clearRender $ Draw.rotate rotation %% quadrants (circleText font "Hello, World!")
        GLFW.swapBuffers
        GLFW.pollEvents
        waitClose font doneRef $ rotation - 0.01
