import csv
import json
import sys
import os

'''
pip3 install influxdb
pip3 install nap
'''
from influxdb import InfluxDBClient
from nap.url import Url


def main():
    if len(sys.argv) == 1:
        print('please input deployment name')
        sys.exit(0)
    else:
        deploymentName = sys.argv[1]

    # get influxDB hostName/port
    # call deployer getContainerUrl
    deployerUrl = '/'.join(['http://localhost:7777', 'v1', 'deployments',
                            deploymentName, 'containers', 'influxsrv', 'url'])
    api = Url(deployerUrl)

    try:
        apiRes = api.get()
    except Exception as e:
        print('call deployer fail')
        sys.exit(0)
    else:
        if apiRes.status_code != 200:
            print(apiRes.json()['data'])
            sys.exit(0)
        else:
            influxsrvUrl = apiRes.content.decode()
            publicDnsName = influxsrvUrl.split(':')[0]

    client = InfluxDBClient(host=publicDnsName, port=8086)
    databases = client.get_list_database()
    for row in databases:
        databaseName = row['name']
        if databaseName == '_internal':
            continue
        writeCSV(client, databaseName)


def writeCSV(client, databaseName):
    client.switch_database(databaseName)
    result = client.query('SHOW MEASUREMENTS')

    # database measurements size must be greater than zero
    if len(result.raw) > 0:
        for tableName in result.raw['series'][0]['values']:
            writeTableData(client, databaseName, tableName[0])


def writeTableData(client, databaseName, tableName):
    result = client.query('select * from "%s"' % (tableName))
    tableColumns = result.raw['series'][0]['columns']
    tableValues = result.raw['series'][0]['values']

    # The directory name can not be a slash
    newTableName = tableName.replace('/', '-')
    filePath = '%s/%s.csv' % (databaseName, newTableName)

    if not os.path.exists(databaseName):
        os.makedirs(databaseName)

    f = open(filePath, "w+")
    csv_file = csv.writer(f)
    csv_file.writerow(tableColumns)
    for row in tableValues:
        csv_file.writerow(row)
    f.close()

if __name__ == '__main__':
    main()

