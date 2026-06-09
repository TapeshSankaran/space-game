-- Animation Manager for animations not in UI --

local anim = require("lib.anim")

local animManager = Class:extract("Animation_Manager")


function animManager:new()

    self.anims = {}
    
    return self
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


return animManager
