-- Background of space, parallax --

require("conf")

local background = Class:extract("Background")

local TIMESCALE = 0.05
local SCALE = 1.0

local nebula_shader = love.graphics.newShader[[

    uniform vec2 cam;
    uniform float time;
    uniform float parallax;

    float PI        = 3.1415926535;
    float SCALE     = 0.004;
    float TIMESCALE = 0.05;

    //	by Ian McEwan, Stefan Gustavson (https://github.com/stegu/webgl-noise)
    //
    vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
    vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

    float snoise(vec3 v) { 
        const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
        const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
        vec3 i  = floor(v + dot(v, C.yyy) );
        vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
        vec3 g = step(x0.yzx, x0.xyz);
        vec3 l = 1.0 - g;
        vec3 i1 = min( g.xyz, l.zxy );
        vec3 i2 = max( g.xyz, l.zxy );

        //  x0 = x0 - 0. + 0.0 * C 
        vec3 x1 = x0 - i1 + 1.0 * C.xxx;
        vec3 x2 = x0 - i2 + 2.0 * C.xxx;
        vec3 x3 = x0 - 1. + 3.0 * C.xxx;

    // Permutations
        i = mod(i, 289.0 ); 
        vec4 p = permute( permute( permute( 
                 i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
               + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
               + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients
    // ( N*N points uniformly over a square, mapped onto an octahedron.)
        float n_ = 1.0/7.0; // N=7
        vec3  ns = n_ * D.wyz - D.xzx;

        vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

        vec4 x_ = floor(j * ns.z);
        vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

        vec4 x = x_ *ns.x + ns.yyyy;
        vec4 y = y_ *ns.x + ns.yyyy;
        vec4 h = 1.0 - abs(x) - abs(y);

        vec4 b0 = vec4( x.xy, y.xy );
        vec4 b1 = vec4( x.zw, y.zw );

        vec4 s0 = floor(b0)*2.0 + 1.0;
        vec4 s1 = floor(b1)*2.0 + 1.0;
        vec4 sh = -step(h, vec4(0.0));

        vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
        vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

        vec3 p0 = vec3(a0.xy,h.x);
        vec3 p1 = vec3(a0.zw,h.y);
        vec3 p2 = vec3(a1.xy,h.z);
        vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
        vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
        p0 *= norm.x;
        p1 *= norm.y;
        p2 *= norm.z;
        p3 *= norm.w;

    // Mix final noise value
        vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
        m = m * m;
        return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                      dot(p2,x2), dot(p3,x3) ) );
    }

    //complexity improvement
    float fbm(vec3 p, int o)
    {
        float value = 0.0;
        float amp = 0.5;

        for(int i = 0; i < o; i++)
        {
            value += amp * snoise(p);
            p *= 2.0;
            amp *= 0.5;
        }

        return value;
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec2 wPos = vec2(screen_coords[0] * SCALE + cam[0] * parallax, screen_coords[1] * SCALE - cam[1] * parallax);
        vec3 nebHash = vec3(wPos[0], wPos[1], time * TIMESCALE);

        float n = fbm(nebHash, 3) * 0.5 + 0.5;
        
        float a = smoothstep(0.0, 0.7, n);

        vec3 c = vec3(
            smoothstep(0.1, 0.6, fbm(vec3(wPos, 1000 + time * TIMESCALE), 2)) * 0.5 + 0.5, 
            smoothstep(0.1, 0.6, fbm(vec3(wPos, 2000 + time * TIMESCALE), 2)) * 0.5 + 0.5, 
            smoothstep(0.1, 0.6, fbm(vec3(wPos, 3000 + time * TIMESCALE), 2)) * 0.5 + 0.5
        );

        if (n < 0.25) {
            a = 0;
        }

        return vec4(color.r * c[0], color.g * c[1], color.b * c[2], color.a * a);
    }
]]

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

            local n = self:fbm( 6,
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

local nebula_parallax = 0.1
function background:update(dt)
    nebula_shader:send("cam", {self.scene.camera.pos.x, self.scene.camera.pos.y})
    nebula_shader:send("parallax", nebula_parallax)
    nebula_shader:send("time", self.scene.time)
end

function background:noise(...)
    local args = { ... }
    for i=1,#args do
        args[i] = args[i] + self.seed[i]
    end
    return love.math.noise(unpack(args))
end

function background:for_grid(mode, func, ...)
    if mode ~= 'screen' then
        local cam = mode
        --cam = Vector(math.ceil(cam.x), math.floor(cam.y))
        local topLeft  = self.scene.world:screen_to_world(Vector(0, 0), cam)
        local botRight = self.scene.world:screen_to_world(Vector(width, height), cam)
        
        local min = Vector(math.floor(topLeft.x) - 1, math.floor(botRight.y) - 1)
        local max = Vector(math.ceil(botRight.x) + 1, math.ceil(topLeft.y) + 1)

        local s = Vector(0.5, 0.5)
        local ws = self.scene.world:coord_in_pixels(s)
        for x=min.x,max.x,s.x do
            for y=min.y,max.y,s.y do
                func(x+ws.x/2, y+ws.y/2, ...)
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

function background:nebula(parallax)
    local c = COLORS.TRUE.BLACK
    if self.colors.nebula then c = self.colors.nebula end
    local color = Color(c.r, c.g, c.b, 0.5)
    love.graphics.setShader(nebula_shader)
    love.graphics.setColor(color:rgb())
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setShader()
end

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

function background:stars(parallax, odds, offset)
    local cam = self.scene.camera.pos * parallax
    local color = self.colors.star and self.colors.star or COLORS.TRUE.WHITE
    self:for_grid(cam, function (x, y, p, o, c, off)
        local n = self:noise(x + off, y + off)
        if n >= 1-o then
            local sp = self.scene.world:world_to_screen(Vector(x, y), cam) + Vector(-width/2, height/1.5)
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
end

function background:draw(pos)
    self:space(0.1)
    self:stars(0.2, 0.1, 1000)
    self:nebula(nebula_parallax)
    self:stars(0.75, 0.025, -1000)
    self:stars(0.8, 0.025, -200)
    self:stars(0.85, 0.025, -500)
    self:stars(0.9, 0.025, 200)
end


return background