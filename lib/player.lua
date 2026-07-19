require("conf")

local player = Class:extract("Player")

local VEL = 5

-- Creation of player, in each scene, must find a way to transfer player info across scenes or make player global
function player:new(scene)
    self.scene = scene
    self.pos = self.scene.world:screen_to_world(Vector(0, 0))
    self.rot = 0
    self.booster = Images.boost1.img
    self.ship = Images.ship.img
    self.vel = Vector(0, 0)
    return self
end

local function lerpAngle(a, b, t)
    local diff = (b - a + math.pi) % (2 * math.pi) - math.pi
    return a + diff * t
end

-- Update player info, manage animations, booster, mode, etc. 
function player:update(dt)
    local targVel = Vector(0, 0)
    if self.vel:mag() < 0.001 then
        self.vel = Vector()
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
    self.vel = lerp(targVel, self.vel, 0.99)

    self.pos = self.pos + self.vel*dt

    local mPos = Input:mouse_screen_position()
    local scrnPos = self.scene.world:world_to_screen(self.pos)
    local ang = scrnPos:angle_to(mPos)
    self.rot = lerpAngle(self.rot, ang + math.pi/2, 0.1)

    Shaders.light:send("res",  { width, height })
    Shaders.light:send("cam",  {self.scene.camera.pos.x, self.scene.camera.pos.y})
    Shaders.light:send("time", self.scene.time)
    Shaders.light:send("zoom", self.scene.camera.zoom)
end

-- Draw player model, update based on info of ship, etc. Micht have to change for future games
function player:draw()
    love.graphics.setShader(Shaders.light)
    local scrnSize = self.scene.camera.zoom - 0.5
    local imgSize = Vector(self.ship:getWidth(), self.ship:getHeight())
    local scrnPos = self.scene.world:world_to_screen(self.pos)
    love.graphics.draw(self.ship, scrnPos.x, scrnPos.y, self.rot, scrnSize, scrnSize, imgSize.w/2, imgSize.h/2)
    love.graphics.setShader()
end

return player