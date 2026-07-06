-- Background of space, parallax --
require("conf")

local background = Class:extract("Background")

local shaders = Shaders

local TIMESCALE = 0.05
local SCALE = 1.0

-- new background, prerenders space background
function background:new(cfg)
    self.colors = cfg.c
    self.scene = cfg.scene
    self.res  = cfg.res and cfg.res or Vector(10, 10)


    local mask = {}
    for i=1,4 do
        table.insert(mask, math.random() > 0.5 and 1 or -1)
    end
    self.seed  = {
        math.random(5000, 15000) * mask[1],
        math.random(5000, 15000) * mask[2],
        math.random(5000, 15000) * mask[3],
        math.random(5000, 15000) * mask[4]
    }

    self.bg = love.graphics.newCanvas(width, width)
    love.graphics.setCanvas(self.bg)

    for x=0,self.bg:getWidth() do
        for y=0,self.bg:getHeight() do
            local uv = Vector(x / width, y / width)

            local n = self:fbm( 1,
                math.cos(uv.x * math.pi * 2) * SCALE,
                math.cos(uv.y * math.pi * 2) * SCALE,
                math.sin(uv.x * math.pi * 2) * SCALE,
                math.sin(uv.y * math.pi * 2) * SCALE
            )
            if n <= 0.6 then
                love.graphics.setColor(self.colors.space[1]:rgb())
                love.graphics.points(x, y)
            else
                love.graphics.setColor((2*(self.colors.space[2]*(1-n) + self.colors.space[3]*n)):rgb())
                love.graphics.points(x, y)
            end
        end
    end
    
    love.graphics.setCanvas()
    
    return self
end

local nebula_parallax = 0.05
-- Update, made to update externals from shaders
function background:update(dt)
    -- Nebula Shader
    shaders.nebula:send("res", { width, height })
    shaders.nebula:send("cam",      {self.scene.camera.pos.x, self.scene.camera.pos.y})
    shaders.nebula:send("parallax", nebula_parallax)
    shaders.nebula:send("time",     self.scene.time)
    shaders.nebula:send("zoom",     self.scene.camera.zoom)

    -- Texture Shader
    --  nothing

    -- Lighting Shader
    shaders.lighting:send("res",  { width, height })
    shaders.lighting:send("cam",  {self.scene.camera.pos.x, self.scene.camera.pos.y})
    shaders.lighting:send("time", self.scene.time)
    shaders.lighting:send("zoom", self.scene.camera.zoom)
end

-- Noise function, using love's noise but adding a seed to it, influenced by random
function background:noise(...)
    local args = { ... }
    for i=1,#args do
        args[i] = args[i] + self.seed[i]
    end
    return love.math.noise(unpack(args))
end

-- For-function to either do something per screen grid or per world grid
function background:for_grid(mode, func, ...)
    if mode ~= 'screen' then
        local cam = mode
        local topLeft  = self.scene.world:screen_to_world(Vector(0, 0), cam)
        local botRight = self.scene.world:screen_to_world(Vector(width, height), cam)
        
        local min = Vector(math.floor(topLeft.x) - 1, math.floor(botRight.y) - 1)
        local max = Vector(math.ceil(botRight.x) + 1, math.ceil(topLeft.y) + 1)

        local s = Vector(0.5, 0.5)
        for x=min.x,max.x,s.x do
            for y=min.y,max.y,s.y do

                func(x+s.x/2, y+s.y/2, ...)
            end
        end

    else
        for x=0,width,self.res.w do
            for y=0,height,self.res.h do
                func(x+self.res.w/2, y+self.res.h/2, ...)
            end
        end
    end
end

-- Noise complexity for any function's benefit (not working)
function background:fbm(o, ...)
    local val = 0.0
    local amp = 0.5
    local dim = {...}
    for i = 0,o do
        val = val + amp * self:noise(...)
        for _, d in ipairs(dim) do
            d = d * 2.0
        end
        amp = amp * 0.5
    end
    return val
