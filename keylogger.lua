
local keylogger = {}
local eventtap = hs.eventtap
local keyCodes = hs.keycodes.map
local event = eventtap.event
local keyDown = event.types.keyDown
local keyboardEventAutorepeat = event.properties.keyboardEventAutorepeat

function keyHandler(aevent)
  print(hs.inspect(aevent:getProperty(8)))
  -- print(hs.inspect(event.properties))
end

function keylogger.init()

  keylogger.eventtapper = eventtap.new({keyDown}, keyHandler)
  keylogger.eventtapper:start()

end
return keylogger
