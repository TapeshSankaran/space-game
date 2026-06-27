-- Main Menu Scene of Gane --
local Scene = require("lib.scene")
local world = require("lib.world")
local background = require("lib.background")
local mainMenu = Scene:extract("Main_Menu")

local VEL = Vector(4, 0)
local SCALE = 0.2
local TIMESCALE = 0.05
local VSCALE = 0.85

function mainMenu:new(sceneMgr)
    self.super.new(self, sceneMgr)
    self.menu = Menus["mainMenu"]

    self.world = world(self)
    self.bg = background({ 
        scene = self,
        c = {
            space={
                COLORS.TRUE.B/3,
                (COLORS.TRUE.B + COLORS.TRUE.R),
                COLORS.TRUE.B/2.5
            },
            nebula=Color(0.2, 0.8, 0.5),
            star=Color(0.85, 0.95, 0.85)
        } 
    })
    self.menu:enable()

    return self
end

function mainMenu:update(dt)
    self.super.update(self, dt)
    self.menu:update(dt)
    self.bg:update(dt)
    local ny = self.bg:noise(self.camera.pos.x * SCALE, self.time * TIMESCALE) * 2 - 1
    local ns = self.bg:noise(self.camera.pos.y * SCALE, self.time * TIMESCALE) * 2 - 1
    self.camera.pos = self.camera.pos + (VEL + Vector(0, ny) * VSCALE) * dt
    self.camera.zoom = 1.0 + ns * SCALE * dt
end

function mainMenu:draw()
    love.graphics.setColor(COLORS.TRUE.GREY:rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)

    self.bg:draw()

    local titleFont = Fonts.s128.martius
    local w = titleFont:getWidth("Main_Menu")
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
    love.graphics.setFont(titleFont)
    love.graphics.print("Main Menu", width/2 - w/2, height*0.1)

    self.bg:post_draw()
    self.menu:draw()
end

function mainMenu:enter() end

function mainMenu:exit() end


return mainMenu