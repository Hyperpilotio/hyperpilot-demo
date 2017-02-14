# goddd API

## List cargos

GET /booking/v1/cargos

Response

```[json]
{
    "cargos": [
        {
            "arrival_deadline": "2017-02-20T19:22:01.984682685Z",
            "destination": "SESTO",
            "misrouted": false,
            "origin": "AUMEL",
            "routed": false,
            "tracking_id": "FTL456"
        },
        {
            "arrival_deadline": "2017-02-27T19:22:01.9860385Z",
            "destination": "CNHKG",
            "misrouted": false,
            "origin": "SESTO",
            "routed": false,
            "tracking_id": "ABC123"
        }
    ]
}
```

=======

## Book new cargo

POST /booking/v1/cargos

Payload
```{json}
{"origin": "SESTO", "destination": "FIHEL", "arrival_deadline": "2016-03-21T19:50:24Z"}
```

Response
```{json}
{
    "tracking_id": "7AC23408"
}
```

======

## Request possible routes for sample cargo 7AC23408

GET /booking/v1/cargos/7AC23408/request_routes

Response
```{json}
{
    "routes": [
        {
            "legs": [
                {
                    "voyage_number": "0400S",
                    "from": "SESTO",
                    "to": "USDAL",
                    "load_time": "2017-02-16T23:13:25.139536612Z",
                    "unload_time": "2017-02-17T19:33:25.139536612Z"
                },
                {
                    "voyage_number": "0400S",
                    "from": "USDAL",
                    "to": "CNHGH",
                    "load_time": "2017-02-19T11:24:25.139536612Z",
                    "unload_time": "2017-02-20T18:18:25.139536612Z"
                },
                {
                    "voyage_number": "0400S",
                    "from": "CNHGH",
                    "to": "USCHI",
                    "load_time": "2017-02-22T04:58:25.139536612Z",
                    "unload_time": "2017-02-23T02:02:25.139536612Z"
                },
                {
                    "voyage_number": "0200T",
                    "from": "USCHI",
                    "to": "USNYC",
                    "load_time": "2017-02-25T09:52:25.139536612Z",
                    "unload_time": "2017-02-26T16:42:25.139536612Z"
                },
                {
                    "voyage_number": "0301S",
                    "from": "USNYC",
                    "to": "FIHEL",
                    "load_time": "2017-02-28T20:17:25.139536612Z",
                    "unload_time": "2017-03-01T12:14:25.139536612Z"
                }
            ]
        },
        {
            "legs": [
                {
                    "voyage_number": "0100S",
                    "from": "SESTO",
                    "to": "JNTKO",
                    "load_time": "2017-02-17T02:13:25.13954795Z",
                    "unload_time": "2017-02-18T02:04:25.13954795Z"
                },
                {
                    "voyage_number": "0300A",
                    "from": "JNTKO",
                    "to": "USNYC",
                    "load_time": "2017-02-20T10:22:25.13954795Z",
                    "unload_time": "2017-02-21T14:05:25.13954795Z"
                },
                {
                    "voyage_number": "0200T",
                    "from": "USNYC",
                    "to": "CNSHA",
                    "load_time": "2017-02-23T04:18:25.13954795Z",
                    "unload_time": "2017-02-23T21:17:25.13954795Z"
                },
                {
                    "voyage_number": "0300A",
                    "from": "CNSHA",
                    "to": "SEGOT",
                    "load_time": "2017-02-25T10:06:25.13954795Z",
                    "unload_time": "2017-02-26T12:20:25.13954795Z"
                },
                {
                    "voyage_number": "0300A",
                    "from": "SEGOT",
                    "to": "DEHAM",
                    "load_time": "2017-02-28T11:17:25.13954795Z",
                    "unload_time": "2017-03-01T15:55:25.13954795Z"
                },
                {
                    "voyage_number": "0301S",
                    "from": "DEHAM",
                    "to": "FIHEL",
                    "load_time": "2017-03-03T03:02:25.13954795Z",
                    "unload_time": "2017-03-03T21:46:25.13954795Z"
                }
            ]
        },
        {
            "legs": [
                {
                    "voyage_number": "0301S",
                    "from": "SESTO",
                    "to": "CNHGH",
                    "load_time": "2017-02-16T23:58:25.13955379Z",
                    "unload_time": "2017-02-17T20:32:25.13955379Z"
                },
                {
                    "voyage_number": "0300A",
                    "from": "CNHGH",
                    "to": "USNYC",
                    "load_time": "2017-02-20T10:05:25.13955379Z",
                    "unload_time": "2017-02-21T15:49:25.13955379Z"
                },
                {
                    "voyage_number": "0200T",
                    "from": "USNYC",
                    "to": "USDAL",
                    "load_time": "2017-02-23T13:07:25.13955379Z",
                    "unload_time": "2017-02-24T16:42:25.13955379Z"
                },
                {
                    "voyage_number": "0400S",
                    "from": "USDAL",
                    "to": "DEHAM",
                    "load_time": "2017-02-26T19:14:25.13955379Z",
                    "unload_time": "2017-02-27T23:31:25.13955379Z"
                },
                {
                    "voyage_number": "0301S",
                    "from": "DEHAM",
                    "to": "FIHEL",
                    "load_time": "2017-03-01T20:58:25.13955379Z",
                    "unload_time": "2017-03-03T03:15:25.13955379Z"
                }
            ]
        },
        {
            "legs": [
                {
                    "voyage_number": "0100S",
                    "from": "SESTO",
                    "to": "USDAL",
                    "load_time": "2017-02-16T22:01:25.139564092Z",
                    "unload_time": "2017-02-18T04:53:25.139564092Z"
                },
                {
                    "voyage_number": "0100S",
                    "from": "USDAL",
                    "to": "FIHEL",
                    "load_time": "2017-02-20T18:22:25.139564092Z",
                    "unload_time": "2017-02-21T17:49:25.139564092Z"
                }
            ]
        }
    ]
}
```

=======

## List available locations

GET /booking/v1/locations

Response
```{json}
{
    "locations": [
    {
                "locode": "NLRTM",
                "name": "Rotterdam"
    },
    {
                "locode": "DEHAM",
                "name": "Hamburg"
    },
    {
                "locode": "SESTO",
                "name": "Stockholm"
    },
    {
                "locode": "AUMEL",
                "name": "Melbourne"
    },
    {
                "locode": "CNHKG",
                "name": "Hongkong"
    },
    {
                "locode": "JNTKO",
                "name": "Tokyo"
    }
    ]

}
```
