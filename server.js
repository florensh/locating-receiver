console.log('starting receiver');

var macs = [];
var lastSent = {};
var readline = require('readline');
var _ = require('lodash');
var exec = require('child_process').exec;

var runCapturing = function(callback) {

  var concat = function(one, two) {
    return one + two;
  };

  var makeFilter = function(m) {
    return ' || wlan.sa == ' + m;
  };

  var macFilter = '&& (wlan.sa == ' + _.head(macs) + _.reduce(_.map(_.tail(macs), makeFilter), concat) + ')';
  var filter = 'wlan.fc.type == 0 && wlan.fc.subtype == 4 ' + macFilter;
  console.log('using filter: ' + filter);
  var spawn = require('child_process').spawn,
    ts = spawn("stdbuf", ["-oL", "-eL", 'tshark', '-i', 'mon0', '-f', 'broadcast', '-Y', filter, '-T', 'fields', '-e', 'frame.time_epoch', '-e', 'wlan.sa', '-e', 'radiotap.dbm_antsignal']);


  readline.createInterface({
    input: ts.stdout,
    terminal: false
  }).on('line', function(line) {
    var a = line.toString().split("\t");
    var rssi = a[2].split(",");
    console.log('Device detected: ' + line);
    sendToBackand(a[0], a[1], rssi[0])
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

var request = require('request');

var resolveMacsToFilter = function(callback) {
  // Configure the request
  var options = {
    url: 'https://young-beach-90165.herokuapp.com/people',
    method: 'GET'
  }

  // Start the request
  request(options, function(error, response, body) {
    if (!error && response.statusCode == 200) {
      var people = JSON.parse(body)._embedded.people;
      var devices = _.flatMap(people, function(p) {
        return _.filter(p.devices, function(d) {
          return d.enabled;
        });
      });

      // Print out the response body
      macs = _.map(devices, function(d) {
        return d.mac;
      });

      _(macs).forEach(function(m) {
        lastSent[m] = null;
      });

      callback();
    }
  })
}

resolveMacsToFilter(function() {
  runCapturing()
});


var sendToBackand = function(timestamp, mac, rssi) {

  var t = new Date();
  t.setSeconds(t.getSeconds() - 300);

  if (!lastSent[mac] || lastSent[mac] < t) {
    lastSent[mac] = new Date();
    request({
      url: 'https://young-beach-90165.herokuapp.com/signals',
      method: 'POST',

      json: {
        rssi: rssi,
        mac: mac,
        timestamp: new Date(Number(timestamp * 1000))
      }
    }, function(error, response, body) {
      if (error) {
        console.log(error);
      } else {
        console.log(response.statusCode, body);
      }
    });

  }


}
