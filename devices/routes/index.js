var express = require('express');
var router = express.Router();
var fs = require('fs');

//var redis = require('redis')
//var client = redis.createClient()
//
//client.on('error', function (err) {
//  console.log('Error ' + err)
//})

var testLight = [{id: 1, Description: "This is a test lightbulb", status: "ON", RValue: 255, GValue: 0, BValue: 255, IValue: 100},
                  {id: 2, Description: "This is a test lightbulb 2", status: "OFF", RValue: 150, GValue: 255, BValue: 0, IValue: 750}];
var testPlug = [{id: 1, Description: "This is a test plug", status: "ON"},
{id: 2, Description: "This is a test plug 2", status: "OFF"}];

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', {lightbulbs: testLight, plugs: testPlug});
});

router.get('/lightbulb/:id', function(req, res) {
  var idnumber = req.params.id - 1;
  var IValueCalc = (testLight[idnumber].IValue / 2) / 100;
  var setStatusColour;
  if(testLight[idnumber].status == "ON") {
    setStatusColour = "green";
  }
  else {
    setStatusColour = "red";
  }
  res.render('lightbulb', { id: req.params.id, 
                            Description: testLight[idnumber].Description,
                            status: testLight[idnumber].status,
                            statusColour: setStatusColour,
                            RValue: testLight[idnumber].RValue, 
                            GValue: testLight[idnumber].GValue, 
                            BValue: testLight[idnumber].BValue, 
                            IValue: testLight[idnumber].IValue, 
                            IValueCSS: IValueCalc
                          });
});

router.get('/plug/:id', function(req, res) {
  var idnumber = req.params.id - 1;
  var setStatusColour;
  if(testPlug[idnumber].status == "ON") {
    setStatusColour = "green";
  }
  else {
    setStatusColour = "red";
  }
  res.render('plug', { id: req.params.id, 
                        Description: testPlug[idnumber].Description,
                        status: testPlug[idnumber].status,
                        statusColour: setStatusColour,
                          });
});

module.exports = router;
