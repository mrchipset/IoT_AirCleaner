function newTCPClient()
    local cnt;
    local tcpc={};
    tcpconnected=0
    cl = net.createConnection(net.TCP, 0)

    cl:on("connection",function(sck,c) 
                        cnt=0
                        print("connection") 
                        
                        --sck:send("connection")
                        tcpconnected=1 
                        ok, json = pcall(sjson.encode, {tcp_id="wujing-air-B123_info",
                        protocol="login"})
                        if ok==true then
                            cl:send(json)
                        end
                        end)
    cl:on("receive", function(sck, c) print(c)
        ok,t = pcall(sjson.decode,c)
        --print(ok)
        if ok == true then
            if  t.func == 'on' then
                gpio.write(0,gpio.LOW)
                --pwm.start(1)
                --pwm.start(2)
                pwm.start(3)
                pwm.start(4)
                --pwm.setduty(3,150)
                mode='on'
            else if t.func == 'off' then
                    gpio.write(0,gpio.HIGH)
                   -- pwm.stop(1)
                    --pwm.stop(2)
                    pwm.stop(3)
                    pwm.stop(4)
                    mode='off'
                          
            end
            end
            if t.func == 'speed' then
                if t.params ~= nil then
                    if mode == 'on' then
                        pwm.setduty(3,t.params*300)
                    end
                end
            else if t.func == 'auto' then
                    mode='auto';
                end
            end
        end  
        print('mode:'..mode)
    end)
    
    cl:on("disconnection", function(sck, c) print("disconnection!") tcpconnected=0  end)
    cl:on("sent", function(c) 
        if cnt ~= 10 then
            --cl:send(cnt)
            cnt = cnt + 1
        end 
    end)

    tcpc.start=function(port,ip)
        cl:connect(port,ip)
        print("TCP client starting")
    end

    tcpc.send=function(content)
        if tcpconnected==1 then
            cl:send(content)
            print("send:"..content)
        else
            --print("unconnected")
        end
    end

    tcpc.close=function()
        if tcpconnected==1 then
            cl:close()
            tcpconnected=0
            cl:connect(3000,'111.231.105.36')
        else
            --print("unconnected")
        end
    end    

    return tcpc
end
