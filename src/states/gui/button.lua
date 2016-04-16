local Button = {}
Button.__index = Button

local globals = GLOBALS

function Button.new( x, y, image, actionFunction )
  local self = setmetatable({}, Button)
  self.image = image
  self.actionFunction = actionFunction
  self.x = x
  self.y = y
  self.w = image:getWidth()
  self.h = image:getHeight()
  
  return self
end

function Button:isOnButton( x, y )
  return x>=self.x and x<=self.x+self.w and y>=self.y and y<=self.y+self.h
end

function Button:mousereleased( x, y, button )
  if self:isOnButton(x,y) then
    self.actionFunction()
  end
end

function Button:draw()
  local lg = love.graphics
  if self:isOnButton(globals.getMousePosition()) then
    lg.setColor(255,255,255)
  else
    lg.setColor(255,255,255,120)
  end
  lg.draw(self.image, self.x, self.y)
end

return Button