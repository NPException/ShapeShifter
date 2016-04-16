local Fader = {}
Fader.__index = function (table, key)
  local faderMethod = Fader[key]
  return faderMethod and faderMethod or table.state[key]
end


local setColor = love.graphics.setColor
local fill = love.graphics.rectangle
local floor = math.floor


function Fader.fader( state, fadeIn, duration, doneCallback )
  local wrap = setmetatable({}, Fader)
  wrap.state = state
  wrap.fadeIn = fadeIn
  wrap.alpha = fadeIn and 255 or 0
  wrap.duration = duration
  wrap.doneCallback = doneCallback
  return wrap
end

function Fader:update( dt )
  local stateUpdate = self.state.update
  if stateUpdate then
    stateUpdate(dt)
  end
  
  if (self.duration == 0) then
    return
  end
  
  local factor = self.fadeIn and -1 or 1
  local diff = (255.0/self.duration) * factor * dt
  self.alpha = self.alpha + diff
  
  if (self.alpha < 0 or self.alpha > 255) then
    self.alpha = self.alpha < 0 and 0 or self.alpha > 255 and 255 or self.alpha
    if (self.doneCallback) then
      self.doneCallback()
    end
    self.duration = 0
  end
end

function Fader:draw()
  self.state:draw()
  
  local width, height = love.graphics.getDimensions()
  setColor(0,0,0,floor(self.alpha+0.5))
  fill("fill", 0,0,width, height)
end

return Fader