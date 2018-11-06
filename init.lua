uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
gpio.mode(0,gpio.OUTPUT)
gpio.write(0,gpio.HIGH)
pwm.setup(1,1000,150)
pwm.setup(2,1000,50)
--pwm.setup(3,1000,0)
--pwm.setup(4,1000,0)

require("lsp")
require("httpsever")
require("tcpinfo")
i=0;
disp_cnt=0;
sda = 3 -- SDA Pin
scl = 4 -- SCL Pin

function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_8x13)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     --disp:setRot180()           -- Rotate Display if needed
end

function welcome_OLED()
   disp:firstPage()
   repeat
     disp:drawFrame(0,0,128,16)
     disp:drawStr(30, 3, "WujingAir")
     disp:drawStr(2, 20, "Welcome!")
     disp:drawStr(2, 40, "Cleaner is on!")
   until disp:nextPage() == false
   
end

function print_OLED(pm1,pm25,pm10,voc)
   disp:firstPage()
   repeat
     disp:drawFrame(0,0,128,16)
     disp:drawStr(30, 3, "WujingAir")
     disp:drawStr(2, 20, string.format("PM1.0: %d",pm1))
     disp:drawStr(2, 30, string.format("PM2.5: %d",pm25))
     disp:drawStr(2, 40, string.format("PM 10: %d",pm10))
     disp:drawStr(2, 50, string.format("V O C: %.3f",voc))
   until disp:nextPage() == false
   
end

-- print ap list
--function listap(t)
--  ap_info=t
--end

wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid="wujing-air-B123",pwd="1234abcd"})
wifi.sta.getap(listap)
server=newHttpServer(80)
server.map("default",newLSPHandler())
init_OLED(sda,scl);
welcome_OLED();
downloadtimer = tmr.create(0)
downloadtimer:register(15000, tmr.ALARM_AUTO, function()
downloadtimer:stop() 
end)
downloadtimer:start()
mode='off';
print("delay...")
k=0;
p_pm1=0;
p_pm2=0;
p_pm10=0;
p_color=1;

modetimer = tmr.create(1)
modetimer:register(1000, tmr.ALARM_AUTO, function() 
    --print(i)
    if wifi.sta.getip()==nil then
        if i < 60 then
            i=i+1;
        else
            modetimer:stop()
        end  
    else
        --server.stop();
        tcp_info=newTCPClient()
        tcp_info.start(3000,'111.231.105.36')
        uart.on("data","B",
          function(data)

            if string.len(data)==40 then
                if string.byte(data,1)==0x4d  then
                    print("ok\n"..node.heap())

                    disp_cnt=disp_cnt+1;
                    low=200;
                    high=600;
                    if disp_cnt==3 then
						disp_cnt=0;
						pm1=string.byte(data,10)*256+string.byte(data,11)
						pm2=string.byte(data,12)*256+string.byte(data,13)
						pm10=string.byte(data,14)*256+string.byte(data,15)
						voc=(string.byte(data,28)*256+string.byte(data,29))/1000
						hum=(string.byte(data,32)*256+string.byte(data,33))/10
						tem=(string.byte(data,30)*256+string.byte(data,31))/10     
						if pm1>3500 then
							pm1=3500
						end     
						if pm2>3500 then
							pm2=3500
						end         
						if pm10>3500 then
							pm10=3500
						end

                            k=pm1-p_pm1
                            color=p_color
                      
                            if pm2>1000 and k>0 then
                                    color=2;
                            end
                          
                            if pm2>2500 then
                                color=3;
                            end
                            
                            
                            if k<-100 and pm1>500 then
                                color=2;
                          
                            else if k>0 and pm1<500 then
                                color=1;
                            end
                            end
      
                            
                            if color==1 then
                                pwm.setduty(1,150)
                                pwm.setduty(2,0)
                            else if color==3 then ---red
                                pwm.setduty(1,0)
                                pwm.setduty(2,100) 
                            else ---yellow
                                pwm.setduty(1,50)
                                pwm.setduty(2,100)  
                            end
                            end
                            
                            p_color=color
                            p_pm2=pm2
                            p_pm1=pm1
                            p_pm10=pm10
                            
                            --pm1=pm1*500/3500
                            --pm2=pm2*500/3500
                            --pm10=pm10*500/3500
                            --voc=voc*0.01/0.4

                            --pm1=pm1/3.5;
                            --pm2=pm2/3.5;
                            --pm10=pm10/3.5;
                            --if pm2<400 then
                            --    pm1=pm1*15/400+5*math.random()+8;
                            --    pm2=pm2*15/400+5*math.random()+10;
                            --    pm10=pm10*15/400+5*math.random()+12;
                            --else if pm2<600 and pm2>400 then
                            --    pm1=75/200*(pm1-400)+75;
                            --    pm2=75/200*(pm2-400)+75;
                            --    pm10=75/200*(pm10-400)+75;
                            --end
                            --    pm1=850/400*(pm1-600)+150;
                            --    pm2=850/400*(pm2-600)+150;
                            --    pm10=850/400*(pm10-600)+150;
                            --end
                            
                            print_OLED(pm1,pm2,pm10,voc)
                            ok, json = pcall(sjson.encode, {tcp_id="wujing-air-B123_info",info_id="wujing-air-B123",protocol="info",
                            info={pm1=pm1,pm2=pm2,pm10=pm10,voc=voc,tem=tem,hum=hum}})
                            if ok == true then
                                print(json)
                                tcp_info.send(json)
                            end  
                            
                            
                        end

                    
                    end
                

                
        end

           
        end, 0)
        tmr.delay(5000000)
        modetimer:stop()
    end

end)
modetimer:start()




