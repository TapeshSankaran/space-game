-- World file for real positioning --

require("conf")

local world = Class:extract("World")

local OPACITY = 0.5
local GRID = Vector(50, 50)

function world:new(scene)
    self.scene = scene

    return self
end

function world:update(dt)
    
end

function world:draw_grid(drawNum)
    if drawNum == nil then drawNum = true end

    local topLeft     = self:screen_to_world(Vector(0, 0))
    local bottomRight = self:screen_to_world(Vector(width, height))

    local minX = math.floor(topLeft.x) - 1
    local maxX = math.ceil(bottomRight.x) + 1

    local minY = math.floor(bottomRight.y) - 1
    local maxY = math.ceil(topLeft.y) + 1

    love.graphics.setColor((COLORS.TRUE.BLACK * Color(1, 1, 1, OPACITY)):rgb())
    for x = minX, maxX do
        local a = self:world_to_screen(Vector(x, minY))
        local b = self:world_to_screen(Vector(x, maxY))

        love.graphics.line(a.x, a.y, b.x, b.y)
    end

    love.graphics.setFont(Fonts.s12.martius)
    for y = minY, maxY do
        love.graphics.setColor((COLORS.TRUE.BLACK * Color(1, 1, 1, OPACITY)):rgb())
        local a = self:world_to_screen(Vector(minX, y))
        local b = self:world_to_screen(Vector(maxX, y))

        love.graphics.line(a.x, a.y, b.x, b.y)
        
        if drawNum then
            love.graphics.setColor((COLORS.TRUE.WHITE * Color(1, 1, 1, OPACITY)):rgb())
            for x = minX, maxX do
                local offset = Vector(
                    Fonts.s12.martius:getWidth(tostring(Vector(x, y)))/2,
                    Fonts.s12.martius:getHeight()/2
                )
                local c = self:world_to_screen(Vector(x, y)) - offset
                love.graphics.print(tostring(Vector(x, y)), c.x, c.y)
            end
        end
    end
end

-- World is positive upward while screen is negative upwards. Screen lives within World, however.
function world:screen_to_world(screenPos, camera)
    local zoom = self.scene.camera.zoom
    local pos
    if camera then pos = camera else pos = self.scene.camera.pos end
    local wPos= Vector(pos.x + screenPos.x/(GRID.x * zoom), pos.y - screenPos.y/(GRID.y * zoom))
    return wPos
end

function world:world_to_screen(worldPos, camera)
    local zoom = self.scene.camera.zoom
    local pos
    if camera then pos = camera else pos = self.scene.camera.pos end
    local relPos = worldPos - pos
    return Vector(relPos.x * GRID.w * zoom, -relPos.y * GRID.h * zoom)
end

function world:coord_in_world(scrnLen)
    local cam = self.scene.camera
    return Vector(scrnLen.x/(GRID.x * cam.zoom), 0 - scrnLen.y/(GRID.y * cam.zoom))
end

function world:coord_in_pixels(wrldPos)
    local cam = self.scene.camera
    return Vector(wrldPos.x * GRID.x * cam.zoom, wrldPos.y * GRID.x * cam.zoom)
end

return world