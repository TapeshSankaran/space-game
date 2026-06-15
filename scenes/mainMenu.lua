-- Main Menu Scene of Gane --
local Scene = require("lib.scene")

local mainMenu = Scene:extract("Main_Menu")

function mainMenu:new(sceneMgr)
    self.super.new(self, sceneMgr)
    self.menu = Menus["mainMenu"]
    self.menu:enable()

    return self
end

function mainMenu:update(dt)
    self.super.update(self, dt)
    self.menu:update(dt)
end

function mainMenu:draw()
    love.graphics.setColor(COLORS.TRUE.GREY:rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)

    local titleFont = Fonts.s128.martius
    local w = titleFont:getWidth("Main_Menu")
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
    love.graphics.setFont(titleFont)
    love.graphics.print("Main Menu", width/2 - w/2, height*0.1)

    self.menu:draw()
end

function mainMenu:enter() end

function mainMenu:exit() end


return mainMenu