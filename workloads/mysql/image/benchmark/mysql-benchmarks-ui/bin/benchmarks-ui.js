/**
 * benchmarks-ui.js - Very simple Express web application for benchmarking MySQL performance.
 *
 * Author: Adam Duston
 * License: MIT
 */
var express = require('express');
var fs = require('fs');
var MysqlBenchmark = require('../lib/mysql-benchmark');
var bodyParser = require('body-parser');

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
   * POST route for form submit runs mysql-benchmark and displays results.
   */
  benchmarkOpts = {
    "mysql_host": req.body.mysql_host,
    "mysql_port": req.body.mysql_port,
    "mysql_pw": req.body.mysql_pw
  };

  runBenchmark(benchmarkOpts, function(err, results) {
    // If the reuturned object is empty pass null to the template for the results object.
    // This will make it easier to determine whether to display an error or not.
    outputResults = null;

    if (err === null) {
      outputResults = results;

      res.render('results', {
        "results": outputResults,
        "mysql_host": req.body.mysql_host,
        "mysql_port": req.body.mysql_port,
        "mysql_pw": req.body.mysql_pw,
        "error": null
      });

    } else {
      res.render('results', {
        "results": null,
        "mysql_host": req.body.mysql_host,
        "mysql_port": req.body.mysql_port,
        "mysql_pw": req.body.mysql_pw,
        "error": err.message
      });
    }


  });
});

app.post('/api/mysql-benchmark', function(req, res) {
  /*
   * Provide an API endpoint for running a benchmark and getting back a raw JSON.
   */
  res.contentType('application/json');

  // Get the benchmark parameters from the request body, or use defaults.
  var mysql_host = req.body.mysql_host !== undefined ? req.body.mysql_host : null;
  var mysql_port = req.body.mysql_port !== undefined ? req.body.mysql_port : 3306;
  var mysql_pw = req.body.mysql_pw !== undefined ? req.body.mysql_pw : "";

  // A Mysql host is required.
  if (!mysql_host) {
    res.status(400);
    res.send();
  }

  benchmarkOpts = {
    "mysql_host": mysql_host,
    "mysql_port": mysql_port,
    "mysql_pw": mysql_pw
  };

   runBenchmark(benchmarkOpts, function(err, results) {
    if (err !== null) {
      res.status(500);
      res.status("Error running mysql-benchmark: " + err);
    } else {
      res.status(200);
      res.json(results);
    }
  });
});

var server = app.listen(6001, "0.0.0.0", function() {
  var host = server.address().address;
  var port = server.address().port;

  console.log('benchmarks-ui running on %s:%d', host, port);
});

var runBenchmark = function(options, callback) {
  /**
   * Run a benchmark for the Mysql server given in options.
   */

  // Assume the options sent are options appropriate for MysqlBenchmark
  benchmark = new MysqlBenchmark(benchmarkOpts);

  console.log("Running benchmark for %s:%s", options.mysql_host, options.mysql_port);

  // Run the benchmark and pass the output to the calling function.
  benchmark.run(options.num_requests, function(err, output) {
    callback(err, output);
  });
};
