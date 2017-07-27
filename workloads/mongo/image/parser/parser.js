class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
                      false : options.verbose;
  }
  processLines(lines = []) {
    let state = 0;
    let benchmarkObj = {};
    for (let i = 0; i < lines.length; i++) {
      switch (state) {
        case 0:
          if (lines[i].indexOf('mongoPerfRunTests') > -1) {
            state++;
            i++
          }
          break;
        case 1:
          if (lines[i].indexOf('Finished Testing.') > -1) {
            state++;
          } else {
            benchmarkObj[lines[i]] = parseFloat(lines[i+1].substr(3));
            i++;
          }
          break;
        default:
          break;
      }
    }
    return benchmarkObj;
  }
}

module.exports = Parser;
