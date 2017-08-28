class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
      false : options.verbose;
  }
  processLines(lines = []) {
    let indexLine = 0;
    for (let i = 0; i < lines.length; i++) {
      // case: FINISHED, KILLED, ERROR, FAILED, UNEXPECTED_ERROR
      if (lines[i].indexOf("FINISHED") >= 0 || lines[i].indexOf("KILLED") >= 0
        || lines[i].indexOf("ERROR") >= 0 || lines[i].indexOf("FAILED") >= 0) {
        indexLine = i - 1;
      }
    }

    let benchmarkObj = JSON.parse(lines.slice(indexLine, lines.length).join(' '));
    if (!!benchmarkObj['error']) {
      throw benchmarkObj;
    }
    return {
      'status': benchmarkObj['status'],
      'time': benchmarkObj['time']
    };

  }
}

module.exports = Parser;
