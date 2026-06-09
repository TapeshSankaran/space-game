-- main.lua --

require("conf")
require("lib.menuMgr")
local sceneMgr = require("lib.sceneMgr")
local input    = require("lib.input")
require("lib.sys-set")

-- On first load. Create global variables here
function love.load()
    -- Set Window Settings --
    system_set()

    -- Input Handling --
    Input = input:new()
    InputEvents = Events:new()

    -- Menu Manager --
    --  Fonts  --
    Fonts = font_maker(FILE_LOCATIONS.FONTS, Fonts)
    --  Menus  --
    Menus = make_menus()

    Scene_Manager = sceneMgr('scenes', { "mainMenu", "gameScene" })
    Scene_Manager:switch("mainMenu")
end

-- Put update funcs, trigger funcs, etc here
function love.update(dt)
    Input:update(dt)
    Scene_Manager:update(dt)
end

-- Every draw frame, put draw functions here
function love.draw()
    Scene_Manager:draw()
    Input:reset()
end

-- Scroll Wheel Input Handling --
function love.wheelmoved(x, y)
    Input:mouse_scrolled(x, y)
end

-- Keyboard Input Handling --
function love.keypressed(key, scancode, isrepeat)
    Input:key_pressed(key, scancode, isrepeat)
end