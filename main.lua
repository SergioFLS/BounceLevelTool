local entire_level = love.filesystem.read("levels/J2MElvl.001")
local level = {
  start_x = string.byte(entire_level, 1),
  start_y = string.byte(entire_level, 2),
  size = string.byte(entire_level, 3),
  exit_x = string.byte(entire_level, 4),
  exit_y = string.byte(entire_level, 5),
  rings = string.byte(entire_level, 6),
  width = string.byte(entire_level, 7),
  height = string.byte(entire_level, 8),
  map = {}
}
for i=1, #entire_level-8 do
  level.map[i] = string.byte(entire_level, i+8)
end

local tiles = {
  [1] = love.graphics.newImage("tiles/1.png"),
  [2] = love.graphics.newImage("tiles/2.png"),
  [3] = love.graphics.newImage("tiles/3.png"),
  [7] = love.graphics.newImage("tiles/7.png"),
  [9] = love.graphics.newImage("tiles/9.png"),
  [13] = love.graphics.newImage("tiles/13.png"),
  [14] = love.graphics.newImage("tiles/14.png"),
  [15] = love.graphics.newImage("tiles/15.png"),
  [16] = love.graphics.newImage("tiles/16.png"),
  [29] = love.graphics.newImage("tiles/29.png"),
  
  bounce = {
    [0] = love.graphics.newImage("tiles/bounce.png"),
  }
}
local pixelScale = 24
local fullscreenEnabled = false

local level_x = 0
local level_y = 0


function RGB(r, g, b)
  return r/255, g/255, b/255
end

function get2Dfrom1D(x, y, width)
  return (width*y+x)+1
end

function love.load(args)
  if args[#args] == "-debug" then require("mobdebug").start() end
end

function love.update()
  local mx, my = love.mouse.getPosition()
  mx = mx - level_x
  my = my - level_y
  
  if love.mouse.isDown(1) then
    level.map[get2Dfrom1D(math.floor(mx/pixelScale), math.floor(my/pixelScale), level.width)] = 29
  end
  
  if love.keyboard.isScancodeDown("d") then level_x = level_x - 4 end
  if love.keyboard.isScancodeDown("a") then level_x = level_x + 4 end
  if love.keyboard.isScancodeDown("s") then level_y = level_y - 4 end
  if love.keyboard.isScancodeDown("w") then level_y = level_y + 4 end
  
  if love.keyboard.isScancodeDown("escape") then love.event.quit(0) end
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == "f11" then
    fullscreenEnabled = not fullscreenEnabled
    love.window.setFullscreen(fullscreenEnabled)
  end
  
  -- Save level
  -- TODO: Make a better way to save
  if scancode == "z" then
    local modified_level = string.char(
      level.start_x,
      level.start_y,
      level.size,
      level.exit_x,
      level.exit_y,
      level.rings,
      level.width,
      level.height
    )
    for k,v in pairs(level.map) do
      modified_level = modified_level .. string.char(v)
    end
    print(love.filesystem.write("savedlevel.001", modified_level))
  end
end

function love.draw()
  local mx, my = love.mouse.getPosition()
  mx = mx - level_x
  my = my - level_y
  
  --love.graphics.clear(RGB(50, 100, 100))
  love.graphics.setBackgroundColor(RGB(162, 211, 227))
  for y=0, level.height-1 do
    for x=0, level.width-1 do
      local final_x = (x*pixelScale)+level_x
      local final_y = (y*pixelScale)+level_y
      local tileFetched = level.map[get2Dfrom1D(x, y, level.width)]
      
      -- Limit how many squares to show at once to avoid segfaults
      if final_x < love.graphics.getWidth() and final_y < love.graphics.getHeight() and
        final_x > -pixelScale and final_y > -pixelScale then
          love.graphics.setColor(0, 0, 0)
          love.graphics.rectangle("line", final_x, final_y, pixelScale, pixelScale)
          
          love.graphics.setColor(1, 1, 1)
          if tiles[tileFetched] then
            love.graphics.draw(tiles[tileFetched], final_x, final_y, 0, pixelScale/12)
          elseif tileFetched ~= 0 then
            love.graphics.print(tostring(tileFetched), final_x, final_y, 0)
          end
      end
    end
  end
  
  love.graphics.draw(tiles.bounce[0], (level.start_x*pixelScale)+level_x, (level.start_y*pixelScale)+level_y, 0, pixelScale/12)
  love.graphics.print(level.map[get2Dfrom1D(math.floor(mx/pixelScale), math.floor(my/pixelScale), level.width)] or "nil", 0, 500)
end