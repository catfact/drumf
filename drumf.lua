--- enc 1:
---- change mode + reset
-------------------
--- write mode:
---- enc 2: select voice
---- key 2: write trigger
---- key 3: write rest
-------------------
--- play mode:
---- key 2: play
---- key 3: top

engine.name = 'Drumf'

local BeatClock = require 'beatclock'

 drumf = include('lib/drumf_engine')
 dr_pattern = include('lib/dr_pattern')

 num_voices = 2
 num_stages = 16

 pattern_1 = dr_pattern.new(num_voices, num_stages,
  function(voice_data)
    for voice=1,num_voices do
       if voice_data[voice] > 0 then engine.trig(voice) end
    end
end)

pattern_1:set_voice_data(1, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
pattern_1:set_voice_data(2, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })

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

dr_save_default_pattern = function()
  path = "drumf/default_pattern"
  pattern_1:save_to_file(path)
end 


dr_load_default_pattern = function()
  path = "drumf/default_pattern"
  pattern_1:load_from_file(path)
end 


--------------------------------
-- INIT
function init() 
  clk:add_clock_params()
  drumf.add_params()
  
  drumf.load_preset(1, 1)
  drumf.load_preset(2, 2)
  
  dr_load_default_pattern()
  
end

 KEY_MODE_PLAY = 1
 KEY_MODE_WRITE = 2
 key_mode = KEY_MODE_PLAY

-- TODO: factor out modes/pages as classes
-- for now, mode-specific state:
local selected_write_voice = 1


 function write_current_stage(pattern, voice, value)
  print("writing value: "..value .. " to stage: "..pattern.stage_index)

-- FIXME: need setter
  --pattern.stage_data[pattern.stage_index] = value
  pattern:set_value(voice, pattern.stage_index, value)
  pattern:advance()
  redraw()
end

 key_press = function(key)
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
      write_current_stage(pattern_1, selected_write_voice, 1)
  end
    if key == 3 then
      write_current_stage(pattern_1, selected_write_voice, 0)
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

 function set_key_mode(mode) 
  key_mode = mode
  if mode == KEY_MODE_WRITE then dr_stop() end
  print("key mode: " .. key_mode)
  redraw()
end 

-- TODO: more tweakable params
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
    if key_mode == KEY_MODE_WRITE then
    -- encoder 2: write mode: select voice to write
      if d > 0 then 
        selected_write_voice = selected_write_voice + 1
        if selected_write_voice > num_voices then selected_write_voice = num_voices
        end
      else 
         selected_write_voice = selected_write_voice - 1
        if selected_write_voice < 1 then selected_write_voice = 1
        end
      end
      redraw()
    end
  end
  if n == 3 then
    -- TODO: ???
  end
end 

 function draw_mode()
    screen.move(1, 10)
  if key_mode == KEY_MODE_PLAY then screen.text("PLAY") end
  if key_mode == KEY_MODE_WRITE then 
    screen.text("WRITE " .. selected_write_voice)
  end
end

 function draw_stage_indicator(pattern, offset)
   local pat_str = ''
   -- pattern advances immediately after trigger;
   -- looks more intuitive if previous stage is indicated
  for stage=1,pattern.num_stages do
     if pattern.stage_index == (stage % num_stages) + 1 then
      pat_str = pat_str .. '*'
    else
      pat_str = pat_str .. ' '
    end
  end
  screen.move(1, 10 + offset)
  screen.text(pat_str)
end

 function draw_pattern(pattern, offset)
   local pat_str
   
   for voice=1, pattern.num_voices do
     pat_str = ''
      for stage=1, pattern.num_stages do
    	  if pattern:get_value(voice, stage) > 0 then
    	    pat_str = pat_str .. '!'
    	  else
    	    pat_str = pat_str .. '.'
    	  end
    end
    
    screen.move(1, 10*voice + offset)
    screen.text(pat_str)
  end
    
end

function redraw()
  screen.clear()
  screen.aa(0)
  screen.font_face(37)
  screen.font_size(11)

  draw_mode()
  draw_stage_indicator(pattern_1, 10)
  draw_pattern(pattern_1, 20)

  -- maybe?
  -- collectgarbage()
  
  screen.update()
  
end

cleanup = function()
  dr_save_default_pattern()
  dr_stop()
end 



