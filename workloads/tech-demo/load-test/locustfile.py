import datetime
import json
import random

from locust import HttpLocust, TaskSet, task

LOCATIONS = ["SESTO", "AUMEL", "CNHKG", "JNTKO", "NLRTM", "DEHAM" ]

class StaticTasks(TaskSet):

    def pick_random_location(self):
        return LOCATIONS[random.randint(0, 5)]

    @task
    def book_new_cargo(self):
        add_days = random.randint(0, 15)
        deadline = datetime.datetime.utcnow() + datetime.timedelta(days=add_days)

        data = {
            "origin": self.pick_random_location(),
            "destination": self.pick_random_location(),
            "arrival_deadline": deadline.isoformat() + "Z"
        }

        self.client.post("/booking/v1/cargos", data=json.dumps(data))

    def route_cargo(self, *args):
        tracking_id = ''.join(args)
        response = self.client.get("/booking/v1/cargos/" + tracking_id + "/request_routes")
        if response.content == "":
            response.failure("No data")
            return
        routes = json.loads(response.content)
        if "routes" not in routes:
            return

        routes_count = len(routes['routes'])
        if routes_count == 0:
            return

        route = random.randint(0, routes_count - 1)
        self.client.post("/booking/v1/cargos/" + tracking_id + "/assign_to_route", data=json.dumps(routes['routes'][route]))

    @task
    def schedule_routing_cargos(self):
        response = self.client.get("/booking/v1/cargos")
        if response.content == "":
            response.failure("No data")
            return
        cargos = json.loads(response.content)
        for cargo in cargos["cargos"]:
            if cargo['routed'] is False:
                self.schedule_task(self.route_cargo, cargo['tracking_id'])

    @task
    def list_cargos(self):
        self.client.get("/booking/v1/cargos")

    @task
    def list_locations(self):
        self.client.get("/booking/v1/locations")

class LoggedInUser(HttpLocust):
    task_set = StaticTasks
