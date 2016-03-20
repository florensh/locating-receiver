console.log('starting tshark');
var sys = require('sys'),
  exec = require('child_process').exec;
exec('sudo airmon-ng start wlan1', function(error, stdout, stderr) {

  if (!error) {
    // print the output
    sys.puts(stdout);
    var spawn = require('child_process').spawn,
      ts = spawn('tshark', ['-i', 'mon0', '-I', '-f', 'broadcast', '-Y', 'wlan.fc.type == 0 && wlan.fc.subtype == 4 && wlan.sa == d0:e1:40:73:89:7c', '-T', 'fields', '-e', 'frame.time_epoch', '-e', 'wlan.sa', '-e', 'radiotap.dbm_antsignal']);

    ts.stdout.on('data', function(data) {
      console.log(data);
    });

    ts.stderr.on('data', function(data) {
      console.log('stderr: ' + data);
    });

    ts.on('exit', function(code) {
      console.log('child process exited with code ' + code);
    });



    var http = require('http');

    var options = {
      host: 'https://young-beach-90165.herokuapp.com',
      path: '/signal',
      method: 'POST'
    };

    callback = function(response) {

    }

    var req = http.request(options, callback);
    req.write({"mac": "d0:e1:40:73:89:7c"});
    req.end();






  }
});
