local Shifter = {}
Shifter.__index = Shifter

local images = require("lib.images")
local lg = love.graphics


function Shifter.new( game )
  local self = setmetatable({}, Shifter)
  self.game = game
  
  self.knobImage = images.shift_knob
  local knobW, knobH = self.knobImage:getDimensions()
  self.knobRadius = knobW > knobH and knobW/2-10 or knobH/2-10 -- set knob radius to the smallest image dimension/2 and subtract another 10 pixels
  self.knobRadiusSqr = self.knobRadius * self.knobRadius
  
  self.knobOffset = -250
  self.knobOffsetX = -self.knobImage:getWidth()/2
  self.knobOffsetY = -self.knobImage:getHeight()/2 + self.knobOffset
  
  self.rodImage = images.shift_rod
  self.rodRadius = self.rodImage:getWidth()/2-10
  
  self.rodOffsetX = -self.rodImage:getWidth()/2
  self.rodOffsetY = -self.rodImage:getHeight() + self.rodRadius + 10
  
  self.x = 340
  self.y = 1000
  
  self.isGrabbed = false
  
  self.symbols = {}
  for i=1,12 do
    self.symbols[i] = images["shift_symbol_"..i]
  end
  
  return self
end


function Shifter:grab( grab, x, y )
  self.isGrabbed = grab
  if (x and y) then
    self.grabX = x - self.x
    self.grabY = y - self.y + self.knobOffset
  end
end


function Shifter:moveTo( x, y )
  local targetX = x - self.grabX
  local targetY = y + self.knobOffset - self.grabY
  
  self.x = targetX
  self.y = targetY
end


function Shifter:isKnob( x, y )
  local dx = self.x - x
  local dy = (self.y + self.knobOffset) - y
  return self.knobRadiusSqr >= dx*dx + dy*dy
end


function Shifter:update( dt )
  
end


function Shifter:draw()
  local x,y = self.x, self.y
  
  lg.setColor(255,255,255)
  lg.draw(self.rodImage, x+self.rodOffsetX, y+self.rodOffsetY)
  lg.draw(self.knobImage, x+self.knobOffsetX, y+self.knobOffsetY)
end

return Shifter