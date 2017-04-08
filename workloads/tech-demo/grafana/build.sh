#!/usr/bin/env bash

export GOOS=linux
export GOARCH=amd64
go build -o config-ds
sudo docker build -t hyperpilot/tech-demo-grafana .
