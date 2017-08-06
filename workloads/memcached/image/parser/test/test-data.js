const PARSER_DATASET = {
    'memcached': [
        {
            'input': `#type       avg     std     min     5th    10th    90th    95th    99th
read    108463.8 34243.1 92709.1 93636.2 94563.3 111855.9 145236.8 306672.7
update      0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0
op_q        1.0     0.0     1.0     1.0     1.0     1.1     1.1     1.1

Total QPS = 9.2 (46 / 5.0s)

Misses = 0 (0.0%)
Skipped TXs = 0 (0.0%)

RX      71362 bytes :    0.0 MB/s
TX       1692 bytes :    0.0 MB/s`,
            'expect': {
                'TotalQps': 9.2
            }
        }
    ]
};

module.exports = {
    'PARSER_DATASET': PARSER_DATASET
};
