function WebSocketClient()
    pin=0
    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin,gpio.HIGH)
    ws = websocket.createClient()
    mytimer = tmr.create()
    mytimer:register(1000, tmr.ALARM_AUTO, function() ws:send(math.random(0,500)) end)
    ws:on("connection", function()
        print("connect")
        --ws:send("connecting")
        mytimer:start()
    end)
    ws:on("receive", function(_, msg, opcode)
      print('got message:', msg, opcode) -- opcode is 1 for text message, 2 for binary
      if msg=='open' then
        print('open')
        gpio.write(pin, gpio.LOW)
        --gpio.write(pin, gpio.HIGH)
      end
      if msg=='close' then
        print('close')
        gpio.write(pin,gpio.HIGH)
      end
    end)
     
    local websockets={}
    
    websockets.start=function()
        ws:connect('wss://www.wujingair.com:10000')
    end

    websockets.stop=function()
        ws:close()
        ws=nil
    end
 

    return websockets
end