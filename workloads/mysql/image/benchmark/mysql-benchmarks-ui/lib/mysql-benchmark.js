/**
 * mysql-benchmarks.js - Utility module for running mysql-benchmarks cli too.
 *
 * Author: Adam Duston
 * License: MIT
 */
var util = require('util');
var spawn = require('child_process').spawn;

function MysqlBenchmark(options) {
  // Set defaults for the options if they're not included.
  var benchmark_bin = "/usr/local/bin/tpcc_start";
  var mysql_host = options.mysql_host !== undefined ? options.mysql_host : "mysql";
  var mysql_port = options.mysql_port !== undefined ? options.mysql_port : 3306;
  var mysql_user = options.mysql_port !== undefined ? options.mysql_port : "root";
  var tpcc_warehouses = options.tpcc_warehouses !== undefined ? options.tpcc_warehouses : 20;
  var tpcc_connections = options.tpcc_connections !== undefined ? options.options.tpcc_connections : 10;
  var tpcc_warmup_time = options.tpcc_warmup_time !== undefined ? options.options.tpcc_warmup_time : 20;
  var tpcc_benchmark_time = options.tpcc_benchmark_time !== undefined ? options.options.tpcc_benchmark_time : 100;

  // build the command-line command to run.
  var cmd_args = ['-d', 'tpcc', '-u', mysql_user, '-w', tpcc_warehouses, '-c', tpcc_connections, '-r', tpcc_warmup_time, '-l', tpcc_benchmark_time];

  this.getBenchmarkCommand = function() {
    return benchmark_bin;
  };

  this.getBenchmarkArgs = function() {
    return cmd_args;
  };

}

MysqlBenchmark.prototype.run = function(num_requests, callback) {
  results = '';

  // Add the number of requests set to the arguments.
  args = this.getBenchmarkArgs();

  // Spawn the child process to run the mysql benchmark.
  var child = spawn(this.getBenchmarkCommand(), args);
  // Collect stdout into a CSV string.
  output = "";
  error_output = "";
  child.stdout.on('data', function(data) {
    output += data;
    console.log("child_process [STDOUT]:%s", data);
  });

  child.stderr.on('data', function(data) {
    // Log errors
    error_output += data;
    console.log("child_process [STDERR]: %s", data);
  });

  child.on('error', function(error) {
    console.log("Error running child process: %s", error);
  });

  // When mysql-benchmark exits convert the csv output to json objects and return to the caller.
  child.on('exit', function(exitCode) {
    benchmarkObj = {};

    if (exitCode !== 0) {
      console.log("Child process exited with code: " + exitCode);
      callback(new Error(error_output), null);
    } else { // Parse the output of mysql-benchmark to an object.
      lines = output.split("\n");
      inResults = false
      resultIndex = 0
      for (var i in lines) {

        if (inResults) {
          if (lines[i] === '') {
            break
          }

          parts = lines[i].split(' ')
          benchmarksObj[resultIndex] = {
            "sc": parts[3].split(':')[1],
            "lt": parts[5].split(':')[1],
            "rt": parts[7].split(':')[1],
            "fl": parts[9].split(':')[1],
          }
          resultIndex++;
        } else if (lines[i] === '<Raw Results2(sum ver.)>') {
          inResults = true;
        }
      }

      // Return the resulting benchmarks data object.
      callback(null, benchmarkObj);
    }
  });

};


module.exports = MysqlBenchmark;
