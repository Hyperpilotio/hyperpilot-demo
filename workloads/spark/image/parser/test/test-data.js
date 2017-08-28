const PARSER_DATASET = {
    'spark': [
        {
            'description': 'Case FINISHED',
            'input': `
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 277.91427183151245
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 278.9187741279602
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 279.926997423172
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 280.9322371482849
            }
            {
                "status": "FINISHED",
                "job_id": "driver-20170826001258-0000",
                "time": 281.93565130233765
            }`,
            'expect': {
                'status': "FINISHED",
                'time': 281.93565130233765
            }
        },
        {
            'description': 'Case FAILED',
            'input': `{
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 277.91427183151245
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 278.9187741279602
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 279.926997423172
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 280.9322371482849
            }
            {
                "status": "FAILED",
                "job_id": "driver-20170826001258-0000",
                "time": 281.93565130233765
            }`,
            'expect': {
                'status': "FAILED",
                'time': 281.93565130233765
            }
        },
        {
            'description': 'Case UNEXPECTED_ERROR',
            'input': `{
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 277.91427183151245
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 278.9187741279602
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 279.926997423172
            }
            {
                "status": "RUNNING",
                "job_id": "driver-20170826001258-0000",
                "time": 280.9322371482849
            }
            {
                "status": "UNEXPECTED_ERROR",
                "job_id": "driver-20170826001258-0000",
                "error": "Network problem",
                "time": 281.93565130233765
            }`,
            'expect': {
                "status": "UNEXPECTED_ERROR",
                "job_id": "driver-20170826001258-0000",
                "error": "Network problem",
                "time": 281.93565130233765
            }
        }
    ]
};

module.exports = {
    'PARSER_DATASET': PARSER_DATASET
};
