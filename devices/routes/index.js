var express = require('express');
var router = express.Router();
var fs = require('fs');


var redis = require('redis')
var client = redis.createClient()

client.on('error', function (err) {
  console.log('Error ' + err);
})
client.on('connect', function() {
  console.log('Redis connected');
  testAdd();
});

var AllLightbulbs = [];
var AllPlugs = [];

//TESTING
/*
function testAdd() {
  client.sadd(['lightbulbs', 'lightbulb1', 'lightbulb2'], function(err, reply) {
    console.log(reply);
    client.hmset('lightbulb1', {'id': 'lightbulb1',
    'name': 'Smart Lightbulb 1',
    'description': 'This is a lightbulb',
    'status': 1, 
    'red': 255,
    'green': 255,
    'blue': 0,
    'intensity': 100
    }, function(err, reply) {
        console.log("set" + reply);
         getLightbulbs();
         getAllPlugs();
    });           
client.hmset('lightbulb2', {'id': 'lightbulb2',
    'name': 'Smart Lightbulb 2',
    'description': 'This is a lightbulb, the second one',
    'status': 1, 
    'red': 255,
    'green': 50,
    'blue': 255,
    'intensity': 80
    }, function(err, reply) {
        console.log("set" + reply);
         getLightbulbs();
         getAllPlugs();
    });   
  });
  client.sadd(['plugs', 'plug1', 'plug2'], function(err, reply) {
    console.log(reply);
    client.hmset('plug1', {'id': 'plug1',
    'name': 'Smart Plug 1',
    'description': 'This is a plug that is on',
    'status': 1, 
    }, function(err, reply) {
        console.log("set" + reply);
         getLightbulbs();
         getAllPlugs();
    });    
    client.hmset('plug2', {'id': 'plug1',
    'name': 'Smart Plug 2',
    'description': 'This is a plug that is off',
    'status': 0, 
    }, function(err, reply) {
        console.log("set" + reply);
         getLightbulbs();
         getAllPlugs();
    });               
  });  
                                              
}
*/

function getLightbulbs() {
  AllLightbulbs = [];
  var lightbulbHashList = [];
  client.smembers('lightbulbs', function(err, reply) {
    lightbulbHashList = reply;
    console.log("lbs" + reply);
    for(i in lightbulbHashList) {
      client.hgetall(lightbulbHashList[i], function(err, object) {
        console.log("lb " + i + object.description);
        AllLightbulbs.push(object);
        console.log(object.name);
      });
    }
  });
}

function getAllPlugs() {
  AllPlugs = [];
  var plugHashList = [];
  client.smembers('plugs', function(err, reply) {
    plugHashList = reply;
    console.log("pgs" + reply);
    for(i in plugHashList) {
      client.hgetall(plugHashList[i], function(err, object) {
        console.log("pg " + i + object.description);
        AllPlugs.push(object);
        console.log(object.name);
      });
    }
  });
}

/* GET home page. */
router.get('/', function(req, res, next) {
  // getLightbulbs();
  // getAllPlugs();
  console.log(AllLightbulbs);
  console.log(AllPlugs);
  res.render('index', {lightbulbs: AllLightbulbs, plugs: AllPlugs});
});

//Renders individual lightbulb page
router.get('/lightbulb/:id', function(req, res) {
  getLightbulbs();

  var currentLightbulb = [];
  
  for(i in AllLightbulbs) {
    if(req.params.id == AllLightbulbs[i].id) {
      currentLightbulb = AllLightbulbs[i];
    }
  }

  var IValueCalc = (currentLightbulb.intensity / 2) / 100;
  var setStatusColour;
  var setStatus;
  if(currentLightbulb.status == 1) {
    setStatusColour = "green";
    setStatus = "ON"
  }
  else {
    setStatusColour = "red";
    setStatus = "OFF"
  }

  res.render('lightbulb', { id: req.params.id, 
    Description: currentLightbulb.description,
    status: setStatus,
    statusColour: setStatusColour,
    RValue: currentLightbulb.red, 
    GValue: currentLightbulb.green, 
    BValue: currentLightbulb.blue, 
    IValue: currentLightbulb.intensity, 
    IValueCSS: IValueCalc
  });
});

//Renders individual plug page
router.get('/plug/:id', function(req, res) {
  getAllPlugs();

  var currentPlug = [];
  for(i in AllPlugs) {
    if(req.params.id == AllPlugs[i].id) {
      currentPlug = AllPlugs[i];
    }
  }
  
  var setStatusColour;
  var setStatus;
  if(currentPlug.status == 1) {
    setStatusColour = "green";
    setStatus = "ON"
  }
  else {
    setStatusColour = "red";
    setStatus = "OFF"
  }

  res.render('plug', { id: req.params.id, 
                        Description: currentPlug.description,
                        status: setStatus,
                        statusColour: setStatusColour,
                          });
});

module.exports = router;
