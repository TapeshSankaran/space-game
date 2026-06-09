-- Main Menu Scene of Gane --
local Scene = require("lib.scene")

local gameScene = Scene:extract("Game_Scene")

function gameScene:new(sceneMgr)
    self.super.new(self, sceneMgr)
    self.menu = Menus["mainMenu"]
    self.menu:enable()

    return self
end

function gameScene:update(dt)

end

function gameScene:draw()
    love.graphics.setColor((COLORS.TRUE.GREY + COLORS.TRUE.BLACK):rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)

    local titleFont = Fonts.s128.martius
    local w = titleFont:getWidth("Game Scene")
    love.graphics.setColor(COLORS.TRUE.GREY:rgb())
    love.graphics.setFont(titleFont)
    love.graphics.print("Game Scene", width/2 - w/2, height*0.1)

    --self.menu:draw()
end

function gameScene:enter() end

function gameScene:exit() end


return gameScene