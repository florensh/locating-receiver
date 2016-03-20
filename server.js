console.log('starting receiver');

var sys = require('sys'),
  exec = require('child_process').exec;



var runCapturing = function(callback) {
  sys.puts(stdout);
  var spawn = require('child_process').spawn,
    ts = spawn('tshark', ['-i', 'mon0', '-f', 'broadcast', '-Y', 'wlan.fc.type == 0 && wlan.fc.subtype == 4 && wlan.sa == d0:e1:40:73:89:7c', '-T', 'fields', '-e', 'frame.time_epoch', '-e', 'wlan.sa', '-e', 'radiotap.dbm_antsignal']);
  ts.stdout.on('data', function(data) {
    callback(data);
  });

  ts.stderr.on('data', function(data) {
    console.log('stderr: ' + data);
  });

  ts.on('exit', function(code) {
    console.log('child process exited with code ' + code);
    exec('sudo airmon-ng start wlan1', function(error, stdout, stderr) {
      if (!error) {
        console.log('putting device in monitor mode successful')
        runCapturing();
      }
    });
  });
}

runCapturing(function(data) {
  console.log(data);
});


var request = require('request');


// Configure the request
var options = {
    url: 'https://young-beach-90165.herokuapp.com/people',
    method: 'GET'
}

// Start the request
request(options, function (error, response, body) {
    if (!error && response.statusCode == 200) {
        // Print out the response body
        console.log(body)
    }
})
