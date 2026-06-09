Color  = require("lib.color")
Vector = require("lib.vector")
Class  = require("lib.class")
Events = require("lib.event")

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
        MARTIUS = "resources/fonts/Martius-LV9L4.ttf",
    },

    RESOURCES = {

    }
}

    -- Colors --
COLORS = {
    TRUE = {
        BLACK = Color(0, 0, 0),
        GREY  = Color(0.5, 0.5, 0.5),
        WHITE = Color(1, 1, 1),

        R = Color(1, 0, 0),
        G = Color(0, 1, 0),
        B = Color(0, 0, 1),
    },
}

-- ======GLOBAL VARS====== --
Scene_Manager = nil
Input = {}
InputEvents = {}

Fonts = { s12 = {s = 12}, s16 = {s = 16}, s28 = {s = 28}, s32 = {s = 32}, s48 = {s = 48}, s64 = {s = 64}, s128 = {s = 128} }
Menus = {}

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
