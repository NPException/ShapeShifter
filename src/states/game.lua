local Game = {}
Game.__index = Game

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local sounds = require("lib.sounds")
local images = require("lib.images")
local Fader = require("states.fader")
local Tween = require("lib.tween")
local RacePanel = require("states.gui.racepanel")
local Shifter = require("states.gui.shifter")

local characters = globals.states.carselect.characters

local oneMeter = 70 -- one meter in pixels

local symbolImages = {}
for i=1,GLOBALS.config.numberOfSymbols do
  symbolImages[i] = images["shift_symbol_"..i]
end


local function randomEnemy(playerChar)
  local available = {}
  for i=1,#characters do
    if i~=playerChar then
      available[#available+1] = i
    end
  end
  return available[math.random(#available)]
end

function Game.new(playerChar)
  local self = setmetatable({}, Game)
  local selfRef = self
  
  self.flashColor = {255,255,255}
  self.flashAlpha = {a=255}
  self.flashTween = Tween.new(0.3, self.flashAlpha, {a=0}, "outSine")
  self.flashTween:update(10) -- make flash finish
  
  self.playerChar = playerChar
  self.enemyChar = randomEnemy(playerChar)
  self.racePanel = RacePanel.new(characters[playerChar].smallCar, characters[self.enemyChar].smallCar)
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
  
  self.playerEngine = sounds["engine_"..self.playerChar]
  self.enemyEngine = sounds["engine_"..self.enemyChar]
  
  self:prepareNextRound()
  
  return self
end

local function playerSpeed(i)
  return 5+i*10.2
end

local function enemySpeed(i)
  return i*10
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
  
  self.enemyEngine:pause()
  self.enemyChar = randomEnemy(self.playerChar)
  self.enemyEngine = sounds["engine_"..self.enemyChar]
  
  variables.playerPos = 10
  variables.playerSpeed = 0
  variables.enemyPos = 20
  variables.enemySpeed = 0
  variables.goal = #seq*70*oneMeter
  variables.canShift = true
  variables.shiftErrors = 0
  variables.running = false
  
  self.racePanel:setBackCarImage(characters[self.enemyChar].smallCar)
  self.racePanel:setGoal(variables.goal)
  
  self.enemyTween = Tween.new(#seq*3/1.5, variables, {enemySpeed=enemySpeed(#seq)}, "inOutSine")
  self.playerTween = nil
  
  self.playerEngine:setVolume(1)
  self.playerEngine:play()
  self.enemyEngine:play()
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
  self.playerTween = Tween.new(1, variables, {playerSpeed=playerSpeed(seqIndex)}, "inOutBack")
  sounds.shift_succeded:play()
end

function Game:wrongGearCallback( seqIndex )
  self:flash({250,50,0})
  local variables = self.variables
  variables.shiftErrors = variables.shiftErrors + 1
  if variables.shiftErrors >= 3 then
    self:roundEnd( "clutch" )
  else
    sounds.shift_failed:play()
  end
end

function Game:finalGearCallback()
  self.variables.canShift = false
end


function Game:roundEnd( status )
  if status == "success" then
    sounds.symbol_presented:play()
    self:prepareNextRound()
    self:flash({255,255,255})
  else
    local reasonImage = status == "granny" and images.race_lost_granny or images.race_lost_clutch
    self.playerEngine:pause()
    self.enemyEngine:pause()
    Fader.fadeTo( require("states.racelost").new(reasonImage, #self.variables.sequence-1), 0, 0.5, {250,20,0} )
  end
end


function Game:update(dt)
  local vars = self.variables
  
  -- tween updates
  self.flashTween:update(dt)
  
  if (vars.running) then
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
  
  local playerRevs = 0.5 + (vars.playerSpeed/playerSpeed(#vars.sequence))*1.7
  self.playerEngine:setPitch(playerRevs)
  
  local enemyRevs = 1 + (vars.enemySpeed/enemySpeed(#vars.sequence))*1.2
  self.enemyEngine:setPitch(enemyRevs)
  
  local playerPos = vars.playerPos
  local enemyPos = vars.enemyPos
  local distance = math.abs(playerPos - enemyPos)
  local trackPos = math.min(playerPos, enemyPos) + distance/2 - 200
  
  local enemyVol = math.max(0, 1-(distance/3000))
  self.enemyEngine:setVolume(enemyVol)
  
  if playerPos-500 > trackPos then
    trackPos = playerPos-500
  elseif trackPos > playerPos-10 then
    trackPos = playerPos-10
  end
  
  trackPos = math.max(0,trackPos)
  
  self.racePanel:update(dt, trackPos, playerPos, enemyPos )
  
  if (playerPos >= vars.goal or enemyPos >= vars.goal) then
    self:roundEnd(playerPos >= vars.goal and "success" or "granny")
  end
end


function Game:draw()
  self.racePanel:draw()

  lg.setColor(255,255,255)
  -- draw background
  lg.draw(images.background_game,0,0)
  -- draw elements
  self.shifter:draw()
  
  local vars = self.variables
  if (not vars.running) then
    local seq = vars.sequence
    local symbol = symbolImages[seq[#seq]]
    local sw, sh = symbol:getDimensions()
    
    if (#seq == 1) then
      local image = images.race_panel_first_gear
      lg.draw(image, 1080/2-image:getWidth()/2, 50)
      lg.setColor(0,0,0)
      lg.draw(symbol, 1080/2-sw/2, 600-sh/2)
    else
      local image = images.race_panel_next_gear
      lg.draw(image, 1080/2-image:getWidth()/2, 50)
      lg.setColor(0,0,0)
      lg.draw(symbol, 1080/2-sw/2, 740-sh/2)
    end
  end
  
  local flashAlpha = self.flashAlpha.a
  if (flashAlpha >= 1) then
    self.flashColor[4] = flashAlpha
    lg.setColor(self.flashColor)
    lg.rectangle("fill",0,0,config.width,config.height)
  end
end


function Game:keypressed( key, scancode, isrepeat )
  if (key == "escape") then
    self.playerEngine:pause()
    self.enemyEngine:pause()
    Fader.fadeTo( globals.states.menu, 0.2, 0.4, {255,255,255})
  elseif (key == "space") then
    self:roundEnd("success")
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