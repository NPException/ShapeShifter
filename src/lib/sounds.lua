-- ---------------------
-- Sound handler
-- ---------------------


-- define sounds table
local sounds = {
  button_hover = {path="assets/sounds/button_mouseover.wav", soundtype="static", volume=0.2, looping=false},
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


function sounds.__index(table, key)
  local info = sounds[key]
  if (not info) then
    error("Tried to access undeclared sound: '"..key.."'")
  end
  print("Loading Sound: '"..key.."', path: '"..info.path.."'")
  
  local sound = loadSound(info.path, info.soundtype)
  sound:setVolume(info.volume)
  sound:setLooping(info.looping or false)
  
  rawset(table, key, sound)
  return sound
end

-- return
return setmetatable({}, sounds)
