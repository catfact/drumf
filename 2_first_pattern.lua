--- hello drumf


--- BADD
--- it overwrites the 'engine' global!!
--- engine = 'Drumf'


-- GOOD
-- set the 'name' field in the engine global
engine.name = 'Drumf'

local BeatClock = require 'beatclock'

local drumf = include('lib/drumf_engine')
local dr_pattern = include('lib/dr_pattern')

local pattern_1 = dr_pattern.new(8, function(stage_value)
  if stage_value > 0 then engine.trig(1) end  
end)

pattern_1.stage_data = { 1, 0, 0, 1, 0, 0, 1, 0 }

-----------------
-- STEP FUNCTION
local clk = BeatClock.new()

clk.on_step = function() 
  pattern_1:advance()
  redraw()
end

dr_start = function() 
  print("start")
   clk:start()
end 
  
dr_stop = function() 
  print("stop")
   clk:stop()
   pattern_1:reset()
end 

function init() 
  clk:add_clock_params()
  drumf.add_params()
  --dr_start()
end

local KEY_MODE_PLAY = 1
local KEY_MODE_WRITE = 2
local key_mode = KEY_MODE_PLAY

local function write_current_stage(pattern, value)
  print("writing value: "..value .. " to stage: "..pattern.stage_index)
  pattern.stage_data[pattern.stage_index] = value
  pattern:advance()
  redraw()
end

local key_press = function(key)
  -- TODO: switch handlers instead of testing in the handler
  if key_mode == KEY_MODE_PLAY  then
    if key == 2 then
      dr_start()
    end
    if key == 3 then
      dr_stop()
    end
  elseif key_mode == KEY_MODE_WRITE  then
    if key == 2 then
      write_current_stage(pattern_1, 1)
  end
    if key == 3 then
      write_current_stage(pattern_1, 0)
    end
  end
end 


-- trigger drums with keys 2, 3
function key(n,z)
  if n > 1 then
    if z == 1 then
      key_press(n)
    end
  end
end 

-- TODO: switch modes

local function set_key_mode(mode) 
  key_mode = mode
  if mode == KEY_MODE_WRITE then dr_stop() end
  print("key mode: " .. key_mode)
  redraw()
end 

-- change filter envelope amount with encoders 2 and 3
function enc(n, d)
  if n == 1 then
    if d > 0 then
      set_key_mode(KEY_MODE_WRITE)
    else
      set_key_mode(KEY_MODE_PLAY)
    end
  end 
  if n == 2 then
    params:delta("1_pitch_base", d)
  end
  if n == 3 then
    params:delta("2_fc_env_ratio", d)
  end
end 

local function draw_mode()
    screen.move(1, 10)
  if key_mode == KEY_MODE_PLAY then screen.text("PLAY") end
  if key_mode == KEY_MODE_WRITE then screen.text("WRITE") end
end

local function draw_stage_indicator(pattern, offset)
  local pat_str = ''
  for i=1,pattern.num_stages do
    if pattern.stage_index == i then
      pat_str = pat_str .. '*'
    else
      pat_str = pat_str .. ' '
    end
  end
  screen.move(1, 10 + offset)
  screen.text(pat_str)
end

local function draw_pattern(pattern, offset)
  local pat_str = ''
  for i=1,pattern.num_stages do
    if pattern.stage_data[i] > 0 then
      pat_str = pat_str .. '!'
    else
      pat_str = pat_str .. '.'
    end
  end
  screen.move(1, 10 + offset)
  screen.text(pat_str)
end

function redraw()
  screen.clear()
  screen.font_face(40)
  screen.font_size(10)

  draw_mode()
  draw_stage_indicator(pattern_1, 10)
  draw_pattern(pattern_1, 20)

  -- maybe?
  -- collectgarbage()
  
  screen.update()
  
end

cleanup = function()
  stop()
  dr_stop = nil
  dr_start = nil
end 
