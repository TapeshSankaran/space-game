local Component = require("lib.component")

local rigidBody = Component:extract("RigidBody")

-- Config { obj(worldObj), mass(float), mods(array<>) }
function rigidBody:new(obj, mass, mods)
    self.super.new(self, obj)
    mods = mods and mods or {}

    self.collider = obj.components['collider'] and obj.components['collider'] or nil

    self.mass = mass and mass or 1

    self.pos   = obj.pos and obj.pos or Vector()
    self.vel   = Vector()
    self.force = Vector()

    self.rot    = obj.rot and obj.rot or Vector()
    self.angVel = 0
    self.torque = 0

    self.linDamp = mods.linDamp and mods.linDamp or 1
    self.angDamp = mods.angDamp and mods.angDamp or 1

    self.space = nil
    return self
end

function rigidBody:has_collider()
    return self.collider ~= nil
end

function rigidBody:add_force(f)
    self.force = self.force + f
end


function rigidBody:add_force_at(f, p)
    self.force = self.force + f
    self.torque = self.torque + p:cross(f)
end

function rigidBody:add_torque(t)
    self.torque = self.torque + t
end

function rigidBody:add_drag(s, dt)
    self.vel    = self.vel    * math.exp(-self.linDamp * s.linDrag * dt)
    self.angVel = self.angvel * math.exp(-self.angDamp * s.angDrag * dt)
end

function rigidBody:integrate_forces(dt)
    local acceleration = self.force / self.mass
    self.vel = self.vel + acceleration * dt
    self.pos = self.pos + self.vel * dt
        
    self.force = Vector()
end

return rigidBody