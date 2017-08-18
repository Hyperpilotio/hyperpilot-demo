curl -XPOST $1:7777/v1/templates/analysis-base --data-binary @templates/analysis-base.json
curl -XPOST $1:7777/v1/templates/memory-optimize --data-binary @templates/memory-optimize-with-benchmark-controller.json
curl -XPOST $1:7777/v1/templates/analysis-base-3-nodes --data-binary @templates/analysis-base-3-nodes.json