end

-- Draw functio for pre-rendered space background
function background:space(parallax)
    if parallax == nil then parallax = 0.05 end
    local cam = self.scene.camera.pos * parallax
    local s   = Vector(self.bg:getWidth(), self.bg:getHeight())
    local p   = self.scene.world:coord_in_pixels(cam)
    local off = Vector(-(p.x % s.x), (p.y % s.y))
    if cam.x == 0 and cam.y == 0 then
        off = Vector(0, 0)
    end
    love.graphics.draw(self.bg, off.x, off.y)
    love.graphics.draw(self.bg, off.x + s.x, off.y + s.y)
    love.graphics.draw(self.bg, off.x + s.x, off.y - s.y)
    love.graphics.draw(self.bg, off.x - s.x, off.y - s.y)
    love.graphics.draw(self.bg, off.x - s.x, off.y + s.y)
    love.graphics.draw(self.bg, off.x, off.y - s.y)
    love.graphics.draw(self.bg, off.x, off.y + s.y)
    love.graphics.draw(self.bg, off.x - s.x, off.y)
    love.graphics.draw(self.bg, off.x + s.x, off.y)
end

-- Draw function for nebula, using GLSL space shader
function background:nebula()
    local c = COLORS.TRUE.BLACK
    if self.colors.nebula then c = self.colors.nebula end
    local color = Color(c.r, c.g, c.b, 0.35)
    love.graphics.setShader(shaders.nebula)
    love.graphics.setColor(color:rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setShader()
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
end

-- Draw function for stars, using for_grid() world grid
function background:stars(parallax, odds, offset)
    local cam = self.scene.camera.pos * parallax
    local color = self.colors.star and self.colors.star or COLORS.TRUE.WHITE
    love.graphics.setColor(Color(0, 0, 0, 0.05):rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)
    self:for_grid(cam, function (x, y, p, o, c, off)
        local n = self:noise(x + off, y + off)
        if n >= 1-o then
            local sp = self.scene.world:world_to_screen(Vector(x, y), cam)
            local t = self.scene.time
            local a = self:noise(x, y, t)
            
            local dist = 0.5 + 0.5 * p
            love.graphics.setColor(Color(c.r, c.g, c.b, a):rgb())
            love.graphics.circle( "fill", sp.x, sp.y, 2*dist )

            love.graphics.setColor(Color(c.r/2, c.g/3, c.b/2, a/6):rgb())
            love.graphics.circle( "fill", sp.x, sp.y, 12*dist*a )

            love.graphics.setColor(Color(c.r/2, c.g/3, c.b/2, a/4):rgb())
            love.graphics.circle( "fill", sp.x, sp.y, 8*dist*a )
        end
    end, parallax, odds, color, offset)
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
end

-- Post-world-render screen texture shader
function background:texture()
    local c = COLORS.TRUE.BLACK
    if self.colors.texture then c = self.colors.texture end
    local color = Color(c.r, c.g, c.b, 0.1)
    love.graphics.setShader(shaders.texture)
    love.graphics.setColor(color:rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setShader()
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
end

function background:lighting()
    local c = COLORS.TRUE.BLACK
    local color = Color(c.r, c.g, c.b, 0.5)
    love.graphics.setShader(shaders.lighting)
    love.graphics.setColor(color:rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setShader()
    love.graphics.setColor(COLORS.TRUE.WHITE:rgb())
end

-- Background Draw Function w/ Parallax effects
function background:draw(pos)
    self:space(0.1)
    self:stars(0.2, 0.1, 1000)
    self:nebula()
    self:stars(0.75, 0.025, -1000)
    self:stars(0.8, 0.025, -200)
    self:stars(0.85, 0.025, -500)
    self:stars(0.9, 0.025, 200)
end

-- Background post-world-render draw function
function background:post_draw()
    self:stars(1.2, 0.02, 2000)
    self:lighting()
    self:texture()
end


return background