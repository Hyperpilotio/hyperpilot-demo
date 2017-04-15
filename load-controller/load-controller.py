import json
import sys
import time
import uuid
import requests
import urllib
import signal
import threading

from optparse import OptionParser
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

class Terminator:
  def __init__(self, httpd):
    signal.signal(signal.SIGINT, self.exit)
    signal.signal(signal.SIGTERM, self.exit)
    self.kill_now = False
    self.httpd = httpd

  def exit(self, signum, frame):
    # Send Locust Stop request
    swarmController.hlConfig.sThread.done = True
    url = 'http://{}:{}/stop'.format(swarmController.hlConfig.master_host, swarmController.hlConfig.master_port)
    
    successful = False
    tryCount = 0
    while not successful and tryCount < 3:
        tryCount += 1
        try:
            r = requests.get(url)
            if r.status_code == requests.codes.ok or r.status_code == requests.codes.accepted:
                successful = True
            else:
                print("Received unexpected error code " + str(r.status_code))
        except requests.ConnectionError as e:
            print "Encountered error when posting to locust master: " + str(e)
        if not successful:
            print "Waiting 2 seconds before retry..."
            time.sleep(2)
            print "Retrying request..."
    self.kill_now = True

terminator = None

class SwarmController:
    def __init__(self):
        pass

    def set_config(self, newConfig):
        self.hlConfig = newConfig

    def change_config(self,low_count, high_count, low_duration_seconds, high_duration_seconds):
        if low_count > 0:
            self.hlConfig.low_count = low_count
        if high_count > 0:
            self.hlConfig.high_count = high_count
        if low_duration_seconds > 0:
            self.hlConfig.low_duration_seconds = low_duration_seconds
        if high_duration_seconds > 0:
            self.hlConfig.high_duration_seconds = high_duration_seconds
        self.hlConfig.sThread.done = True
        self.hlConfig.sThread.join()
        self.hlConfig.run()

    def start_swarm(self):
        self.hlConfig.run()

    def stop_swarm(self):
        self.hlConfig.sThread.done = True

swarmController = SwarmController()

class SwarmThread(threading.Thread):
    def __init__(self, hlConfig):
        threading.Thread.__init__(self)
        self.hlConfig = hlConfig
        self.done = False

    def run(self):
        is_low_count = True
        self.done = False
        while not self.done:
            if is_low_count:
                print("Setting swarm to low count " + str(self.hlConfig.low_count))
                self.hlConfig.swarm(self.hlConfig.low_count, self.hlConfig.low_count)
                print("Sleeping for " + str(self.hlConfig.low_duration_seconds) + " seconds")
                wait(self.hlConfig.sThread, self.hlConfig.low_duration_seconds)
            else: # high_count
                print("Setting swarm to high count " + str(self.hlConfig.high_count))
                self.hlConfig.swarm(self.hlConfig.high_count, self.hlConfig.low_count)
                print("Sleeping for " + str(self.hlConfig.high_duration_seconds) + " seconds")
                wait(self.hlConfig.sThread, self.hlConfig.high_duration_seconds)
            is_low_count = not is_low_count




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
        self.sThread = SwarmThread(self)
        self.sThread.daemon = True
        self.sThread.start()


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
    if url.find("://") == -1:
        return url
    local_path = url.split("/")[-1]
    print("Downloading file " + url + " to " + local_path)
    urllib.urlretrieve(url, local_path)
    return local_path

def wait(sThread, duration):
    start = time.time()
    while not sThread.done:
        time.sleep(0.05)
        if (time.time() - start > duration):
            break

class S(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        # so that terminal doesn't get flooded with server requests
        return

    def do_POST(self):
        # Doesn't do anything with posted data
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length) # <--- Gets the data itself
        if post_data == "exit":
            self.send_response(200)
            terminator.exit(None, None)
            return
        data = json.loads(post_data)
        configChanged = False
        low_count = -1
        high_count = -1
        low_duration_seconds = -1
        high_duration_seconds = -1
        if 'low_count' in data:
            low_count = int(data['low_count'])
            configChanged = True
        if 'low_duration_seconds' in data:
            low_duration_seconds = int(data['low_duration_seconds'])
            configChanged = True
        if 'high_count' in data:
            high_count = int(data['high_count'])
            configChanged = True
        if 'high_duration_seconds' in data:
            high_duration_seconds = int(data['high_duration_seconds'])
            configChanged = True
        if configChanged:
            print("Restarting swarm")
            swarmController.change_config(low_count, high_count, 
                low_duration_seconds, high_duration_seconds)
        self.send_response(200)

def start_server(httpd):
    print('Starting httpd...')
    httpd.serve_forever()

def main():
    # Initialize
    server_address = ('', 8001)
    httpd = HTTPServer(server_address, S)
    t = threading.Thread(target=start_server, args = (httpd,))
    t.daemon = True
    t.start()
    global terminator
    terminator = Terminator(httpd)
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
        swarmController.set_config(load_configuration)
        swarmController.start_swarm()
    while True:
        time.sleep(1)
        if terminator.kill_now:
            httpd.shutdown()
            break
    print("\nProgram exited")

if __name__ == '__main__':
    main()