"""EC2 Instance Type Crawler."""
from objdict import ObjDict
from pymongo import MongoClient
from bs4 import BeautifulSoup as soup
import urllib2
import json
import argparse
import sys
import ijson
import re


AWS_REGION = "us-east-1"
OUTPUT_FILE_NAME = "nodetypes.json"
AWS_PRICING_API_BASE_URL = "https://pricing.us-east-1.amazonaws.com"
AWS_PRICING_API = AWS_PRICING_API_BASE_URL + "/offers/v1.0/aws/index.json"
AWS_PRICING_API_REGION_INDEX = "/offers/v1.0/aws/AmazonEC2/current/region_index.json"
KEY_CPU_CREDITS_INSTANCETYPE = "Instance type"
KEY_CPU_CREDITS_MAX_EARN = "Maximum earned CPU credit balance"
KEY_CPU_CREDITS_INITIAL = "Initial CPU credit"
KEY_CPU_CREDITS_BASE_PERFORMANCE = "Base performance (CPU utilization)"
KEY_CPU_CREDITS_EARN_PER_HOUR = "CPU credits earned per hour"
KEY_CPU_CREDITS_VCPUS = "vCPUs"
KEY_NETWORK_BANDWIDTH_INSTANCETYPE = "Instance type"
KEY_NETWORK_BANDWIDTH_DEFAULT_EBS_OPTIMIZE = "EBS-optimized by default"
KEY_NETWORK_BANDWIDTH_MAX = "Max. bandwidth (Mbps)"
KEY_NETWORK_BANDWIDTH_EXPECTED_THROUGHPUT = "Expected throughput (MB/s)"
KEY_NETWORK_BANDWIDTH_MAX_IOPS = "Max. IOPS (16 KB I/O size)"


products = {}
onDemandPricing = {}
reservedPricing = {}

cpuCredits = []
bandwidth = []
clusterNetworking = ["r4", "x1", "m4", "c4", "c3", "i2", "cr1", "hs1", "p2", "g3", "d2"]


def getEBSConfig(instanceType):
    if len(bandwidth) <= 0:
        mp = soup(urllib2.urlopen("http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-ec2-config.html"), "html.parser")
        table = mp.find(id="w144aac23c29c25b9c15")
        trs = table.find_all("tr")
        firstRow = True
        keys = []
        for row in trs:
            if firstRow:
                firstRow = False
                keys = [x.children.next().replace("*", "") for x in row.find_all("th")]
                continue

            tds = row.find_all("td")
            bandwidthItem = {}
            for i in range(len(tds)):
                text = ""
                if tds[i].find("code") is not None:
                    text = tds[i].find("code").children.next().replace("*", "")
                else:
                    text = tds[i].children.next().replace("*", "") if next(tds[i].children, None) is not None else ""
                bandwidthItem[keys[i]] = text
            bandwidth.append(bandwidthItem)

    result = filter(lambda x: x.get(KEY_NETWORK_BANDWIDTH_INSTANCETYPE) == instanceType, bandwidth)

    return result[0] if len(result) > 0 else None


def getCpuCredits(instanceType):
    if len(cpuCredits) <= 0:
        mp = soup(urllib2.urlopen("http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/t2-instances.html"), "html.parser")
        table = mp.find(id="w144aac17c11c23c13c12")
        trs = table.find_all("tr")
        firstRow = True
        keys = []
        for row in trs:
            if firstRow:
                firstRow = False
                ths = [x for x in row.find_all("th")]
                for th in ths:
                    if th.find("p") is not None:
                        keys.append(th.find("p").children.next().replace("*", ""))
                    else:
                        keys.append(th.children.next())
                continue

            tds = row.find_all("td")
            cpuCreditItem = {}
            for i in range(len(tds)):
                text = ""
                if tds[i].find("p") is not None:
                    if tds[i].find("p").find("code") is not None:
                        text = tds[i].find("p").find("code").children.next().replace("*", "")
                    else:
                        text = tds[i].find("p").children.next().replace("*", "")
                else:
                    text = tds[i].children.next().replace("*", "")
                cpuCreditItem[keys[i]] = text
            # print cpuCreditItem
            cpuCredits.append(cpuCreditItem)
    result = filter(lambda x: x.get(KEY_CPU_CREDITS_INSTANCETYPE) == instanceType, cpuCredits)

    return result[0] if len(result) > 0 else None


