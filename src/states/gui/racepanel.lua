local Panel = {}
Panel.__index =PanelGame

local lg = love.graphics

local images = require("lib.images")

function Panel.new(frontCarImage, backCarImage)
  local self = setmetatable({}, Panel)
  self.frontCarImage = frontCarImage
  self.backCarImage = backCarImage
  
  self.trackPosition = 0
  self.frontPosition = 0
  self.backPostition = 0
  
  return self
end

--[[
  trackPosition = the point of the track where the rendering should start (the leftmost pixel)
  frontPosition = position of the front car on the track
  backPosition = position of the back car on the track
]]--
function Panel:update(dt, trackPosition frontPostion, backPosition)
  self.trackPosition = trackPosition
  self.frontPostion = frontPostion
  self.backPosition = backPosition
end

function Panel:draw()
  -- draw scenery
  
  -- draw cars
  -- lg.draw(self.backCarImage, ...
  -- lg.draw(self.frontCarImage, ...
  
end

return Panel