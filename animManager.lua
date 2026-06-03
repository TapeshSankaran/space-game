
local anim = require "anim"

local animManager = {}
animManager.__index = animManager

function animManager:new()
    local aManager = setmetatable({}, animManager)

    aManager.anims = {}
    
    return aManager
end

function animManager:update()
    local anims = self.anims
    for i=1, #anims do
        anims[i]:update()
    end
end


function animManager:get_anim(index)
    return self.anims[index]
end

-- cfg: [name*, img*, fw*, fh*, fps, sx, sy, r, isLoop]
function animManager:new_anim(cfg)
    self.anims[cfg.name] = anim:new(cfg)
end

