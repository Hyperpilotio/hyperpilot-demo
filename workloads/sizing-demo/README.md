# EC2 Instance Type Crawler

get EC2 instance type details

## USAGE

```
python ec2_ins_type_crawler.py --help
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
            "name": "d2.2xlarge",
            "instanceFamily": "Storage optimized",
            "hourlyCost": {
                "LinuxOnDemand": {
                    "value": 1.38,
                    "unit": "USD"
                },
                "LinuxReserved": {
                    "value": 0.804,
                    "unit": "USD"
                },
                "WindowsOnDemand": {
                    "value": 1.601,
                    "unit": "USD"
                },
                "WindowsReserved": {
                    "value": 0.885,
                    "unit": "USD"
                }
            },
            "cpuConfig": {
                "vCPU": 8,
                "ecu": 104,
                "cpuCredits": {},
                "cpuType": "Intel Xeon E5-2676v3 (Haswell)",
                "clockSpeed": {
                    "value": 2.4,
                    "unit": "GHz"
                }
            },
            "memoryConfig": {
                "size": {
                    "value": 61,
                    "unit": "GiB"
                }
            },
            "networkConfig": {
                "performance": "High",
                "clusterNetworking": true,
                "enhancedNetworking": true
            },
            "storageConfig": {
                "devices": 6,
                "size": {
                    "value": 2000,
                    "unit": "GB"
                },
                "storageType": "HDD",
                "EBSOptimized": "Yes",
                "maxBandwidth": {
                    "value": 1000,
                    "unit": "Mbps"
                },
                "expectedThroughput": {
                    "value": 125,
                    "unit": "MB/s"
                },
                "maxIOPS": {
                    "value": 8000,
                    "unit": "16KB I/O size"
                }
            }
        }
    ],
    "region": "us-east-1"
}
```
