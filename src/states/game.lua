local Game = {}
Game.__index = Game

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local RacePanel = require("states.gui.racepanel")

function Game.new()
  local self = setmetatable({}, Game)
  self.racePanel = RacePanel.new(images.car1, images.car2)
  self.trackPosition = 0
  self.frontCarPosition = 100
  self.backCarPosition = 100
  return self
end


function Game:update(dt)
  -- TODO update positions
  
  self.racePanel:update( self.trackPosition, self.frontCarPosition, self.backCarPosition )
end

function Game:draw()
  self.racePanel:draw()

  lg.setColor(255,255,255)
  -- draw background
  lg.draw(images.background_game,0,0)
  -- draw elements
  
end

return Game