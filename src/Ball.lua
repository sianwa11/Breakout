Ball = Class{}

function Ball:init(skin)
  self.width = 8
  self.height = 8

  self.dx = 0
  self.dy = 0

  self.skin = skin
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
end

function Ball:collides(target)
  -- first, check to see if the left edge of either is farther to the right
  -- than the right edge of the other
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end

  return true
end

function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
  self.dx = 0
  self.dy = 0
end

function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  --ball bounces back from walls
  --for left wall
  if self.x <= 0 then
    self.x = 0
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end

  --for right wall
  if self.x >= VIRTUAL_WIDTH - 8 then
    self.x = VIRTUAL_WIDTH - 8
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end

  --for top of screen
  if self.y <= 0  then
    self.y = 0
    self.dy = -self.dy
    gSounds['wall-hit']:play()
  end
end

function Ball:render()
  love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin],
      self.x, self.y)
end
