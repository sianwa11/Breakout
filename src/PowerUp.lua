PowerUp = Class{}

function PowerUp:init(type)
  self.width = 16
  self.height = 16
  self.x = VIRTUAL_WIDTH / 2
  self.y = 0

  self.dx = 0
  self.dy = 0

  self.type = type
  self.inAction = true
end

function PowerUp:update(dt)
  --updating velocity
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  --bounce off the wall like the ball
  --right wall
  if self.x >= VIRTUAL_WIDTH - 16 then
    self.x = VIRTUAL_WIDTH - 16
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end

  --left wall
  if self.x <=0 then
    self.x = 0
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end
end

function PowerUp:collides(target)
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



function PowerUp:render()
  if self.inAction then
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
     self.x, self.y)
  end
end
