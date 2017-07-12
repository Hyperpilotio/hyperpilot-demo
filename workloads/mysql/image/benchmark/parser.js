class Parser {
    constructor(options) {
        this.isVerbose = (options === undefined || options.verbose === undefined) ?
            false : options.verbose;
    }
    processLines(lines = []) {
        let benchmarkObj = {};
        let measuringStart = "MEASURING START.";
        let stoppingThreads = "STOPPING THREADS..................................................";
        let capturedLines = [];
        let captureMode = false;

        for (let i = 0; i < lines.length; i++) {
            let line = lines[i]
            if (line.indexOf(stoppingThreads) != -1) {
                break;
            }

            if (captureMode) {
                capturedLines.push(line);
            }

            if (line.indexOf(measuringStart) != -1) {
                captureMode = true;
            }
        }

        for (let i in capturedLines) {
            let capturedLine = capturedLines[i].trim();
            if (capturedLine !== "") {
                // We only expect one output as we should set interval to the length of the load test.
                let values = capturedLine.split(",")[1].split(":")[1].split("|");
                benchmarkObj["95th_percentile"] = parseFloat(values[0]);
                benchmarkObj["99th_percentile"] = parseFloat(values[1]);
                break;
            }
        }

        return benchmarkObj;
    }
}

module.exports = Parser;
