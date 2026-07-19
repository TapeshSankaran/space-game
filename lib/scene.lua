-- Scenes for game --

require("conf")

local physSpace = require("lib.physicsSpace")
local splineMgr = require("lib.splineMgr")

local scene = Class:extract("Scene")

-- when scene is made
function scene:new(sceneMgr)
    self.manager = sceneMgr
    self.splineManager = splineMgr()

    self.defaultSpace = physSpace({})
    
    self.time    = 0.0
    self.camera  = {}
    self.camera.pos = Vector()
    self.camera.zoom = 1.0

    return self
end

function scene:update(dt)
    self.time = self.time + dt
    self.splineManager:update(dt)
end

function scene:draw() end

function scene:enter() end

function scene:exit() end


return scene