<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8"> 
	<title>Welcome</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>



<body>

            <form  role="form" action="test.lsp" method="get" >
            <div class="form-group">
            <span>SSID:</span><select name="ssid">
            <%
                --local i=0;
                --if i < 5 then
                --for k,v in pairs(ap_info) do
                --i=i+1
                --<option value="<% echo(k) %>"><% echo(k) %></option>
             %>
                    
                    <option value="home">home</option>
                    <option value="xie">xie</option>
                    <option value="ChinaNet-2.4G-B485">ChinaNet-2.4G-B485</option>
            <%       
                --end
                end
            %>
            </select>
            </div>
            <div class="form-group">
            <p>Password: <input type="text" name="pwd" /></p>
            <button type="submit" class="btn btn-default" >Connect</button>
            </div>
        </form>
    
  




	
</body>
</html>

   

    
