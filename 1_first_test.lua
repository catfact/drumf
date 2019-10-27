--- hello drumf


--- BADD
--- it overwrites the 'engine' global!!
--- engine = 'Drumf'


-- GOOD
-- set the 'name' field in the engine global
engine.name = 'Drumf'

-- local drumf_params = include('drumf_params.lua')

-- FIXME: include didn't work after boot! wny not.
local drumf = dofile('/home/we/dust/code/hackalong/lib/drumf_engine.lua')

function init() 
  engine.list_commands()
  drumf.add_params()
  params:set('1_pitch_base', 200)
end

-- trigger drums with keys 2, 3
function key(n,z)
  if n > 1 then
    if z == 1 then
      engine.trig(n-1)
    end
  end
end 

-- change filter envelope amount with encoders 2 and 3
function enc(n, d)
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
  screen.text("drumf")
  screen.update()
end
