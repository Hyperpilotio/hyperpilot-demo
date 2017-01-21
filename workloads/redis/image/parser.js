class Parser {
    constructor() {}

    processLines(lines = []) {
        let benchmarkObj = {};
        for (let i in lines) {
            // There might be an empty line at the end somewhere.
            if (lines[i] === '' || lines[i] === '\n') {
                continue;
            }
            // Clean up quotes from each line
            let noquotes = lines[i].replace(/["]+/g, '');

            // Set the first column to a key and the second column to the value in an object.
            let columns = noquotes.split(",");
            benchmarkObj[columns[0]] = columns[1];
        }

        return benchmarkObj;
    }
}

module.exports = Parser;
