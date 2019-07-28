Paddle = Class{}

function Paddle:init(skin)
  --x placed in middle
  self.x = VIRTUAL_WIDTH / 2 - 32

  --y
  self.y = VIRTUAL_HEIGHT - 32

  self.dx = 0
  self.width = 64
  self.height = 16

  -- the skin only has the effect of changing our color, used to offset us
  -- into the gPaddleSkins table later
  self.skin = skin
  -- the variant is which of the four paddle sizes we currently are; 2
  -- is the starting size, as the smallest is too tough to start with
  self.size = 2
end

function Paddle:update(dt)
  if love.keyboard.isDown('left') then
    self.dx = -PADDLE_SPEED
  elseif love.keyboard.isDown('right') then
    self.dx = PADDLE_SPEED
  else
    self.dx = 0
  end

  if self.size == 3 then
    self.width = 96
  elseif self.size == 4 then
    self.width = 128
  elseif self.size == 1 then
    self.width = 32
  else
    self.width = 64
  end

--makes sure it doesnt go past left and right wall
  if self.dx < 0 then
    self.x = math.max(0, self.x + self.dx * dt)
  else
    self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
  end
end

function Paddle:render()
  love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 *(self.skin - 1)],
      self.x, self.y)
end
