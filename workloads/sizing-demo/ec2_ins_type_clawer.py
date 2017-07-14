"""EC2 Instance Type Clawer."""
from objdict import ObjDict
import urllib2
import json
import argparse

AWS_REGION = "us-east-1"
OUTPUT_FILE_NAME = "nodetypes.json"


def grab(region):
    """grab."""
    response = urllib2.urlopen('http://www.ec2instances.info/instances.json')
    data = json.load(response)
    ec2_instances = ObjDict()
    ec2_instances.data = []
    for obj in data:
        if obj.get("pricing", {}).get(region) is None:
            continue
        ec2 = ObjDict()
        ec2.name = obj.get("instance_type")
        ec2.instanceFamily = obj.get("instance_type", "").split(".")[0]
        ec2.category = obj.get("family", "")
        ec2.hourlyCost = ObjDict()
        hourlyCostLinux = obj.get("pricing", {}).get(region, {}).get("linux", {})
        ec2.hourlyCost.LinuxOnDemand = hourlyCostLinux.get("ondemand", 0.0)
        ec2.hourlyCost.LinuxReserved = hourlyCostLinux.get("reserved", {}).get("yrTerm1Standard.allUpfront", 0.0)
        hourlyCostMsWin = obj.get("pricing", {}).get(region, {}).get("mswin", {})
        ec2.hourlyCost.WindowsOnDemand = hourlyCostMsWin.get("ondemand", 0.0)
        ec2.hourlyCost.WindowsReserved = hourlyCostMsWin.get("reserved", {}).get("yrTerm1Standard.allUpfront", 0.0)
        ec2.cpuConfig = ObjDict()
        ec2.cpuConfig.vCPU = obj.get("vCPU", 0)
        ec2.cpuConfig.cpuCredits = ""
        ec2.cpuConfig.cpuType = ""
        ec2.cpuConfig.clockSpeed = ""
        ec2.memoryConfig = ObjDict()
        ec2.memoryConfig.size = obj.get("memory", 0)
        ec2.networkConfig = ObjDict()
        ec2.networkConfig.performance = obj.get("network_performance", 0)
        ec2.networkConfig.bandwidth = 0
        ec2.networkConfig.clusterNetworking = ""
        ec2.storageConfig = ObjDict()

        if obj.get("storage") is None:
            storageType = "EBS Only"
        else:
            storage = obj.get("storage", {})
            storageType = "{} GB".format(storage.get("size", 0) * storage.get("devices", 0))
            if storage.get("devices", 0) > 1:
                storageType += "( {} * {} GB)".format(
                    storage.get("devices", 0),
                    storage.get("size", 0))
            if storage.get("includes_swap_partition", False):
                storageType += " + 900M swap"
            if storage.get("nvme_ssd", False):
                storageType += " NVMe"
            if storage.get("ssd", False):
                storageType += " SSD"
            else:
                storageType += " HDD"
        ec2.storageConfig.storageType = storageType
        ec2.storageConfig.bandwidth = obj.get("ebs_max_bandwidth")
        ec2_instances.data.append(ec2)
    return ec2_instances


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", type=str, required=False, dest="region", default=AWS_REGION, help="set aws-region, default is {}".format(AWS_REGION))
    parser.add_argument("-o", type=str, required=False, dest="output", default=OUTPUT_FILE_NAME, help="set output file name")
    args = parser.parse_args()
    with open(args.output, "w") as dumpFile:
        dumpFile.write(json.dumps(json.loads(grab(args.region).__str__()), indent=4))
