require("conf")

local physSpace = Class:extract("Physics_Space")

--Config: 
function physSpace:new(cfg)
    self.gravity = cfg.gravity and cfg.gravity or Vector()
    self.linDrag = cfg.linDrag and cfg.linDrag or 0
    self.angDrag = cfg.angDrag and cfg.angDrag or 0

    self.bodies = {}
    self.colliders = {}
    return self
end

function physSpace:add(component)
    if component:is_type("RigidBody") then
    
        table.insert(self.bodies, component)
        component.space = self
    
    elseif component:is_type("Collider") then
        
        table.insert(self.colliders, component)
        component.space = self

    end
end

function physSpace:update(dt)
    for _, rb in ipairs(self.bodies) do
        if rb:is_active() then goto continue end

        rb:add_force(self.gravity * rb.mass)
        rb:add_drag(self, dt)

        if rb:has_collider() then
            --TODO: collider calcs
        end

        rb:integrate_forces(dt)
        ::continue::
    end
end

return physSpace