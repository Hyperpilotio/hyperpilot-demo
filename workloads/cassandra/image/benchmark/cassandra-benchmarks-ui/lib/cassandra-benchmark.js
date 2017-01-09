/**
 * cassandra-benchmarks.js - Utility module for running cassandra-benchmarks cli too.
 *
 * Author: Adam Duston
 * License: MIT
 */
var util = require('util');
var spawn = require('child_process').spawn;

var createCmdConfig = function(config) {
    // Reference:  https://docs.datastax.com/en/cassandra/3.0/cassandra/tools/toolsCStress.html
    config = Object.assign({
        benchmark_bin: "/usr/bin/cassandra-stress",
        cassandra_host: "cassandra-serve",
        cassandra_subCmd: "write",
        cassandra_mode: "native cql3",
        num_requests: 10000,
        cassandra_consistency: "one",
        cassandra_keyspace: "keyspace1"
    }, config);
    return config;
};

function CassandraBenchmark(options) {
    // Set defaults for the options if they're not included.
    var config = createCmdConfig(options);

    // build the command-line command to run.
    var cmd_args = [config.cassandra_subCmd, util.format("n=%d", config.num_requests), util.format("cl=%s", config.cassandra_consistency), '-mode', config.cassandra_mode, '-schema', util.format("keyspace=%s", config.cassandra_keyspace), '-node', config.cassandra_host];

    this.getBenchmarkCommand = function() {
        return options.benchmark_bin;
    };

    this.getBenchmarkArgs = function() {
        return cmd_args;
    };
}

CassandraBenchmark.prototype.run = function(num_requests, callback) {
    var n = num_requests !== undefined ? num_requests : 10000;
    results = '';

    // Add the number of requests set to the arguments.
    args = this.getBenchmarkArgs();
    // NOTE: workaround, change the request numbers according to certain index of array.
    args[1] = "n=" + n.toString();

    console.log("cmd arguments: ", args);

    // Spawn the child process to run the cassandra benchmark.
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

    // When cassandra-benchmark exits convert the csv output to json objects and return to the caller.
    child.on('exit', function(exitCode) {
        benchmarkObj = {};

        if (exitCode !== 0) {
            console.log("Child process exited with code: " + exitCode);
            callback(new Error(error_output), null);
        } else { // Parse the output of cassandra-benchmark to an object.
            lines = output.split("\n");
            var count = 0;
            for (var i in lines) {
                // There might be an empty line at the end somewhere.
                if (lines[i] === '') {
                    continue;
                }

                columns = lines[i].split(/[ ]{1,}[:] /);

                if (columns.length > 1) {
                    benchmarkObj[columns[0]] = columns[1];
                    continue;
                }

                // Set the first column to a key and the second column to the value in an object.
                benchmarkObj[count] = lines[i];
                count = count + 1;
            }

            // Return the resulting benchmarks data object.
            callback(null, benchmarkObj);
        }
    });

};


module.exports = CassandraBenchmark;
