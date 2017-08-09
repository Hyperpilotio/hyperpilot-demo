#!/usr/bin/env bash
curl -XPOST -H "Content-Type: application/json" http://$1:7779/calibrate/lucene -d "{}"
