print("drumf_engine.lua")

local ControlSpec = require "controlspec"

local specs = {}

specs.pitch_base = ControlSpec.new(10, 20000, "exp", 0, 55, "Hz")
specs.pitch_env_ratio = ControlSpec.new(0, 8, "lin", 0, 1)
specs.fm_ratio = ControlSpec.new(0.01, 10, "lin", 0.01, 1.5)
specs.fm_mod = ControlSpec.new(0, 20, "lin", 0, 0)
specs.noise_rate = ControlSpec.new(10, 20000, "exp", 0, 10, "hz")
specs.noise_shape = ControlSpec.new(0, 2, "lin", 0, 0)
specs.osc_level  = ControlSpec.new(0, 1, "lin", 0, 1)
specs.noise_level  = ControlSpec.new(0, 1, "lin", 0, 1)
specs.noise_amp_env_atk = ControlSpec.new(0.001, 8, "exp", 0, 0.001, "s")
specs.noise_amp_env_sus = ControlSpec.new(0.0001, 8, "exp", 0, 0.001, "s")
specs.noise_amp_env_rel = ControlSpec.new(0.001, 8, "exp", 0, 0.001, "s")
specs.osc_amp_env_atk = ControlSpec.new(0.001, 8, "exp", 0, 0.1, "s")
specs.osc_amp_env_sus = ControlSpec.new(0.0001, 8, "exp", 0, 0.001, "s")
specs.osc_amp_env_rel = ControlSpec.new(0.001, 8, "exp", 0, 0.1, "s")
specs.pitch_env_atk = ControlSpec.new(0.001, 8, "exp", 0, 0.001, "s")
specs.pitch_env_sus = ControlSpec.new(0.001, 8, "exp", 0, 0.001, "s")
specs.pitch_env_rel = ControlSpec.new(0.001, 8, "exp", 0, 0.1, "s")
specs.fc_env_atk = ControlSpec.new(0.001, 8, "exp", 0, 0.001, "s")
specs.fc_env_sus = ControlSpec.new(0.0001, 8, "exp", 0, 0.001, "s")
specs.fc_env_rel = ControlSpec.new(0.001, 8, "exp", 0, 0.1, "s")
specs.fc_env_ratio = ControlSpec.new(0, 8, "lin", 0, 1)
specs.fc_base = ControlSpec.new(10, 20000, "exp", 0, 10, "hz")
specs.filter_gain = ControlSpec.new(0, 10, 'lin', 0, 1)

local NUM_VOICES = 4

local command_names = {
   "pitch_base",
   "pitch_env_ratio",
   "fm_ratio",
   "fm_mod",
   "noise_rate",
   "noise_shape",
   "osc_level",
   "noise_level",
   "noise_amp_env_atk",
   "noise_amp_env_sus",
   "noise_amp_env_rel",
   "osc_amp_env_atk",
   "osc_amp_env_sus",
   "osc_amp_env_rel",
   "pitch_env_atk",
   "pitch_env_sus",
   "pitch_env_rel",
   "fc_env_atk",
   "fc_env_sus",
   "fc_env_rel",
   "fc_env_ratio",
   "fc_base",
   "filter_gain"
}

local NUM_COMMANDS = #command_names

local function add_params() 

   for voice=1,NUM_VOICES do
      for com_idx=1, NUM_COMMANDS do
        
         local com_name
         local param_name
         local spec
      
      	 com_name = command_names[com_idx]
      	 param_name = ""..voice.."_"..com_name
      	 print('adding parameter; com name: ' .. com_name .. '; param name: ' ..param_name)
      	 print(engine[com_name])
      	 
      	 local action_fn = function(value) 
      	   print('sending: '..com_name.. '; voice: '..voice..'; value: '..value)
        	 engine[com_name](voice, value)
        	end
      	 
      	 spec = specs[com_name]
      	 
      	 params:add{
      	   type='control',
      		    controlspec=spec,
      		    id=param_name,
      		    name=param_name,
      		    action=action_fn
      	 }
      end
   end
end

-- assumes add_params() or equivalent has been called
-- @param voice: voice index
-- @param name: parameter name (without leading voice number)
-- @param value: new value
local function set_voice_param(voice, name, value, silent)
   local index = ''..voice.."_"..name
   print(index, value)
   if silent == nil then silent = false end
   params:set(index, value, silent)
end

local preset_data = {
   -- low A kickdrum
   {
      pitch_base = 55,
      pitch_env_ratio = 0.25,
      fm_ratio = 1.77,
      fm_mod = 4,
      noise_rate = 12000,
      noise_shape = 1,
      osc_level = 0.5,
      noise_level = 0.5,
      noise_amp_env_atk = 0.001,
      noise_amp_env_sus = 0.001,
      noise_amp_env_rel = 0.004,
      osc_amp_env_atk = 0.001,
      osc_amp_env_sus = 0.001,
      osc_amp_env_rel = 0.02,
      pitch_env_atk = 0.001,
      pitch_env_sus = 0,
      pitch_env_rel = 0.01,
      fc_env_atk = 0,
      fc_env_sus = 0,
      fc_env_rel = 0,
      fc_env_ratio = 0,
      fc_base = 330,
      filter_gain = 1.0
   },
    -- higher, snappier
   {
      pitch_base = 220,
      pitch_env_ratio = 2.0,
      fm_ratio = 2.23,
      fm_mod = 20,
      noise_rate = 8000,
      noise_shape = 0,
      osc_level = 0.5,
      noise_level = 0.8,
      noise_amp_env_atk = 0.001,
      noise_amp_env_sus = 0.005,
      noise_amp_env_rel = 0.005,
      osc_amp_env_atk = 0.001,
      osc_amp_env_sus = 0.000,
      osc_amp_env_rel = 0.001,
      pitch_env_atk = 0.001,
      pitch_env_sus = 0,
      pitch_env_rel = 0.004,
      fc_env_atk = 0.001,
      fc_env_sus = 0,
      fc_env_rel = 0.005,
      fc_env_ratio = 0.2,
      fc_base = 8000,
      filter_gain = 1.0
   }
}

local function load_preset(voice, preset)
   local data = preset_data[preset]
   for param,val in pairs(data) do
     print(param, val)
      set_voice_param(voice, param, val)
   end   
end

Drumf = {}
Drumf.specs = specs
Drumf.add_params = add_params
Drumf.set_voice_param = set_voice_param
Drumf.load_preset = load_preset
Drumf.NUM_COMMANDS = NUM_COMMANDS



return Drumf
