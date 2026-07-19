require('conf')

local sprite2d = Class:extract("Sprite2D")

function sprite2d:new(cmpts)
    self.components = cmpts
end

function sprite2d:update(dt)
    for _, component in ipairs(self.components) do
        if type(component.update) == 'function' then
            component:update(dt)
        end
    end
end

return sprite2d