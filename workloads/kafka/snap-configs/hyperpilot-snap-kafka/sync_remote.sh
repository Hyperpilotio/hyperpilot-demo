aws s3 sync . s3://hyperpilot-snap-kafka --acl public-read --exclude .DS_Store --exclude sync_remote.sh --delete
