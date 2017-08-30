#!/usr/bin/env python
"""
Add components to targeting template.

Assumptions:
    1. Have m nodes. Only run container (kind: deployment) on m - 1 nodes except the node with id 1.
    2. Running DaemonSet (kind: daemonset) container on every node.
    3. container name is consistent in the definition
        (components/[AGENT].json and the flag (ex:--[AGENT] true))
"""

import argparse
import json
import os
import sys

DEFAULT_COMPONENT_DIR = 'components'
FILE_NAME_PREFIX = 'modified-'

# NOTE Make sure the name of container is consistent in the components/[AGENT].json and here
AGENT_MAP = {
    'dd': {
        'name': 'dd',
        'type': 'daemonset'
    },
    'benchmark': {
        'name': 'benchmark',
        'type': 'deployment'
    },
    'snap': {
        'name': 'snap',
        'type': 'deployment'
    }
}

parser = argparse.ArgumentParser(description='Generate a template for deployment with additional components.')

# FIXME not an optional parameter
parser.add_argument('--template', dest='template',
                    type=str, help='The template')
parser.add_argument('--benchmark', dest='benchmark', nargs='?',
                    type=bool, help='Add benchmark-agent')
parser.add_argument('--snap', dest='snap', nargs='?',
                    type=bool, help='Add snap-agent')
parser.add_argument('--dd', dest='dd', nargs='?',
                    type=bool, help='Add datadog\'s agent: dd-agent')



def file_name(component=''):
    """
    Return the input string with suffix '-agent'
    """
    return '{}-agent.json'.format(component)

def add_component(template_path='', targeting_template_path='', components=[]):
    with open(template_path, 'r') as template_json:
        template_data = json.load(template_json)
    for component in components:
        if component['type'] == 'deployment':
            add_container_component(template_data=template_data, component=component['name'])
        elif component['type'] == 'daemonset':
            add_daemonset_component(template_data=template_data, component=component['name'])
    with open(targeting_template_path, 'w') as targeting_template:
        json.dump(template_data, targeting_template, indent=4)


def add_container_component(template_data={}, component=''):
    """
    Read the definition of component from json file and
    add it into the template.
    """
    path = os.path.join(DEFAULT_COMPONENT_DIR, file_name(component))
    if os.path.isfile(path):
        for i in range(1, len(template_data['clusterDefinition']['nodes'])):
            template_data['nodeMapping'].append({
                "task": '{}-agent'.format(component),
                "id": i + 1
            })
        with open(path, 'r') as component_def:
            component_dic = json.load(component_def)
            template_data['kubernetes']['taskDefinitions'].append(component_dic)


def add_daemonset_component(template_data={}, component=''):
    """
    Read the definition of DaemonSet from json file and
    add it into the template.
    """
    path = os.path.join(DEFAULT_COMPONENT_DIR, file_name(component))
    if os.path.isfile(path):
        component_dic = {}
        with open(path, 'r') as component_def:
            component_dic = json.load(component_def)
            template_data['kubernetes']['taskDefinitions'].append(component_dic)


def main():
    """
    Main function
    """
    args = parser.parse_args()

    template_path = os.path.join(args.template)
    targeting_template = os.path.basename(args.template)
    targeting_template_path = os.path.join('{}{}'.format(FILE_NAME_PREFIX, os.path.basename(args.template)))
    if os.path.isfile(template_path):
        components = []
        if args.dd:
            components.append(AGENT_MAP['dd'])
        if args.snap:
            components.append(AGENT_MAP['snap'])
        if args.benchmark:
            components.append(AGENT_MAP['benchmark'])
        add_component(
            template_path=template_path,
            targeting_template_path=targeting_template_path,
            components=components)
        print(targeting_template_path)
    else:
        print('--template is missing or the value is invalid')
        sys.exit(1)


main()
