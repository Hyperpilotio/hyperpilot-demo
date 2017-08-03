const assert = require('assert');
const PARSER_DATASET = require('./test-data').PARSER_DATASET;

describe('Parser', function() {
  describe('#lucene', function() {
    it('should successfully parse the result of lucene-benchmark',
    function() {
        for (let i = 0; i < PARSER_DATASET.lucene.length; i ++) {
          const Parser = require('../parser');
          const parser = new Parser({});
          const lines = PARSER_DATASET.lucene[i].input.split('\n');
          const benchmarkObj = parser.processLines(lines);

          assert.equal(benchmarkObj['ops/sec'], PARSER_DATASET.lucene[i].expect['ops/sec']);
        }
      });
  });
});
