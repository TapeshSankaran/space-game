-- Input Actions --

require("conf")

---@class Input
local input = Class:extract("Input")

local scroll = nil

local MOUSE = {
    LEFT   = { left=1, lef=1, le=1, l=1, lft=1 },
    RIGHT  = { right=2, righ=2, rig=2, ri=2, r=2 },
    MIDDLE = { middle=3, middl=3, midd=3, mid=3, mi=3, m=3, scroll=3, scrl=3, s=3 },
}

local KEYBOARD = {
    MODE = {
        KEY = {k=1, key=1},
        SC  = {scan=2, scancode=2, sc=2}
    },
}

function input:new()

    
    self.mouse = {}
    self.mouse.prevPos = Vector(0, 0)
    self.mouse.pos = Vector(0, 0)
    
    self.mouse.left = {}
    self.mouse.right = {}
    self.mouse.middle = {}
    self.mouse.left.click   = false
    self.mouse.right.click  = false
    self.mouse.middle.click = false
    self.mouse.left.release   = false
    self.mouse.right.release  = false
    self.mouse.middle.release = false
    
    self.mouse.scrolling    = Vector(0, 0)
    self.mouse.enabled      = true
    
    
    self.keyboard = {}
    self.keyboard.prev_pressed = {}
    self.keyboard.pressed      = {}
    self.keyboard.enabled      = true
    
    self.enabled = true
    self.scene   = nil
    self.dt      = 0.0
    
    return self
end

-- This function should run at the START of the update loop for accurate inputs. the call functions should run after inputs are recorded --
function input:update(dt)

    -- Mouse --
    self.dt = dt
    self.mouse.prevPos = self.mouse.pos
    self.mouse.pos     = Vector(love.mouse.getPosition())

    
    self.mouse.left.release   = (love.mouse.isDown(1) == false and self.mouse.left.prev   == true) and true or false
    self.mouse.right.release  = (love.mouse.isDown(2) == false and self.mouse.right.prev  == true) and true or false
    self.mouse.middle.release = (love.mouse.isDown(3) == false and self.mouse.middle.prev == true) and true or false
    
    self.mouse.left.click   = (love.mouse.isDown(1) == true and self.mouse.left.prev   == false) and true or false
    self.mouse.right.click  = (love.mouse.isDown(2) == true and self.mouse.right.prev  == false) and true or false
    self.mouse.middle.click = (love.mouse.isDown(3) == true and self.mouse.middle.prev == false) and true or false
    self.mouse.scrolling    = scroll and scroll or Vector(0, 0)

    self.mouse.left.prev   = love.mouse.isDown(1)
    self.mouse.right.prev  = love.mouse.isDown(2)
    self.mouse.middle.prev = love.mouse.isDown(3)
    
    -- Scene Change --
    if self.scene ~= Scene_Manager:current_scene() then
        self.scene = Scene_Manager:current_scene()
    end

end

function input:reset()
    -- Keyboard --
    self.keyboard.prev_pressed = self.keyboard.pressed
    self.keyboard.pressed = {}

    -- Mouse --
    scroll = Vector(0, 0)
end

function input:set_enable(b)
    self.enabled = b
end

-- MOUSE FUNCTIONS --

function input:mouse_scrolled(x, y)
    if not self:mouse_is_enabled() then
        scroll = Vector(0, 0)
        return
    end

    if x > 0 then x = 1 elseif x < 0 then x = -1 end
    if y > 0 then y = 1 elseif y < 0 then y = -1 end

    scroll = Vector(x, y)
end

function input:mouse_get_scroll()
    return self.mouse.scrolling
end

function input:is_scrolling()
    return self.mouse.scrolling ~= 0
end

function input:mouse_screen_position()
    if not self:mouse_is_enabled() then return end
    return self.mouse.pos
end

function input:mouse_world_position()
    if not self:mouse_is_enabled() then return end
    if not self.scene.world then return nil end
    return self.scene.world:screen_to_world(self.mouse.pos)
end

function input:mouse_screen_velocity()
    if not self:mouse_is_enabled() then return end
    return (self.mouse.pos - self.mouse.prevPos) / self.dt
end

function input:is_mouse_down(code)
    if not self:mouse_is_enabled() then return false end

    local b
    if MOUSE.RIGHT[code] then
        b = 2
    elseif MOUSE.MIDDLE[code] then
        b = 3
    else
        b = 1
    end

    return love.mouse.isDown(b)
end

function input:mouse_clicked(code)
    if not self:mouse_is_enabled() then return false end

    if MOUSE.RIGHT[code] then
        return self.mouse.right.click
    elseif MOUSE.MIDDLE[code] then
        return self.mouse.middle.click
    else
        return self.mouse.left.click
    end
end

function input:mouse_released(code)
    if not self:mouse_is_enabled() then return false end

    if MOUSE.RIGHT[code] then
        return self.mouse.right.release
    elseif MOUSE.MIDDLE[code] then
        return self.mouse.middle.release
    else
        return self.mouse.left.release
    end
end

function input:mouse_set_enable(b)
    self.mouse.enabled = b
end

function input:mouse_is_enabled()
    return self.mouse.enabled and self.enabled
end


-- KEYBOARD FUNCTIONS --

function input:key_pressed(key, scancode, isrepeat)
    if not self:keyboard_is_enabled() then return end
    local item = { k=key, sc=scancode, is_r=isrepeat }
    self.keyboard.pressed[key] = item
end

function input:get_pressed()
    if not self:keyboard_is_enabled() then return {} end

    return self.keyboard.pressed
end

function input:is_key_pressed(key)
    return self.keyboard.pressed[key:lower()] ~= nil
end

function input:is_key_down(key)
    return love.keyboard.isDown(key:lower())
end

function input:get_key_pressed(key)
    key = key:lower()
    if self:is_key_pressed(key) then
        return self.keyboard.pressed[key]
    end
end

function input:keyboard_set_enable(b)
    self.keyboard.enabled = b
end

function input:keyboard_is_enabled()
    return self.keyboard.enabled and self.enabled
end


return input