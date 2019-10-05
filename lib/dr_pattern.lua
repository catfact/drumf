local Pattern = {}

Pattern.__index = Pattern

-- @param num_stages: maximum pattern length
-- @param callback: function that gets fired on each stage
Pattern.new = function(num_stages, callback)
   local p = setmetatable({}, Pattern)
   p.num_stages = num_stages   
   p.callback = callback
   
   p.stage_data = {}
   for i=1,num_stages do
      p.stage_data[i] = 0
   end
   p.stage_index = 1
   
   return p
end


function Pattern:advance()
   self.callback(self.stage_data[self.stage_index])
   self.stage_index = self.stage_index + 1
   if self.stage_index > self.num_stages then self.stage_index = 1 end
end

function Pattern:reset()
   self.stage_index = 1
end

-- TODO:t
-- arbitrary loop points
-- loop points with counters!
-- nested loop points with counters!!

return Pattern
