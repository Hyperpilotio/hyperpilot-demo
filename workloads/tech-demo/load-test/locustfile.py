from locust import HttpLocust, TaskSet, task

class StaticTasks(TaskSet):
    @task
    def list_cargos(self):
        self.client.get("/booking/v1/cargos")

    @task
    def list_locations(self):
        self.client.get("/booking/v1/locations")

class LoggedInUser(HttpLocust):
    task_set = StaticTasks
    min_wait = 5000
    max_wait = 15000
