# IoT_AirCleaner
This project is base on NodeMcu ESP8266 Wifi Model to Control Our Cleaner At every Corner in the World.

##clock.lua
In this file, an 24hr mode clock is implemented.

##httpserver.lua
Implement a extremely tiny httpserver for ESP8266. The memory usage is restrictly limited because of the leak of system resources.

This server is used to connect to other AP accessing to Internet.

##lsp.lua
This is a dynamic html translation script to make html templates like jsp.

##\*.lsp 
These files are like jsp files, combing html and lua.

##testap.lua
This file store default ap information for the hardware.

##tcpinfo.lua & websockets.lua
These files are two kind of communication proctol choice to communicate with the server.

##init.lua
This file can be used as main entry point of a program. I have all my hardware configure in this file including uart, spi and iic.

Uart is used to get air quality informantion. spi or iic is used to transfer data to 9314LCD IC.

This file has a main loop with timer.

#Nodemcu Firmware requirement
##*IIC, SPI, UART, TIMER, TCP, HTTP, WEBSOCKET, SSL and JSON*
