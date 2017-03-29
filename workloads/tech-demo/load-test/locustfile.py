import datetime
import json
import random

from locust import HttpLocust, TaskSet, task

LOCATIONS = ["SESTO", "AUMEL", "CNHKG", "JNTKO", "NLRTM", "DEHAM" ]

class StaticTasks(TaskSet):
    def pick_random_location(self):
        return LOCATIONS[random.randint(0, 5)]

    @task(5)
    def book_new_cargo(self):
        add_days = random.randint(0, 15)
        deadline = datetime.datetime.utcnow() + datetime.timedelta(days=add_days)

        data = {
            "origin": self.pick_random_location(),
            "destination": self.pick_random_location(),
            "arrival_deadline": deadline.isoformat() + "Z"
        }

        self.client.post("/booking/v1/cargos", data=json.dumps(data))

    def delete_cargo(self, *args):
        tracking_id = ''.join(args)
        self.client.delete("/booking/v1/cargos/" + tracking_id)

    def route_cargo(self, *args):
        tracking_id = ''.join(args)
        with self.client.get("/booking/v1/cargos/" + tracking_id + "/request_routes", catch_response=True) as response:
            if response.status_code == 404:
                # We might have a race when we assign routes it's already deleted
                response.success()

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
            picked_route = json.dumps(routes['routes'][route])
            with self.client.post("/booking/v1/cargos/" + tracking_id + "/assign_to_route", data=picked_route, catch_response=True) as postResponse:
                if postResponse.status_code == 404:
                    response.success()

    @task(8)
    def schedule_routing_cargos(self):
        response = self.client.get("/booking/v1/cargos")
        if response.content == "":
            response.failure("No data")
            return
        cargos = json.loads(response.content)
        for cargo in cargos["cargos"]:
            if random.randint(0, 1) == 0:
                continue
            if cargo['routed'] is False:
                self.schedule_task(self.route_cargo, cargo['tracking_id'])
            else:
                self.schedule_task(self.delete_cargo, cargo['tracking_id'])

    @task(10)
    def list_cargos(self):
        self.client.get("/booking/v1/cargos")

    @task(10)
    def list_locations(self):
        self.client.get("/booking/v1/locations")

class LoggedInUser(HttpLocust):
    task_set = StaticTasks
