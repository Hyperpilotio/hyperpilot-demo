# Benchmark

## POST /api/benchmark

```{json}
{
    "name": "cassandra",
    "region": "us-east-1",
    "allowedPorts": [8083, 8086, 7777, 7778, 8089, 6001, 7000, 7001, 7199, 8012, 9042, 9160, 61621],
    "nodeMapping": [
        {
            "task": "cassandra-serve",
            "id": 1
        },
        {
            "task": "monitor",
            "id": 2
        },
        {
            "task": "snap",
            "id": 1
        },
        {
            "task": "cassandra-bench",
            "id": 2
        }
    ],
    "clusterDefinition": {
        "nodes": [
            {
                "instanceType": "t2.medium",
                "id": 1
            },
            {
                "instanceType": "t2.medium",
                "id": 2
            }
        ]
    },
    "taskDefinitions": [
        {
            "volumes": [
                {
                    "host": {
                        "sourcePath": "\/"
                    },
                    "name": "root"
                },
                {
                    "host": {
                        "sourcePath": "\/var\/run"
                    },
                    "name": "var_run"
                },
                {
                    "host": {
                        "sourcePath": "\/var\/log"
                    },
                    "name": "var_log"
                },
                {
                    "host": {
                        "sourcePath": "\/sys"
                    },
                    "name": "sys"
                },
                {
                    "host": {
                        "sourcePath": "\/var\/lib\/docker\/"
                    },
                    "name": "var_lib_docker"
                },
                {
                    "host": {
                        "sourcePath": "\/cgroup"
                    },
                    "name": "cgroup"
                }
            ],
            "containerDefinitions": [
                {
                    "mountPoints": [
                        {
                            "readOnly": true,
                            "containerPath": "\/rootfs",
                            "sourceVolume": "root"
                        },
                        {
                            "readOnly": false,
                            "containerPath": "\/var\/run",
                            "sourceVolume": "var_run"
                        },
                        {
                            "readOnly": false,
                            "containerPath": "\/var\/log",
                            "sourceVolume": "var_log"
                        },
                        {
                            "readOnly": true,
                            "containerPath": "\/sys",
                            "sourceVolume": "sys"
                        },
                        {
                            "readOnly": true,
                            "containerPath": "\/sys\/fs\/cgroup",
                            "sourceVolume": "cgroup"
                        },
                        {
                            "readOnly": true,
                            "containerPath": "\/var\/lib\/docker",
                            "sourceVolume": "var_lib_docker"
                        }
                    ],
                    "essential": true,
                    "memory": 200,
                    "cpu": 128,
                    "image": "wen777\/snap:alpine",
                    "name": "snap"
                }
            ],
            "family": "snap"
        },
        {
            "volumes": [],
            "containerDefinitions": [
                {
                    "environment": [
                        {
                            "value": "snap",
                            "name": "PRE_CREATE_DB"
                        },
                        {
                            "value": "root",
                            "name": "ADMIN_USER"
                        },
                        {
                            "value": "hyperpilot",
                            "name": "INFLUXDB_INIT_PWD"
                        }
                    ],
                    "essential": true,
                    "portMappings": [
                        {
                            "hostPort": 8083,
                            "containerPort": 8083
                        },
                        {
                            "hostPort": 8086,
                            "containerPort": 8086
                        }
                    ],
                    "memory": 300,
                    "cpu": 512,
                    "image": "tutum\/influxdb",
                    "name": "influxsrv"
                },
                {
                    "environment": [
                        {
                            "value": "localhost",
                            "name": "INFLUXDB_HOST"
                        },
                        {
                            "value": "8086",
                            "name": "INFLUXDB_PORT"
                        },
                        {
                            "value": "snap",
                            "name": "INFLUXDB_NAME"
                        },
                        {
                            "value": "grafana-clock-panel,grafana-piechart-panel",
                            "name": "GF_INSTALL_PLUGINS"
                        },
                        {
                            "value": "root",
                            "name": "INFLUXDB_USER"
                        },
                        {
                            "value": "hyperpilot",
                            "name": "INFLUXDB_PASS"
                        }
                    ],
                    "links": [
                        "influxsrv"
                    ],
                    "essential": true,
                    "portMappings": [
                        {
                            "hostPort": 3000,
                            "containerPort": 3000
                        }
                    ],
                    "memory": 300,
                    "cpu": 512,
                    "image": "grafana\/grafana",
                    "name": "grafana"
                }
            ],
            "family": "monitor"
        },
        {
            "volumes": [
                {
                    "host": {
                        "sourcePath": "\/var\/run\/docker.sock"
                    },
                    "name": "docker_sock"
                }
            ],
            "containerDefinitions": [
                {
                    "portMappings": [
                        {
                            "hostPort": 7199,
                            "containerPort": 7199
                        },
                        {
                            "hostPort": 7000,
                            "containerPort": 7000
                        },
                        {
                            "hostPort": 7001,
                            "containerPort": 7001
                        },
                        {
                            "hostPort": 9160,
                            "containerPort": 9160
                        },
                        {
                            "hostPort": 9042,
                            "containerPort": 9042
                        },
                        {
                            "hostPort": 8012,
                            "containerPort": 8012
                        },
                        {
                            "hostPort": 61621,
                            "containerPort": 61621
                        }
                    ],
                    "essential": true,
                    "memory": 3072,
                    "cpu": 1024,
                    "image": "wen777\/cassandra",
                    "name": "cassandra-serve"
                },
                {
                    "mountPoints": [
                        {
                            "containerPath": "\/var\/run\/docker.sock",
                            "sourceVolume": "docker_sock"
                        }
                    ],
                    "portMappings": [
                        {
                            "hostPort": 7778,
                            "containerPort": 7778
                        }
                    ],
                    "essential": true,
                    "memory": 50,
                    "cpu": 128,
                    "image": "hyperpilot\/benchmark-agent",
                    "name": "benchmark-agent"
                }
            ],
            "family": "cassandra-serve"
        },
        {
            "containerDefinitions": [
                {
                    "essential": true,
                    "portMappings": [
                        {
                            "hostPort": 6001,
                            "containerPort": 6001
                        }
                    ],
                    "memory": 1024,
                    "cpu": 1024,
                    "image": "wen777\/bench:cassandra",
                    "name": "cassandra-bench"
                }
            ],
            "family": "cassandra-bench"
        }
    ]
}
```
Sample input

