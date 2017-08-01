const PARSER_DATASET = {
    'memcached': [
        {
            'input': `#type       avg     std     min     5th    10th    90th    95th    99th
read       78.4   116.7    34.0    45.0    51.5   115.7   144.5   204.3
update      0.0     0.0     0.0     0.0     0.0     0.0     0.0     0.0
op_q        1.0     0.0     1.0     1.0     1.0     1.1     1.1     1.1

Total QPS = 12664.0 (63320 / 5.0s)

Misses = 0 (0.0%)
Skipped TXs = 0 (0.0%)

RX   15700040 bytes :    3.0 MB/s
TX    2279556 bytes :    0.4 MB/s`,
            'expect': {
                'TotalQps': 12664.0
            }
        }
    ]
};

module.exports = {
    'PARSER_DATASET': PARSER_DATASET
};
