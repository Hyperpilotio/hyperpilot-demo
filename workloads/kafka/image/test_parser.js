// Parser tests
const Parser = require('./Parser.js');

var lines = require('fs').readFileSync('test_stdout').toString().split('\n')
var parser = new Parser();
var benchmarkObj = parser.processLines(lines);

console.log(benchmarkObj);
console.log(benchmarkObj['throughput']);
console.log(benchmarkObj['95thLatency']);
