PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
  self.highScores = params.highScores
end

function PaddleSelectState:init()
  -- the paddle we're highliting will be passed to the ServeState
  -- when we press Enter
  self.currentPaddle = 1
end

function PaddleSelectState:update(dt)
  if love.keyboard.wasPressed('left') then
    if self.currentPaddle == 1 then
      gSounds['no-select']:play()
    else
      gSounds['select']:play()
      self.currentPaddle = self.currentPaddle - 1
    end
  elseif love.keyboard.wasPressed('right') then
    if self.currentPaddle == 4 then
      gSounds['no-select']:play()
    else
      gSounds['select']:play()
      self.currentPaddle = self.currentPaddle + 1
    end
  end

  --select paddle and move into serve state, passing in the selection
  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
    gSounds['confirm']:play()

    gStateMachine:change('serve', {
      paddle = Paddle(self.currentPaddle),
      bricks = LevelMaker.createMap(1),
      health = 3,
      score = 0,
      highScores = self.highScores,
      level = 1
    })
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end


function PaddleSelectState:render()
  --instructions
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf("Select paddle with left and right!", 0, VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center')
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf("(Press Enter to continue!)", 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

  --left arrow should render normally if we're higher than 1 else
  --shadowy to let us know we cant go further left
  if self.currentPaddle == 1 then
    --tint
    love.graphics.setColor(0.1, 0.1, 0.1, 0.5)
  end

  love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
      VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

  --resert to white
  love.graphics.setColor(1, 1, 1, 1)

  --right arrow should render normally if we're less than 4
  --else tint it
  if self.currentPaddle == 4 then
    --tint
    love.graphics.setColor(0.1, 0.1, 0.1, 0.5)
  end

  love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
      VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

  --reset to white
  love.graphics.setColor(1, 1, 1, 1)

  --draw paddle based on which one we've selected
  love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)],
      VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

end
