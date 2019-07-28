require 'src/Dependencies'

function love.load()
  love.graphics.setDefaultFilter('nearest','nearest')

  math.randomseed(os.time())

  love.window.setTitle('Breakout')

  --retro fonts
  gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
  }
  love.graphics.setFont(gFonts['small'])

  --load graphics
  gTextures = {
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['main'] = love.graphics.newImage('graphics/breakout.png'),
    ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png'),
  }

  gFrames = {
    ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['powerups'] = GenerateQuadsPowerUps(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
  }

  --initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  --sounds
  gSounds = {
    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
    ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
    ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

    ['music'] = love.audio.newSource('sounds/music.wav', 'static')
  }

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return PlayState() end,
    ['serve'] = function() return ServeState() end,
    ['game-over'] = function() return GameOverState() end,
    ['victory'] = function() return VictoryState() end,
    ['high-scores'] = function() return HighScoreState() end,
    ['enter-high-score'] = function() return EnterHighScoreState() end,
    ['paddle-select'] = function() return PaddleSelectState() end,
    ['impossible'] = function() return ImpossibleState() end
  }
  gStateMachine:change('start', {
    highScores = loadHighScores()
  })

  --play music outside of all states
  --gSounds['music']:play()
  --gSounds['music']:setLooping(true)

  -- a table we'll use to keep track of which keys have been pressed this
  -- frame, to get around the fact that LÖVE's default callback won't let us
  -- test for input from within other functions
  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  gStateMachine:update(dt)

  --reset keys pressed
  love.keyboard.keysPressed = {}
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
  --add table of keys pressed this frame
  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end
end

function love.draw()
  -- begin drawing with push, in our virtual resolution
  push:apply('start')

  local backgroundWidth = gTextures['background']:getWidth()
  local backgroundHeight = gTextures['background']:getHeight()

  love.graphics.draw(gTextures['background'],
    --draw at coordinates 0, 0
      0, 0,
    --no rotation
      0,
      --scale factors on X and Y axis so it fits to full screen
      VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

  gStateMachine:render()

  displayFPS()

  push:apply('end')
end

--[[
    Loads high scores from a .lst file, saved in LÖVE2D's default save directory in a subfolder
    called 'breakout'.
]]
function loadHighScores()
  love.filesystem.setIdentity('breakout')

  --if the file doesnt exist, initialize it with some default scores
  if not love.filesystem.exists('breakout.lst') then
    local scores = ''
    for i = 10, 1, -1 do
      scores = scores .. 'CTO\n'
      scores = scores .. tostring(i * 1000) .. '\n'
    end

    love.filesystem.write('breakout.lst', scores)
  end

  --flag for whether we're reading a name or not
  local name = true
  local currentName = nil
  local counter = 1

  --initialize scores table with at least 10 blank entries
  local scores = {}

  for i = 1, 10 do
    -- blank table; each will hold a name and a score
    scores[i] = {
      name = nil,
      score = nil
    }
  end

  --iterate over each line in the file, filling in names and scores
  for line in love.filesystem.lines('breakout.lst') do
    if name then
      scores[counter].name = string.sub(line, 1, 3)
    else
      scores[counter].score = tonumber(line)
      counter = counter + 1
    end

    --flip the name flag
    name = not name
  end

  return scores
end

--[[
    Render health based on how much health the player has
]]
function renderHealth(health)
  --start of rendering health
  local healthX = VIRTUAL_WIDTH - 100

  --render health left
  for i = 1, health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
    healthX = healthX + 11
  end

  --render missing health
  for i = 1, 3 - health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
    healthX = healthX + 11
  end

end

--render frames per second
function displayFPS()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS:' .. tostring(love.timer.getFPS()), 5, 5)
end

--[[
    Renders score at top right, with left-side padding for score number
]]
function renderScore(score)
  love.graphics.setFont(gFonts['small'])
  love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
  love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end
