local color = require "color"

-- ======CONFIGURATION====== --

    -- Size of Display --
width  = 1200
height = 900

    -- Fullscreen? --
isFull = false

    -- Set Random Seed --
seed = os.time() -- [default: 5 for testing, os.time() for main use]

-- ======ENUMS====== --

    -- File Locations --
FILE_LOCATIONS = {
    IMAGES = {

    },

    SPRITE_SHEETS = {

    },

    SFX   = {

    },

    FONTS = {

    },

    RESOURCES = {

    }
}

    -- Colors --
COLORS = {
    TRUE = {
        BLACK = color(0, 0, 0),
        GREY  = color(0.5, 0.5, 0.5),
        WHITE = color(1, 1, 1),

        R = color(1, 0, 0),
        G = color(0, 1, 0),
        B = color(0, 0, 1),
    },
}

-- ======GLOBAL VARS====== --
Anim_Manager = nil
Fonts = { s12 = {s = 12}, s16 = {s = 16}, s28 = {s = 28}, s32 = {s = 32}, s48 = {s = 48}, s64 = {s = 64}, s128 = {s = 128} }

-- ======USEFUL FUNCTIONS====== --
function indexOf(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then return i end
    end
    return nil  -- Not found
end

function indexOfName(tbl, val)
    for i, v in ipairs(tbl) do
        if v.name == val then return i end
    end
    return nil  -- Not found
end

function love.conf(t)
   t.console = true
end
