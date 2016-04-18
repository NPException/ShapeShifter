local Shifter = {}
Shifter.__index = Shifter

local images = require("lib.images")
local lg = love.graphics

local gearbox = require("lib.gearbox")
local gears = {"a","b","c","d","e","f"}
local symbolImages = {}
for i=1,GLOBALS.config.numberOfSymbols do
  symbolImages[i] = images["shift_symbol_"..i]
end

local symbolBG = images.shift_symbol_bg
local sbgXOffset, sbgYOffset = symbolBG:getDimensions()
sbgXOffset, sbgYOffset = (-sbgXOffset/2), (-sbgYOffset/2)
  

local snapDistance = 100

function Shifter.new()
  local self = setmetatable({}, Shifter)
  
  self.knobImage = images.shift_knob
  local knobW, knobH = self.knobImage:getDimensions()
  self.knobRadius = knobW > knobH and knobW/2-10 or knobH/2-10
  self.knobRadiusSqr = self.knobRadius * self.knobRadius
  
  self.knobOffset = -250
  self.knobOffsetX = -self.knobImage:getWidth()/2
  self.knobOffsetY = -self.knobImage:getHeight()/2 + self.knobOffset
  
  self.rodImage = images.shift_rod
  self.rodRadius = self.rodImage:getWidth()/2-10
  
  self.rodOffsetX = -self.rodImage:getWidth()/2
  self.rodOffsetY = -self.rodImage:getHeight() + self.rodRadius + 10
  
  self.sequence = {}
  
  self:reset()
  
  return self
end


local function distSqr(ax, ay, bx, by)
  local dx = ax-bx
  local dy = ay-by
  return dx*dx + dy*dy
end


function Shifter:reset()
  -- gear index that the player has currently locked in
  self.activeGear = 4

  -- gear that is physically nearest to where the stick is positioned
  self.nearestGear = gears[self.activeGear]
  local gearNode = gearbox.nodes[self.nearestGear]
  
  -- gear stick position
  self.x = gearNode.x
  self.y = gearNode.y
  
  -- if the knob is currently held/dragged by the player
  self.isGrabbed = false
  
  -- the next symbol in the sequence that the player has to shift to
  self.sequenceIndex = 1
  
  -- symbols on the gears, f.e. symbol[1]=3 will make gear "a" have symbol number 3
  self.gearSymbols = {}
    
  -- symbol displayed on gear knob
  self.knobSymbol = nil
  self.knobSymbolColor = {255,255,255}
end

--[[
  neutralGear: will be called whenever the player enters neutral
  correctGear: will be called when the player tucks in a right gear
  wrongGear:   will be called when the player tucks in a wrong gear
  finalGear:   will be called when the player tucks in the finalGear of the sequence
]]--
function Shifter:setCallbacks(neutralGear, correctGear, wrongGear, finalGear)
  self.neutralGear = neutralGear
  self.correctGear = correctGear
  self.wrongGear = wrongGear
  self.finalGear = finalGear
end


function Shifter:isInDistance(dist)
  if (not self.nearestGear:startsWith("n")) then
    local gearNode = gearbox.nodes[self.nearestGear]
    local sqrDistToGear = distSqr(self.x, self.y, gearNode.x, gearNode.y)
    return (sqrDistToGear < dist*dist)
  end
  return false
end


function Shifter:nextSymbol()
  return self.sequence[self.sequenceIndex]
end


