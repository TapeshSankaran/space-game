local Component = require("lib.component")

local collider = Component:extract('Collider')

function collider:new(obj, mesh, masks)
    self.super.new(self, obj)
    self.rigidbody = obj.component['rigidbody'] and obj.component['rigidbody'] or nil
    self.mesh = mesh
    self.masks = masks or 0
    
    self.space = nil
    return self
end

function collider:has_rigidbody()
    return self.rigidbody ~= nil
end

function collider:triggered() end

return collider