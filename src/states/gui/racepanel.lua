local Panel = {}
Panel.__index =Panel

local lg = love.graphics

local images = require("lib.images")

function Panel.new(frontCarImage, backCarImage, goal)
  local self = setmetatable({}, Panel)
  self.frontCarImage = frontCarImage
  
  self:reset(backCarImage, goal)
  
  self.road_width = images.road:getWidth()
  self.bollards_bg_width = images.bollards_bg:getWidth()
  self.bollards_fg_width = images.bollards_fg:getWidth()
  self.mountains_width = images.mountains:getWidth()
  
  return self
end

function Panel:reset(backCarImage, goal)
  self.backCarImage = backCarImage
  
  self.trackPosition = 0
  self.frontPosition = 0
  self.frontPositionOld = 0
  self.backPositionOld = 0
  self.backPosition = 0
  self.mountainPosition = 0
  self.bollardBgPosition = 0
  self.bollardFgPosition = 0
  
  self.goal = goal
  self.frontIndicator = 0
  self.backIndicator = 0
  
  self.backVibration = 0
  self.frontVibration = 0
  
  self.frontMoving = false
  self.backMoving = false
  self.time = 0
end

function Panel:setBackCarImage( backCarImage )
  self.backCarImage = backCarImage
end

function Panel:setGoal( goal )
  self.goal = math.max(1,goal)
end

--[[
  trackPosition = the point of the track where the rendering should start (the leftmost pixel)
  frontPosition = position of the front car on the track
  backPosition = position of the back car on the track
]]--
function Panel:update(dt, trackPosition, frontPosition, backPosition)
  self.time = self.time + (2 * dt)
  if self.time > 2 then
    --print(self.frontPositionOld .. " " .. trackPosition .. " " .. frontPosition)
    -- check car is moving
    if self.frontPositionOld ~= frontPosition then
      self.frontMoving = true
    else
      self.frontMoving = false
    end
    if self.backPositionOld ~= backPosition then
      self.backMoving = true
    else
      self.backMoving = false
    end
  
  self.frontPositionOld = frontPosition
  self.backPositionOld = backPosition
    self.time = 0
  end
  
  self.frontIndicator = frontPosition/self.goal
  self.backIndicator = backPosition/self.goal
  
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
  local backScale = 0.8
  lg.draw(self.backCarImage, self.backPosition, self.backVibration + 300-self.backCarImage:getHeight()*backScale, 0, backScale)
  if self.frontMoving and self.time >=1.5 then self.frontVibration = math.random(0.2,1.5)  else self.frontVibration = 0 end
  lg.draw(self.frontCarImage, self.frontPosition, self.frontVibration + 390-self.frontCarImage:getHeight(),0)
  
  -- draw foreground scenery
  lg.draw(images.bollards_fg,self.bollardFgPosition + 2,360,0)
  lg.draw(images.bollards_fg,self.bollardFgPosition + self.bollards_fg_width + 2,360,0)
  
  -- indicator bar
  local indX, indY = 80,100
  local indW = 700

  local indFrontX = indX + indW*self.frontIndicator
  
  local indBackX = indX + indW*self.backIndicator
  
  lg.setColor(0,0,0)
  lg.setLineWidth(5)
  lg.setLineStyle("smooth")
  lg.line(indX, indY, indX+indW, indY)
  lg.line(indX, indY-10, indX, indY+10)
  lg.line(indX+indW, indY-10, indX+indW, indY+10)
  
  lg.setColor(140,35,40)
  lg.line(indBackX-10,indY-20, indBackX,indY-5, indBackX+10,indY-20)
  lg.setColor(20,90,15)
  lg.line(indFrontX-10,indY+20, indFrontX,indY+5, indFrontX+10,indY+20)
end

return Panel