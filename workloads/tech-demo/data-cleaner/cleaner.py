from pymongo import MongoClient
from influxdb import InfluxDBClient

# Clean mongo
def clean_mongo():
    c = MongoClient(host=['mongo.default:27017'])
    db = c.goddd
    collections = db.collection_names(include_system_collections=False)
    for collection in collections:
        db.drop_collection(collection)

def clean_influx():
    client = InfluxDBClient(host="influxsrv.hyperpilot", port=8086)
    databases = client.get_list_database()
    for row in databases:
        databaseName = row['name']
        if databaseName == '_internal':
            continue

        client.drop_database(databaseName)
        client.create_database(databaseName)

print("Cleaning mongo")
clean_mongo()
print("Cleaning influx")
clean_influx()
