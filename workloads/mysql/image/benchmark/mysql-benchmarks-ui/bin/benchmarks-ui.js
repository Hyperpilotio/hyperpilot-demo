/**
 * benchmarks-ui.js - Very simple Express web application for benchmarking MySQL performance.
 *
 * Author: Adam Duston
 * License: MIT
 */
var express = require('express');
var fs = require('fs');
var mysqllib = require('../lib/mysql-benchmark');
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
        "error": null
      });

    } else {
      res.render('results', {
        "results": null,
        "mysql_host": req.body.mysql_host,
        "mysql_port": req.body.mysql_port,
        "error": err.message
      });
    }


  });
});

app.post('/api/mysql-loaddata', function(req, res) {
  var mysql_host = req.body.mysql_host !== undefined ? req.body.mysql_host : "mysql-server";
  var mysql_port = req.body.mysql_port !== undefined ? req.body.mysql_port : 3306;
  var tpcc_warehouses = req.body.tpcc_warehouses !== undefined ? req.body.tpcc_warehouses : 20;

  loaddataOpts = {
    "mysql_host": mysql_host,
    "mysql_port": mysql_port,
    "tpcc_warehouses": tpcc_warehouses
  }

  loaddata(loaddataOpts, function(err) {
    if (err !== null) {
      res.status(500);
      res.status("Error loadding tpcc data: " + err);
    } else {
      res.status(200);
    }
    res.send();
  });
});

app.post('/api/mysql-benchmark', function(req, res) {
  /*
   * Provide an API endpoint for running a benchmark and getting back a raw JSON.
   */
  res.contentType('application/json');

  // Get the benchmark parameters from the request body, or use defaults.
  var mysql_host = req.body.mysql_host !== undefined ? req.body.mysql_host : "mysql-server";
  var mysql_port = req.body.mysql_port !== undefined ? req.body.mysql_port : 3306;
  var mysql_pw = req.body.mysql_pw !== undefined ? req.body.mysql_pw : "";

  // A Mysql host is required.
  if (!mysql_host) {
    res.status(400);
    res.send();
    return
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
    res.send();
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
  benchmark = new mysqllib.MysqlBenchmark(options);

  console.log("Running benchmark for %s:%s", options.mysql_host, options.mysql_port);

  // Run the benchmark and pass the output to the calling function.
  benchmark.run(function(err, output) {
    callback(err, output);
  });
};

var loaddata = function(options, callback) {
  loaddata = new mysqllib.LoadData(options);
  console.log("Loadding TPCC data")

  loaddata.run(function(err) {
    callback(err);
  });
};
