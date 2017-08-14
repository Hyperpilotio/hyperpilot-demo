class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
      false : options.verbose;
  }
  processLines(lines = []) {
    const benchmarkObj = JSON.parse(lines.join('\n'))

    return {
      'status': benchmarkObj['status'],
      'time': benchmarkObj['time']
    };
  }
}

module.exports = Parser;
