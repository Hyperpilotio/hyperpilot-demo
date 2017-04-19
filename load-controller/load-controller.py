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
from os import curdir, sep

#globals
terminator = None
swarm_controller = None

class Terminator:
  def __init__(self, httpd):
    signal.signal(signal.SIGINT, self.exit)
    signal.signal(signal.SIGTERM, self.exit)
    self.kill_now = False
    self.httpd = httpd

  def exit(self, signum, frame):
    print "Signal received, exiting"

    # Send Locust stop request
    swarm_controller.stop()

    url = 'http://{}:{}/stop'.format(swarm_controller.hl_config.master_host, swarm_controller.hl_config.master_port)
    successful = False
    try_count = 0
    while not successful and try_count < 3:
        try_count += 1
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

class SwarmController:
    def __init__(self, hl_config):
        self.hl_config = hl_config

    def change_config(self,low_count, high_count, low_duration_seconds, high_duration_seconds):
        if low_count > 0:
            self.hl_config.low_count = low_count
        if high_count > 0:
            self.hl_config.high_count = high_count
        if low_duration_seconds > 0:
            self.hl_config.low_duration_seconds = low_duration_seconds
        if high_duration_seconds > 0:
            self.hl_config.high_duration_seconds = high_duration_seconds
        print("Restarting swarm")
        self.hl_config.s_thread.done = True
        self.hl_config.s_thread.join()
        self.run(hl_config)

    def stop(self):
        if self.s_thread is not None:
            self.s_thread.done = True
            self.s_thread.join()
            self.s_thread = None

    def change_config(self, new_config):
        self.stop()
        self.run(new_config)

    def run(self, new_config):
        self.s_thread = SwarmThread(new_config)
        self.s_thread.daemon = True
        self.s_thread.start()

class SwarmThread(threading.Thread):
    def __init__(self, hl_config):
        threading.Thread.__init__(self)
        self.hl_config = hl_config
    def run(self):
        is_low_count = True
        self.done = False
        while not self.done:
            if is_low_count:
                print "Setting swarm to low count %d, hatch rate %d " % (self.hl_config.low_count, self.hl_config.low_hatch_rate)
                self.hl_config.swarm(self.hl_config.low_count, self.hl_config.low_hatch_rate)
                print "Sleeping for " + str(self.hl_config.low_duration_seconds) + " seconds"
                self.wait(self.hl_config.low_duration_seconds)
            else: # high_count
                print "Setting swarm to high count %d, hatch rate %d " % (self.hl_config.high_count, self.hl_config.high_hatch_rate)
                self.hl_config.swarm(self.hl_config.high_count, self.hl_config.high_hatch_rate)
                print "Sleeping for " + str(self.hl_config.high_duration_seconds) + " seconds"
                self.wait(self.hl_config.high_duration_seconds)
            is_low_count = not is_low_count

    def wait(self, duration):
        start = time.time()
        while not self.done:
            if (time.time() - start > duration):
                break
            time.sleep(0.05)

class HiLoLoadConfiguration(object):
    def __init__(self, master_host, master_port, run_id, \
                 low_count, low_hatch_rate, low_duration_seconds, \
                 high_count, high_hatch_rate, high_duration_seconds):
        self.master_host = master_host
        self.master_port = master_port
        self.run_id = run_id
        self.low_count = low_count
        self.low_hatch_rate = low_hatch_rate
        self.low_duration_seconds = low_duration_seconds
        self.high_count = high_count
        self.high_hatch_rate = high_hatch_rate
        self.high_duration_seconds = high_duration_seconds

    @staticmethod
    def parse(master_host, master_port, run_id, dct):
        low_count = int(dct['low_count'])
        low_hatch_rate = low_count
        if 'low_hatch_rate' in dct:
          low_hatch_rate = int(dct['low_hatch_rate'])

        low_duration_seconds = int(dct['low_duration_seconds'])
        high_count = int(dct['high_count'])
        high_hatch_rate = high_count
        if 'high_hatch_rate' in dct:
          high_hatch_rate = int(dct['high_hatch_rate'])

        high_duration_seconds = int(dct['high_duration_seconds'])

        return HiLoLoadConfiguration(master_host, master_port, run_id, \
                                     low_count, low_hatch_rate, low_duration_seconds, \
                                     high_count, high_hatch_rate, high_duration_seconds)

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

def start_server(httpd):
    print('Starting httpd...')
    httpd.serve_forever()

class LoadRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        sendReply = False
        if self.path == "/":
            self.path="/loadUI.html"
            f=open(curdir + sep + self.path)
            mimetype = 'text/html'
            self.send_header('Content-type', mimetype)
            self.end_headers()
            self.wfile.write(f.read())
            f.close()
        self.send_response(200)

            
    def log_message(self, format, *args):
        # so that terminal doesn't get flooded with server requests
        return

    def do_POST(self):
        # Doesn't do anything with posted data
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length) # <--- Gets the data itself

        # Changing config
        if swarm_controller.hl_config is None:
            print "Cannot find config in swarm controller during change"
            self.send_response(500)
            return

        data = json.loads(post_data)
        running_config = swarm_controller.hl_config
        try:
          new_config = parse_load_configuration(running_config.master_host, \
                                                running_config.master_port, \
                                                running_config.run_id, data)

          print("Restarting swarm")
          swarm_controller.change_config(new_config)
          self.send_response(200)
        except Exception as e:
          print "Unable to parse new config",  e
          self.send_response(400)
          return

def main():
    # Initialize
    server_address = ('', 8001)
    httpd = HTTPServer(server_address, LoadRequestHandler)
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
        global swarm_controller
        swarm_controller = SwarmController(load_configuration)
        swarm_controller.run(load_configuration)
    while True:
        time.sleep(1)
        if terminator.kill_now:
            httpd.shutdown()
            break
    print("\nProgram exited")

if __name__ == '__main__':
    main()