import json
import sys
import time
import uuid
import requests
import urllib

from optparse import OptionParser

class HiLoLoadConfiguration(object):
    def __init__(self, master_host, master_port, run_id, low_count, low_duration_seconds, high_count, high_duration_seconds):
        self.master_host = master_host
        self.master_port = master_port
        self.run_id = run_id
        self.low_count = low_count
        self.low_duration_seconds = low_duration_seconds
        self.high_count = high_count
        self.high_duration_seconds = high_duration_seconds

    @staticmethod
    def parse(master_host, master_port, run_id, dct):
        low_count = int(dct['low_count'])
        low_duration_seconds = int(dct['low_duration_seconds'])
        high_count = int(dct['high_count'])
        high_duration_seconds = int(dct['high_duration_seconds'])
        return HiLoLoadConfiguration(master_host, master_port, run_id, low_count, low_duration_seconds, high_count, high_duration_seconds)

    def run(self):
        is_low_count = True
        done = False
        while not done:
            if is_low_count:
                print("Setting swarm to low count " + str(self.low_count))
                self.swarm(self.low_count, self.low_count)
                print("Sleeping for " + str(self.low_duration_seconds) + " seconds")
                time.sleep(self.low_duration_seconds)
                is_low_count = False
            else: # high_count
                print("Setting swarm to high count " + str(self.high_count))
                self.swarm(self.high_count, self.high_count)
                print("Sleeping for " + str(self.high_duration_seconds) + " seconds")
                time.sleep(self.high_duration_seconds)
                is_low_count = True

    # Extract this to base class once we have more load configuartions
    def swarm(self, locust_count, hatch_rate):
        data = {'locust_count': locust_count, 'hatch_rate': hatch_rate, 'stage_id': self.run_id}
        # Send Locust Swarm request
        url = 'http://{}:{}/swarm'.format(self.master_host, self.master_port)
        successful = False
        while not successful:
            try:
                r = requests.post(url, data=data)
                if r.status_code == requests.codes.ok or r.status_code == requests.codes.accepted:
                    successful = True
                else:
                    print("Received unexpected error code " + str(r.status_code))
            except requests.ConnectionError as e:
                print "Encountered error when posting to locust master: " + str(e)
            if not successful:
                print "Waiting 10 seconds before retry..."
                time.sleep(10)
                print "Retrying request..."


def parse_load_configuration(master_host, master_port, run_id, dct):
    load_type = dct['type']
    if load_type == 'hilo':
      return HiLoLoadConfiguration.parse(master_host, master_port, run_id, dct)
    else:
      print("Unsupported load type: " + load_type)
      sys.exit(1)

def download_url(url):
    local_path = url.split("/")[-1]
    print("Downloading file " + url + " to " + local_path)
    urllib.urlretrieve(url, local_path)
    return local_path

def main():
    # Initialize
    parser = OptionParser(usage="locust_load_controller [options]")

    parser.add_option(
        '--master-host',
        action='store',
        type='str',
        dest='master_host',
        default="127.0.0.1",
        help="Host or IP address of locust master"
    )

    parser.add_option(
        '--master-port',
        action='store',
        type='int',
        dest='master_port',
        default=8089,
        help="The port to connect to that is used by the locust master"
    )

    parser.add_option(
        '--load-file',
        action='store',
        type='str',
        dest='load_file',
        help="File to specifies load pattern"
    )

    opts, args = parser.parse_args()

    if not opts.load_file:
        print("Load file required")
        sys.exit(1)

    if not opts.master_host:
        print("Locust master host required")

    run_id = str(uuid.uuid1())

    local_load_file = download_url(opts.load_file)
    with open(local_load_file) as json_data:
        j = json.load(json_data)
        load_configuration = parse_load_configuration(opts.master_host, opts.master_port, run_id, j)
        load_configuration.run()

if __name__ == '__main__':
    main()
