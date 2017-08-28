#!/usr/bin/env python
"""
Collects parser in each subdirectory and upload them to AWS S3
"""

import os
import boto3

s3 = boto3.client('s3')
BUCKET_NAME = 'hyperpilot-benchmark-parsers'

if __name__ == "__main__":
    for path in os.listdir("."):
        parser_js_path = os.path.join(path, 'images', 'parser', 'parser.js')
        if os.path.isfile(parser_js_path):
            print("Upload {} workload's parser.js".format(path))
            s3.upload_file(
                parser_js_path, BUCKET_NAME, '{}/parser.js'.format(path),
                ExtraArgs={'ACL': 'public-read'}
            )
