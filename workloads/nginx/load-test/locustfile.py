from locust import HttpLocust, TaskSet, task

class StaticTasks(TaskSet):
    @task
    def loadIndex(self):
        self.client.get("/index.html")

class LoggedInUser(HttpLocust):
    task_set = StaticTasks
    min_wait = 0
    max_wait = 0
