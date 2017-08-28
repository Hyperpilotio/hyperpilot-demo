class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
                      false : options.verbose;
  }
  processLines(lines = []) {
    let benchmarkObj = {};
    let lastLine = lines[lines.length-2].split(',')

  try {
      var reFloat=/[+-]?([0-9]*[.])?[0-9]+/
      benchmarkObj['throughput'] = parseFloat(lastLine[1].split(' ')[3].match(reFloat)[0]);
      benchmarkObj['avgLatency'] = parseFloat(lastLine[2].split(' ')[1]);
      benchmarkObj['maxLatency'] = parseFloat(lastLine[3].split(' ')[1]);
      benchmarkObj['50thLatency'] = parseFloat(lastLine[4].split(' ')[1]);
      benchmarkObj['95thLatency'] = parseFloat(lastLine[5].split(' ')[1]);
      benchmarkObj['99thLatency'] = parseFloat(lastLine[6].split(' ')[1]);
      benchmarkObj['99.9thLatency'] = parseFloat(lastLine[7].split(' ')[1]);
      benchmarkObj['throughputMetric'] = 'MB/sec';
      benchmarkObj['latencyMetric'] = 'ms';
  }
  catch(err) {
      console.log(err);
      console.log(lines);
  }


    return benchmarkObj;
  }
}

module.exports = Parser;
