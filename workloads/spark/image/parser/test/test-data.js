const PARSER_DATASET = {
    'spark': [
        {
            'description': 'Case FINISHED',
            'input': `{
                "status": "FINISHED",
                "time": 39.07477569580078,
                "job_id": "driver-20170812005528-0011"
            }`,
            'expect': {
                'status': "FINISHED",
                'time': 39.07477569580078
            }
        },
        {
            'description': 'Case FAILED',
            'input': `{
                "status": "FAILED",
                "time": 39.07477569580078,
                "job_id": "driver-20170812005528-0011"
            }`,
            'expect': {
                'status': "FAILED",
                'time': 39.07477569580078
            }
        }
    ]
};

module.exports = {
    'PARSER_DATASET': PARSER_DATASET
};
