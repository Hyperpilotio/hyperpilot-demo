class Parser {
    constructor(options) {
        this.isVerbose = (options === undefined || options.verbose === undefined) ?
            false : options.verbose;
    }
    processLines(lines = []) {
        let benchmarkObj = {};

        let inRawResults = false;
        let inTpmcResults = false;
        let resultIndex = 0;
        for (let i in lines) {
            if (inTpmcResults) {
                if (lines[i] === '') {
                    inTpmcResults = false;
                    continue;
                }

                benchmarkObj[resultIndex] = {
                    "tpmc": lines[i].trim().split(" ")[0]
                };
                resultIndex++;
            } else if (inRawResults) {
                if (lines[i] === '') {
                    inRawResults = false;
                    continue;
                }

                let parts = lines[i].split(' ');
                benchmarkObj[resultIndex] = {
                    "sc": parts[3].split(':')[1],
                    "lt": parts[5].split(':')[1],
                    "rt": parts[7].split(':')[1],
                    "fl": parts[9].split(':')[1]
                };
                resultIndex++;
            } else if (inTpmcResults) {

            } else if (lines[i] === '<Raw Results2(sum ver.)>') {
                inRawResults = true;
            } else if (lines[i] === '<TpmC>') {
                inTpmcResults = true;
            }
        }

        return benchmarkObj;
    }
}

module.exports = Parser;
