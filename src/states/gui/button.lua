local Button = {}
Button.__index = Button

local globals = GLOBALS
local screenW, screenH = globals.config.width, globals.config.height
local lg = love.graphics
local Tween = require("lib.tween")

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
  self.orgX = x
  self.orgY = y
  self.x = x
  self.y = y
  self.w = image:getWidth()
  self.h = image:getHeight()
  
  self.color = {255,255,255,190}
  self.hoverColor = {255,255,255}
  self.hoverImage = nil
  
  if (maskImage) then
    self.maskData = maskImage:getData()
  end
  
  return self
end

function Button:setHoverImage( hoverImage )
  self.hoverImage = hoverImage
end

function Button:setHoverColor( hoverColor )
  self.hoverColor = hoverColor
end

function Button:setColor( color )
  self.color = color
end

function Button:tween( time, target, easing )
  self.tweener = Tween.new(time, self, target, easing)
end

-- returns true if the button has a tween and the tween finished in this update
function Button:update( dt )
  if self.tweener and self.tweener:update(dt) then
    self.tweener = nil
    return true
  end
  return false
end

function Button:isOnButton( x, y )
  local onButton = x>=self.x and x<self.x+self.w and y>=self.y and y<self.y+self.h
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
  if (x > screenW or y > screenH or x+self.w < 0 or y+self.h < 0) then
    return false
  end
  if self:isOnButton(x,y) then
    self.actionFunction()
    return true
  end
  return false
end

function Button:draw()
  local x, y = self.x, self.y
  if (x > screenW or y > screenH or x+self.w < 0 or y+self.h < 0) then
    return
  end
  
  local image = self.image
  if self:isOnButton(globals.getMousePosition()) then
    lg.setColor(self.hoverColor)
    if (self.hoverImage) then
      image = self.hoverImage
    end
  else
    lg.setColor(self.color)
  end
  
  lg.draw(image, x, y)
end

return Button