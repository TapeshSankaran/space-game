
require("conf")

function system_set() 
  -- Set Title of Window --
  love.window.setTitle("Basic Game")
  
  -- Set Filter for Clearness --
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Set Dimentions for Window --
  love.window.setMode(width, height, {fullscreen = isFull})
  
  -- Set Color --
  love.graphics.setBackgroundColor(COLORS.TRUE.BLACK:rgb())
  
  -- SET RANDOM SEED --
  math.randomseed(seed)

  -- Console Settings --
  os.execute('cls')
  io.stdout:setvbuf("no")
end
