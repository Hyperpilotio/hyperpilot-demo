
class Parser {
  constructor(options) {
    this.isVerbose = (options === undefined || options.verbose === undefined) ?
                      false : options.verbose;
  }
  processLines(lines = []) {
    let benchmarkObj = {};
    let grabValue = false;
    let xmlString = "";
    let m = []
    // const regex = /<metric[^>]* unit="(.*?)"[^>]*>(.*?)<\/metric>/;
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].indexOf("<benchResults>") > -1) {
          grabValue = true;
      }
      if (grabValue) {
          xmlString = xmlString.concat(lines[i]);
      }
      if (lines[i].indexOf("</benchResults>") > -1) {
          grabValue = false
      }
    }
    if (xmlString) {
        require('xml2js').parseString(xmlString, (err, result) => {
            if (err) {
                throw err
            } else {
                let summary = result.benchResults.benchSummary[0].metric[0]
                benchmarkObj[summary.$["unit"]] = summary["_"]
            }
        })
    }
    console.log(benchmarkObj)
    return benchmarkObj;
  }
}

module.exports = Parser;
