#!/usr/bin/env python
"""
Collects application.json in each subdirectory and save them into MongoDB
"""

import sys
import os
import json
import glob
import boto3
from pymongo import MongoClient


BUCKET_NAME = "workload-deploy-json"


if __name__ == "__main__":
    if len(sys.argv) > 1:
        BUCKET_NAME = sys.argv[1]

    s3 = boto3.resource('s3')
    bucket = s3.create_bucket(
        ACL='private',
        Bucket=BUCKET_NAME
        )

    for path in os.listdir("."):
        if os.path.isdir(path):
            files = glob.glob("{}/deploy-*.json".format(path))
            for deploy_json_path in files:
                # deploy_json_path = os.path.join(path, f)
                print deploy_json_path
                if os.path.isfile(deploy_json_path):
                    with open(deploy_json_path) as f:
                        try:
                            deploy_json = json.load(f)

                        except ValueError as e:
                            print("ERROR: Unable to decode {path}".format(path=deploy_json_path))
                            print("       JSON Decode Error: {error}".format(error=e))
                            continue
                        print("Updating {name} with {path}".format(
                            name=deploy_json["name"],
                            path=deploy_json_path
                        ))

                        s3.Object(BUCKET_NAME, deploy_json_path.replace("/", "-").replace(".json", "")).upload_file(deploy_json_path)
