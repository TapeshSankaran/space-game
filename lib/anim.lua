-- Animation.lua --

require("conf")

local Animation = Class:extract("Animation")

-- cfg: [img*, fw*, fh*, fps, sx, sy, r, isLoop]
function Animation:new(cfg)

  self.image       = cfg.img
  self.frameWidth  = cfg.fw
  self.frameHeight = cfg.fh
  
  self.fps  = cfg.fps and cfg.fps or 12
  self.sx   = cfg.sx  and cfg.sx  or 2.2
  self.sy   = cfg.sy  and cfg.sy  or 2.2
  self.rot  = cfg.r   and cfg.r   or 0
  self.loop = cfg.isLoop ~= nil and cfg.isLoop or false
  
  self.timer  = 0
  self.frames = {}
  self.done   = false

  local cols = cfg.img:getWidth() / cfg.fw
  local rows = cfg.img:getHeight() / cfg.fh
  for y = 0, rows - 1 do
    for x = 0, cols - 1 do
      table.insert(self.frames, love.graphics.newQuad(
        x * cfg.fw, y * cfg.fh,
        cfg.fw, cfg.fh,
        cfg.img:getDimensions()
      ))
    end
  end

  self.totalFrames = #self.frames
  self.currentFrame = 1

  return self
end

function Animation:update(dt)
  if self.done then return end
  
  self.timer = self.timer + dt
  local frameIndex = math.floor(self.timer * self.fps) + 1
  
  if frameIndex > self.totalFrames then
    if self.loop then
      self.timer = 0
      frameIndex = 1
    else
      self.done = true
      frameIndex = self.totalFrames
    end
  end
  self.currentFrame = frameIndex
end

function Animation:draw(x, y)
  if not self.done then
    love.graphics.draw(
      self.image,
      self.frames[self.currentFrame],
      x, y,
      self.rot,
      self.sx,
      self.sy,
      self.frameWidth/2,
      self.frameHeight/2
    )
  end
end

function Animation:isLooping()
  return self.loop
end

function Animation:setLoop(value)
  self.loop = value
end

function Animation:isDone()
  return self.done
end

function Animation:reset()
  self.timer = 0
  self.currentFrame = 1
  self.done = false
end

return Animation
