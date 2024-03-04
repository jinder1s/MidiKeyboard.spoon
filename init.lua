-- Source: https://gist.github.com/EgillAntonsson/37cc2a1341d649971f85f22b528eda7d


local socket = require "socket"
local spoons   = require("hs.spoons")

local obj    = {
-- Metadata
    name      = "MidiKeyboard",
    author    = "jinder",
    license   = "MIT - https://opensource.org/licenses/MIT",
    spoonPath = spoons.scriptPath(),
    spoonMeta = "placeholder for _coresetup metadata creation",
}

obj.__index = obj

obj.piano = dofile(obj.spoonPath .. "piano.lua")
obj.actor = dofile(obj.spoonPath .. "scaleNoteActor.lua")
obj.constants = dofile(obj.spoonPath .. "constants.lua")
obj.keylogger = dofile(obj.spoonPath .. "keylogger.lua")

function obj:init()
    -- obj.keylogger.init()
    obj.actor.init(obj.constants)
    obj.piano.init(obj.constants, obj.actor.NoteActor, obj.actor.NoteOffActor, obj.actor.pedalActor)
end

return obj
