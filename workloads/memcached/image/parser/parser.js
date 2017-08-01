class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
      false : options.verbose;
  }
  processLines(lines = []) {
    if (lines.length != 12) {
      console.error(`Warn: the format of input is wrong\nResult: ${lines}`);
      return {};
    }
    const benchmarkObj = {};

    try {
      const operationList = ['read', 'update', 'op_q'];
      // microsecond
      const typeList = ['avg', 'std', 'min', '5th', '10th', '90th', '95th', '99th'];

      const regex = /[-+]?([0-9]*\.[0-9]+|[0-9]+)/g;
      for (let i = 0; i < operationList.length; i++) {
        const str = lines[i + 1];
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


      let arr = [];

      arr = (/(\d+.\d+)\s+\((\d+\s+\/\s+\d+.\d+s)\)/g).exec(lines[5]);
      benchmarkObj['TotalQps'] = parseFloat(arr[1]);
      benchmarkObj['TotalQpsFraction'] = arr[2];

      arr = (/(\d+)\ \((\d+.\d+)/g).exec(lines[7])
      benchmarkObj['Misses'] = parseInt(arr[1]);
      benchmarkObj['MissesPercentage'] = parseFloat(arr[2]);

      arr = (/(\d+)\ \((\d+.\d+)/g).exec(lines[8])
      benchmarkObj['SkippedTXs'] = parseInt(arr[1]);
      benchmarkObj['SkippedTXsPercentage'] = parseFloat(arr[2]);

      arr = (/(\d+\ bytes)\s+:\s+(\d+.\d+\ [TKMG]B\/.)/g).exec(lines[10]);
      benchmarkObj['RXBytes'] = arr[1];
      benchmarkObj['RX_avg'] = arr[2];

      arr = (/(\d+\ bytes)\s+:\s+(\d+.\d+\ [TKMG]B\/.)/g).exec(lines[11]);
      benchmarkObj['TXBytes'] = arr[1];
      benchmarkObj['TX_avg'] = arr[2];

    }
    catch (err) {
      console.error(err)
    }

    return benchmarkObj;
  }
}

module.exports = Parser;
