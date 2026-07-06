
local shaders = {}

-- Noise shader, taken from outside source(https://github.com/stegu/webgl-noise)
local noise = [[
    float PI        = 3.1415926535;

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
]]

shaders.nebula = love.graphics.newShader(noise .. [[
    uniform vec2 res;
    uniform vec2 cam;
    uniform float time;
    uniform float parallax;
    uniform float zoom;

    float SCALE = 0.0025;
    float TIMESCALE = 0.025;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec2 center = screen_coords - res / 2;
        vec2 wPos = vec2((center.x * SCALE / zoom + cam.x * parallax) , (center.y * SCALE / zoom - cam.y * parallax) ) ;
        vec3 nebHash = vec3(wPos[0], wPos[1], time * TIMESCALE);

        float n = fbm(nebHash, 4) * 0.5 + 0.5;
        
        float a = floor(smoothstep(0.0, 0.8, n) * 15) / 15;

        vec3 c = vec3(
            floor(smoothstep(0.2, 0.7, fbm(vec3(wPos, 1000 + time * TIMESCALE), 3) * 0.5 + 0.5) * 15) / 15, 
            floor(smoothstep(0.2, 0.7, fbm(vec3(wPos, 2000 + time * TIMESCALE), 3) * 0.5 + 0.5) * 15) / 15, 
            floor(smoothstep(0.2, 0.7, fbm(vec3(wPos, 3000 + time * TIMESCALE), 3) * 0.5 + 0.5) * 15) / 15
        );

        if (n < 0.3) {
            float strength = smoothstep(0.3, 0.0, n);

            vec3 haze = 1 - color.rgb/2;

            c = mix(c, haze, strength * 0.6);
            a *= 1.0 + strength * 0.25;
        } else {
            c *= color.rgb;
        }

        return vec4(c, color.a * a);
    }
]])

shaders.texture = love.graphics.newShader(noise .. [[
    
    float SCALE = 0.001;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec3 hash = vec3(screen_coords, 30000);
        float n = fbm(hash, 3) * 0.5 + 0.5;
        
        float a = smoothstep(0.2, 1.0, n);

        vec3 c = vec3(
            smoothstep(0.0, 0.6, fbm(vec3(screen_coords, 1000), 1)) * 0.5 + 0.5, 
            smoothstep(0.0, 0.5, fbm(vec3(screen_coords, 2000), 1)) * 0.5 + 0.5, 
            smoothstep(0.0, 0.3, fbm(vec3(screen_coords, 3000), 1)) * 0.5 + 0.5
        ) * 0.1;

        return vec4(color.r * c.r, color.g * c.g, color.b * c.b, color.a * a);
    }
]])

shaders.lighting = love.graphics.newShader(noise .. [[
    uniform vec2 res;
    uniform vec2 cam;
    uniform float time;
    uniform float zoom;

    float SCALE = 0.0015;
    float TIMESCALE = 0.025;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixelColor = Texel(texture, texture_coords);
        vec2 center = screen_coords - res / 2;
        vec2 wPos = vec2((center.x * SCALE / zoom + cam.x * 0.125) , (center.y * SCALE / zoom - cam.y * 0.125) ) ;
        vec3 lightHash = vec3(wPos[0], wPos[1], time * TIMESCALE);

        float n = fbm(lightHash, 1) * 0.5 + 0.5;
        float a = smoothstep(0.0, 0.8, n);

        return vec4(color.rgb*pixelColor.rgb*a, color.a * pixelColor.a * a);
    }
]])

shaders.light = love.graphics.newShader(noise .. [[
    uniform vec2 res;
    uniform vec2 cam;
    uniform float time;
    uniform float zoom;

    float SCALE = 0.0015;
    float TIMESCALE = 0.025;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixelColor = Texel(texture, texture_coords);
        vec2 center = screen_coords - res / 2;
        vec2 wPos = vec2((center.x * SCALE / zoom + cam.x * 0.125) , (center.y * SCALE / zoom - cam.y * 0.125) ) ;
        vec3 lightHash = vec3(wPos[0], wPos[1], time * TIMESCALE);

        float n = fbm(lightHash, 1) * 0.5 + 0.5;
        float a = smoothstep(0.0, 0.8, n);

        return vec4(color.rgb*pixelColor.rgb*a, color.a * pixelColor.a);
    }
]])

return shaders