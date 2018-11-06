var net = require('net')    //引入网络模块
const WebSocket = require('ws');

//var app = require('http').createServer(handler)
//var io = require('socket.io')(app);
//var fs = require('fs');
//var http = require('http');
var mysql = require('mysql');
var util = require('util');
//var sqlite3 = require('sqlite3');  
//var values = require('object.values');

var socket_sessions={};
var socket_table=new Set();
var tcp_table=new Set();
var tcp_session={};
var HOST = '0.0.0.0';     //定义服务器地址
var PORT = 3000;            //定义端口号



/*
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'arrival',
  password : 'arrivalzxcvbnm,./',
  database : 'arrival'
});
*/

var pool = mysql.createPool({
    protocol : 'mysql',
    host     : 'localhost',
    port     :  3306,
    user     : 'root',
    password : 'zhou,./0810',
    database : 'db_Air_Cleaner',
    connectionLimit:100, //最大连接数
    multipleStatements: true
})

function bufToArray(buffer) {
  let array = new Array();
  for (data of buffer.values()) array.push(data);
  return array;
}


console.info('Server is running on port ' + PORT);
var server = net.createServer();

//监听连接事件
server.on('connection', function(socket) {
    var client = socket.remoteAddress + ':' + socket.remotePort;
    console.info('Connected to ' + client);
    //监听数据接收事件
    socket.on('data', function(data) {
    	try{
    		session_data=new Buffer(data).toString();
            console.log(session_data);
	        if(typeof(session_data)!='object')
	    	session_data=JSON.parse(session_data);
            switch(session_data.protocol)
            {
            	case 'login':
            		socket.tcp_id=session_data.tcp_id;
            		tcp_session[socket.tcp_id]=socket;
            		tcp_table.add(socket);
            		console.log(tcp_table);
            		break;
              case 'handshake':
                socket.write(JSON.stringify({func:'handshake'}));
                console.log('handshake');
                break;
            	case 'info':
                socket.write(JSON.stringify({func:'handshake'}));
            	wss.clients.forEach(function each(client) {
      			if (client.readyState === WebSocket.OPEN) {
        				client.send(JSON.stringify(session_data.info));
      				}
    			});
                var  addSql = 'UPDATE tb_Reg_Cleaner SET current_info=?,online_time=now() where cleaner_id=?';
                var  addSqlParams = [JSON.stringify(session_data.info),session_data.info_id];
                pool.getConnection(function(err,conn){
                    if(err){
                        //do something
                    }
                    conn.query(addSql,addSqlParams,function (err, result) {
                    if(err){
                     console.log('UPDATE ERROR] - ',err.message);
                     return;
                    }  
                  var  addSql = 'INSERT INTO `tb_History_Data`(`id`,`cleaner_id`,`pm1`,`pm2`,`pm10`,`voc`,`hum`,`tem`,`time`) VALUES(NULL,?,?,?,?,?,?,?,NULL)';
                  var  addSqlParams = [session_data.info_id,session_data.info.pm1,session_data.info.pm2,session_data.info.pm10,
                  							session_data.info.voc,session_data.info.hum,session_data.info.tem];
                  conn.query(addSql,addSqlParams,function (err, result) {
                    if(err){
                     console.log('[INSERT ERROR] - ',err.message);
                     return;
                    }  
                  });
                          
                  conn.release(); //释放连接
                  });
                });
            		console.log(session_data.info);
            		break;
            	default:
            		break;
            }
        }catch(err)
        {

        }

        //console.log(socket);
     });

    //监听连接断开事件
    socket.on('end', function() {
        console.log('Client disconnected.');
        tcp_table.delete(socket.tcp_id);
        console.log(tcp_table);
    });
});

//TCP服务器开始监听特定端口
server.listen(PORT, HOST);






