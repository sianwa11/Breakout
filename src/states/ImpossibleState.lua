ImpossibleState = Class{__includes = BaseState}

function ImpossibleState:enter(params)
  self.level = params.level
  self.score = params.score
  self.highScores = params.highScores
  self.paddle = params.paddle
  self.health = params.health
  self.ball = params.ball

  self.bricks = Brick()
  self.bricks.color = 6
  self.bricks.tier = 3
end

function ImpossibleState:update(dt)
  self.paddle:update(dt)

  --have the ball track the players
  self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
  self.ball.y = self.paddle.y - 8

  --go to play screen if player presses enter
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('serve', {
      level = self.level + 11,
      bricks = LevelMaker.createMap(self.level + 11),
      paddle = self.paddle,
      health = self.health,
      score = self.score,
      highScores = self.highScores
    })
  end
end

function ImpossibleState:render()
    self.paddle:render()
    self.ball:render()

    renderHealth(self.health)
    renderScore(self.score)

    --Level complete text
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('This is the Impossible State',
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    --instruction set
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve', 0, VIRTUAL_HEIGHT / 2,
          VIRTUAL_WIDTH, 'center')
end
