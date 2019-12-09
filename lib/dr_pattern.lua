--[[
Pattern: mult-voice sequence
each stage has voice value array and transport data (loop points)
--]]

-- dofile("pod_copy.lua")

local Pattern = {}

local StageData = {}

-- @param voice_data: array of numbers
-- @param loop_data: { head=n, tail=n }
StageData.new = function(voice_data, loop_data)
  local obj = {}
  -- voice data is one number per voice, per stage (voice/param value)
  obj.voice_data = voice_data
  -- loop data is two numbers per stage (loop counter max, current)
  obj.loop_data = loop_data
  return obj
end



Pattern.__index = Pattern

-- @param num_stages: maximum pattern length
-- @param callback: function that gets fired on each stage
Pattern.new = function(num_voices, num_stages, callback)
   local p = setmetatable({}, Pattern)
   p.num_voices = num_voices
   p.num_stages = num_stages   
   p.callback = callback
   
   p.stage_data = {}
   for stage=1,num_stages do
      local voice_data = {}
      local loop_data = {head=0, tail=0}
      for voice=1,num_voices do
        voice_data[voice] = 0
      end
      p.stage_data[stage] = StageData.new(voice_data, loop_data)
   end
   p.stage_index = 1
   
   return p
end


-- TODO? factor out into separate Transport class

-- advance the pattern position
function Pattern:advance()
   self.callback(self.stage_data[self.stage_index].voice_data)
   self.stage_index = self.stage_index + 1
   if self.stage_index > self.num_stages then self.stage_index = 1 end
end

-- reset the pattern position
function Pattern:reset()
   self.stage_index = 1
end

-- @param voice: voice index
-- @param values: array of <stage_num> values for given voice
function Pattern:set_voice_data(voice, values)
  local n = self.num_stages
  print(self, n)
  for stage=1,n do
    local val = self.stage_data[stage].voice_data[voice] 
    if val ~= nil then
      self.stage_data[stage].voice_data[voice] = values[stage]; 
    end
  end
end

function Pattern:get_value(voice, stage)
  return self.stage_data[stage].voice_data[voice]
end


function Pattern:set_value(voice, stage, val)
  self.stage_data[stage].voice_data[voice] = val
end

-- TODO:
-- arbitrary loop points
-- loop points with counters!
-- nested loop points with counters!!


-- return string representation of stage data
function Pattern:stage_data_string(stage_idx)
   local str = "  { \n"
   str = str.."    voice_data = { "
   for i=1,self.num_voices do
      str = str..self.stage_data[stage_idx].voice_data[i]..", "
   end
   str = str.."   },\n"
   str = str.."    loop_data = {}" -- TODO
   str = str.."\n  }"
   return str
end

function Pattern:data_string()
    local ns = self.num_stages
   local nv = self.num_voices

   local str = ""
   -- TODO
   str = str.."stage_data = {\n"
   for stage=1,ns do
      str = str..self:stage_data_string(stage)..", \n"
   end
   str = str.."}"
   return str
end

-- save to file path
function Pattern:save_to_file(name)
   path = norns.state.data .. name .. ".lua"   
   print("saving pattern to file path: "..path)    
   local fd = io.open(path, "w+")
   io.output(fd)
   io.write(self:data_string())
   io.close(fd)   
end

function Pattern:load_from_file(name)
   path = norns.state.data .. name ..'.lua'
   -- this will create global variable "stage_data"

   print("loading pattern from file path: "..path)
   dofile(path)
   print(stage_data)

   -- doesn't really copy the data
   --self.stage_data = stage_data
   
   local ns = self.num_stages
   local nv = self.num_voices

   for stage=1,ns do
      for voice=1,nv do
	 self.stage_data[stage].voice_data[voice] = stage_data[stage].voice_data[voice]
      end
   end
end


return Pattern
