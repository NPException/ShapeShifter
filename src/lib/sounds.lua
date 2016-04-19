-- ---------------------
-- Sound handler
-- ---------------------


-- define sounds table
local sounds = {
  button_mouseover = {path="assets/sounds/button_mouseover.wav", soundtype="static", volume=0.1, looping=false},
  button_pressed = {path="assets/sounds/button_pressed.wav", soundtype="static", volume=0.1, looping=false},
  shift_failed = {path="assets/sounds/shift_failed.wav", soundtype="static", volume=0.1, looping=false},
  shift_succeded = {path="assets/sounds/shift_succeded.wav", soundtype="static", volume=0.1, looping=false},
  neutral_gear = {path="assets/sounds/gear.wav", soundtype="static", volume=0.02, looping=false},
  gear = {path="assets/sounds/gear.wav", soundtype="static", volume=0.1, looping=false},
  symbol_presented = {path="assets/sounds/symbol_presented.wav", soundtype="static", volume=0.1, looping=false},
  
  engine_1 = {path="assets/sounds/engine_1.ogg", soundtype="static", volume=0.1, looping=true},
  engine_2 = {path="assets/sounds/engine_2.ogg", soundtype="static", volume=0.1, looping=true},
}


-- shorten love function and error handling
local loadSound = function(soundPath, soundType)
  local status, msg = pcall(love.audio.newSource, soundPath, soundType)
  if (status) then
    return msg
  else
    print("No image present at path '"..soundPath.."'. Using default image.")
    return nil
  end
end


local source_play = function(self) self.source:play() end
local source_pause = function(self) self.source:pause() end
local source_setPitch = function(self, pitch) self.source:setPitch(pitch) end
local source_setVolume = function(self, vol) self.source:setVolume(self.maxVolume * (vol < 0 and 0 or vol > 1 and 1 or vol)) end


function sounds.__index(table, key)
  local info = sounds[key]
  if (not info) then
    error("Tried to access undeclared sound: '"..key.."'")
  end
  print("Loading Sound: '"..key.."', path: '"..info.path.."'")
  
  local sound = {
    source=loadSound(info.path, info.soundtype),
    maxVolume = info.volume,
    play = source_play,
    pause = source_pause,
    setPitch = source_setPitch,
    setVolume = source_setVolume
  }
  sound:setVolume(1)
  sound.source:setLooping(info.looping or false)
  
  rawset(table, key, sound)
  return sound
end

-- return
return setmetatable({}, sounds)
