--[[
Pattern: mult-voice sequence
each stage has voice value array and transport data (loop points)
--]]

local Pattern = {}

local StageData = {}

-- @param voice_data: array of numbers
-- @param loop_data: { head=n, tail=n }
StageData.new = function(voice_data, loop_data)
  local obj = {}
  obj.voice_data = voice_data
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

return Pattern
