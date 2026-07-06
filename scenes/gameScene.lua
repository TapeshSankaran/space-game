-- Main Menu Scene of Gane --
local Scene = require("lib.scene")
local world = require("lib.world")
local background = require("lib.background")
local player = require("lib.player")
local gameScene = Scene:extract("Game_Scene")

local VEL = 4

function gameScene:new(sceneMgr)
    self.super.new(self, sceneMgr)
    self.menu = Menus["mainMenu"]
    self.menu:enable()
    
    self.world = world(self)
    self.player = player:new(self)

    self.bg = background({ 
        scene = self, 
        c = {
            space={
                COLORS.TRUE.B/3, 
                (COLORS.TRUE.B + COLORS.TRUE.R), 
                COLORS.TRUE.B/2.5
            }, 
            nebula=Color(0.2, 0.8, 0.5),
            star=Color(0.9, 0.95, 0.7)
        }
    })
    
    self.camVel = Vector()

    return self
end

function gameScene:update(dt)
    self.super.update(self, dt)
    self.player:update(dt)

    self.camera.pos = lerp(self.camera.pos, self.player.pos, 0.05)

    self.bg:update(dt)
end

function gameScene:draw()
    love.graphics.setColor((COLORS.TRUE.GREY + COLORS.TRUE.BLACK):rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)

    self.bg:draw()
    --self.world:draw_grid(self.camera.zoom >= 1)
    
    local titleFont = Fonts.s128.martius
    local w = titleFont:getWidth("Game Scene")
    love.graphics.setColor(COLORS.TRUE.GREY:rgb())
    love.graphics.setFont(titleFont)
    love.graphics.print("Game Scene", width/2 - w/2, height*0.1)
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
    --self.player:draw()
    self.bg:post_draw()
    --self.menu:draw()
end

function gameScene:enter() end

function gameScene:exit() end



return gameScene