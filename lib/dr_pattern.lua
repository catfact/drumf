--[[
   Pattern: mult-voice sequence
   each stage has voice value array and transport data (loop points)
--]]

-- dofile("pod_copy.lua")

local Pattern = {}
Pattern.__index = Pattern

local StageData = {}
StageData.__index = stageData

local LoopData = {}
LoopData.__index = LoopData

LoopData.new = function(count_start, count_end)
   local obj = setmetatable({}, LoopData)
   obj.count_start = count_start
   obj.count_end = count_end   
   obj.current_start = count_start
   obj.current_end = count_end
   return obj
end

function LoopData:check_start()
   if self.count_start > 0 then
      if self.current_start > 0 then
	 self.current_start = self.current_start - 1
	 return true
      else
	 self.current_start = self.count_start
	 return false
      end
   end
   return false
end

   function LoopData:check_end()
   if self.count_end > 0 then
      if self.current_end > 0 then
	 self.current_end = self.current_end - 1
	 return true
      else
	 self.current_end = self.count_end
	 return false
      end
   else
      return false
   end
end

-- @param voice_data: array of numbers
-- @param loop_start
-- @param loop_end
StageData.new = function(voice_data, loop_start, loop_end)
   if loop_start == nil then loop_start = 0 end
   if loop_end == nil then loop_end = 0 end
   print('loop start: '..loop_start..' loop end: '..loop_end)
   local obj = setmetatable({}, StageData)
   -- voice data is one number per voice, per stage (voice/param value)
   obj.voice_data = voice_data
   obj.loop_data = LoopData.new(loop_start, loop_end)
   return obj
end

-- @param num_stages: maximum pattern length
-- @param callback: function that gets fired on each stage
Pattern.new = function(num_voices, num_stages, callback)
   local p = setmetatable({}, Pattern)
   p.num_voices = num_voices
   p.num_stages = num_stages   
   p.callback = callback

   print(num_voices, num_stages, callback)
   
   p.stage_data = {}
   for stage=1,num_stages do
      local voice_data = {}
      for voice=1, num_voices do
	 voice_data[voice] = 0
      end
      p.stage_data[stage] = StageData.new(voice_data)
   end
   p.stage_index = 1
   
   return p
end

-- fire the callback and advance the position
function Pattern:tick()   
   --self.callback(self.stage_data[self.stage_index].voice_data)
   self.callback(self)
   self:advance()
end

-- search backwards for nearest nonzero loop start counter
function Pattern:find_last_loop_start()
   i = self.stage_index
   while (i > 1) do
      i = i - 1
      if self.stage_data[i].loop_data:check_start() then
	 return i
      end
   end
   return 1
end

function Pattern:advance()
   local loop = self.stage_data[self.stage_index].loop_data
   if loop:check_end() then
      self.stage_index = self:find_last_loop_start()
   else
      self.stage_index = self.stage_index + 1
      if self.stage_index > self.num_stages then
	 self.stage_index = 1
      end
   end
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

function Pattern:set_loop_start(stage, count)
   self.stage_data[stage].loop_data.count_start = count
end

function Pattern:set_loop_end(stage, count)
   self.stage_data[stage].loop_data.count_end = count
end

function Pattern:reset_loops()
   for s=1,self.num_stages do
      local loop = self.stage_data[s].loop_data
      loop.current_start = loop.count_start
      loop.current_end = loop.count_end
   end
end

-- set loop start count for given stage
-- @param stage
-- @param value
function Pattern:set_loop_start(stage, value)
   self.stage_data[stage].loop_data.count_start = value
end

-- set loop end count for given stage
-- @param stage
-- @param value
function Pattern:set_loop_end(stage, value)
   self.stage_data[stage].loop_data.count_end = value
end

function Pattern:get_value(voice, stage)
   return self.stage_data[stage].voice_data[voice]
end


function Pattern:set_value(voice, stage, val)
   self.stage_data[stage].voice_data[voice] = val
end


-- return string representation of stage data
function Pattern:stage_data_string(stage_idx)
   local str = "  { \n"
   str = str.."    voice_data = { "
   for i=1,self.num_voices do
      str = str..self.stage_data[stage_idx].voice_data[i]..", "
   end
   str = str.."},\n"
   str = str.."    loop_data = { "
   str = str.."count_start = "..self.stage_data[stage_idx].loop_data.count_start..", "
   str = str.."count_end = "..self.stage_data[stage_idx].loop_data.count_end..", "
   str = str.."}"
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
   
   local ns = self.num_stages
   local nv = self.num_voices

   for stage=1,ns do
      for voice=1,nv do
	 self.stage_data[stage].voice_data[voice] = stage_data[stage].voice_data[voice]
      end
   end
end


return Pattern
