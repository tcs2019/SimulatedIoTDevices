// Updates slider numbers and light bulb colour as sliders are changed
function changeBulb() {
  var r = document.getElementById('RValue').value;
  var g = document.getElementById('GValue').value;
  var b = document.getElementById('BValue').value;
  var i = document.getElementById('IValue').value;

  document.getElementById('RNumber').innerHTML = r;
  document.getElementById('GNumber').innerHTML = g;
  document.getElementById('BNumber').innerHTML = b;
  document.getElementById('INumber').innerHTML = i;

  i /= 100;

  document.getElementById('overlay').style.backgroundColor =
    'rgba(' + r + ', ' + g + ', ' + b + ', ' + i + ')';
}

// Changes text and colour of ON/OFF text
function changeStatus() {
  if (document.getElementById('deviceStatus').innerHTML == 'OFF') {
    document.getElementById('deviceStatus').innerHTML = 'ON';
    document.getElementById('deviceStatus').style.color = 'green';
    document.getElementById('plug').style.backgroundColor = 'green';
  } else {
    document.getElementById('deviceStatus').innerHTML = 'OFF';
    document.getElementById('deviceStatus').style.color = 'red';
    document.getElementById('plug').style.backgroundColor = 'red';
  }
}
