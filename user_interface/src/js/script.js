function checkRequest() {
    var check = new XMLHttpRequest();
    check.open('GET', '/', true);
    check.onload = function () {

    };
    check.send();  
}

function changeBulb() {
    var r = document.getElementById("RValue").value;
    var g = document.getElementById("GValue").value;
    var b = document.getElementById("BValue").value;
    var i = document.getElementById("IValue").value;
    
    document.getElementById("RNumber").innerHTML = r;
    document.getElementById("GNumber").innerHTML = g;
    document.getElementById("BNumber").innerHTML = b;
    document.getElementById("INumber").innerHTML = i;
    
    i = (i / 2) / 100;
    
    document.getElementById("overlay").style.backgroundColor = "rgba(" + r + ", " + g + ", " + b + ", " + i + ")";
}

function changePlug() {
    if(document.getElementById("plug1Status").innerHTML == "OFF") {
        document.getElementById("plug1Status").innerHTML = "ON";
        document.getElementById("plug1Status").style.color = "green";
        document.getElementById("plug1").style.backgroundColor = "green";
    }
    else {
        document.getElementById("plug1Status").innerHTML = "OFF";
        document.getElementById("plug1Status").style.color = "red";
        document.getElementById("plug1").style.backgroundColor = "red";
    }
}