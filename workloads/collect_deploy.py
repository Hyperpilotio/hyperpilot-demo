#!/usr/bin/env python
"""
Collects application.json in each subdirectory and save them into MongoDB
"""

import sys
import os
import json
import glob
from pymongo import MongoClient

MONGO_URL = "localhost:27017"
MONGO_USER = "analyzer"
MONGO_PASSWORD = "hyperpilot"
CONFIGDB_NAME = "configdb"


def replaceDotToUnderline(json):
    if isinstance(json, dict):
        iterator = json.iteritems()
    else:
        iterator = enumerate(json)
    for k, v in iterator:
        if isinstance(k, basestring) and "." in k:
            json.pop(k)
            k = k.replace(".", "_")
            json[k] = v
        if isinstance(v, (dict, list)):
            replaceDotToUnderline(v)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        MONGO_URL = sys.argv[1]

    configdb = MongoClient(MONGO_URL).get_database(CONFIGDB_NAME)
    configdb.authenticate(MONGO_USER, MONGO_PASSWORD)

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
                            replaceDotToUnderline(deploy_json)
                            deploy_json["name"] = deploy_json_path.replace("/", "-").replace(".json", "")
                        except ValueError as e:
                            print("ERROR: Unable to decode {path}".format(path=deploy_json_path))
                            print("       JSON Decode Error: {error}".format(error=e))
                            continue
                        print("Updating {name} with {path}".format(
                            name=deploy_json["name"],
                            path=deploy_json_path
                        ))
                        configdb.deployments.replace_one(
                            filter={"name": deploy_json["name"]},
                            replacement=deploy_json,
                            upsert=True
                        )
