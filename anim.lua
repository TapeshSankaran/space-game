-- Animation.lua
local Animation = {}
Animation.__index = Animation

-- cfg: [img*, fw*, fh*, fps, sx, sy, r, isLoop]
function Animation:new(cfg)
  local anim = setmetatable({}, Animation)

  anim.image       = cfg.img
  anim.frameWidth  = cfg.fw
  anim.frameHeight = cfg.fh
  
  anim.fps  = cfg.fps and cfg.fps or 12
  anim.sx   = cfg.sx  and cfg.sx  or 2.2
  anim.sy   = cfg.sy  and cfg.sy  or 2.2
  anim.rot  = cfg.r   and cfg.r   or 0
  anim.loop = cfg.isLoop ~= nil and cfg.isLoop or false
  
  anim.timer  = 0
  anim.frames = {}
  anim.done   = false

  local cols = cfg.img:getWidth() / cfg.fw
  local rows = cfg.img:getHeight() / cfg.fh
  for y = 0, rows - 1 do
    for x = 0, cols - 1 do
      table.insert(anim.frames, love.graphics.newQuad(
        x * cfg.fw, y * cfg.fh,
        cfg.fw, cfg.fh,
        cfg.img:getDimensions()
      ))
    end
  end

  anim.totalFrames = #anim.frames
  anim.currentFrame = 1

  return anim
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
