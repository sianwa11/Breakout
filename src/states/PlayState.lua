PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.highScores = params.highScores
  self.ball = params.ball
  self.level = params.level

  --give ball random velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)

  self.powerup = PowerUp()
  self.powerup.type = math.random(10)
  self.powerup.dx = math.random(-80, 90)
  self.powerup.dy = math.random(80, 20)
  self.triggered = false


  COUNTDOWN_TIME = 30
  self.timer = 0

  self.extras = {
    ['one'] = Ball(math.random(7)),
    ['two'] = Ball(math.random(7))
  }

  self.extras['one'].dx = math.random(-200, 200)
  self.extras['one'].dy = math.random(-50, -60)
  self.extras['two'].dx = math.random(-200, 200)
  self.extras['two'].dy = math.random(-50, -60)



end

function PlayState:update(dt)
  if self.paused then
    if love.keyboard.wasPressed('space') then
      self.paused = false
      gSounds['pause']:play()
      gSounds['music']:play()
    else
      return
    end
  elseif love.keyboard.wasPressed('space') then
    self.paused = true
    gSounds['pause']:play()
    gSounds['music']:pause()
    return
  end



  self.timer = self.timer + dt
 --updates positions based on velocity
  self.paddle:update(dt)
  self.ball:update(dt)

  if self.timer > COUNTDOWN_TIME then
    self.triggered = true
    self.powerup:update(dt)
    end

--collision of the ball with the paddles
  if self.ball:collides(self.paddle) then
    --raise the ball above the paddle in case it goes below it then reverse dy
    self.ball.y = self.paddle.y - 8
    self.ball.dy = -self.ball.dy

    --tweak angle of bounce based on where it hits the paddle

    --if we hit the paddle on its left side while moving left
    --The second line sets a dx of 50 in the left along with
    --8 times the distance of the ball from the center
    if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
      self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))

    --elseif we hit the paddle on its right side while moving right
  elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2) - self.ball.x)
    end
    gSounds['paddle-hit']:play()
  end

--when powerup collides with the paddle
  if self.powerup:collides(self.paddle) then
     gSounds['paddle-hit']:play()
     self.powerup.y = self.powerup.y - 16
     self.powerup.inAction = false
     if self.paddle.size >= 4 then
       self.paddle.size = 4
     elseif self.paddle.size == 1 then
       self.paddle.size = self.paddle.size + 1
     else
       self.paddle.size = self.paddle.size + 1
     end
  end

  self:extraCollision1()
  self:extraCollision2()

  --collision detection for the extra balls
  --not so clean code :)
  --first ball
  if self.extras['one']:collides(self.paddle) then
    self.extras['one'].y = self.paddle.y - 8
    self.extras['one'].dy = -self.extras['one'].dy

  if self.extras['one'].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
    self.extras['one'].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.extras['one'].x))
  end
  gSounds['paddle-hit']:play()
  end

--second ball
  if self.extras['two']:collides(self.paddle) then
    self.extras['two'].y = self.paddle.y - 8
    self.extras['two'].dy = -self.extras['two'].dy

  if self.extras['two'].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.extras['two'].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2) - self.extras['two'].x)
  end
    gSounds['paddle-hit']:play()
  end

  --spawn two balls when the powerup collides with paddle
  if not self.powerup.inAction then
    for k, extra in pairs(self.extras) do
      extra:update(dt)
    end
  end

  --detect collision across all bricks with the ball
  for k, brick in pairs(self.bricks) do

    if brick.inPlay and self.ball:collides(brick) then

      --add to score
      self.score = self.score + (brick.tier * 200 + brick.color * 25)

      --triggers hit function that removes it from play
      brick:hit()


      --go to victory screen if all bricks have been hit
      if self:checkVictory() then
        gSounds['victory']:play()

        gStateMachine:change('victory', {
          paddle = self.paddle,
          health = self.health,
          score = self.score,
          ball = self.ball,
          level = self.level,
          highScores = self.highScores
        })
      end
      --collision code for Bricks
      --we check to see if the opposite side of our velocity is outside of the brick
      --if it is we trigger a collision on that side else we are within the X+width of
      --the beick and should check to see if the top or bottom edge is outside of the Brick
      --colliding on top or bottom accordingly

      --left edge;only check if we're moving right
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then

        --flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - self.ball.width

        --right edge only check if we're moving left
        elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then

        --flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x + 32

        --top edge if no X collisions, always check
        elseif self.ball.y < brick.y then

        --flip y velocity and reset position outside of brick
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y - 8

        --bottom edge if no X collisions or top collision, last possibly
      else

        --flip y velocity and reset position outside of brick
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y + 16
      end

      --slightly scale the y velocity to speed up game
      self.ball.dy = self.ball.dy * 1.02

      --only allow colliding with one brick for corners
      break
    end
  end

  --if extra balls go below screen stop them
  if self.extras['one'].y >= VIRTUAL_HEIGHT then
    self.extras['one'].y = self.extras['one'].y
  elseif self.extras['two'].y >= VIRTUAL_HEIGHT then
    self.extras['one'].y = self.extras['one'].y

  end

  --if ball goes below screen reverse to start state and decrease health
  if self.ball.y >= VIRTUAL_HEIGHT then
    self.health = self.health - 1
    --if health is lost reduce paddle size
    self.paddle.size = self.paddle.size - 1
    --prevents paddle size from going below 1
    if self.paddle.size <= 1 then
      self.paddle.size = 1
    end
    gSounds['hurt']:play()

    if self.health == 0 then
      gStateMachine:change('game-over', {
        score = self.score,
        highScores = self.highScores
      })
    else
      gStateMachine:change('serve', {
        paddle = self.paddle,
        bricks = self.bricks,
        health = self.health,
        score = self.score,
        level = self.level,
        highScores = self.highScores
      })
    end
  end


  --for rendering particle systems
  for k, brick in pairs(self.bricks) do
    brick:update(dt)
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

