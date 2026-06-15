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
    drawNum = drawNum ~= nil and drawNum or true

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
function world:screen_to_world(screenPos)
    local cam = self.scene.camera
    local wPos= Vector(cam.pos.x + screenPos.x/GRID.x, cam.pos.y - screenPos.y/GRID.y)
    return wPos
end

function world:world_to_screen(worldPos)
    local cam = self.scene.camera
    local relPos = worldPos - cam.pos
    return Vector(relPos.x * GRID.w * cam.zoom, -relPos.y * GRID.h * cam.zoom)
end


return world