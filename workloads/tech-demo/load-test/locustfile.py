import datetime
import json
import random

from locust import HttpLocust, TaskSet, task

LOCATIONS = ["SESTO", "AUMEL", "CNHKG", "JNTKO", "NLRTM", "DEHAM" ]

class StaticTasks(TaskSet):
    def pick_random_location(self):
        return LOCATIONS[random.randint(0, 5)]

    def book_new_cargo(self):
        add_days = random.randint(0, 15)
        deadline = datetime.datetime.utcnow() + datetime.timedelta(days=add_days)
        data = {
            "origin": self.pick_random_location(),
            "destination": self.pick_random_location(),
            "arrival_deadline": deadline.isoformat() + "Z"
        }
        response = self.client.post("/booking/v1/cargos", data=json.dumps(data))
        return json.loads(response.content)["tracking_id"]

    def delete_cargo(self, tracking_id):
        self.client.delete("/booking/v1/cargos/" + tracking_id)

    def route_cargo(self, tracking_id):
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
        picked_route = json.dumps(routes['routes'][route])
        self.client.post("/booking/v1/cargos/" + tracking_id + "/assign_to_route", data=picked_route)

    @task(10)
    def create_route_delete_cargo(self):
        tracking_id = self.book_new_cargo()
        self.route_cargo(tracking_id)
        self.delete_cargo(tracking_id)

    @task(1)
    def list_cargos(self):
        self.client.get("/booking/v1/cargos")

    @task(1)
    def list_locations(self):
        self.client.get("/booking/v1/locations")

class LoggedInUser(HttpLocust):
    task_set = StaticTasks
