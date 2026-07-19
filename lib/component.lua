require('conf')

local component = Class:extract("Component")

function component:new(obj)
    self.parent = obj
    obj.components[self.type] = self
    return self
end

