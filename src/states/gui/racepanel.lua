local Panel = {}
Panel.__index =Panel

local lg = love.graphics

local images = require("lib.images")

function Panel.new(frontCarImage, backCarImage)
  local self = setmetatable({}, Panel)
  self.frontCarImage = frontCarImage
  self.backCarImage = backCarImage
  
  self.trackPosition = 0
  self.frontPosition = 0
  self.backPosition = 0
  
  self.frontMoving = false
  self.backMoving = false
  self.time = 0
  
  return self
end

--[[
  trackPosition = the point of the track where the rendering should start (the leftmost pixel)
  frontPosition = position of the front car on the track
  backPosition = position of the back car on the track
]]--
function Panel:update(dt, trackPosition, frontPosition, backPosition)
  self.time = self.time + (1 * dt)
  if self.time > 2 then
    print("Tick")
    -- check car is moving
    if self.frontPosition ~= frontPosition then
      self.frontMoving = true
    else
      self.frontMoving = false
    end
    if self.backPosition ~= backPosition then
      self.backMoving = true
    else
      self.backMoving = false
    end

    self.time = 0
  end
  
  self.trackPosition = -(trackPosition%922)
  self.frontPosition = frontPosition
  self.backPosition = backPosition
end

function Panel:draw()
  -- draw scenery
  lg.draw(images.mountains,self.trackPosition * 0.1,0,0,2)
  lg.draw(images.bollards_bg,self.trackPosition + 2,210,0,1.5)
  
  -- road
  lg.draw(images.road,self.trackPosition,250)
  lg.draw(images.road,self.trackPosition+922, 250)
  
  if self.time > 1.9 then
  print(math.floor((-self.trackPosition % 922)+0.5))
 end
 
  -- draw cars
  if self.backMoving and self.time >=1.5 then backVibration = math.random(0.2,1.5) else backVibration = 0 end
  lg.draw(self.backCarImage,self.backPosition,backVibration + 200,0,0.8)
  if self.frontMoving and self.time >=1.5 then frontVibration = math.random(0.2,1.5)  else frontVibration = 0 end
  lg.draw(self.frontCarImage,self.frontPosition,frontVibration + 250,0)
  
  -- draw foreground scenery
  lg.draw(images.bollards_fg,self.trackPosition + 2,360,0,1.5)
end

return Panel