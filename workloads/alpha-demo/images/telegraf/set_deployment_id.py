"""Read Deployment ID from node label."""
from kubernetes import client, config
import sys
import errno

if __name__ == '__main__':
    try:
        config.load_incluster_config()
        nodes = client.CoreV1Api().list_node()
        if len(nodes.items) > 0:
            print nodes.items[0].metadata.labels.get("hyperpilot/deployment", "")
    except:
        print "this container cannot run outside k8s."
        sys.exit(errno.EPERM)
