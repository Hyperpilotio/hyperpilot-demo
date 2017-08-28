const assert = require('assert');
const PARSER_DATASET = require('./test-data').PARSER_DATASET;

describe('Parser', function () {
  describe('#spark', function () {
    const Parser = require('../parser');
    const parser = new Parser({});
    for (let i = 0; i < PARSER_DATASET.spark.length; i++) {
      it(`${PARSER_DATASET.spark[i].description} should successfully parse the result of spark-benchmark`,
        function () {
          try {
            const lines = PARSER_DATASET.spark[i].input.split('\n');
            const benchmarkObj = parser.processLines(lines);
            assert.deepEqual(benchmarkObj, PARSER_DATASET.spark[i].expect);
          } catch (e) {
            assert.deepEqual(e, PARSER_DATASET.spark[i].expect);
          }
        });
    }
  });
});
