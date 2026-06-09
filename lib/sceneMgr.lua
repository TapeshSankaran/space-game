-- Scene manager for scenes --

require("conf")

local sMgr = Class:extract("Scene_Manager")


function sMgr:new(sceneDir, scenes)
    
    self.dir = sceneDir and sceneDir or ""

    self.prev_scene = nil
    self.curr_scene = nil    
    
    if scenes == nil then
        self.scenes = nil
        return self
    end

    self.scenes = {}
    for _, scene in ipairs(scenes) do
        local s = require(self.dir .. '.' .. scene)
        self.scenes[scene] = s(self)
    end

    return self
end

function sMgr:update(dt)
    if self.curr_scene ~= nil then
        self.curr_scene:update(dt)
    end
end

function sMgr:draw()
    if self.curr_scene ~= nil then
        self.curr_scene:draw()
    end
end

function sMgr:add(scene)
    if type(scene) == "string" then
        local s = require(self.dir .. '.' .. scene)
        self.scenes['scene'] = s

    elseif scene.is_type and scene:is_type("Scene") then
        table.insert(self.scenes, scene)
    end
end

function sMgr:remove(scene)

end

function sMgr:switch(scene)
    if self.curr_scene ~= nil then
        self.curr_scene:exit()
    end

    if type(scene) == "string" and self.scenes[scene]:is_type("Scene") then
        print("Switching to scene: " .. scene)
        self.prev_scene = self.curr_scene
        self.curr_scene = self.scenes[scene]
        self.curr_scene:enter()
    end
end

function sMgr:current_scene()
    return self.curr_scene
end

function sMgr:list_scenes()
    return self.scenes
end


return sMgr