-- Background of space, parallax --

require("conf")

local background = Class:extract("Background")


function background:new(cfg)
    self.colors = cfg.c
    self.scene = cfg.scene
    
    return self
end

function background:draw(pos)

end


return background