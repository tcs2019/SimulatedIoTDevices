setInterval(function() {
  const url = window.location.href;
  $('.deviceListDiv').load(url);
}, 5000);