const wss = new WebSocket.Server({ port: 12345 });

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(data) {
    console.log('received: %s', data);
    try{
		ws.send(data);
	    if(typeof(data)!='object')
	    	data=JSON.parse(data);
	    console.log(data);
	    switch(data.protocol)
	    {
	    	case 'login':
	    		ws.wx_id=data.wx_id;
	    		socket_table.add(ws.wx_id);
	    		socket_sessions[ws.wx_id]=ws;
	    		console.log(socket_table);
	    		break;
	    	case 'func':
	    		console.log(data.func);
	    		
	    		switch(data.func)
	    		{
	    			case 'on':
	    			case 'off':
	    			case 'auto':
	    				if(tcp_session[data.tcp_id]!=null)
						tcp_session[data.tcp_id].write(JSON.stringify({func:data.func,params:0}));
	    				break;
	    			case 'speed':
				case 'params':
						if(tcp_session[data.tcp_id]!=null)
	    				tcp_session[data.tcp_id].write(JSON.stringify({func:data.func,params:data.params}));
	    				break;
	    			default:
	    				break;
	    		}
	    		break;
	    	case 'info':
                var sql="";
                var dataset=[];
                switch(data.period)
                {
                  case 'day':
                    for (var i =0; i < 24; i++) {
                      sql+=util.format('SELECT avg(pm1) as pm1,avg(pm2) as pm2,avg(pm10) as pm10,avg(voc) as voc,avg(tem) as tem,avg(hum) as hum FROM `tb_History_Data` WHERE time>NOW()-INTERVAL %d HOUR and time<NOW()-INTERVAL %d HOUR;',i+1,i);
                    }
                    break;
                  case 'week':
                    for (var i =0; i < 7; i++) {
                      sql+=util.format('SELECT avg(pm1) as pm1,avg(pm2) as pm2,avg(pm10) as pm10,avg(voc) as voc,avg(tem) as tem,avg(hum) as hum FROM `tb_History_Data` WHERE to_days(time)=to_days(now())-%d;',i);
                    }
                    break;
                  case 'month':
                    console.log("month");
                    for (var i =0; i < 12; i++) {
                      sql+=util.format('SELECT avg(pm1) as pm1,avg(pm2) as pm2,avg(pm10) as pm10,avg(voc) as voc,avg(tem) as tem,avg(hum) as hum FROM `tb_History_Data` WHERE time>NOW()-INTERVAL %d MONTH and time<NOW()-INTERVAL %d MONTH;',i+1,i);
                    }
                    break;
                }
                pool.getConnection(function(err,conn){
                  var addSql=sql;
                  //console.log(sql);
                  //var  addSql = 'SELECT cleaner_info FROM `tb_History_Data` WHERE cleaner_id=? AND to_days(time)=to_days(now())';
                  var  addSqlParams = [data.tcp_id];

                  conn.query(addSql,addSqlParams,function (err, result) {
                    if(err){
                     console.log('[INSERT ERROR] - ',err.message);
                     return;
                    }  

                    for(var i=result.length-1;i>=0;i--)
                    {
                      dataset.push(result[i][0]);
                    }
                    //console.log(JSON.stringify(dataset));
                    ws.send(JSON.stringify(dataset));
		    //console.log(dataset[0].pm1);
                  });
                          
                  conn.release(); //释放连接
                  });
               
	    		break;
	    	default:
	    		break;
	    }


    }
    catch(err)
    {
    	console.log(err);
    }
  });


  ws.on('close', function disconnect() {
  		socket_table.delete(ws.wx_id);  
  		console.log(socket_table);
      });
  
});

/*
app.listen(8888);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

io.on('connection', function (socket) {
    console.log("connection");
    socket.emit('news',{login:"login"});
    socket.on('login', function (data) {
        if(typeof(data)!='object')
            data=JSON.parse(data);
        sessions[data.phone]=socket;
        socket_table[socket.id]=data.phone;
        console.log(data);
        socket.emit("login",data);
        console.log(socket_table);
        var db = new sqlite3.Database('./db/sessions.db',function() {
            db.all("select * from message where to_user=?",[data.phone],function(err,res){
            if(!err)
                res.forEach((row) => {
                    socket.emit('message',JSON.stringify({from:row.from_user,message:row.message}));
                    db.run("delete from message where id=?",[row.id]);
                });
            else
              console.log(err);
            });
            db.close();
        });
        


      });
      //接收消息
      socket.on('message', function (data) {
        if(typeof(data)!='object')
          data=JSON.parse(data);
        console.log("socket");
        if(values(socket_table).includes(data.phone))
        {
            console.log("send");
            sessions[data.phone].emit('message',JSON.stringify({from:socket_table[socket.id],content:data.message}));
        }
        else
        {
            console.log("save");
            if(typeof(data.message=='object'))
                ss=JSON.stringify(data.message);
            else
                ss=data.message;
            var db = new sqlite3.Database('./db/sessions.db',function() {
            db.run("insert into message values(NULL,?,?,?)",[socket_table[socket.id],data.phone,ss]
                ,function(){db.close();})}); 
            console.log(typeof(data.message));
        }
      });

    socket.on('function', function (data) {
        if(typeof(data)!='object')
          data=JSON.parse(data);
        console.log("function");
        let time1;
        let time2;
        time1=new Date();
        time2=new Date(time1-data.time*1000);
        var  addSql = 'SELECT lat,lon,time FROM location_info where hardware_id=? and time<? and time>?';
        var  addSqlParams = [data.hardware_id,time1,time2];
        console.log(time1,time2);
        pool.getConnection(function(err,conn){
            if(err){
                //do something
            }
            conn.query(addSql,addSqlParams,function (err, result) {
            if(err){
             console.log('[INSERT ERROR] - ',err.message);
             return;
            }        

           console.log('--------------------------INSERT----------------------------');
           //console.log('INSERT ID:',result.insertId);        
            //console.log('INSERT ID:',result);
                let this_send_buff=[];      
                for (var i=0; i<result.length; i++) {          
                    let firstResult = result[i];
                    this_send_buff.push({'lat':firstResult.lat,'lon':firstResult.lon,'time':firstResult.time});
                }
                console.log(this_send_buff);
                sessions[data.phone].emit('message',JSON.stringify(this_send_buff)); 
           console.log('-----------------------------------------------------------------\n\n');  
            conn.release(); //释放连接
            });
        });

      });

      //删除连接
      socket.on('disconnect', function (data) {
        //if(typeof(data)!='object')
        //  data=JSON.parse(data);
        console.log("disconnect");
        delete sessions[socket_table[socket.id]];
        delete socket_table[socket.id];
        console.log(socket_table);

      });

});
*/
