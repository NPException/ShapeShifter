local Game = {}
Game.__index = Game

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local RacePanel = require("states.gui.racepanel")
local Shifter = require("states.gui.shifter")

function Game.new()
  local self = setmetatable({}, Game)
  self.racePanel = RacePanel.new(images.car1, images.car2)
  self.trackPosition = 0
  self.frontCarPosition = 100
  self.backCarPosition = 100
  self.frontCarAcceleration = 0
  self.backCarAcceleration = 0
  
  self.shifter = Shifter.new(self)
  return self
end


function Game:update(dt)
  self.shifter:update(dt)
  
  self.trackPosition = self.trackPosition + 0.1 
  self.frontCarPosition = self.frontCarPosition + self.frontCarAcceleration
  self.backCarPosition = self.backCarPosition + self.backCarAcceleration
  
  self.racePanel:update(dt, self.trackPosition, self.frontCarPosition, self.backCarPosition )
end


function Game:draw()
  self.racePanel:draw()

  lg.setColor(255,255,255)
  -- draw background
  lg.draw(images.background_game,0,0)
  -- draw elements
  self.shifter:draw()
end


function Game:keypressed( key, scancode, isrepeat )
  if (key == "escape") then
    local Fader = require("states.fader")
    local Menu = require("states.menu")
    Fader.fadeTo( Menu.new(), 0.2, 0.4, {255,255,255})
  elseif (key == "m") then
    self.frontCarAcceleration = self.frontCarAcceleration + 0.1
  elseif (key == "n") then
    self.frontCarAcceleration = 0
  end
end


function Game:mousepressed( x, y, button )
  if (self.shifter:isKnob( x, y )) then
    self.shifter:grab(true, x, y)
  end
end


function Game:mousereleased( x, y, button )
  self.shifter:grab(false)
end


function Game:mousemoved( x, y, dx, dy )
  if (self.shifter.isGrabbed) then
    self.shifter:moveTo( x, y )
  end
end


return Game