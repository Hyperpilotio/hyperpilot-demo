#!/bin/bash

ls templates/*.json | cut -d"/" -f2 | cut -d"." -f1 | xargs -I{} curl -XPOST $1:7777/v1/templates/{} --data-binary @templates/{}.json
