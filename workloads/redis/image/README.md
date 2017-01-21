## POST /api/benchmark

Payload

```{json}
{
	"name": "redis-test",
	"workflow": ["run"],
	"commandSet": {
		"run": {
			"name": "load-testing",
			"binPath": "/usr/bin/redis-benchmark",
			"args": ["-h", "redis-serve", "-p", "6379", "--csv", "-n", "100"],
			"type": "run"
		}
	}
}
```

Response

```{json}
{
  "PING_INLINE": "11111.11",
  "PING_BULK": "14285.71",
  "SET": "20000.00",
  "GET": "14285.71",
  "INCR": "20000.00",
  "LPUSH": "16666.67",
  "LPOP": "20000.00",
  "SADD": "16666.67",
  "SPOP": "16666.67",
  "LPUSH (needed to benchmark LRANGE)": "25000.00",
  "LRANGE_100 (first 100 elements)": "20000.00",
  "LRANGE_300 (first 300 elements)": "16666.67",
  "LRANGE_500 (first 450 elements)": "20000.00",
  "LRANGE_600 (first 600 elements)": "14285.71",
  "MSET (10 keys)": "16666.67"
}
```
