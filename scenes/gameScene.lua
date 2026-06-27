-- Main Menu Scene of Gane --
local Scene = require("lib.scene")
local world = require("lib.world")
local background = require("lib.background")

local gameScene = Scene:extract("Game_Scene")

local VEL = 4

function gameScene:new(sceneMgr)
    self.super.new(self, sceneMgr)
    self.menu = Menus["mainMenu"]
    self.menu:enable()

    self.world = world(self)
    self.bg = background({ scene = self, c = {space={COLORS.TRUE.B/3, (COLORS.TRUE.B + COLORS.TRUE.R), COLORS.TRUE.B/2.5}, nebula=Color(0.9, 0.0, 0.7)} })
    self.camVel = Vector()

    return self
end

function gameScene:update(dt)
    self.super.update(self, dt)
    local targVel = Vector(0, 0)
    if self.camVel:mag() < 0.001 then
        self.camVel = Vector()
    end
    if Input:is_key_down('w') then
        targVel = targVel + Vector(0, VEL)
    end
    if Input:is_key_down('a') then
        targVel = targVel + Vector(-VEL, 0)
    end
    if Input:is_key_down('s') then
        targVel = targVel + Vector(0, -VEL)
    end
    if Input:is_key_down('d') then
        targVel = targVel + Vector(VEL, 0)
    end
    if Input:is_scrolling() then
        if (Input:mouse_get_scroll().y == -1 and self.camera.zoom > 0.5) or
           (Input:mouse_get_scroll().y == 1  and self.camera.zoom < 2.0) then
            self.camera.zoom = (self.camera.zoom + 0.1 * Input:mouse_get_scroll().y)
        end
    end
    self.camVel = lerp(targVel, self.camVel, 0.975)

    self.camera.pos = self.camera.pos + self.camVel*dt

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

    self.bg:post_draw()
    --self.menu:draw()
end

function gameScene:enter() end

function gameScene:exit() end



return gameScene