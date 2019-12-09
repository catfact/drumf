Pattern = dofile("dr_pattern.lua")

nv = 4
ns = 16


action = function(pat)
   local stage = pat.stage_data[pat.stage_index]
   local loop = stage.loop_data

   print(""
	    ..stage.voice_data[1].."\t"..stage.voice_data[2].."\t"
	    ..loop.current_start.."/"..loop.count_start..", "
	    ..loop.current_end.."/"..loop.count_end
   )
end


p = Pattern.new(nv, ns, action)
for v=1,nv do
   local arr = {}
   for s=1,ns do
      arr[s]= s + ((v-1)*ns)
   end
   p:set_voice_data(v, arr)
end


p:set_loop_start(3, 3)
p:set_loop_end(9, 4)

p:reset_loops()

print(p:data_string())

for i=1,40 do
   p:tick()
end
