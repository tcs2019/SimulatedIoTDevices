var express = require('express');
var router = express.Router();
var fs = require('fs');

var redis = require('redis')
var client = redis.createClient()

client.on('error', function (err) {
  console.log('Error ' + err);
})

//Connects to Redis server and retrieves data
client.on('connect', function() {
  console.log('Redis connected');
  getLightbulbs();
  getAllPlugs();
});

//Stores objects for use on server
var AllLightbulbs = [];
var AllPlugs = [];

//Gets data for all lightbulbs and stores it
function getLightbulbs() {
  client.smembers('lightbulbs', function(err, reply) {
    AllLightbulbs = [];
    var lightbulbHashList = [];
    lightbulbHashList = reply;
    for(i in lightbulbHashList) {
      client.hgetall(lightbulbHashList[i], function(err, object) {
        AllLightbulbs.push(object);
      });
    }
  });
}

//Gets data for all plugs and stores it
function getAllPlugs() {
  client.smembers('plugs', function(err, reply) {
  AllPlugs = [];
  var plugHashList = [];
    plugHashList = reply;
    for(i in plugHashList) {
      client.hgetall(plugHashList[i], function(err, object) {
        AllPlugs.push(object);
      });
    }
  });
}

//Gets home page and renders lists of devices
router.get('/', function(req, res, next) {
   getLightbulbs();
   getAllPlugs();
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

  res.render('lightbulb', { 
    name: currentLightbulb.name, 
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

//Renders individual plug
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

  res.render('plug', { 
    name: currentPlug.name, 
    Description: currentPlug.description,
    status: setStatus,
    statusColour: setStatusColour,
  });
});

module.exports = router;

/* TESTING FUNCTIONS

router.get('/lightbulbchange', function(req, res) {
  client.hmset('lightbulb1', {'id': 'lightbulb1',
    'name': 'Smart Lightbulb 1',
    'description': 'This is a lightbulb that was changed',
    'status': 1, 
    'red': 0,
    'green': 255,
    'blue': 255,
    'intensity': 100
    }, function(err, reply) {
        console.log("set" + reply);
    }); 

    res.render('index', {lightbulbs: AllLightbulbs, plugs: AllPlugs});
});

router.get('/plugchange', function(req, res) {
  client.hmset('plug2', {'id': 'plug2',
  'name': 'Smart Plug 2',
  'description': 'This is a plug that is off that is on now',
  'status': 1, 
  }, function(err, reply) {
      console.log("set" + reply);
  }); 

  res.render('index', {lightbulbs: AllLightbulbs, plugs: AllPlugs});
});

function testAdd() {
  client.sadd(['lightbulbs', 'lightbulb1', 'lightbulb2', 'lightbulb3'], function(err, reply) {
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
    });        
    client.hmset('lightbulb3', {'id': 'lightbulb3',
    'name': 'Smart Lightbulb 3',
    'description': 'This is a lightbulb 3',
    'status': 1, 
    'red': 255,
    'green': 255,
    'blue': 0,
    'intensity': 100
    }, function(err, reply) {
        console.log("set" + reply);
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
    });    
    client.hmset('plug2', {'id': 'plug2',
    'name': 'Smart Plug 2',
    'description': 'This is a plug that is off',
    'status': 0, 
    }, function(err, reply) {
        console.log("set" + reply);
    });               
  });  
                                              
}

*/
