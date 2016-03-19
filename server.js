var spawn = require('child_process').spawn,
  ts = spawn('tshark', ['-i', 'mon0', '-I', '-f', 'broadcast', '-R', 'wlan.fc.type == 0 && wlan.fc.subtype == 4', '-T', 'fields', '-e', 'frame.time_epoch', '-e', 'wlan.sa', '-e', 'radiotap.dbm_antsignal']);



ts.stdout.on('data', function(data) {
  console.log('stdout: ' + data);
});

ts.stderr.on('data', function(data) {
  console.log('stderr: ' + data);
});

ts.on('exit', function(code) {
  console.log('child process exited with code ' + code);
});
