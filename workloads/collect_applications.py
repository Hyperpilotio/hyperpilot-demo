#!/usr/bin/env python
"""
Collects application.json in each subdirectory and save them into MongoDB
"""

import os
import json
from pymongo import MongoClient

MONGO_URL = "internal-mongo-elb-624130134.us-east-1.elb.amazonaws.com:27017"
MONGO_USER = "analyzer"
MONGO_PASSWORD = "hyperpilot"
CONFIGDB_NAME = "configdb"

if __name__ == "__main__":
    configdb = MongoClient(MONGO_URL).get_database(CONFIGDB_NAME)
    configdb.authenticate(MONGO_USER, MONGO_PASSWORD)

    for path in os.listdir("."):
        if os.path.isdir(path):
            application_json_path = os.path.join(path, "application.json")
            if os.path.isfile(application_json_path):

                with open(application_json_path) as f:
                    application_json = json.load(f)
                    print("Updating {name} with {path}".format(
                        name=application_json["name"],
                        path=application_json_path
                    ))
                    configdb.applications.replace_one(
                        filter={"name": application_json["name"]},
                        replacement=application_json,
                        upsert=True
                    )
