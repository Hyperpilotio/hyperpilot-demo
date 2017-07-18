"""EC2 Instance Type Clawer."""
from objdict import ObjDict
from pymongo import MongoClient
import urllib2
import json
import argparse
import sys
import ijson


AWS_REGION = "us-east-1"
OUTPUT_FILE_NAME = "nodetypes.json"
AWS_PRICING_API_BASE_URL = "https://pricing.us-east-1.amazonaws.com"
AWS_PRICING_API = AWS_PRICING_API_BASE_URL + "/offers/v1.0/aws/index.json"

products = {}
onDemandPricing = {}
reservedPricing = {}


def compose(region):
    # search for insTypes
    insTypes = list(set(map(lambda x: x["attributes"]["instanceType"], products.values())))
    ec2Instances = ObjDict()
    ec2Instances.data = []
    ec2Instances.region = region
    # for each insTypes find Linux / Windows pricing
    for insType in insTypes:
        product = filter(lambda x:
                         x["attributes"]["instanceType"] == insType and
                         x["attributes"]["tenancy"] == "Shared", products.values())[0]
        result = ObjDict()
        result.name = insType
        result.instanceFamily = insType.split(".")[0]
        result.category = product["productFamily"]

        result.hourlyCost = findPrice(insType)

        result.cpuConfig = ObjDict()
        result.cpuConfig.vCPU = product["attributes"]["vcpu"]
        result.cpuConfig.cpuCredits = product["attributes"]["ecu"]
        result.cpuConfig.cpuType = product["attributes"]["physicalProcessor"]
        result.cpuConfig.clockSpeed = product["attributes"].get("clockSpeed", 0)

        result.memoryConfig = ObjDict()
        result.memoryConfig.size = product["attributes"]["memory"]

        result.networkConfig = ObjDict()
        result.networkConfig.performance = product["attributes"]["networkPerformance"]
        result.networkConfig.bandwidth = 0
        result.networkConfig.enhancedNetworking = False

        result.storageConfig = ObjDict()
        storage = product["attributes"]["storage"]
        if storage == "EBS only":
            result.storageConfig.devices = 0
            result.storageConfig.size = 0
            result.storageConfig.storageType = storage
        else:

            parse = storage.split(" ")
            result.storageConfig.devices = parse[0]
            result.storageConfig.size = parse[2]
            result.storageConfig.storageType = "HDD" if len(parse) < 4 else parse[3]
        result.storageConfig.bandwidth = product["attributes"].get("dedicatedEbsThroughput", "0")
        ec2Instances.data.append(result)
    return ec2Instances


def grab(region):
    """grab."""
    response = urllib2.urlopen(AWS_PRICING_API)
    data = json.load(response)
    ec2RegionIndex = AWS_PRICING_API_BASE_URL + data["offers"]["AmazonEC2"]["currentRegionIndexUrl"]
    # working with huge JSON data
    ec2InsSpecsIndex = json.load(urllib2.urlopen(ec2RegionIndex))

    ec2InsSpecs = ijson.items(urllib2.urlopen(AWS_PRICING_API_BASE_URL + ec2InsSpecsIndex["regions"][region]["currentVersionUrl"]), "")

    for item in ec2InsSpecs:
        for key, value in item.items():
            if key == "products":
                for objKey, objValue in value.items():
                    if objValue["productFamily"] == "Compute Instance":
                        # insert each products into products collection
                        products[objKey] = objValue

            if key == "terms":
                for objKey, objValue in value.items():
                    if objKey == "OnDemand":
                        for k, v in objValue.items():
                            onDemandPricing[k] = v
                    if objKey == "Reserved":
                        for k, v in objValue.items():
                            reservedPricing[k] = v


def findPrice(instanceType):
    """find price."""
    hourlyCost = ObjDict()
    linuxProductList = filter(lambda x:
                              x["attributes"]["operatingSystem"] == "Linux" and
                              x["attributes"]["instanceType"] == instanceType and
                              x["attributes"]["tenancy"] == "Shared",
                              products.values())
    skulinux = map(lambda x: x["sku"], linuxProductList)
    if len(skulinux) == 0:
        hourlyCost.LinuxOnDeamond = 0
    else:
        hourlyCost.LinuxOnDeamond = onDemandPricing[skulinux[0]].values()[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]

    reservedLinuxDict = {k: v for k, v in reservedPricing.iteritems() if k in skulinux}
    for _, v in reservedLinuxDict.items():
        price = filter(lambda x:
                       x["termAttributes"]["LeaseContractLength"] == "1yr" and
                       x["termAttributes"]["PurchaseOption"] == "No Upfront",
                       v.values())
        if len(price) == 0:
            hourlyCost.LinuxReserved = 0
        else:
            hourlyCost.LinuxReserved = price[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]

    windowsProductList = filter(lambda x:
                                x["attributes"]["operatingSystem"] == "Windows" and
                                x["attributes"]["instanceType"] == instanceType and
                                x["attributes"]["tenancy"] == "Shared" and
                                x["attributes"]["licenseModel"] == "License Included" and
                                x["attributes"]["preInstalledSw"] == "NA",
                                products.values())

    skuWindows = map(lambda x: x["sku"], windowsProductList)
    if len(skuWindows) == 0:
        hourlyCost.WindowsOnDemand = 0
    else:
        hourlyCost.WindowsOnDemand = onDemandPricing[skuWindows[0]].values()[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]
    reservedWindowsDict = {k: v for k, v in reservedPricing.iteritems() if k in skuWindows}
    for _, v in reservedWindowsDict.items():
        price = filter(lambda x:
                       x["termAttributes"]["LeaseContractLength"] == "1yr" and
                       x["termAttributes"]["PurchaseOption"] == "No Upfront",
                       v.values())
        if len(price) == 0:
            hourlyCost.WindowsReserved = 0
        else:
            hourlyCost.WindowsReserved = price[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]

    return hourlyCost


def updateDB(mongoUrl, region, postData):
    """update mongo db."""
    client = MongoClient(mongoUrl)
    db = client.configdb
    # search for record
    post = postData
    result = db.nodetypes.update({"region": region}, post, upsert=True)
    print result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-r",
                        type=str,
                        required=False,
                        dest="region",
                        default=AWS_REGION,
                        help="set aws-region, default is all regions")

    parser.add_argument("-o",
                        type=str,
                        required=False,
                        dest="output",
                        default=OUTPUT_FILE_NAME,
                        help="set output file name")

    parser.add_argument("--mongo-url",
                        type=str,
                        required=False,
                        dest="conn",
                        default="mongodb://localhost:27017",
                        help="mongoDB connection url, for example: --mongo-url=mongodb://user:password@mongo.host:port")
    args = parser.parse_args()
    grab(args.region)
    result = compose(args.region)
    try:
        updateDB(args.conn, args.region, result)
    except Exception as e:
        print "Error: {}".format(e)
        sys.exit()
    with open(args.output, "w") as dumpFile:
        dumpFile.write(json.dumps(json.loads(result.__str__()), indent=4))
