#!/bin/sh

export GOOS=linux
export GOARCH=amd64
go build -o config-ds
docker build -t adrianliaw/grafana:hyperpilot .
