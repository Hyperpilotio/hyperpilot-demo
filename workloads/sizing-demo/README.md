# EC2 Instance Type Clawer

get EC2 instance type details

## USAGE

```
python ec2_ins_type_clawer.py --help
```

## ARGUMENTS
|Name|Default|Description|
|----|----|----|
|-r|us-east-1|set aws-region you want to query|
|-o|nodetypes.json|set output file name|
|--mongo-url|mongodb://localhost:27017|mongoDB connection url, for example: --mongo-url=mongodb://user:password@localhost:27017|

## OUTPUT

```
{
    "_id": {
        "$oid": "596c583c6d704195160ff4c0"
    },
    "data": [
        {
            "name": "m1.small",
            "instanceFamily": "m1",
            "category": "General purpose",
            "hourlyCost": {
                "LinuxOnDemand": "0.044",
                "LinuxReserved": "0.024",
                "WindowsOnDemand": "0.075",
                "WindowsReserved": "0.048"
            },
            "cpuConfig": {
                "vCPU": 1,
                "cpuCredits": "",
                "cpuType": "",
                "clockSpeed": ""
            },
            "memoryConfig": {
                "size": 1.7
            },
            "networkConfig": {
                "performance": "Low",
                "bandwidth": 0,
                "clusterNetworking": ""
            },
            "storageConfig": {
                "storageType": "160 GB + 900M swap HDD",
                "bandwidth": 0
            }
        },
        {
            "name": "m1.medium",
            "instanceFamily": "m1",
            "category": "General purpose",
            "hourlyCost": {
                "LinuxOnDemand": "0.087",
                "LinuxReserved": "0.047",
                "WindowsOnDemand": "0.149",
                "WindowsReserved": "0.096"
            },
            "cpuConfig": {
                "vCPU": 1,
                "cpuCredits": "",
                "cpuType": "",
                "clockSpeed": ""
            },
            "memoryConfig": {
                "size": 3.75
            },
            "networkConfig": {
                "performance": "Moderate",
                "bandwidth": 0,
                "clusterNetworking": ""
            },
            "storageConfig": {
                "storageType": "410 GB HDD",
                "bandwidth": 0
            }
        }
    ],
    "region": "us-east-1"
}
```
