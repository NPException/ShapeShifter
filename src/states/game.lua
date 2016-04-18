local Game = {}
Game.__index = Game

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local Fader = require("states.fader")
local Tween = require("lib.tween")
local RacePanel = require("states.gui.racepanel")
local Shifter = require("states.gui.shifter")

local characters = require("states.carselect").characters

local oneMeter = 70 -- one meter in pixels

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
  
  self.flashColor = {255,255,255}
  self.flashAlpha = {a=255}
  self.flashTween = Tween.new(0.3, self.flashAlpha, {a=0}, "outSine")
  self.flashTween:update(10) -- make flash finish
  
  self.playerChar = playerChar
  self.racePanel = RacePanel.new(characters[playerChar].smallCar, randomEnemyCarImage(playerChar))
  self.shifter = Shifter.new(self)
  
  self.shifter:setCallbacks(
    function() selfRef:neutralGearCallback() end,
    function(seqIndex) selfRef:correctGearCallback(seqIndex) end,
    function(seqIndex) selfRef:wrongGearCallback(seqIndex) end,
    function() selfRef:finalGearCallback() end
  );
  
  self.variables = {
    sequence = {},
    playerPos = 10,
    playerSpeed = 0,
    enemyPos = 20,
    enemySpeed = 0,
    running = false,
    goal = 0,
    isNeutral = true,
    canShift = true
  }
  
  self:prepareNextRound()
  
  return self
end


function Game:flash(color)
  self.flashColor = color
  self.flashTween:reset()
end


function Game:prepareNextRound()
  local variables = self.variables
  local seq = variables.sequence
  seq[#seq+1] = math.random(#symbolImages)
  self.shifter:reset()
  self.shifter:setSequence(seq)
  
  variables.playerPos = 10
  variables.playerSpeed = 0
  variables.enemyPos = 20
  variables.enemySpeed = 0
  variables.goal = #seq*70*oneMeter
  variables.canShift = true
  variables.shiftErrors = 0
  variables.running = false
  
  self.racePanel:setBackCarImage(randomEnemyCarImage(self.playerChar))
  self.racePanel:setGoal(variables.goal)
  
  self.enemyTween = Tween.new(#seq*3/1.5, variables, {enemySpeed=#seq*10}, "inOutSine")
  self.playerTween = nil
end


function Game:neutralGearCallback()
  self.variables.isNeutral = true
  
  if (not self.variables.running) then
    -- TODO: start round here
    self.variables.running = true
  end
end

function Game:correctGearCallback( seqIndex )
  local variables = self.variables
  variables.isNeutral = false
  variables.shiftErrors = 0
  self.playerTween = Tween.new(1, variables, {playerSpeed=5+seqIndex*10.2}, "inOutBack")
end

function Game:wrongGearCallback( seqIndex )
  self:flash({250,50,0})
  local variables = self.variables
  variables.shiftErrors = variables.shiftErrors + 1
  if variables.shiftErrors >= 3 then
    self:roundEnd( false )
  end
end

function Game:finalGearCallback()
  self.variables.canShift = false
end


function Game:roundEnd( success )
  if (success) then
    self:prepareNextRound()
    self:flash({255,255,255})
  else
    local menu = require("states.menu").new()
    globals.state = Fader.create( menu, true, 1, menu, {250,20,0})
  end
end


function Game:update(dt)
  local vars = self.variables
  
  -- tween updates
  self.flashTween:update(dt)
  
  if (self.variables.running) then
    if self.enemyTween and self.enemyTween:update(dt) then
      self.enemyTween = nil
    end
    if self.playerTween and self.playerTween:update(dt) then
      self.playerTween = nil
    elseif vars.isNeutral then
      vars.playerSpeed = math.max(0, vars.playerSpeed-0.1*dt)
    end
    
    vars.enemyPos = vars.enemyPos + vars.enemySpeed*oneMeter*dt
    vars.playerPos = vars.playerPos + vars.playerSpeed*oneMeter*dt
  end
  
  local playerPos = vars.playerPos
  local enemyPos = vars.enemyPos
  local trackPos = math.min(playerPos, enemyPos) + math.abs(playerPos - enemyPos)/2 - 200
  
  if playerPos-500 > trackPos then
    trackPos = playerPos-500
  elseif trackPos > playerPos-10 then
    trackPos = playerPos-10
  end
  
  trackPos = math.max(0,trackPos)
  
  self.racePanel:update(dt, trackPos, playerPos, enemyPos )
  
  if (playerPos >= vars.goal or enemyPos >= vars.goal) then
    self:roundEnd(playerPos >= vars.goal)
  end
end


function Game:draw()
  self.racePanel:draw()

  lg.setColor(255,255,255)
  -- draw background
  lg.draw(images.background_game,0,0)
  -- draw elements
  self.shifter:draw()
  
  local flashAlpha = self.flashAlpha.a
  if (flashAlpha >= 1) then
    self.flashColor[4] = flashAlpha
    lg.setColor(self.flashColor)
    lg.rectangle("fill",0,0,config.width,config.height)
  end
end


function Game:keypressed( key, scancode, isrepeat )
  if (key == "escape") then
    local Fader = require("states.fader")
    local Menu = require("states.menu")
    Fader.fadeTo( Menu.new(), 0.2, 0.4, {255,255,255})
  elseif (key == "space") then
    self:roundEnd(true)
  end
end


function Game:mousepressed( x, y, button )
  if (self.variables.canShift and self.shifter:isKnob( x, y )) then
    self.shifter:grab(true, x, y)
  end
end


function Game:mousereleased( x, y, button )
  self.shifter:grab(false)
end


function Game:mousemoved( x, y, dx, dy )
  if (self.variables.canShift and self.shifter.isGrabbed) then
    self.shifter:moveTo( x, y )
  end
end


return Game