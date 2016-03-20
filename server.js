console.log('starting tshark');
var sys = require('sys'),
  exec = require('child_process').exec;
exec('sudo airmon-ng start wlan1', function(error, stdout, stderr) {
  if (!error) {
    // print the output
    sys.puts(stdout);
    var spawn = require('child_process').spawn,
    // am = spawn('airmon-ng', ['start', 'wlan1']),
    ts = spawn('tshark', ['-i', 'mon0', '-I', '-f', 'broadcast && wlan.fc.type == 0 && wlan.fc.subtype == 4', '-T', 'fields', '-e', 'frame.time_epoch', '-e', 'wlan.sa', '-e', 'radiotap.dbm_antsignal']);
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
