
require('conf')

local spline = require("lib.spline")
local splineMgr = Class:extract('Spline_Manager')

function splineMgr:new(scene)
    self.scene = scene
    self.splines = {  }
    return self
end

function splineMgr:update(dt)

    for key, s in pairs(self.splines) do
        s:update(dt)
    end

end

function splineMgr:get_spline(key)
    return self.splines[key]
end

function splineMgr:add_spline(key, s)
    if s.is_type and s:is_type("Spline") then
        s:set_manager(self)
        self.splines[key] = s
    else
        self.splines[key] = spline(s, key, self)
    end
end

function splineMgr:pop_spline(key)
    local s = table.clone(self.splines[key])
    self.splines[key] = nil

    return s
end

return splineMgr