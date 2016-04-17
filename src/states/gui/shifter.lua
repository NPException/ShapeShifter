local Shifter = {}
Shifter.__index = Shifter

local images = require("lib.images")
local lg = love.graphics

local gearbox = require("lib.gearbox")
local gears = {"a","b","c","d","e","f"}
local symbols = {}
for i=1,12 do
  symbols[i] = images["shift_symbol_"..i]
end

function Shifter.new()
  local self = setmetatable({}, Shifter)
  
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
  
  self.nearestGear = "n2"
  local gearNode = gearbox.nodes[self.nearestGear]
  self.x = gearNode.x
  self.y = gearNode.y
  
  self.isGrabbed = false
  
  return self
end


local function distSqr(ax, ay, bx, by)
  local dx = ax-bx
  local dy = ay-by
  return dx*dx + dy*dy
end


function Shifter:grab( grab, x, y )
  self.isGrabbed = grab
  if (x and y) then
    self.grabX = x - self.x
    self.grabY = y - self.y + self.knobOffset
  end
  if (not grab and not self.nearestGear:startsWith("n")) then
    local snapDistance = 100
    local gearNode = gearbox.nodes[self.nearestGear]
    local sqrDistToGear = distSqr(self.x, self.y, gearNode.x, gearNode.y)
    if (sqrDistToGear < snapDistance*snapDistance) then
      self.x = gearNode.x
      self.y = gearNode.y
    end
  end
end


function Shifter:moveTo( x, y )
  local targetX = x - self.grabX
  local targetY = y + self.knobOffset - self.grabY
  
  local nextGear
  local nextGearError
  local nextX, nextY
  
  local neighbours = gearbox.neighbours[self.nearestGear]
  for i=1,#neighbours do
    local neighbour = neighbours[i]
    local px, py = gearbox.project( targetX, targetY, self.nearestGear, neighbour)
    local distanceError = distSqr(targetX, targetY, px, py)
    if not nextGear or distanceError<nextGearError then
      nextGear = neighbour
      nextGearError = distanceError
      nextX, nextY = px, py
    end
  end
  
  local gearNode = gearbox.nodes[self.nearestGear]
  local nextGearNode = gearbox.nodes[nextGear]
    
  local distToCurrentGear = distSqr(gearNode.x, gearNode.y, nextX, nextY)
  local distToNextGear = distSqr(nextGearNode.x, nextGearNode.y, nextX, nextY)
  
  if (distToNextGear < distToCurrentGear) then
    self.nearestGear = nextGear
  end
  
  self.x, self.y = nextX, nextY
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