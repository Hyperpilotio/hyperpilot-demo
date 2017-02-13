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
```

