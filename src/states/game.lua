local Game = {}
Game.__index = Game

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")

function Game.new()
  return setmetatable({}, Game)
end

function Game:draw()
  -- init
  
  -- draw background
  lg.draw(images.backgrounds.background_ph,0,0,0) -- temp
  -- draw elements
  
  -- draw scores
  
end

function Game:update(dt)
  
end

return Game