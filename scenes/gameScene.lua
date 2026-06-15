-- Main Menu Scene of Gane --
local Scene = require("lib.scene")
local world = require("lib.world")

local gameScene = Scene:extract("Game_Scene")

local VEL = 4

function gameScene:new(sceneMgr)
    self.super.new(self, sceneMgr)
    self.menu = Menus["mainMenu"]
    self.menu:enable()

    self.world = world(self)
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
        self.camera.zoom = self.camera.zoom + 0.1 * Input:mouse_get_scroll().y
    end
    self.camVel = lerp(targVel, self.camVel, 0.975)

    self.camera.pos = self.camera.pos + self.camVel*dt
end

function gameScene:draw()
    love.graphics.setColor((COLORS.TRUE.GREY + COLORS.TRUE.BLACK):rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)

    self.world:draw_grid(false)

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