/**
 * redis-benchmarks.js - Utility module for running redis-benchmarks cli too.
 *
 * Author: Adam Duston
 * License: MIT
 */
var util = require('util');
var spawn = require('child_process').spawn;

function RedisBenchmark(options) {
  // Set defaults for the options if they're not included.
  var benchmark_bin = options.benchmark_bin !== undefined ? options.benchmark_bin : "/usr/local/bin/redis-benchmark";
  var redis_host = options.redis_host !== undefined ? options.redis_host : "127.0.0.1";
  var redis_port = options.redis_port !== undefined ? options.redis_port : 6379;
  var redis_pw = options.redis_pw !== undefined ? options.redis_pw : "";

  // build the command-line command to run.
  var cmd_args = ['-h', redis_host, '-p', redis_port, '-a', util.format("\"%s\"", redis_pw), '--csv'];

  this.getBenchmarkCommand = function() {
    return benchmark_bin;
  };

  this.getBenchmarkArgs = function() {
    return cmd_args;
  };

}

RedisBenchmark.prototype.run = function(num_requests, callback) {
  var n = num_requests !== undefined ? num_requests : 10000;
  results = '';

  // Add the number of requests set to the arguments.
  args = this.getBenchmarkArgs();
  args.push("-n");
  args.push(n.toString());

  // Spawn the child process to run the redis benchmark.
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

  // When redis-benchmark exits convert the csv output to json objects and return to the caller.
  child.on('exit', function(exitCode) {
    benchmarkObj = {};

    if (exitCode !== 0) {
      console.log("Child process exited with code: " + exitCode);
      callback(new Error(error_output), null);
    } else { // Parse the output of redis-benchmark to an object.
      lines = output.split("\n");
      for (var i in lines) {
        // There might be an empty line at the end somewhere.
        if (lines[i] === '') {
          continue;
        }
        // Clean up quotes from each line
        noquotes = lines[i].replace(/["]+/g, '');

        // Set the first column to a key and the second column to the value in an object.
        columns = noquotes.split(",");
        benchmarkObj[columns[0]] = columns[1];
      }

      // Return the resulting benchmarks data object.
      callback(null, benchmarkObj);
    }
  });

};


module.exports = RedisBenchmark;
