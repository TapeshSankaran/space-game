require('conf')

local meshMgr = Class:extract('Mesh_Manager')

local mesh = require("lib.mesh")

function meshMgr:new(meshLst)
    self.meshes = {}
    for _, name in ipairs(meshLst) do
        table.insert(self.meshes, mesh:new(name, Images[name]))
    end
    self.curr   = self.meshes[1]
    table.remove(self.meshes, 1)
    return self
end

function meshMgr:update()
    if not self.finished then
        self.curr:update()
    end
    if self.curr.finished == true then
        if #self.meshes > 0 then
            self.curr = self.meshes[1]
            table.remove(self.meshes, 1)
        else
            self.finished = true
            Disabled = false
        end
    end
end

function meshMgr:draw()

    if not self.finished then
        love.graphics.setColor(COLORS.TRUE.GREY:rgb())
        love.graphics.rectangle("fill", 0, 0, width, height)
        self.curr:draw()
    end
end

return meshMgr