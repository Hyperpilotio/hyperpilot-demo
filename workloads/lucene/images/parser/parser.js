var xml2js = require('xml2js');

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
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].indexOf("<benchResults>") > -1) {
                grabValue = true;
            }
            if (grabValue) {
                xmlString = xmlString.concat(lines[i]);
            }
            if (lines[i].indexOf("</benchResults>") > -1) {
                grabValue = false;
            }
        }
        if (xmlString) {
            let parser = new xml2js.Parser();
            parser.parseString(xmlString, (err, result) => {
                if (err) {
                    throw err;
                    return null;
                } else {
                    let summary = result.benchResults.benchSummary[0].metric[0];
                    benchmarkObj[summary.$["unit"]] = parseFloat(summary["_"]);
                }
            });
            // wait until done parsing
            while(benchmarkObj.length <= 0) {};
            return benchmarkObj;
        }
    }
}

module.exports = Parser;