--[[
  Renders the objects
]]
function PlayState:render()
  --render bricks
  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  --render all particle systems
  for k, brick in pairs(self.bricks) do
    brick:renderParticles()
  end


  self.paddle:render()
  self.ball:render()

 if self.triggered then
   self.powerup:render()

   --render extra balls when powerup collides with paddle
   if not self.powerup.inAction then
     for k, extra in pairs(self.extras) do
       extra:render()
     end
   end
end



  renderScore(self.score)
  renderHealth(self.health)

  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH,'center')
  end
end

--[[
  Check if all bricks are out of play
]]
function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
          end
    end

    return true
end

--[[
  detect collision for extra balls
  ]]
function PlayState:extraCollision1()
  for k, brick in pairs(self.bricks) do

    if brick.inPlay and self.extras['one']:collides(brick) then
      --add to score
      self.score = self.score + (brick.tier * 200 + brick.color * 25)
      --triggers hit function that removes it from play
      brick:hit()

      if self:checkVictory() then
        gSounds['victory']:play()

        gStateMachine:change('victory', {
          paddle = self.paddle,
          health = self.health,
          score = self.score,
          ball = self.ball,
          level = self.level,
          highScores = self.highScores
        })
      end

      if self.extras['one'].x + 2 < brick.x and self.extras['one'].dx > 0 then

        --flip x velocity and reset position outside of brick
        self.extras['one'].dx = -self.extras['one'].dx
        self.extras['one'].x = brick.x - self.extras['one'].width

        --right edge only check if we're moving left
        elseif self.extras['one'].x + 6 > brick.x + brick.width and self.extras['one'].dx < 0 then

        --flip x velocity and reset position outside of brick
        self.extras['one'].dx = -self.extras['one'].dx
        self.extras['one'].x = brick.x + 32

        --top edge if no X collisions, always check
        elseif self.extras['one'].y < brick.y then

        --flip y velocity and reset position outside of brick
        self.extras['one'].dy = -self.extras['one'].dy
        self.extras['one'].y = brick.y - 8

        --bottom edge if no X collisions or top collision, last possibly
      else

        --flip y velocity and reset position outside of brick
        self.extras['one'].dy = -self.extras['one'].dy
        self.extras['one'].y = brick.y + 16
      end

      --slightly scale the y velocity to speed up game
      self.extras['one'].dy = self.extras['one'].dy * 1.02

      --only allow colliding with one brick for corners
      break

    end
  end
end


function PlayState:extraCollision2()
  for k, brick in pairs(self.bricks) do

    if brick.inPlay and self.extras['two']:collides(brick) then
      --add to score
      self.score = self.score + (brick.tier * 200 + brick.color * 25)
      --triggers hit function that removes it from play
      brick:hit()

      if self:checkVictory() then
        gSounds['victory']:play()

        gStateMachine:change('victory', {
          paddle = self.paddle,
          health = self.health,
          score = self.score,
          ball = self.ball,
          level = self.level,
          highScores = self.highScores
        })
      end

      if self.extras['two'].x + 2 < brick.x and self.extras['two'].dx > 0 then

        --flip x velocity and reset position outside of brick
        self.extras['two'].dx = -self.extras['two'].dx
        self.extras['two'].x = brick.x - self.extras['two'].width

        --right edge only check if we're moving left
      elseif self.extras['two'].x + 6 > brick.x + brick.width and self.extras['two'].dx < 0 then

        --flip x velocity and reset position outside of brick
        self.extras['two'].dx = -self.extras['two'].dx
        self.extras['two'].x = brick.x + 32

        --top edge if no X collisions, always check
      elseif self.extras['two'].y < brick.y then

        --flip y velocity and reset position outside of brick
        self.extras['two'].dy = -self.extras['two'].dy
        self.extras['two'].y = brick.y - 8

        --bottom edge if no X collisions or top collision, last possibly
      else

        --flip y velocity and reset position outside of brick
        self.extras['two'].dy = -self.extras['two'].dy
        self.extras['two'].y = brick.y + 16
      end

      --slightly scale the y velocity to speed up game
      self.extras['two'].dy = self.extras['two'].dy * 1.02

      --only allow colliding with one brick for corners
      break

    end
  end
end