```{json}
{
	"name": "cassandra-test",
	"workflow": ["run"],
	"commandSet": {
		"run": {
			"name": "load-testing",
			"binPath": "/usr/bin/cassandra-stress",
			"args": ["write", "n=1000000", "-rate", "threads=50", "-node", "cassandra-serve"],
			"type": "load-test"
		}
	},
    "measurement": "cassandra/benchmark"
}
```

Sample output

```{json}
{
  "op rate": "14671 [WRITE:14671]",
  "partition rate": "14671 [WRITE:14671]",
  "row rate": "14671 [WRITE:14671]",
  "latency mean": "3.4 [WRITE:3.4]",
  "latency median": "2.3 [WRITE:2.3]",
  "latency 95th percentile": "7.5 [WRITE:7.5]",
  "latency 99th percentile": "13.1 [WRITE:13.1]",
  "latency 99.9th percentile": "58.3 [WRITE:58.3]",
  "latency max": "289.5 [WRITE:289.5]",
  "Total partitions": "1000000 [WRITE:1000000]",
  "Total errors": "0 [WRITE:0]",
  "total gc count": "0",
  "total gc mb": "0",
  "total gc time (s)": "0",
  "avg gc time(ms)": "NaN",
  "stdev gc time(ms)": "0",
  "Total operation time": "00:01:08"
}
```
