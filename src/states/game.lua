local Game = {}
Game.__index = Game

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local Tween = require("lib.tween")
local RacePanel = require("states.gui.racepanel")
local Shifter = require("states.gui.shifter")

local characters = require("states.carselect").characters

local symbolImages = {}
for i=1,GLOBALS.config.numberOfSymbols do
  symbolImages[i] = images["shift_symbol_"..i]
end


local function randomEnemyCarImage(playerChar)
  local available = {}
  for i=1,#characters do
    if i~=playerChar then
      available[#available+1] = i
    end
  end
  return characters[available[math.random(#available)]].smallCar
end

function Game.new(playerChar)
  local self = setmetatable({}, Game)
  local selfRef = self
  
  self.playerChar = playerChar
  self.racePanel = RacePanel.new(characters[playerChar].smallCar, randomEnemyCarImage(playerChar))
  self.shifter = Shifter.new(self)
  
  self.shifter:setCallbacks(
    function() selfRef:neutralGearCallback() end,
    function() selfRef:correctGearCallback() end,
    function() selfRef:wrongGearCallback() end,
    function() selfRef:finalGearCallback() end
  );
  
  self.variables = {
    sequence = {},
    playerPos = 10,
    playerSpeed = 0,
    enemyPos = 20,
    enemySpeed = 0
  }
  
  self:prepareNextRound()
  
  return self
end


function Game:prepareNextRound()
  local variables = self.variables
  variables.playerPos = 10
  variables.playerSpeed = 0
  variables.enemyPos = 20
  variables.enemySpeed = 0
  local seq = variables.sequence
  seq[#seq+1] = math.random(#symbolImages)
  self.shifter:setSequence(seq)
  
  self.enemyTween = Tween.new(#seq*3, variables, {enemySpeed=#seq*100}, "inOutBack")
end


function Game:neutralGearCallback()
  print("Neutral")
end

function Game:correctGearCallback()
  print("Correct")
end

function Game:wrongGearCallback()
  print("Wrong")
end

function Game:finalGearCallback()
  print("Done")
end


function Game:update(dt)
  self.shifter:update(dt)
  local vars = self.variables
  local oneMeter = 70 -- one meter in pixels
  
  -- tween updates
  self.enemyTween:update(dt)
  
  vars.enemyPos = vars.enemyPos + vars.enemySpeed*oneMeter*dt
  
  local playerPos = vars.playerPos
  local enemyPos = vars.enemyPos
  local trackPos = math.min(playerPos, enemyPos) + math.abs(playerPos - enemyPos)/2
  
  
  self.racePanel:update(dt, trackPos, playerPos, enemyPos )
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