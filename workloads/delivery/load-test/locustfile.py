from locust import HttpLocust, TaskSet, task

# curl localhost:8080/booking/v1/cargos

class StaticTasks(TaskSet):
    @task
    def list_cargos(self):
       response = self.client.get("/booking/v1/cargos")
       if response.status_code == 200:
           response.success()
       else:
           response.failure("Got wrong response code {}".format(response.status_code))

class LoggedInUser(HttpLocust):
    task_set = StaticTasks
    min_wait = 0
    max_wait = 0
