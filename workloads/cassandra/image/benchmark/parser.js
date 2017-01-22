class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
                      false : options.verbose;
  }
  processLines (lines = []) {
    let benchmarkObj = {};
    let count = 0;
    for (let i in lines) {
      // There might be an empty line at the end somewhere.
      if (lines[i] === '' || lines[i] === '\n') {
        continue;
      }

      let columns = lines[i].split(/[ ]{1,}[:] /);

      if (columns.length > 1) {
        // Set the first column to a key and the second column to the value in an object.
        benchmarkObj[columns[0]] = columns[1];
        continue;
      }

      if (this.isVerbose) {
        benchmarkObj[count] = lines[i];
      }
      count = count + 1;
    }
    return benchmarkObj;
  }
}

module.exports = Parser;
