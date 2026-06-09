-- Scenes for game --

require("conf")

local scene = Class:extract("Scene")

-- when scene is made
function scene:new(sceneMgr)
    self.manager = sceneMgr

    return self
end

function scene:update(dt) end

function scene:draw() end

function scene:enter() end

function scene:exit() end


return scene