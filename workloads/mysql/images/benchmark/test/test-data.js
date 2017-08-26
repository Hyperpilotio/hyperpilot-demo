const PARSER_DATASET = {
    'mysql': [
        {
            'input': `***************************************
                *** ###easy### TPC-C Load Generator ***
                ***************************************
                option d with value 'tpcc'
            option h with value 'mysql-server'
            option u with value 'root'
            option w with value '20'
            option c with value '50'
            option r with value '20'
            option l with value '100'
                <Parameters>
                [server]: mysql-server
            [port]: 3306
            [DBname]: tpcc
            [user]: root
            [pass]:
            [warehouse]: 20
            [connection]: 50
            [rampup]: 20 (sec.)
            [measure]: 100 (sec.)

            RAMP-UP TIME.(20 sec.)

            MEASURING START.

            100, 114(0):3.666|4.247, 109(0):0.922|1.216, 12(0):0.290|0.390, 11(0):4.284|4.914, 16(0):12.448|14.702

            STOPPING THREADS..................................................

                <Raw Results>
                [0] sc:1842  lt:2  rt:0  fl:0
            [1] sc:1846  lt:0  rt:0  fl:0
            [2] sc:185  lt:0  rt:0  fl:0
            [3] sc:184  lt:0  rt:0  fl:0
            [4] sc:191  lt:0  rt:0  fl:0
                in 100 sec.

                <Raw Results2(sum ver.)>
                [0] sc:1846  lt:2  rt:0  fl:0
            [1] sc:1848  lt:0  rt:0  fl:0
            [2] sc:185  lt:0  rt:0  fl:0
            [3] sc:184  lt:0  rt:0  fl:0
            [4] sc:191  lt:0  rt:0  fl:0

                <Constraint Check> (all must be [OK])
            [transaction percentage]
            Payment: 43.44% (>=43.0%) [OK]
            Order-Status: 4.35% (>= 4.0%) [OK]
            Delivery: 4.33% (>= 4.0%) [OK]
            Stock-Level: 4.49% (>= 4.0%) [OK]
            [response time (at least 90% passed)]
            New-Order: 99.89%  [OK]
            Payment: 100.00%  [OK]
            Order-Status: 100.00%  [OK]
            Delivery: 100.00%  [OK]
            Stock-Level: 100.00%  [OK]

                <TpmC>
                1106.400 TpmC`,
            'expect': {
                '95th_percentile': 3.666,
                '99th_percentile': 4.247,
                'TpmC': 1106.4
            }
        }
    ]
};

module.exports = {
    'PARSER_DATASET': PARSER_DATASET
};
