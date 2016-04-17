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
  self.mountainPosition = 0
  self.bollardBgPosition = 0
  self.bollardFgPosition = 0
  
  self.backVibration = 0
  self.frontVibration = 0
  
  self.frontMoving = false
  self.backMoving = false
  self.time = 0
  
  self.road_width = images.road:getWidth()
  self.bollards_bg_width = images.bollards_bg:getWidth()
  self.bollards_fg_width = images.bollards_fg:getWidth()
  self.mountains_width = images.mountains:getWidth()
  
  return self
end

--[[
  trackPosition = the point of the track where the rendering should start (the leftmost pixel)
  frontPosition = position of the front car on the track
  backPosition = position of the back car on the track
]]--
function Panel:update(dt, trackPosition, frontPosition, backPosition)
  self.time = self.time + (2 * dt)
  if self.time > 2 then
    --print(frontPosition .. " " .. trackPosition .. " " .. frontPosition)
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
  
  self.trackPosition = -(trackPosition%self.road_width)
  self.mountainPosition = -((trackPosition * 0.1)%self.mountains_width)
  self.bollardBgPosition = -(trackPosition%self.bollards_bg_width)
  self.bollardFgPosition = -(trackPosition%self.bollards_fg_width)
  
  self.frontPosition = frontPosition - trackPosition
  self.backPosition = backPosition - trackPosition
end

function Panel:draw()
  -- draw scenery
  lg.draw(images.mountains,self.mountainPosition,10,0)
  lg.draw(images.mountains,self.mountainPosition + self.mountains_width,10,0)

  if self.mountainPosition + self.mountains_width < 165 then
    lg.draw(images.mountains,self.mountainPosition + self.mountains_width + self.mountains_width,10,0)
  end
  
  lg.draw(images.bollards_bg,self.bollardBgPosition,210,0)
  lg.draw(images.bollards_bg,self.bollardBgPosition + self.bollards_bg_width,210,0)
  
  -- road
  lg.draw(images.road,self.trackPosition,250)
  lg.draw(images.road,self.trackPosition+self.road_width, 250)
 
  -- draw cars
  if self.backMoving and self.time >=1.5 then self.backVibration = math.random(0.2,1.5) else self.backVibration = 0 end
  lg.draw(self.backCarImage,self.backPosition,self.backVibration + 200,0,0.8)
  if self.frontMoving and self.time >=1.5 then self.frontVibration = math.random(0.2,1.5)  else self.frontVibration = 0 end
  lg.draw(self.frontCarImage,self.frontPosition,self.frontVibration + 250,0)
  
  -- draw foreground scenery
  lg.draw(images.bollards_fg,self.bollardFgPosition + 2,360,0)
  lg.draw(images.bollards_fg,self.bollardFgPosition + self.bollards_fg_width + 2,360,0)
end

return Panel