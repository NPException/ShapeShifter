local Button = {}
Button.__index = Button

local globals = GLOBALS

--[[
  x, y: position of the button (top left corner)
  image: the image that should be rendered
  maskImage: the button mask that defines the clickable area (rgb:[0,0,0]=no button, rgb:[255,0,0]=button)
  actionFunction: a function that should be executed on click
]]--
function Button.new( x, y, image, maskImage, actionFunction )
  local self = setmetatable({}, Button)
  self.image = image
  self.actionFunction = actionFunction
  self.x = x
  self.y = y
  self.w = image:getWidth()
  self.h = image:getHeight()
  
  if (maskImage) then
    self.maskData = maskImage:getData()
  end
  
  return self
end

function Button:isOnButton( x, y )
  local onButton = x>=self.x and x<=self.x+self.w and y>=self.y and y<=self.y+self.h
  if self.maskData and onButton then
    local floor = math.floor
    local bx, by = floor(x-self.x), floor(y-self.y)
    local r = self.maskData:getPixel( bx, by )
    return r==255
  else
    return onButton
  end
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