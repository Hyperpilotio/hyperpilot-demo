const assert = require('assert');
const PARSER_DATASET = require('./test-data').PARSER_DATASET;

describe('Parser', function() {
  describe('#mysql', function() {
    it('should successfully parse the result of mysql-benchmark',
    function() {
        for (let i = 0; i < PARSER_DATASET.mysql.length; i ++) {

          const Parser = require('../parser');
          const parser = new Parser({});
          const lines = PARSER_DATASET.mysql[i].input.split('\n');
          const benchmarkObj = parser.processLines(lines);

          assert.deepEqual(benchmarkObj, PARSER_DATASET.mysql[i].expect);
        }
      });
  });
});


