-- main.lua --

local config = require "conf"
local a_manager = require "a_manager"

-- On first load. Create global variables here
function love.load()
    -- Animation Manager --
    Anim_Manager = a_manager:new()
end

-- Put update funcs, trigger funcs, etc here
function love.update()
    Anim_Manager:update()
end

-- Every draw frame, put draw functions here
function love.draw()

end