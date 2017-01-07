/**
 * benchmarks-ui.js - Very simple Express web application for benchmarking Cassandra performance.
 *
 * Author: Adam Duston
 * License: MIT
 */
var express = require('express');
var fs = require('fs');
var CassandraBenchmark = require('../lib/cassandra-benchmark');
var bodyParser = require('body-parser');

// Load the configuration from the config file.
var configFile = "./config/config.json";
try {
  var config = JSON.parse(fs.readFileSync(configFile));
} catch (e) {
  // Quit if the config file can't be read
  console.log("Error parsing %s - %s", configFile, e);
  process.exit(1);
}

// Set a default for the cassandra-benchmark bin location, or use the one from the config.json
var benchmark_cmd = "/usr/local/bin/cassandra-benchmark";
if (config.hasOwnProperty("benchmark_cmd")) {
  benchmark_cmd = config.benchmark_cmd;
}

// Initialize the express application. Use Jade as the view engine
var app = express();
app.set('view engine', 'jade');
app.set('json spaces', 2);

// Create a static resource for the public directory.
app.use(express.static('public'));

// Use the json BodyParser
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: true
}));


// GET route for index
app.get('/', function(req, res) {
  res.render('index');
});

app.post('/', function(req, res) {
  /*
   * POST route for form submit runs cassandra-benchmark and displays results.
   */
  benchmarkOpts = {
    "cassandra_host": req.body.cassandra_host,
    "num_requests": req.body.num_requests,
    "benchmark_bin": benchmark_cmd
  };

  runBenchmark(benchmarkOpts, function(err, results) {
    // If the reuturned object is empty pass null to the template for the results object.
    // This will make it easier to determine whether to display an error or not.
    outputResults = null;

    if (err === null) {
      outputResults = results;

      res.render('results', {
        "results": outputResults,
        "cassandra_host": req.body.cassandra_host,
        "num_requests": req.body.num_requests,
        "error": null
      });

    } else {
      res.render('results', {
        "results": null,
        "cassandra_host": req.body.cassandra_host,
        "num_requests": req.body.num_requests,
        "error": err.message
      });
    }


  });
});

app.post('/api/cassandra-benchmark', function(req, res) {
  /*
   * Provide an API endpoint for running a benchmark and getting back a raw JSON.
   */
  res.contentType('application/json');

  // Get the benchmark parameters from the request body, or use defaults.
  var cassandra_host = req.body.host !== undefined ? req.body.host : null;
  var cassandra_port = req.body.port !== undefined ? req.body.port : 6379;
  var cassandra_pw = req.body.password !== undefined ? req.body.password : "";
  var num_requests = req.body.requests !== undefined ? req.body.requests : 10000;

  // A Cassandra host is required.
  if (!cassandra_host) {
    res.status(400);
    res.send();
  }

  benchmarkOpts = {
    "cassandra_host": cassandra_host,
    "num_requests": num_requests,
    "benchmark_bin": benchmark_cmd
  };

   runBenchmark(benchmarkOpts, function(err, results) {
    if (err !== null) {
      res.status(500);
      res.status("Error running cassandra-benchmark: " + err);
    } else {
      res.status(200);
      res.json(results);
    }
  });
});

app.get('/api/cassandra-instances', function(req, res) {
  /*
   * Provide an API endpoint to get information about the Cassandra services bound to this application. Return as a JSON
   * which includes the instance name and credentials.
   */
  res.contentType('application/json');

  // Just return an empty result if the app isn't running in CloudFoundry.
  return res.json({});
});

// Start the application. Get bind details from cfenv
var server = app.listen(6001, "0.0.0.0", function() {
  var host = server.address().address;
  var port = server.address().port;

  console.log('benchmarks-ui running on %s:%d', host, port);
});

var runBenchmark = function(options, callback) {
  /**
   * Run a benchmark for the Cassandra server given in options.
   */

  // Assume the options sent are options appropriate for CassandraBenchmark
  benchmark = new CassandraBenchmark(benchmarkOpts);

  console.log("Running benchmark for %s:%s", options.cassandra_host, options.cassandra_port);

  // Run the benchmark and pass the output to the calling function.
  benchmark.run(options.num_requests, function(err, output) {
    callback(err, output);
  });

};
