console.log('starting tshark');
var sys = require('sys'),
  exec = require('child_process').exec;
exec('sudo airmon-ng start wlan1', function(error, stdout, stderr) {
  if (!error) {
    // print the output
    sys.puts(stdout);
    var spawn = require('child_process').spawn,
    // am = spawn('airmon-ng', ['start', 'wlan1']),
    ts = spawn('tshark', ['-i', 'mon0', '-f', 'broadcast', '-Y', 'wlan.sa == d0:e1:40:73:89:7c', '-T', 'fields', '-e', 'frame.time_epoch', '-e', 'wlan.sa', '-e', 'radiotap.dbm_antsignal']);
    // ts = spawn('tshark', ['-i', 'mon0']);
    ts.stdout.on('data', function(data) {
      console.log('stdout: ' + data);
    });

    ts.stderr.on('data', function(data) {
      console.log('stderr: ' + data);
    });

    ts.on('exit', function(code) {
      console.log('child process exited with code ' + code);
    });
  } else {
    // handle error
  }
});







// am.stdout.on('data', function(data) {
//   console.log('stdout: ' + data);
// });
//
// am.stderr.on('data', function(data) {
//   console.log('stderr: ' + data);
// });
//
// am.on('exit', function(code) {
//   console.log('child process exited with code ' + code);
// });