function Shifter:generateNextSymbols()
  for i=1,6 do
    self.gearSymbols[i] = nil
  end
  
  local nextSymbol = self:nextSymbol()
  if (not nextSymbol) then
    return
  end
  
  local nextGear
  repeat
    nextGear = math.random(6)
  until nextGear ~= self.activeGear
  
  self.gearSymbols[nextGear] = nextSymbol
  
  local availableSymbols = {}
  for i=1,#symbolImages do
    if i~=nextSymbol then
      availableSymbols[#availableSymbols+1] = i
    end
  end
  
  for i=1,6 do
    if i~=nextGear and i~=self.activeGear then
      -- takes a random index, removes the element from the list, and returns the removed element
      self.gearSymbols[i] = table.remove(availableSymbols, math.random(#availableSymbols))
    end
  end
end


function Shifter:setSequence(sequence)
  self.sequenceIndex = 1
  self.sequence = sequence
  self:generateNextSymbols()
end


function Shifter:changeGear(nextGear)
  if (self.activeGear ~= nextGear) then
    if (nextGear == nil) then
      -- entering neutral
      self.knobSymbol = nil
      if (self.neutralGear) then
        self.neutralGear()
      end
    else
      -- entering a gear
      self.knobSymbol = self.gearSymbols[nextGear]
      if (self.knobSymbol == self:nextSymbol()) then
        -- correct gear
        self.knobSymbolColor[1] = 30
        self.knobSymbolColor[2] = 250
        self.knobSymbolColor[3] = 0
        
        -- check if this was the final gear
        if (self.sequenceIndex == #self.sequence) then
          if (self.finalGear) then
            self.finalGear()
          end
        else
          if (self.correctGear) then
            self.correctGear()
          end
        end
        -- generate layout for next gear in sequence (or none) and make sure that the new active gear is set
        self.activeGear = nextGear
        self.sequenceIndex = self.sequenceIndex + 1
        self:generateNextSymbols()
      elseif (self.knobSymbol ~= nil) then
        -- wrong gear
        self.knobSymbolColor[1] = 250
        self.knobSymbolColor[2] = 20
        self.knobSymbolColor[3] = 0
        if (self.wrongGear) then
          self.wrongGear()
        end
      end
      -- if knobSymbol is nil, then it was the gear from the last shift
    end
  end
  
  self.activeGear = nextGear
end


function Shifter:grab( grab, x, y )
  self.isGrabbed = grab
  if (x and y) then
    self.grabX = x - self.x
    self.grabY = y - self.y + self.knobOffset
  end
  if (not grab and self:isInDistance(snapDistance)) then
    for i=1,#gears do
      if (gears[i] == self.nearestGear) then
        self:changeGear(i)
        break
      end
    end
    local gearNode = gearbox.nodes[self.nearestGear]
    self.x = gearNode.x
    self.y = gearNode.y
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
  
  if (not self:isInDistance(snapDistance)) then
    self:changeGear(nil)
  elseif (self:isInDistance(10)) then
    for i=1,6 do
      if (gears[i] == self.nearestGear) then
        self:changeGear(i)
        break
      end
    end
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
  
  local nextSymbol = self:nextSymbol()
  for i=1,6 do
    local symbol = self.gearSymbols[i]
    if (symbol) then
      local gearNode = gearbox.nodes[gears[i]]
      lg.setColor(255,255,nextSymbol == symbol and 0 or 255)
      lg.draw(symbolBG, gearNode.x + sbgXOffset, gearNode.y + sbgYOffset)
      local symbolImage = symbolImages[symbol]
      local w,h = symbolImage:getDimensions()
      local scale = 0.8
      lg.setColor(0,0,0)
      lg.draw(symbolImage, gearNode.x - (w*scale/2), gearNode.y - (h*scale/2), 0, scale) 
    end
  end
  
  lg.setColor(255,255,255)
  lg.draw(self.rodImage, x+self.rodOffsetX, y+self.rodOffsetY)
  lg.draw(self.knobImage, x+self.knobOffsetX, y+self.knobOffsetY)
  
  if (self.knobSymbol) then
    local symbolImage = symbolImages[self.knobSymbol]
    local w,h = symbolImage:getDimensions()
    lg.setColor(self.knobSymbolColor)
    lg.draw(symbolImage, self.x - (w/2), self.y + self.knobOffset - (h/2)) 
  end
end

return Shifter