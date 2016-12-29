from locust import HttpLocust, TaskSet, task
import random

class EmployeeTasks(TaskSet):
    @task
    def loadIndex(self):
        employeeId = random.random() * 10
        self.client.get("/employees/" + str(employeeId))

class LoggedInUser(HttpLocust):
    task_set = EmployeeTasks
    min_wait = 0
    max_wait = 0
