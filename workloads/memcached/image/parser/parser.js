class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
      false : options.verbose;
  }
  processLines(lines = []) {
    // Remove empty string from array
    const len = lines.length;
    for (let i = 0; i < len; i++) {
      lines[i] !== '' && lines.push(lines[i]);
    }
    lines.splice(0, len);

    const benchmarkObj = {};

    const operationList = ['read', 'update', 'op_q'];
    // microsecond
    const typeList = ['avg', 'std', 'min', '5th', '10th', '90th', '95th', '99th'];

    let index = 0;
    const firstLine = '#type       avg     std     min     5th    10th    90th    95th    99th'
    for (index = 0; index < lines.length; index++) {
      if (lines[index] === firstLine) {
        index++;
        break;
      }
    }

    const regex = /[-+]?([0-9]*\.[0-9]+|[0-9]+)/g;
    for (let i = 0; i < operationList.length; i++) {
      const str = lines[index + i];
      let m = {};
      let valueArr = [];
      while ((m = regex.exec(str)) !== null) {
        if (m.index === regex.lastIndex) {
          regex.lastIndex++;
        }
        valueArr.push(parseFloat(m[0]));
      }

      for (let j = 0; j < typeList.length; j++) {
        benchmarkObj[`${operationList[i]}_${typeList[j]}`] = valueArr[j];
      }
    }

    index = index + operationList.length;

    let arr = [];

    arr = (/(\d+.\d+)\s+\((\d+\s+\/\s+\d+.\d+s)\)/g).exec(lines[index++]);
    benchmarkObj['TotalQps'] = parseFloat(arr[1]);
    benchmarkObj['TotalQpsFraction'] = arr[2];

    arr = (/(\d+)\ \((\d+.\d+)/g).exec(lines[index++])
    benchmarkObj['Misses'] = parseInt(arr[1]);
    benchmarkObj['MissesPercentage'] = parseFloat(arr[2]);

    arr = (/(\d+)\ \((\d+.\d+)/g).exec(lines[index++])
    benchmarkObj['SkippedTXs'] = parseInt(arr[1]);
    benchmarkObj['SkippedTXsPercentage'] = parseFloat(arr[2]);

    arr = (/(\d+\ bytes)\s+:\s+(\d+.\d+\ [TKMG]B\/.)/g).exec(lines[index++]);
    benchmarkObj['RXBytes'] = arr[1];
    benchmarkObj['RX_avg'] = arr[2];

    arr = (/(\d+\ bytes)\s+:\s+(\d+.\d+\ [TKMG]B\/.)/g).exec(lines[index++]);
    benchmarkObj['TXBytes'] = arr[1];
    benchmarkObj['TX_avg'] = arr[2];

    return benchmarkObj;
  }
}

module.exports = Parser;
