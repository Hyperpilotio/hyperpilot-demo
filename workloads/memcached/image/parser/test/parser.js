const assert = require('assert');
const PARSER_DATASET = require('./test-data').PARSER_DATASET;

describe('Parser', function() {
  describe('#Memcached', function() {
    it('should successfully parse the result of memcached-benchmark',
    function() {
        for (let i = 0; i < PARSER_DATASET.memcached.length; i ++) {
          const Parser = require('../parser');
          const parser = new Parser({});
          const lines = PARSER_DATASET.memcached[i].input.split('\n');
          const benchmarkObj = parser.processLines(lines);

          assert.equal(benchmarkObj.TotalQps, PARSER_DATASET.memcached[i].expect.TotalQps);
        }
      });
  });
});
