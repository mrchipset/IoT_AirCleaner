minute=20
hour=23
tmr.create():alarm(60000, tmr.ALARM_AUTO, function()
  minute=minute+1
  if minute == 60 then
    minute=0
    hour=hour+1
  end
  if hour == 24 then
    hour=0
  end
  print(string.format("%02d:%02d",hour,minute))
end)
