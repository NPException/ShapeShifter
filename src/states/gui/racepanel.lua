local Panel = {}
Panel.__index =PanelGame

local lg = love.graphics

local images = require("lib.images")

function Panel.new(frontCarImage, backCarImage)
  local self = setmetatable({}, Panel)
  self.frontCarImage = frontCarImage
  self.backCarImage = backCarImage
  
  self.frontPosition = 0
  self.backPostition = 0
  
  return self
end

--[[
  frontPostion & backPosition: Values from 0 to 1. Indicating how far to the right the
  cars should be drawn respectively
]]--
function Panel:update(dt, frontPostion, backPosition)
  self.frontPostion = frontPostion
  self.backPosition = backPosition
end

function Panel:draw()
  -- draw scenery
  
  -- draw cars
  -- lg.draw(self.backCarImage, 30 + 500*self.backPosition ...
  -- lg.draw(self.frontCarImage ...
  
end

return Panel