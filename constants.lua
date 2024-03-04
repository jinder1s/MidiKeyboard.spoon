local constants = {}
constants.notes = { "C", { "C#", "Db" }, "D", { "D#", "Eb" }, "E", "F", { "F#", "Gb" }, "G", { "G#", "Ab" }, "A",
  { "A#", "Bb" }, "B" }
constants.scaleMapping = { "I", "IIb", "II", "IIIb", "III", "IV", "Vb", "V", "VIb", "VI", "VIIb", "VII" }

constants.majorScale = { "I", "II", "III", "IV", "V", "VI", "VII" }
constants.minorScale = { "I", "II", "IIIb", "IV", "V", "VIb", "VIIb" }


constants.chromatic_movements = {
  major = { 4, 3 },
  minor = { 3, 4 },
  diminished = { 3, 3 },
  sus2 = { 2, 5 },
  sus4 = { 4, 1 },
}

constants.scale_movements = {
  scale = { 2, 2 },
  sus2 = { 1, 3 },
  sus4 = { 3, 1 },
  sixth = { 2, 3 },
}



constants.key_to_note_mapping = {}

constants.currentScale = "B"
constants.scaleIndex = nil
for index, note in ipairs(constants.notes) do
  if type(note) == "table" then
    if constants.currentScale == note[1] or constants.currentScale == note[2] then
      constants.scaleIndex = index
      break
    end
  else
    if note == constants.currentScale then
      constants.scaleIndex = index
      break
    end
  end
end
for i = 0, 127, 1 do
  local octave = (i - (constants.scaleIndex - 1)) // 12 - 3
  local note_index = (i + 1) % 12
  local note = constants.notes[note_index]
  constants.key_to_note_mapping[i] = { octave = octave, note = note, key = i, note_index = note_index }
end

-- local function tableInOneLine(tbl)
--   local str = "{ "
--   for key, value in pairs(tbl) do
--     if (type(value) == "table") then
--       value = tableInOneLine(value)
--     end
--     str = str .. key .. " = " .. value .. ", "
--   end
--   str = str .. " }"
--   return str
-- end




