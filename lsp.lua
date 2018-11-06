_G.cjson = sjson

function newLSPHandler()

    local function doLSP(script,params)

        script="%>"..string.gsub(script,"%c"," ").."<%"
        script=string.gsub(script,"%%>"," echo('")
        script=string.gsub(script,"<%%","') ")

        local paramsStr=" local params=cjson.decode('"..cjson.encode(params).."') "

        local echoStr=" local __echos={} function echo(msg) table.insert(__echos,msg) end "

        script=paramsStr..echoStr..script.." return table.concat(__echos) "

        local result=loadstring(script)()
        return result
    end

    local function readFile(path)

        path=string.gsub(path,"^/","")

        if not file.open(path,"r") then
            return nil
        end

        local content=""

        while true do
            local part=file.read()

            if not part then
                break
            end
            content=content..part
        end
        file.close()
        return content
    end


    local function getType(path)

        local index=string.find(path,"\.[^\.]*$")
        if index==nil then
            return nil
        end

        return string.sub(path,index+1)
    end


    local function output(socket,status,content)

        local response="HTTP/1.1 "..status.."\r\n"
        response=response.."Content-Length: "..string.len(content).."\r\n"
        response=response.."\r\n"..content
        socket:send(response)
    end

    local function handler(socket,path,params)
        if path=="/" then
            path="/index.lsp"
        end
        print(path)
        local content=readFile(path)
        print(path)
        if not content then
            output(socket,"200 OK","404 NOT FOUND")
            return
        end

        if getType(path)=="lsp" then
            content=doLSP(content,params)
        end
        output(socket,"200 OK",content)
    end

    return handler
end
