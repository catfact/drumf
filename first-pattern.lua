--- hello drumf


--- BADD
--- it overwrites the 'engine' global!!
--- engine = 'Drumf'


-- GOOD
-- set the 'name' field in the engine global
engine.name = 'Drumf'

local BeatClock = require 'beatclock'

-- FIXME: include doesnt' seem to be working?
--local drumf = include('lib/drumf_engine.lua')
local drumf = dofile(_path.code..'/hackalong/lib/drumf_engine.lua')
local dr_pattern = dofile(_path.code..'/hackalong/lib/dr_pattern.lua')

local pattern_1 = dr_pattern.new(8, function(stage_value)
  if stage_value > 0 then engine.trig(1) end  
end)

pattern_1.stage_data = { 1, 0, 0, 1, 0, 0, 1, 0 }

-----------------
-- STEP FUNCTION
local clk = BeatClock.new()

clk.on_step = function() 
  pattern_1:advance()
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

local key_press = function(key)
  -- TODO: switch handlers instead of testing in the handler
  if key_mode == KEY_MODE_PLAY  then
    if key == 2 then
      dr_start()
    end
    if key == 3 then
      dr_stop()
    end
    if key_mode == KEY_MODE_WRITE  then
      if key == 2 then
        -- TODO
    end
      if key == 3 then
       -- TODO
      end
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
local function next_mode()
  print("next mode")
  if key_mode == KEY_MODE_PLAY then key_mode = KEY_MODE_WRITE end
  if key_mode == KEY_MODE_WRITE then key_mode = KEY_MODE_PLAY end
  print("key mode: " .. key_mode)
  redraw()
end 

local function previous_mode()
  print("previous mode")
  if key_mode == KEY_MODE_PLAY then key_mode = KEY_MODE_WRITE end
  if key_mode == KEY_MODE_WRITE then key_mode = KEY_MODE_PLAY end
  print("key mode: " .. key_mode)
  redraw()
end 

-- change filter envelope amount with encoders 2 and 3
function enc(n, d)
  if n == 1 then
    print("enc 1; d = " .. d)
    if d > 0 then
      next_mode()
    else
      previous_mode()
    end
  end 
  if n == 2 then
    params:delta("1_pitch_base", d)
  end
  if n == 3 then
    params:delta("2_fc_env_ratio", d)
  end
end 

function redraw()
  screen.clear()
  screen.move(1, 10)
  screen.text("DR DRUMF")
  
  screen.move(1, 20)
  if key_mode == KEY_MODE_PLAY then screen.text("PLAY") end
  if key_mode == KEY_MODE_WRITE then screen.text("WRITE") end
  screen.update()
end

cleanup = function()
  stop()
  dr_stop = nil
  dr_start = nil
end 
