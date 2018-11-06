ok,t = pcall(sjson.decode,'{"key":"value"}')
--print(ok)
if ok == true then
for k,v in pairs(t) do print(k,v) end
end
