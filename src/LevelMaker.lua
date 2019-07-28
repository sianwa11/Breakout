--[[
  Creates randomized levels for our Breakout game. Returns a table of
  bricks that the game can render, based on the current level we're at
  in the game.
]]

--global patterns(used to make entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

--per row patterns
SOLID = 1           --all colors the same in this row
ALTERNATE = 2       --alternate colours
SKIP = 3            --skip every other block
NONE = 4            --no blocks this row


LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
  local bricks = {}

  --randomly choose the number of rows
  local numRows = math.random(1, 5)

  --randomly choose the number of columns
  --ensure that the colums are odd because even patterns leads to asymmetry
  local numCols = math.random(7, 13)
  numCols = numCols %2 == 0 and (numCols + 1) or numCols

  --highest possible spawned brick colour in this level;ensure
  --we dont go above 3
  local highestTier = math.min(3, math.floor(level / 5))

  --highest colour of the highest tier
  local highestColor = math.min(5, level % 5 + 3)

  --lay out bricks such that they touch each other and fill the space
  for y = 1 , numRows do
    --whether we want to enable skipping for this row
    local skipPattern = math.random(1, 2) == 1 and true or false

    --whether we want to enable alternating colors for this row
    local alternatePattern = math.random(1, 2) == 1 and true or false

    --for the impossible state
    local solidBlock = 1

    --choose two colors to alternate between
    local alternateColor1 = math.random(1, highestColor)
    local alternateColor2 = math.random(1, highestColor)
    local alternateTier1 = math.random(0, highestTier)
    local alternateTier2 = math.random(1, highestTier)

    --used only when we want to skip a block, for skip pattern
    local skipFlag = math.random(2) == 1 and true or false

    --used only when we want to alternate a block, for alternate pattern
    local alternateFlag = math.random(2) == 1 and true or false

    --used when we want a totally full solid keyblock
    local solidFlag = math.min(2,1) == 1 and true or false
    -- if level == 2 then
    --   solidFlag = false
    -- end

    --solid color we'll use if we're not alternating
    local solidColor = math.random(1, highestColor)
    local solidTier = math.random(0, highestTier)


    for x = 1, numCols do
      if solidFlag then
        --if skipping is turned on and we're on a skip iteration
        if skipPattern and skipFlag then
          --turn skipping off for the next iteration
          skipFlag = not skipFlag

          goto continue
        else

          --flip the flag to true on an iteration we dont use it
          skipFlag = not skipFlag
        end


      end

      b = Brick(
          --x-coordinate
          (x-1)                  --decrement x by 1 because tables are 1-indexed, cords are 0
          *32                    --multiply by 32, the brick width
          + 8                    --the screen should have 8 pixels of padding we can fit 13 cols+ 16 pixels total
          + (13 - numCols) * 16, --left-side padding for when there are fewer than 13 columns


          --y-coordinate
          y * 16                --just use y * 16 since we are padding anyway
    )

    if solidFlag then
      --if we're alternating, figure out which color/tier we're on
      if alternatePattern and alternateFlag then
        b.color = alternateColor1
        b.tier = alternateTier1
        alternateFlag = not alternateFlag
      else
        b.color = alternateColor2
        b.tier = alternateTier2
        alternateFlag = not alternateFlag
      end

      --if not alternating and we made it here use the solid color/tier
      if not alternatePattern then
        b.color = solidColor
        b.tier = solidTier
      end

      if not solidFlag then
        b.color = 6
        b.tier = 3
      end

    end

    table.insert(bricks, b)

    --lua's version of the 'continue' statement
    ::continue::
    end
  end

  --in the event we didnt generate any bricks, try again
  if #bricks == 0 then
    return self.createMap(level)
  else
    return bricks
  end
end