local useWholeKeyboard =
{
  { b = { { sn = "I", lb = 0, ub = 15 }, },           k = "a" },
  { b = { { sn = "II", lb = 0, ub = 15 }, },          k = "b" },
  { b = { { sn = "III", lb = 0, ub = 15 }, },         k = "c" },
  { b = { { sn = "IV", lb = 0, ub = 15 }, },          k = "d" },
  { b = { { sn = "V", lb = 0, ub = 15 }, },           k = "e" },
  { b = { { sn = "VI", lb = 0, ub = 15 }, },          k = "f" },
  { b = { { sn = "VII", lb = 0, ub = 15 }, },         k = "g" },

  { b = { { sn = "I", lb = 31, ub = 45 }, },          k = "h" },
  { b = { { sn = "II", lb = 31, ub = 45 }, },         k = "i" },
  { b = { { sn = "III", lb = 31, ub = 45 }, },        k = "j" },
  { b = { { sn = "IV", lb = 31, ub = 45 }, },         k = "k" },
  { b = { { sn = "V", lb = 31, ub = 45 }, },          k = "l" },
  { b = { { sn = "VI", lb = 31, ub = 45 }, },         k = "m" },
  { b = { { sn = "VII", lb = 31, ub = 45 }, },        k = "n" },

  { b = { { sn = "I", lb = 16, ub = 30 }, },          k = "o" },
  { b = { { sn = "II", lb = 16, ub = 30 }, },         k = "p" },
  { b = { { sn = "III", lb = 16, ub = 30 }, },        k = "q" },
  { b = { { sn = "IV", lb = 16, ub = 30 }, },         k = "r" },
  { b = { { sn = "V", lb = 16, ub = 30 }, },          k = "s" },
  { b = { { sn = "VI", lb = 16, ub = 30 }, },         k = "t" },
  { b = { { sn = "VII", lb = 16, ub = 30 }, },        k = "u" },
  { b = { { sn = "I", lb = 46, }, },                  k = "v" },
  { b = { { sn = "II", lb = 46, }, },                 k = "w" },
  { b = { { sn = "III", lb = 46, }, },                k = "x" },
  { b = { { sn = "IV", lb = 46, }, },                 k = "y" },
  { b = { { sn = "V", lb = 46, }, },                  k = "z" },

  -- { b = { { sn = "IIb", lb = 0, ub = 15 }, },   k = "escape" },
  { b = { { sn = "IIIb", lb = 0, ub = 15 }, },        k = "shift",  ignore_cc = true },
  { b = { { sn = "Vb", lb = 0, ub = 15 }, },          k = "ctrl",   ignore_cc = true },
  { b = { { sn = "VIb", lb = 0, ub = 15 }, },         k = "alt",    ignore_cc = true },
  { b = { { sn = "VIIb", lb = 0, ub = 15 }, },        k = "cmd",    ignore_cc = true },
  { b = { { sn = "IIb", lb = 16, ub = 30 }, },        k = "delete", ignore_cc = true },
  { b = { { sn = "IIIb", lb = 16, ub = 30 }, },       k = "escape", ignore_cc = true },
  { b = { { sn = "Vb", lb = 16, ub = 30 }, },         k = "space",  ignore_cc = true },
  { b = { { sn = "VIb", lb = 16, ub = 30 }, },        k = "return", ignore_cc = true },
  { b = { { sn = "VIIb", lb = 16, ub = 30 }, },       k = "tab",    ignore_cc = true },


  { b = { { c = { sn = "I", t = "major" } } },        k = "a" },
  { b = { { c = { sn = "II", t = "major" } } },       k = "b" },
  { b = { { c = { sn = "III", t = "major" } } },      k = "c" },
  { b = { { c = { sn = "IV", t = "major" } } },       k = "d" },
  { b = { { c = { sn = "V", t = "major" } } },        k = "e" },
  { b = { { c = { sn = "VI", t = "major" } } },       k = "f" },
  { b = { { c = { sn = "VII", t = "major" } } },      k = "g" },
  { b = { { c = { sn = "I", t = "minor" } } },        k = "h" },
  { b = { { c = { sn = "II", t = "minor" } } },       k = "i" },
  { b = { { c = { sn = "III", t = "minor" } } },      k = "j" },
  { b = { { c = { sn = "IV", t = "minor" } } },       k = "k" },
  { b = { { c = { sn = "V", t = "minor" } } },        k = "l" },
  { b = { { c = { sn = "VI", t = "minor" } } },       k = "m" },
  { b = { { c = { sn = "VII", t = "minor" } } },      k = "n" },
  { b = { { c = { sn = "I", t = "diminished" } } },   k = "o" },
  { b = { { c = { sn = "II", t = "diminished" } } },  k = "p" },
  { b = { { c = { sn = "III", t = "diminished" } } }, k = "q" },
  { b = { { c = { sn = "IV", t = "diminished" } } },  k = "r" },
  { b = { { c = { sn = "V", t = "diminished" } } },   k = "s" },
  { b = { { c = { sn = "VI", t = "diminished" } } },  k = "t" },
  { b = { { c = { sn = "VII", t = "diminished" } } }, k = "u" },
  { b = { { c = { sn = "I", t = "sus2" } } },         k = "v" },
  { b = { { c = { sn = "II", t = "sus2" } } },        k = "w" },
  { b = { { c = { sn = "III", t = "sus2" } } },       k = "x" },
  { b = { { c = { sn = "IV", t = "sus2" } } },        k = "y" },
  { b = { { c = { sn = "V", t = "sus2" } } },         k = "z" },

  -- { b = { { sn = "IIb", lb = 0, ub = 20 }, },   k = "escape" },
  { b = { { c = { sn = "IIIb", t = "major" } } },     k = "shift",  ignore_cc = true },
  { b = { { c = { sn = "Vb", t = "major" } } },       k = "ctrl",   ignore_cc = true },
  { b = { { c = { sn = "VIb", t = "major" } } },      k = "alt",    ignore_cc = true },
  { b = { { c = { sn = "VIIb", t = "major" } } },     k = "cmd",    ignore_cc = true },
  { b = { { c = { sn = "IIb", t = "minor" } } },      k = "delete", ignore_cc = true },
  { b = { { c = { sn = "IIIb", t = "minor" } } },     k = "escape", ignore_cc = true },
  { b = { { c = { sn = "Vb", t = "minor" } } },       k = "space",  ignore_cc = true },
  { b = { { c = { sn = "VIb", t = "minor" } } },      k = "return", ignore_cc = true },
  { b = { { c = { sn = "VIIb", t = "minor" } } },     k = "tab",    ignore_cc = true },

  { b = { { sn = "I", }, { sn = "IIb", } },           k = "1" },
  { b = { { sn = "I", }, { sn = "II", } },            k = "2" },
  { b = { { sn = "I", }, { sn = "IIIb", } },          k = "3" },
  { b = { { sn = "I", }, { sn = "III", } },           k = "4" },
  { b = { { sn = "I", }, { sn = "IV", } },            k = "5" },
  { b = { { sn = "I", }, { sn = "Vb", } },            k = "6" },
  { b = { { sn = "I", }, { sn = "V", } },             k = "7" },
  { b = { { sn = "I", }, { sn = "VIb", } },           k = "8" },
  { b = { { sn = "I", }, { sn = "VI", } },            k = "9" },
  { b = { { sn = "I", }, { sn = "VIIb", } },          k = "0" },


  { b = { { sn = "IIb", }, { sn = "II", } },          k = "-" },
  { b = { { sn = "IIb", }, { sn = "IIIb", } },        k = "=" },
  { b = { { sn = "IIb", }, { sn = "III", } },         k = "[" },
  { b = { { sn = "IIb", }, { sn = "IV", } },          k = "]" },
  { b = { { sn = "IIb", }, { sn = "Vb", } },          k = "\\" },
  { b = { { sn = "IIb", }, { sn = "V", } },           k = ";" },
  { b = { { sn = "IIb", }, { sn = "VIb", } },         k = "'",      desc = "single-quote" },
  { b = { { sn = "IIb", }, { sn = "VI", } },          k = "`" },
  { b = { { sn = "IIb", }, { sn = "VIIb", } },        k = "," },
  { b = { { sn = "IIb", }, { sn = "VII", } },         k = "." },

  { b = { { sn = "II", }, { sn = "IIIb", } },         k = '/' },
  { b = { { sn = "II", }, { sn = "III", } },          k = 'left' },
  { b = { { sn = "II", }, { sn = "IV", } },           k = 'down' },
  { b = { { sn = "II", }, { sn = "Vb", } },           k = 'up' },
  { b = { { sn = "II", }, { sn = "V", } },            k = 'right' },

}



constants.key_config = useWholeKeyboard

constants.modifier_keys = {shift= true,
                           ctrl=true, alt=true, cmd=true, delete=true, escape = true, space=true, ["return"]=true, tab=true}
return constants
