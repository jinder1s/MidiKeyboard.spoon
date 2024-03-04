local socket = require "socket"
local piano = {
}

local PressRecognizerCallback = function()
  -- if #piano.noteOnQueue > 0 then
  --   -- print(hs.inspect(piano.noteOnQueue))
  -- end
  local ct = socket.gettime()
  local cm = ct % 1
  local cdn = hs.timer.localTime()
  local cday_now = (cdn + cm) * 1000

  -- if #piano.noteOnQueue > 0 then
  --   hs.fnutils.each(piano.noteOnQueue,
  --                   function (note)
  --                     piano.noteActorCallback({note})
  --                   end
  --   )
  --   piano.noteOnQueue = {}
  -- end
  if #piano.noteOnQueue > 0 and cday_now - piano.noteOnQueue[#piano.noteOnQueue].dt > piano.waitBetweenNotesTime then
    piano.noteActorCallback(piano.noteOnQueue, piano.pressedKeys)
    piano.noteOnQueue = {}
  end
end

function piano.OnEventCallback(object, deviceName, commandType, description, metadata)
  local hour, minutes, seconds, milli = metadata.timestamp:match(piano.pattern)
  local day_time = (hour * 60 * 60 + minutes * 60 + seconds) * 1000 + milli
  -- print('ts: ', metadata.timestamp,", ds: ", day_time )
  metadata.dt = day_time
  metadata.tr = socket.gettime()
  if commandType == 'noteOn' then
    table.insert(piano.noteOnQueue, metadata)
    piano.pressedKeys[metadata.note] = metadata
  elseif commandType == 'noteOff' then
    table.insert(piano.noteOffQueue, metadata)
    piano.pressedKeys[metadata.note] = nil
    piano.noteOffCallback(metadata)
  end


  if commandType == 'controlChange' then
    if metadata.controllerNumber == 22 or metadata.controllerNumber == 21 or metadata.controllerNumber == 64 then
      piano.pedalCallback(metadata)
    end
  end
end

function piano.init(constants, noteActorCallback, noteOffCallback, pedalCallback)
  piano.pattern = "(%d+):(%d+):(%d+).(%d+)"
  print(hs.inspect(hs.midi.devices()))
  piano.myDeviceName = 'FANTOM-6 7 8'
  piano.MidiDevice = nil
  piano.noteOnQueue = {}
  piano.noteOffQueue = {}
  piano.pressedKeys = {}
  piano.main_timer = nil
  piano.noteActorCallback = function(notes, pressedKeys) print(hs.inspect(notes) .. hs.inspect(pressedKeys)) end
  piano.pedalCallback = function(metadata) print("pedal: ", hs.inspect(metadata)) end

  piano.waitBetweenNotesTime = 28 -- milliseconds
  piano.noNewNoteWaitTime = piano.waitBetweenNotesTime

  piano.MidiDevice = hs.midi.new('FANTOM-6 7 8') or hs.midi.new("Seaboard RISE 2")
  if not piano.MidiDevice then
    print("no midi device found, returning")
    return
  else
    print("Connected")
    piano.main_timer = hs.timer.doEvery(0.005, PressRecognizerCallback)
  end
  piano.MidiDevice:callback(piano.OnEventCallback)
  if noteActorCallback then
    piano.noteActorCallback = noteActorCallback
  end
  if noteOffCallback then
    piano.noteOffCallback = noteOffCallback
  end
  if pedalCallback then
    piano.pedalCallback = pedalCallback
  end
end

return piano