def makeValueWithUnit(value, unit):
    data = ObjDict()
    data.value = value
    data.unit = unit
    return data

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
        result.instanceFamily = product["attributes"].get("instanceFamily", "")
        result.hourlyCost = findPrice(insType)

        result.cpuConfig = ObjDict()
        result.cpuConfig.vCPU = int(product["attributes"].get("vcpu", 0))
        ecu = product["attributes"].get("ecu", "0")
        ecu = "0" if ecu == "Variable" else ecu
        result.cpuConfig.ecu = float(ecu)
        result.cpuConfig.cpuCredits = 0
        credits = getCpuCredits(insType)
        if credits is None:
            result.cpuConfig.cpuCredits = {}
        else:
            credit = ObjDict()
            credit.max = int(credits[KEY_CPU_CREDITS_MAX_EARN])
            credit.init = int(credits[KEY_CPU_CREDITS_INITIAL])
            credit.base = credits[KEY_CPU_CREDITS_BASE_PERFORMANCE]
            credit.earnPerHour = int(credits[KEY_CPU_CREDITS_EARN_PER_HOUR])
            credit.vCPUs = int(credits[KEY_CPU_CREDITS_VCPUS])
            result.cpuConfig.cpuCredits = credit

        result.cpuConfig.cpuType = product["attributes"].get("physicalProcessor", "")
        clockSpeed = re.sub(' +', ' ', product["attributes"].get("clockSpeed", "0")).split(" ")
        clockSpeedValueIndex = 0
        try:
            clockSpeedValueIndex = clockSpeed.index("GHz") - 1 if clockSpeed.index("GHz") > 0 else 0
        except ValueError:
            clockSpeedValueIndex = 0
        result.cpuConfig.clockSpeed = makeValueWithUnit(float(clockSpeed[clockSpeedValueIndex]), "GHz")

        result.memoryConfig = ObjDict()
        result.memoryConfig.size = makeValueWithUnit(float(product["attributes"].get("memory", "0").split(" ")[0].replace(",", "")), "GiB")

        result.networkConfig = ObjDict()
        result.networkConfig.performance = product["attributes"].get("networkPerformance", "")
        result.networkConfig.clusterNetworking = True if insType.split(".")[0] in clusterNetworking else False
        result.networkConfig.enhancedNetworking = bool(product["attributes"].get("enhancedNetworkingSupported", "False"))

        result.storageConfig = ObjDict()
        storage = product["attributes"]["storage"]
        if storage == "EBS only":
            result.storageConfig.devices = 0
            result.storageConfig.size = makeValueWithUnit(0, "GB")
            result.storageConfig.storageType = storage
        else:
            parse = storage.split(" ")
            result.storageConfig.devices = int(parse[0])
            result.storageConfig.size = makeValueWithUnit(int(parse[2].replace(",", "")), "GB")
            result.storageConfig.storageType = "HDD" if len(parse) < 4 else parse[3]
        # result.storageConfig.bandwidth = makeValueWithUnit(int(product["attributes"].get("dedicatedEbsThroughput", "0").split(" ")[0]), "Mbps")

        ebsItem = getEBSConfig(insType)
        if ebsItem is not None:
            result.storageConfig.EBSOptimized = ebsItem[KEY_NETWORK_BANDWIDTH_DEFAULT_EBS_OPTIMIZE]
            result.storageConfig.maxBandwidth = makeValueWithUnit(int(ebsItem[KEY_NETWORK_BANDWIDTH_MAX].replace(",","")), "Mbps")
            result.storageConfig.expectedThroughput = makeValueWithUnit(float(ebsItem[KEY_NETWORK_BANDWIDTH_EXPECTED_THROUGHPUT].replace(",", "")), "MB/s")
            result.storageConfig.maxIOPS = makeValueWithUnit(int(ebsItem[KEY_NETWORK_BANDWIDTH_MAX_IOPS].replace(",", "")), "16KB I/O size")

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
        hourlyCost.LinuxOnDemand = 0
    else:
        hourlyCost.LinuxOnDemand = makeValueWithUnit(float(onDemandPricing[skulinux[0]].values()[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]), "USD")

    reservedLinuxDict = {k: v for k, v in reservedPricing.iteritems() if k in skulinux}
    for _, v in reservedLinuxDict.items():
        price = filter(lambda x:
                       x["termAttributes"]["LeaseContractLength"] == "1yr" and
                       x["termAttributes"]["PurchaseOption"] == "No Upfront",
                       v.values())
        if len(price) == 0:
            hourlyCost.LinuxReserved = makeValueWithUnit(0, "USD")
        else:
            hourlyCost.LinuxReserved = makeValueWithUnit(float(price[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]), "USD")

    windowsProductList = filter(lambda x:
                                x["attributes"]["operatingSystem"] == "Windows" and
                                x["attributes"]["instanceType"] == instanceType and
                                x["attributes"]["tenancy"] == "Shared" and
                                x["attributes"]["licenseModel"] == "License Included" and
                                x["attributes"]["preInstalledSw"] == "NA",
                                products.values())

    skuWindows = map(lambda x: x["sku"], windowsProductList)
    if len(skuWindows) == 0:
        hourlyCost.WindowsOnDemand = makeValueWithUnit(0, "USD")
    else:
        hourlyCost.WindowsOnDemand = makeValueWithUnit(float(onDemandPricing[skuWindows[0]].values()[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]), "USD")
    reservedWindowsDict = {k: v for k, v in reservedPricing.iteritems() if k in skuWindows}
    for _, v in reservedWindowsDict.items():
        price = filter(lambda x:
                       x["termAttributes"]["LeaseContractLength"] == "1yr" and
                       x["termAttributes"]["PurchaseOption"] == "No Upfront",
                       v.values())
        if len(price) == 0:
            hourlyCost.WindowsReserved = makeValueWithUnit(0, "USD")
        else:
            hourlyCost.WindowsReserved = makeValueWithUnit(float(price[0]["priceDimensions"].values()[0]["pricePerUnit"]["USD"]), "USD")

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
                        default="ALL",
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
    regions = []
    if args.region == "ALL":
        regions = json.load(urllib2.urlopen(AWS_PRICING_API_BASE_URL + AWS_PRICING_API_REGION_INDEX))["regions"].keys()
    else:
        regions.append(args.region)

    print regions
    for region in regions:
        grab(region)
        result = compose(region)
        try:
            updateDB(args.conn, region, result)
        except Exception as e:
            print "Error: {}".format(e)
            sys.exit()
        with open("{}-{}".format(region, args.output), "w") as dumpFile:
            dumpFile.write(json.dumps(json.loads(result.__str__()), indent=4))
