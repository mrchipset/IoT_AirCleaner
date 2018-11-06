<%
local ssid=params["ssid"]
local pwd=params["pwd"]
wifi.sta.config({ssid=ssid,pwd=pwd,save=true})

webdelaytimer=tmr.create(3)
webdelaytimer:register(10000, tmr.ALARM_AUTO, function()
     print("end")
     if wifi.sta.getip()~=nil then
        node.restart()
     end
     webdelaytimer:stop()
    end)
webdelaytimer:start()
%>

<html>
    <head>
        <title>welcome</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <p><center><h1>Connecting...<br>The device will reboot in a moment!</h1></center></p>
    </head>    
    <body>
    </body>
</html>
