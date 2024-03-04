local socket = require "socket"
local hsevent = hs.eventtap.event
local OK = {} -- outputKeyboard
print(hs.inspect(hs.keycodes.map))
OK.activeBindings = {}
OK.noteOff = {}

OK.implicit_rules = {
  { one_to_one_note = true },
  { has_cc = true }
}
function bindKey(binding, output)
  local assignment = hs.fnutils.copy(binding)
  for i, rule in pairs(binding.b) do
    if rule.sn then
      if not output.sn then
        output.sn = {}
      end
      if not output.sn[rule.sn] then
        output.sn[rule.sn] = {}
      end
      table.insert(output.sn[rule.sn], assignment)
    elseif rule.k then
      if not output.k then
        output.k = {}
      end
      if not output.k[rule.k] then
        output.k[rule.k] = {}
      end
      table.insert(output.k[rule.k], assignment)
    elseif rule.c then
      local chord_notes = OK.createChord(rule.c.sn, OK.constants.chromatic_movements[rule.c.t], OK.constants
        .scaleMapping)
      local sn_binding = {
        b = hs.fnutils.map(chord_notes, function(note) return { sn = note, lb = 0, ub = 40 } end),
        k = binding.k
      }
      output = bindKey(sn_binding, output)
    elseif rule.i then
      if not output.i then
        output.i = {}
      end
      if not output.i[rule.i] then
        output.i[rule.i] = {}
      end
      table.insert(output.i[rule.i], assignment)
    elseif rule.cc then
      if not output.cc then
        output.cc = {}
      end
      if not output.cc[rule.cc] then
        output.cc[rule.cc] = {}
      end
      table.insert(output.cc[rule.cc], assignment)
    end
  end

  return output
end

local Press = function(binding)
  print("clicking: ", binding.k)


  local event = hsevent.newKeyEvent(binding.k, true)
  event:post()
  return event
end



local PressRepeat = function(binding)
  if OK.constants.modifier_keys[binding.k] then
    print("modifier_keys")
    return
  end
  print("repeating: ", binding.k)
  if socket.gettime() - binding.notes[1].tr > 0.35 then
    local event = hsevent.newKeyEvent(binding.k, true)
    event:setProperty(8, 1)
    event:post()
    return event
  end
end

