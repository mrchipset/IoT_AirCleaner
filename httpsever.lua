function newHttpServer(port)
    local server=0
    local maps={}
    local function split(str,delim)
        local items={}
        local start=1
        while true do
            local pos=string.find(str,delim,start,true)
            if not pos then
                table.insert(items,string.sub(str,start))
                break
            end
            table.insert(items,string.sub(str,start,pos-1))
            start=pos+string.len(delim)
        end
        return items
    end

    local function request(socket,path,params)
        local handler=maps[path]
        if not handler then
            handler=maps["default"]
            if not handler then
                return
            end
        end
        handler(socket,path,params)
    end

    local function parseGET(socket,line)
        local items=split(line," ")
        if table.getn(items)~=3 or items[1]~="GET" or items[3]~="HTTP/1.1" then
            return
        end
        items=split(items[2],"?")
        local path=items[1]
        local paramsStr=items[2]
        local params={}
        if paramsStr then
            items=split(paramsStr,"&")
            for i,param in pairs(items) do
                local keyValue=split(param,"=")
                if table.getn(keyValue)~=2 then
                    return
                end
                local key=keyValue[1]
                local value=keyValue[2]
                params[key]=value
            end
        end
        request(socket,path,params)
    end

    server=net.createServer(net.TCP,60)
    if not port then
        port=80
    end
    server:listen(port,function(client)
        client:on("receive",function(socket,data)
            local lines=split(data,"\r\n")
            for i,line in pairs(lines) do
                parseGET(socket,string.gsub(line,"%c",""))
            end
        end)
    end)

    local http={}

    http.map=function(path,handler)
        maps[path]=handler
    end

    http.stop=function()
        server:close()
    end
    return http
end