local PressNew = function(binding, notes)
  hs.alert.closeAll()
  local alertStrings = hs.fnutils.map(notes,
    function(note) return string.format("%s %d", note.sn, note.velocity) end)
  local alertString = hs.fnutils.reduce(alertStrings,
    function(output, astring) if #output > 0 then return output .. ", " .. astring else return astring end end, "")
  alertString = alertString .. " " .. binding.k
  hs.alert.show(alertString, nil, nil, 0.5)
  local newInfo = hs.fnutils.copy(binding)
  newInfo.notes = notes

  newInfo.event = Press(binding)

  table.insert(OK.activeBindings, newInfo)
end
local turnOffPress = function(key)
  print("stopping", key)
  hsevent.newKeyEvent(key, false):post()
end

local turnOffPressEverything = function()
  for key, value in ipairs(hs.keycodes.map) do
    hsevent.newKeyEvent(key, false):post()
  end
end


local function doesRuleMatchNotes(rule, notes, binding)
  local matching_note = nil
  if rule.sn then
    matching_note =
        hs.fnutils.find(notes,
          function(note)
            return note.sn == rule.sn
          end
        )
    if not matching_note then
      return false
    end
  elseif rule.key then
    matching_note = hs.fnutils.find(notes,
      function(note)
        return note.note == rule.key
      end
    )
    if not matching_note then
      return false
    end
  elseif rule.chord then
  elseif rule.i then
  end

  if rule.lb and (not matching_note or matching_note.velocity < rule.lb) then
    return false
  end
  if rule.ub and (not matching_note or matching_note.velocity > rule.ub) then
    return false
  end

  if rule.o and matching_note and matching_note.o ~= rule.o then
    return false
  end

  if rule.cc then
    if not OK.pedals[rule.cc] then
      return false
    end
    if OK.pedals[rule.cc].controllerValue ~= 1 then
      return false
    end
  end

  if rule.one_to_one_note then
    local rules_with_key_or_sn =
        hs.fnutils.filter(binding.b,
          function(rule2)
            if rule2.key or rule2.sn then
              return true
            end
            return false
          end)
    if  #rules_with_key_or_sn ~= #notes then
      return false
    end
  end

  if rule.has_cc and not binding.ignore_cc then
    local pedal_pressed = hs.fnutils.some(OK.pedals,
      function(pedal)
        if pedal.controllerValue == 1 then return true end
        return false
      end)
    if pedal_pressed then
      local has_cc_rule = hs.fnutils.some(binding.b,
        function(rule2)
          if rule2.cc then return true end
          return false
        end)
      if not has_cc_rule then
        return false
      end
    end
  end

  return true
end

function OK.NoteActor(currentNotes, pressedNotes)
  -- print(hs.inspect(currentNotes))

  for _, note in ipairs(currentNotes) do
    note.sn = OK.scale_note_mapper(note.note)
    note.o = OK.octave_mapper(note.note)
  end

  local note_with_match = hs.fnutils.find(currentNotes,
    function(note)
      return OK.mapping.k[note.note] or
          OK.mapping.sn[note.sn]
    end)

  local possibleBindings = OK.mapping.k[note_with_match.note] or
      OK.mapping.sn[note_with_match.sn]
  if possibleBindings then
    local matching_bindings = hs.fnutils.filter(
      possibleBindings,
      function(binding)
        return hs.fnutils.every(
          binding.b,
          function(rule)
            return doesRuleMatchNotes(rule, currentNotes, binding)
          end
        ) and hs.fnutils.every(
          OK.implicit_rules,
          function(rule)
            return doesRuleMatchNotes(rule, currentNotes, binding)
          end
        )
      end
    )
    if matching_bindings and #matching_bindings > 0 then
      if #matching_bindings == 1 then
        PressNew(matching_bindings[1], currentNotes)
      else
        local max_binding = nil
        for _, binding in hs.fnutils.sortByKeyValues(matching_bindings, function(a, b) return #a.b > #b.b end) do
          max_binding = binding
          break
        end
        PressNew(max_binding, currentNotes)
      end
    else
      print("No binding found from: ", hs.inspect(currentNotes))


      local alertStrings = hs.fnutils.map(currentNotes,
        function(note) return string.format("%s %d", note.sn, note.velocity) end)
      local alertString = hs.fnutils.reduce(alertStrings,
        function(output, astring) if #output > 0 then return output .. ", " .. astring else return astring end end, "")
      alertString = alertString
      hs.alert.show(alertString, nil, nil, 0.5)
    end
  else

      local alertStrings = hs.fnutils.map(currentNotes,
        function(note) return string.format("%s %d", note.sn, note.velocity) end)
      local alertString = hs.fnutils.reduce(alertStrings,
        function(output, astring) if #output > 0 then return output .. ", " .. astring else return astring end end, "")
      alertString = alertString
      hs.alert.show(alertString, nil, nil, 0.5)
    print("No binding found from: ", hs.inspect(currentNotes))
  end
end

function OK.pressActiveKeys()
  if OK.activeBindings and #OK.activeBindings > 0 then
    hs.fnutils.each(OK.activeBindings, PressRepeat)
  end
end

function OK.NoteOffActor(note_metadata)
  local turnOffBindings = {}
  local leftOverBindings = {}

  for _, binding in ipairs(OK.activeBindings) do
    -- print("off bindnidg: ", hs.inspect(binding))
    local yes = false
    for _, old_note in ipairs(binding.notes) do
      if note_metadata.note == old_note.note then
        yes = true
      end
    end
    if yes then
      table.insert(turnOffBindings, binding)
    else
      table.insert(leftOverBindings, binding)
    end
  end
  OK.activeBindings = leftOverBindings
  if #turnOffBindings == 0 then
    print("No binding to turn off from: ", note_metadata.note)
  elseif #turnOffBindings > 1 then
    print("Too many mappings match: ", note_metadata.note, ", b: ", hs.inspect(turnOffBindings))
  else
    turnOffPress(turnOffBindings[1].k)
  end
end

function OK.pedalActor(metadata)
  OK.pedals[metadata.controllerNumber] = metadata
end

function OK.scale_note_mapper(key)
  local note = OK.constants.key_to_note_mapping[key]
  local note_index = note.note_index
  local scale_mapping_index = ((note_index - OK.constants.scaleIndex) + 12) % 12 + 1
  local scale_mapping = OK.constants.scaleMapping[scale_mapping_index]

  -- print("kye: ", hs.inspect(key),", note: ", hs.inspect( note ),"index: ", scale_mapping_index, ", mapping: ", scale_mapping)
  return scale_mapping
end

function OK.createChord(sn, movement, notes)
  local note_index = nil
  for i, pos_note in ipairs(notes) do
    if sn == pos_note or (type(pos_note) == 'table' and (sn == pos_note[1] or sn == pos_note[2])) then
      note_index = i
      break
    end
  end
  local chord = { notes[note_index] }
  local next_note_index = note_index
  for _, move in ipairs(movement) do
    next_note_index = next_note_index + move
    if next_note_index > #notes then
      next_note_index = next_note_index - #notes
    end
    local next_note = notes[next_note_index]
    table.insert(chord, next_note)
  end
  return chord
end

function OK.octave_mapper(key)
  return OK.constants.key_to_note_mapping[key].octave
end

function OK.init(constants)
  turnOffPressEverything()
  OK.constants = constants
  OK.mapping = { k = {}, sn = {}, c = {}, i = {} }
  OK.QuitAfterNumTries = 200
  OK.attempts = 0
  OK.activeBindings = {}
  OK.activeBindingsTimer = hs.timer.doEvery(0.1, OK.pressActiveKeys)
  OK.pedals = {}
  for _, binding in ipairs(constants.key_config) do
    OK.mapping = bindKey(binding, OK.mapping)
  end
end

return OK
